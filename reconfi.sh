#!/bin/sh

##
## Настройка системы и необходимого ПО
##
## @link https://github.com/mekras/reconfi
##

# Завершать сценарий при обращении к неустановленной переменной.
set -o nounset
# Выход при ошибках вызываемых команд.
set -o errexit

# TODO Заменить на -v
if [ "${VERBOSE:-}" != "" ]; then
  set -o verbose
fi

# TODO Заменить на -vv
if [ "${DEBUG:-}" != "" ]; then
  set -o xtrace
fi

##
## Коды ошибок
##
#errNoError=0
errCancelledByUser=201
errInvalidUsage=202
errParallelRun=203
errInvalidSystemConfiguration=204
errApiArgumentMissing=240
#errApiInvalidValue=241
errUnknownError=254

# Путь к папке временных файлов.
tmpDir=${TMPDIR:-${TEMP:-${TMP:-/tmp}}}
# Файл блокировки
lockFile="${tmpDir}/reconfi.lock"
# Папка очередей.
queuesDir=""

#systemctl='sudo systemctl --force'
zypper_install='sudo zypper install --auto-agree-with-licenses'
zypper_remove='sudo zypper remove'

# Признак того, что нужен повторный вход.
isReloginNeeded=0
# Признак того, что нужна перезагрузка.
isRebootNeeded=0

####################################################################################################
## Утверждения
## ===========
##
## Эти функции предназначены для использования в файлах конфигурации системы. В будущем возможно
## преобразование файлов в форматах YAML, tree и т. п. в файлы shell, вызывающие эти функции.
##
## Сами функции не выполняют настройку системы, они только добавляют нужные действия в очереди
## (см. queues_*).
##
## Общие параметры
## ---------------
##
## Эти параметры могут быть добавлены к любому утверждению. Применяются только если утверждение
## не выполнено и были внесены изменения в систему.
# - reboot=<recommend/require> — перезагрузка:
#    - recommend — предложить (в конце);
#    - require — потребовать для продолжения.
# - session-restart=<recommend/require> — перезапуск сессии:
#    - recommend — предложить (в конце);
#    - require — потребовать для продолжения.
####################################################################################################

##
# Файл существует.
#
# @param $1 Путь к файлу.
#
assert__file_exists() {
  path="${1:-}"
  [ "${path}" != '' ] || error__fatal "${errApiArgumentMissing}" "[file exists] Не указан путь к файлу."
  shift

  queues__enqueue files "cmd__file_exists \"${path}\"" "$@"
}

##
# Файл не существует.
#
# @param $1 Путь к файлу.
#
assert__file_not_exists() {
  path="${1:-}"
  [ "${path}" != '' ] || error__fatal "${errApiArgumentMissing}" "[file not exists] Не указан путь к файлу."
  shift

  queues__enqueue files "cmd__file_not_exists \"${path}\" \"$*\""
}

##
# Группа включает указанного пользователя.
#
# @param $1 Имя группы.
# @param $2 Имя пользователя.
#
assert__group_contains() {
  groupName="${1:-}"
  [ "${groupName}" != '' ] || error__fatal "${errApiArgumentMissing}" "[group contains] Не указано имя группы."
  shift
  userName="${1:-}"
  [ "${userName}" != '' ] || error__fatal "${errApiArgumentMissing}" "[group contains] Не указано имя пользователя."
  shift

  queues__enqueue groups "cmd__group_contains ${groupName} ${userName}"
}

##
# Параметр в файле .ini установлен.
#
# @param $1 Путь к файлу.
# @param $2 Раздел (используйте точку «.» для корневого раздела).
# @param $2 Ключ.
# @param $3 Значение.
#
assert__ini_set() {
  path="${1:-}"
  [ "${path}" != '' ] || error__fatal "${errApiArgumentMissing}" "[ini set] Не указан путь к файлу."
  shift
  section="${1:-}"
  [ "${section}" != '' ] || error__fatal "${errApiArgumentMissing}" "[ini set] Не указан раздел."
  shift
  key="${1:-}"
  [ "${key}" != '' ] || error__fatal "${errApiArgumentMissing}" "[ini set] Не указан ключ."
  shift
  value="${1:-}"
  [ "${value}" != '' ] || error__fatal "${errApiArgumentMissing}" "[ini set] Не указано значение."
  shift

  # TODO Вынести в cmd_*
  # FIXME section не поддерживается.

  if [ -f "${path}" ]; then
    if grep -E "^${key}=" "${path}" >/dev/null; then
      sudo sed -i "/^${key}=.*/c\\${key}=${value}" "${path}"
    else
      echo "${key}=${value}" | sudo tee -a "${path}"
    fi
  fi
}

##
# [openSUSE] Источник ПО подключён.
#
# @param $1 URL.
# @param $2 Название.
#
assert__opensuse_repo_connected() {
  if [ "${ID}" != "opensuse" ] && [ "${ID}" != "opensuse-leap" ]; then
    return
  fi

  uri="${1:-}"
  [ "${uri}" != '' ] || error__fatal "${errApiArgumentMissing}" "[openSUSE repo] Не указан URI репозитория."
  shift
  name="${1:-}"
  [ "${name}" != '' ] || error__fatal "${errApiArgumentMissing}" "[openSUSE repo] Не указано имя репозитория."
  shift

  queues__enqueue repositories "cmd__opensuse_repo_add \"${uri}\" \"${name}\"" "$@"
}

##
# [openSUSE] Источник ПО не подключён.
#
# @param $1 URL.
#
assert__opensuse_repo_disconnected() {
  if [ "${ID}" != "opensuse" ] && [ "${ID}" != "opensuse-leap" ]; then
    return
  fi

  uri="${1:-}"
  [ "${uri}" != '' ] || error__fatal "${errApiArgumentMissing}" "[openSUSE repo] Не указан URI репозитория."
  shift

  queues__enqueue repositories "cmd__opensuse_repo_remove \"${uri}\"" "$@"
}

##
# Указанные пакеты установлены.
#
# @param $1 Список пакетов.
#
assert__packages_installed() {
  for pkg in "$@"; do
    queues__enqueue install "cmd__package_install ${pkg}"
  done
}

##
# Указанные пакеты отсутствуют.
#
# @param $1 Список пакетов.
#
assert__packages_not_installed() {
  for pkg in "$@"; do
    queues__enqueue remove "cmd__package_remove ${pkg}"
  done
}

####################################################################################################
## API
##
## Функции, которые могут быть вызваны из файла конфигурации системы.
####################################################################################################

##
# Запрашивает у пользователя подтверждение действия.
#
# @param $1 Вопрос, который надо задать пользователю.
# @param $2 Возможные варианты ответов: ynq
#
api__confirm() {
  question="${1}"
  shift
  variants="${1:-ynq}"

  variantYes=0
  variantNo=0
  variantQuit=0

  while true; do
    printf '%s (' "${question}"
    case "${variants}" in
      *y*)
        printf 'y — да; '
        variantYes=1
        ;;
    esac
    case "${variants}" in
      *n*)
        printf 'n — нет; '
        variantNo=1
        ;;
    esac
    case "${variants}" in
      *q*)
        printf 'q — выход; '
        variantQuit=1
        ;;
    esac
    printf "\b\b): "
    read -r answer
    case ${answer} in
      '')
        return 0
        ;;
      [YyДд]*)
        if [ "${variantYes}" -eq 1 ]; then
          return 0
        fi
        ;;
      [NnНн]*)
        if [ "${variantNo}" -eq 1 ]; then
          return 1
        fi
        ;;
      *)
        if [ "${variantQuit}" -eq 1 ]; then
          echo 'Сценарий прерван пользователем.'
          exit "${errCancelledByUser}"
        fi
        ;;
    esac
    echo 'Недопустимый ответ. Попробуйте ещё раз.'
  done
}

##
# Обрабатывает общие параметры.
#
api__process_common_parameters() {
  for param in "$@"; do
    case $param in
      'reboot=recommend')
        api__reboot_recommend
        ;;
      'reboot=require')
        api__reboot_require
        ;;
      'session-restart=recommend')
        api__session_exit_recommend
        ;;
      'session-restart=require')
        api__session_exit_require
        ;;
    esac
  done
}

##
# Перезагрузить систему.
#
api__reboot() {
  sudo reboot
}

##
# Рекомендуется перезагрузка.
#
api__reboot_recommend() {
  isRebootNeeded=1
}

##
# Необходима перезагрузка.
#
api__reboot_force() {
  # TODO Надо записывать признак куда-то в файл, чтобы даже при перезапуске reconfi выдавался
  #      запрос на перезагрузку.
  echo
  echo 'Для продолжения необходимо перезагрузить систему.'
  echo
  if api__confirm 'Перезагрузить?' yq; then
    api__reboot
  fi
}

##
# Завершение сеанса.
#
api__session_exit() {
  # TODO Добавить поддержку других сред.
  qdbus org.kde.ksmserver /KSMServer logout 0 0 0 2>/dev/null || qdbus-qt5 org.kde.ksmserver /KSMServer logout 0 0 0
}

##
# Рекомендуется завершение сеанса.
#
api__session_exit_recommend() {
  isReloginNeeded=1
}

##
# Необходимо завершение сеанса.
#
api__session_exit_require() {
  # TODO Надо записывать признак куда-то в файл, чтобы даже при перезапуске reconfi выдавался
  #      запрос на завершение.
  echo
  echo 'Для продолжения необходимо завершить сеанс текущего пользователя.'
  echo
  if api__confirm 'Завершить?' yq; then
    api__session_exit
  fi
}

####################################################################################################
## Команды
##
## Эти функции предназначены для постановки их в очереди из функций api_* для последующего пакетного
## выполнения. Именно эти функции должны вносить изменения в систему.
####################################################################################################

##
# Создаёт файл.
#
# @param $1 Путь к файлу.
#
cmd__file_exists() {
  path="${1}"
  shift

  if [ -f "${path}" ]; then
    print__ok "Файл ${path} существует."
    return
  fi

  print__check_failed "Файл ${path} существует."
  api__confirm 'Создать?' || return

  if echo "${path}" | grep -E "^${HOME}" >/dev/null; then
    touch "${path}"
  else
    sudo touch "${path}"
  fi
  api__process_common_parameters "$@"
}

##
# Удаляет файл.
#
# @param $1 Путь к файлу.
#
cmd__file_not_exists() {
  path="${1}"
  shift

  if [ ! -f "${path}" ]; then
    print__ok "Файл ${path} не существует."
    return
  fi

  print__check_failed "Файл ${path} существует."
  api__confirm 'Удалить?' || return

  sudo unlink "${path}"

  api__process_common_parameters "$@"
}

cmd__group_contains() {
  groupName="${1}"
  shift
  userName="${1}"
  shift
  if id -nG "${userName}" | grep "${groupName}" >/dev/null; then
    print__ok "Пользователь ${userName} входит в группу ${groupName}."
  else
    print__check_failed "Пользователь ${userName} не входит в группу ${groupName}."
    api__confirm 'Добавить?'
    su -c "usermod --append --groups=${groupName} ${userName}"
    print_fixed
    api__session_exit_recommend
    api__process_common_parameters "$@"
  fi
}

##
# [openSUSE] Источник ПО подключён.
#
# @param $1 URL.
# @param $2 Название.
#
cmd__opensuse_repo_add() {
  uri="${1}"
  shift
  name="${1}"
  shift

  if sudo zypper repos "${uri}" >/dev/null 2>/dev/null; then
    print__ok "Репозиторий \"${uri}\" подключён."
  else
    print__check_failed "Репозиторий \"${uri}\" не подключён."
    if api__confirm 'Подключить?'; then
      #sudo zypper removerepo "${name}"
      sudo zypper addrepo --name "${name}" --refresh "${uri}" "${name}"
      sudo zypper --gpg-auto-import-keys refresh
      api__process_common_parameters "$@"
    fi
  fi
}

##
# [openSUSE] Источник ПО не подключён.
#
# @param $1 URL.
#
cmd__opensuse_repo_remove() {
  uri="${1}"
  shift

  if ! sudo zypper repos "${uri}" >/dev/null 2>/dev/null; then
    print__ok "Репозиторий \"${uri}\" не подключён."
    return
  fi

  print__check_failed "Репозиторий \"${uri}\" подключён."
  if api__confirm 'Удалить?'; then
    sudo zypper removerepo "${uri}"
    api__process_common_parameters "$@"
  fi
}

##
# Устанавливает пакет, если он не установлен.
#
# @param $1 Имя пакета.
#
# Изменить поведение можно с помощью «рецептов» — функций с определённым именем:
# - recipe__$1_installed — проверяет, установлен ли пакет (код возврата 0 — установлен);
# - recipe__$1_before_install — вызывается перед установкой;
# - recipe__$1_install — устанавливает пакет;
# - recipe__$1_after_install — вызывается после установки.
# - recipe__$1_configure — настраивает пакет, вызывается всегда;
cmd__package_install() {
  pkg="${1}"
  shift

  if is_package_installed "${pkg}"; then
    print__ok "${pkg} установлен."
    recipe__run "${pkg}" configure || true
    return
  fi

  print__check_failed "${pkg} не установлен."
  if ! api__confirm 'Установить?'; then
    return
  fi

  recipe__run "${pkg}" before_install || true

  if ! recipe__run "${pkg}" install; then
    ${zypper_install} "${pkg}"
  fi

  recipe__run "${pkg}" after_install || true

  api__process_common_parameters "$@"
}

cmd__package_remove() {
  pkg="${1}"
  shift

  if is_package_installed "${pkg}"; then
    print__check_failed "Установлен лишний пакет ${pkg}"
    if api__confirm 'Удалить?'; then
      ${zypper_remove} "${pkg}"
      api__process_common_parameters "$@"
    fi
  else
    print__ok "${pkg} отсутствует."
  fi
}

#function apply_patch
#{
#    patchFile=${SCRIPT_DIR}/${1}
#    message=${2}
#
#    api__confirm "Применить патч ${1}?"
#    print_check "${message}"
#    if cd / && sudo patch --ignore-whitespace --forward --reject-file=- --batch --strip=1 < ${patchFile} >/dev/null; then
#        print_fixed
#    else
#        print_checked
#    fi
#}

##
# Выполняет рецепт.
#
# @param $1 Имя субъекта (например, пакета) рецепта.
# @param $2 Вариант рецепта (installed, before_install…).
recipe__run() {
  subject="${1}"
  type="${2}"
  recipe="recipe__$(echo "${subject}" | tr '-' '_')_${type}"

  if type "${recipe}" 1>/dev/null 2>/dev/null; then
    $recipe
  else
    false
  fi
}

##
# Выводит сообщение о фатальной ошибке и прекращает выполнение сценария.
#
# @param $1 Код завершения.
# @param $2 Сообщение об ошибке.
#
error__fatal() {
  echo "${2:-Неизвестная ошибка}"
  exit "${1:-${errUnknownError}}"
}

##
# Функция, выполняется при завершении сценария из-за ошибки.
#
handler__onError() {
  echo 'Выполнение сценария прервано из-за ошибки.'
  queues__cleanup
  lock__removeLock
}

##
# Функция, вызываемая при нормальном завершении сценария.
#
handler__onExit() {
  queues__cleanup
  lock__removeLock
}

##
# Устанавливает блокировку параллельного запуска.
#
lock__setLock() {
  echo $$ >"${lockFile}"
}

##
# Снимает блокировку параллельного запуска.
#
lock__removeLock() {
  unlink "${lockFile}"
}

##
# Проверяет отсутствие блокировки.
#
lock__ensureNoLock() {
  if [ -f "${lockFile}" ]; then
    pid=$(cat "${lockFile}")
    if kill -0 "${pid}" 2>/dev/null; then
      echo "Другая копия сценария уже выполняется с PID ${pid}."
      exit $errParallelRun
    fi
    echo 'Обнаружен устаревший файл блокировки. Удаляю…'
    lock__removeLock
  fi
}

#function enable_services
#{
#    for service in "$@"; do
#        print_check "Служба ${service} включена"
#        if ${systemctl} is-enabled ${service} >/dev/null; then
#            print_checked
#        else
#            print_check_failed
#            api__confirm 'Включить?'
#            ${systemctl} enable ${service}
#            print_fixed
#        fi
#
#        print_check "Служба ${service} запущена"
#        if ${systemctl} is-active ${service} >/dev/null; then
#            print_checked
#        else
#            print_check_failed
#            api__confirm 'Запустить?'
#            ${systemctl} start ${service}
#        fi
#    done
#}

is_package_installed() {
  pkg="${1:-}"
  if ! recipe__run "${pkg}" installed; then
    rpm -q --whatprovides "${pkg}" >/dev/null
  fi
}

#function install_file
#{
#    filename=${1}
#    check=${2}
#
#    print_check "${check}"
#    if sudo stat /${filename} >/dev/null; then
#        print_checked
#    else
#        print_check_failed
#        api__confirm "Установить файл ${filename}?"
#        sudo cp ${SCRIPT_DIR}/${filename} /${filename}
#    fi
#}
#
#function install_npm_packages
#{
#    for pkg in "$@"; do
#        print_check "NPM: ${pkg} установлен"
#        if sudo npm -g list ${pkg} >/dev/null; then
#            print_checked
#        else
#            print_check_failed
#            api__confirm 'Установить?'
#            sudo npm -g install ${pkg}
#        fi
#    done
#}

##
# Очищает папку очередей.
#
queues__cleanup() {
  if [ "${queuesDir}" != "" ]; then
    rm -rf "${queuesDir}"
  fi
}

##
# Добавляет команду в очередь.
#
# @param $1 Имя очереди.
# @param $2 Команда.
#
queues__enqueue() {
  queue="${1}"
  command="${2}"

  echo "${command}" >>"${queuesDir}/${queue}"
}

##
# Выполняет очередь.
#
# @param $1 Имя очереди.
#
queues__run() {
  queue="${queuesDir}/${1}"

  if [ -f "${queue}" ]; then
    # shellcheck disable=SC1090
    . "${queue}"
  fi
}

##
# Выводит описание проверки.
#
# @param $1 Описание проверки.
#
print_check() {
  printf '→ %s: ' "${1}"
}

##
# Выводит сообщение о провалившейся проверке.
#
print__check_failed() {
  echo " ❌ ${1}"
}

##
# Выводит сообщение об успешной проверке.
#
# @param $1 Описание.
#
print__ok() {
  echo " ✔ ${1}"
}

##
# Выводит сообщение о том, что проблема исправлена.
#
print_fixed() {
  echo "✔ Исправлено."
}

####################################################################################################
# Рецепты
####################################################################################################

recipe__snapd_after_install() {
  api__session_exit_recommend
  sudo systemctl enable snapd.apparmor.service
  sudo systemctl enable snapd
  sudo systemctl start snapd
}

####################################################################################################

confFile="${1:-}"
if [ "${confFile}" = '' ]; then
  echo 'Не указан путь к файлу конфигурации системы.'
  exit "${errInvalidUsage}"
fi

if [ ! -f "${confFile}" ]; then
  echo "Файл \"${confFile}\" не найден."
  exit "${errInvalidUsage}"
fi

trap handler__onError HUP INT QUIT ABRT TERM
trap handler__onExit 0

lock__ensureNoLock
lock__setLock

# TODO Надо проверять поддержку русской локали, при необходимости устанавливать.
# TODO Надо проверять наличие оболочки типа Bash, с поддержкой цветов и переключаться на неё.

echo
echo "——————————————————————————————————————————"
echo "reconfi — установка ПО и настройка системы"
echo "——————————————————————————————————————————"
echo

api__confirm 'Начать проверку и настройку системы?'

# shellcheck disable=SC1091
. /etc/os-release

queuesDir="$(mktemp --tmpdir -d RCFI.XXXX)"

# shellcheck disable=SC1090
. "${confFile}"

#print_check 'Группа wheel может выполнять sudo со своим паролем'
#if /bin/true; then
#    print_checked
#else
##ifneq (,$(realpath /usr/sudoers.orig))
##	su -c "$(patch) /etc/sudoers patch/sudoers.patch"
##	su -c reboot
##endif
#    isReloginNeeded=1
#fi

#print_check 'Имя хоста совпадает с именем главного пользователя'
#if [ "$(hostname)" == "${USER}" ]; then
#    print_checked
#else
#    print_check_failed
#    api__confirm 'Изменить имя хоста?'
#    sudo hostnamectl set-hostname ${USER}
#    print_fixed
#    isRebootNeeded=1
#fi

#print_check "Хост $(hostname) вписан в /etc/hosts"
#if grep "$(hostname)" /etc/hosts >/dev/null; then
#    print_checked
#else
#    print_check_failed
#    api__confirm 'Вписать?'
#    echo -e "\n127.0.0.1\t$(hostname)" | sudo tee --append /etc/hosts >/dev/null
#    print_fixed
#fi

echo 'Для настройки системы нужны права суперпользователя.'
if [ "$(sudo whoami)" = "root" ]; then
  echo "Права получены."
else
  echo "Не удалось получить права суперпользователя."
  exit "${errInvalidSystemConfiguration}"
fi

queues__run groups
queues__run repositories
queues__run remove
queues__run install
queues__run files

if [ ${isRebootNeeded} -eq 1 ]; then
  echo
  echo 'Для применения сделанных изменений надо перезагрузить систему.'
  echo
  if api__confirm 'Перезагрузить?' yn; then
    api__reboot
  fi
fi

if [ ${isReloginNeeded} -eq 1 ]; then
  echo
  echo 'Для применения сделанных изменений надо заново войти в систему.'
  echo
  if api__confirm 'Завершить сеанс?' yn; then
    api__session_exit
  fi
fi

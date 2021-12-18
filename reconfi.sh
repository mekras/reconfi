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

##
# API: Группа включает в себя указанного пользователя.
#
# @param $1 Имя группы.
# @param $2 Имя пользователя.
#
api__group_contains() {
  groupName="${1:-}"
  [ "${groupName}" != '' ] || error__fatal "${errApiArgumentMissing}" "[group contains] Не указано имя группы."
  userName="${2:-}"
  [ "${userName}" != '' ] || error__fatal "${errApiArgumentMissing}" "[group contains] Не указано имя пользователя."

  queues__enqueue groups "cmd__group_contains ${groupName} ${userName}"
}

##
# API: [openSUSE] Источник ПО должен быть подключён.
#
# @param $1 URL.
# @param $2 Название.
#
api__opensuse_repo() {
  if [ "${ID}" != "opensuse" ] && [ "${ID}" != "opensuse-leap" ]; then
    return
  fi

  uri="${1:-}"
  [ "${uri}" != '' ] || error__fatal "${errApiArgumentMissing}" "[openSUSE repo] Не указан URI репозитория."
  name="${1:-}"
  [ "${name}" != '' ] || error__fatal "${errApiArgumentMissing}" "[openSUSE repo] Не указано имя репозитория."

  queues__enqueue repositories "cmd__opensuse_repo \"${uri}\" \"${name}\""
}

##
# API: Указанные пакеты должны быть установлены.
#
# @param $1 Список пакетов.
#
api__packages_install() {
  for pkg in "$@"; do
    queues__enqueue install "cmd__package_install ${pkg}"
  done
}

api__packages_remove() {
  for pkg in "$@"; do
    queues__enqueue remove "cmd__package_remove ${pkg}"
  done
}

##
# Запросить завершение сеанса.
#
api__session_request_restart() {
  isReloginNeeded=1
}

##
# Действия с текущей сессией.
#
session__check_for_actions() {
  if [ ${isReloginNeeded} -eq 1 ]; then
    echo
    echo 'Для применения сделанных изменений надо заново войти в систему.'
    echo
    if confirm 'Завершить сеанс?'; then
      # TODO Добавить поддержку других сред.
      qdbus org.kde.ksmserver /KSMServer logout 0 0 0 2>/dev/null || qdbus-qt5 org.kde.ksmserver /KSMServer logout 0 0 0
    fi
  fi
}

api__ini_set() {
  path="${1}"
  key=$2
  value="${3}"

  if [ -f "$path" ]; then
    if grep -E "^${key}=" "${path}" >/dev/null; then
      sudo sed -i "/^${key}=.*/c\\${key}=${value}" "${path}"
    else
      echo "${key}=${value}" | sudo tee -a "${path}"
    fi
  fi
}

##
# API: Установить значение переменной окружения.
#
# @param $1 Имя переменной.
# @param $2 Значение переменной.
#
api__variables() {
  name="${1:-}"
  [ "${name}" != '' ] || error__fatal "${errApiArgumentMissing}" "[variables] Не указано имя переменной."
  value="${2:-}"
  [ "${value}" != '' ] || error__fatal "${errApiArgumentMissing}" "[variables] Не указано значение для ${name}."
  export "${name}=${value}"
}

cmd__group_contains() {
  groupName=$1
  userName=$2
  if id -nG "${userName}" | grep "${groupName}" >/dev/null; then
    print__ok "Пользователь ${userName} входит в группу ${groupName}."
  else
    print_check_failed
    confirm 'Добавить пользователя в группу?'
    su -c "usermod --append --groups=${groupName} ${userName}"
    print_fixed
    api__session_request_restart
  fi
}

cmd__opensuse_repo() {
  uri=$1
  name=$2

  if sudo zypper repos "${uri}" >/dev/null 2>/dev/null; then
    print__ok "Репозиторий \"${uri}\" подключён."
  else
    print__check_failed "Репозиторий \"${uri}\" не подключён."
    if confirm 'Подключить?'; then
      #sudo zypper removerepo "${name}"
      sudo zypper addrepo --name="${name}" --refresh "${uri}" "${name}"
      sudo zypper --gpg-auto-import-keys refresh
    fi
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

  if is_package_installed "${pkg}"; then
    print__ok "${pkg} установлен."
    recipe__run "${pkg}" configure || true
    return
  fi

  print__check_failed "${pkg} не установлен."
  if ! confirm 'Установить?'; then
    return
  fi

  recipe__run "${pkg}" before_install || true

  if ! recipe__run "${pkg}" install; then
    ${zypper_install} "${pkg}"
  fi

  recipe__run "${pkg}" after_install || true
}

cmd__package_remove() {
  pkg="${1}"
  if is_package_installed "${pkg}"; then
    print__check_failed "Установлен лишний пакет ${pkg}"
    if confirm 'Удалить?'; then
      ${zypper_remove} "${pkg}"
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
#    confirm "Применить патч ${1}?"
#    print_check "${message}"
#    if cd / && sudo patch --ignore-whitespace --forward --reject-file=- --batch --strip=1 < ${patchFile} >/dev/null; then
#        print_fixed
#    else
#        print_checked
#    fi
#}

checkNeededActions() {
  if [ ${isRebootNeeded} -eq 1 ]; then
    echo
    printf "Для применения сделанных изменений надо перезагрузить систему."
    echo
    printf "Нажмите Enter для перезагрузки."
    read -r
    sudo reboot
  fi
}

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
# Запрашивает у пользователя подтверждение действия.
#
# @param $1 Вопрос, который надо задать пользователю.
#
confirm() {
  question="${1}"
  shift

  printf "%s [Y/n/q]: " "${question}"
  read -r answer
  case ${answer} in
    '') ;;
    [YyДд]*) ;;
    [NnНн]*)
      return 1
      ;;
    *)
      echo 'Сценарий прерван пользователем.'
      exit "${errCancelledByUser}"
      ;;
  esac
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
#            confirm 'Включить?'
#            ${systemctl} enable ${service}
#            print_fixed
#        fi
#
#        print_check "Служба ${service} запущена"
#        if ${systemctl} is-active ${service} >/dev/null; then
#            print_checked
#        else
#            print_check_failed
#            confirm 'Запустить?'
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
#        confirm "Установить файл ${filename}?"
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
#            confirm 'Установить?'
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
  api__session_request_restart
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

confirm 'Начать проверку и настройку системы?'

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
#    confirm 'Изменить имя хоста?'
#    sudo hostnamectl set-hostname ${USER}
#    print_fixed
#    isRebootNeeded=1
#fi

#print_check "Хост $(hostname) вписан в /etc/hosts"
#if grep "$(hostname)" /etc/hosts >/dev/null; then
#    print_checked
#else
#    print_check_failed
#    confirm 'Вписать?'
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
session__check_for_actions

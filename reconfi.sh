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

##
# Коды ошибок
#
#errNoError=0
errCancelledByUser=201
errInvalidUsage=202
errParallelRun=203
errInvalidSystemConfiguration=204
errApiArgumentMissing=240
errApiInvalidValue=241
errUnknownError=254

# Путь к папке временных файлов.
tmpDir=${TMPDIR:-${TEMP:-${TMP:-/tmp}}}
# Файл блокировки
lockFile="${tmpDir}/reconfi.lock"

#SCRIPT_DIR=$(realpath $(dirname ${0}))
#
#systemctl='sudo systemctl --force'
zypper_install='sudo zypper install --auto-agree-with-licenses --no-confirm'
#zypper_remove='sudo zypper remove --no-confirm'

# Признак того, что нужен повторный вход.
isReloginNeeded=0
# Признак того, что нужна перезагрузка.
isRebootNeeded=0

##
# API: Проверяет работу sudo.
#
api__check_sudo() {
  echo 'Проверяем правильность настройки sudo'
  if [ "$(sudo whoami)" = "root" ]; then
    echo "Порядок, можно продолжать."
  else
    echo "sudo настройка неправильно, дальнейшая работа невозможна."
    exit "${errInvalidSystemConfiguration}"
  fi
}

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

  print_check "В группу ${groupName} входит пользователь ${userName}"
  if id -nG "${userName}" | grep "${groupName}" >/dev/null; then
    print_checked
  else
    print_check_failed
    confirm 'Добавить пользователя в группу?'
    su -c "usermod --append --groups=${groupName} ${userName}"
    print_fixed
    isReloginNeeded=1
  fi
}

##
# API: [openSUSE] Источник ПО должен быть подключён.
#
# @param $1 URL.
# @param $2 Название.
#
api__opensuse_repo() {
  uri="${1:-}"
  [ "${uri}" != '' ] || error__fatal "${errApiArgumentMissing}" "[openSUSE repo] Не указан URI репозитория."
  name="${1:-}"
  [ "${name}" != '' ] || error__fatal "${errApiArgumentMissing}" "[openSUSE repo] Не указано имя репозитория."

  print_check "Репозиторий \"${uri}\" подключён"
  if sudo zypper repos "${uri}" >/dev/null 2>/dev/null; then
    print_checked
  else
    print_check_failed
    confirm 'Подключить?'
    sudo zypper removerepo "${name}"
    sudo zypper addrepo --name="${name}" --refresh "${uri}" "${name}"
    sudo zypper --gpg-auto-import-keys refresh
  fi
}

##
# API: Указанные пакеты должны быть установлены.
#
# @param $1 Список пакетов.
#
api__packages() {
  for pkg in "$@"; do
    print_check "${pkg} установлен"
    if is_package_installed "${pkg}"; then
      print_checked
    else
      print_check_failed
      confirm 'Установить?'
      ${zypper_install} "${pkg}"
    fi
  done
}
##
# API: Действия с текущей сессией.
#
# @param $1 Действие.
#
api__session() {
  action="${1:-}"
  [ "${action}" != '' ] || error__fatal "${errApiArgumentMissing}" "[session] Не указано действие."

  case "${action}" in
    'restart-if-needed')
      if [ ${isReloginNeeded} -eq 1 ]; then
        echo
        echo "Для применения сделанных изменений надо заново войти в систему."
        echo
        echo "Нажмите Enter для выхода."
        read -r
        # TODO Добавить поддержку других сред.
        qdbus org.kde.ksmserver /KSMServer logout 0 0 0
      fi
      ;;

    *)
      error__fatal "${errApiInvalidValue}" "[session] Неизвестная команда ${action}."
      ;;
  esac
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
# Запрашивает у пользователя подтверждение действия.
#
# @param $1 Вопрос, который надо задать пользователю.
#
confirm() {
  question="${1}"
  shift

  printf "%s [Y/n]: " "${question}"
  read -r answer
  case ${answer} in
    '') ;;
    [YyДд]*) ;;
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
  lock__removeLock
}

##
# Функция, вызываемая при нормальном завершении сценария.
#
handler__onExit() {
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
  rpm -q --whatprovides "${1:-}" >/dev/null
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
print_check_failed() {
  echo "❌ нет"
}

##
# Выводит сообщение об успешной проверке.
#
print_checked() {
  echo "✔ да"
}

##
# Выводит сообщение о том, что проблема исправлена.
#
print_fixed() {
  echo "✔ Исправлено."
}

#function print_note
#{
#    echo
#    echo "(i) ${1}"
#    echo
#}
#
#function remove_packages
#{
#    for pkg in "$@"; do
#        print_check "${pkg} отсутствует"
#        if is_package_installed ${pkg}; then
#            print_check_failed
#            confirm 'Удалить?'
#            ${zypper_remove} ${pkg}
#        else
#            print_checked
#        fi
#    done
#}

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

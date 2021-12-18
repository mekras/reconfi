api__group_contains wheel "$USER"

api__opensuse_repo "http://download.nvidia.com/opensuse/leap/$VERSION/" "nvidia"

api__packages_remove \
  akregator \
  arphic-bsmi00lp-fonts \
  arphic-fonts \
  arphic-gbsn00lp-fonts \
  baekmuk-ttf-fonts \
  dragonplayer \
  git-gui \
  gitk \
  indic-fonts \
  ipa-gothic-fonts \
  ipa-pgothic-fonts \
  ipa-pmincho-fonts \
  jomolhari-fonts \
  kamoso \
  khmeros-fonts \
  lklug-fonts \
  pothana2000-fonts \
  sil-padauk-fonts

##
## Основная система
##
api__opensuse_repo "http://download.opensuse.org/distribution/leap/$VERSION/repo/oss/" "Основной репозиторий"
api__opensuse_repo "http://download.opensuse.org/update/leap/$VERSION/oss" "Основной репозиторий обновлений"
api__opensuse_repo "http://download.opensuse.org/debug/distribution/leap/$VERSION/repo/oss" "Debug Repository"
api__opensuse_repo "http://download.opensuse.org/debug/update/leap/$VERSION/oss/" "Update Repository (Debug)"
api__opensuse_repo "http://download.opensuse.org/source/distribution/leap/$VERSION/repo/oss/" "Source Repository"

api__opensuse_repo "http://download.opensuse.org/distribution/leap/$VERSION/repo/non-oss/" "Репозиторий Non-OSS"
api__opensuse_repo "http://download.opensuse.org/update/leap/$VERSION/non-oss/" "Репозиторий обновлений (Non-Oss)"
api__opensuse_repo "http://download.opensuse.org/debug/distribution/leap/$VERSION/repo/non-oss/" "Debug Repository (Non-OSS)"
api__opensuse_repo "http://download.opensuse.org/debug/update/leap/$VERSION/non-oss/" "Update Repository (Debug, Non-OSS)"
api__opensuse_repo "http://download.opensuse.org/source/distribution/leap/$VERSION/repo/non-oss/" "Source Repository (Non-OSS)"

api__opensuse_repo "https://download.opensuse.org/repositories/system:/snappy/openSUSE_Leap_$VERSION" "snappy"
api__opensuse_repo "https://download.opensuse.org/repositories/filesystems/openSUSE_Leap_$VERSION/" "filesystems"

api__opensuse_repo "http://download.opensuse.org/repositories/mozilla/openSUSE_Leap_$VERSION/" "mozilla"
api__opensuse_repo "https://linux.teamviewer.com/yum/stable/main/binary-x86_64/" "TeamViewer"

api__opensuse_repo "https://download.opensuse.org/repositories/devel:/languages:/php/openSUSE_Leap_$VERSION/" "devel:languages:php"

api__opensuse_repo "https://download.opensuse.org/repositories/home:/Sauerland:/hardware/openSUSE_Leap_$VERSION/" "home:Sauerland:hardware"

api__packages_install \
  git \
  etckeeper \
  cmake \
  curl \
  davfs2 \
  drweb \
  ffmpeg \
  filelight \
  fish \
  fuse \
  gcc \
  gcc-c++ \
  gimp \
  gimp-save-for-web \
  gstreamer-plugins-bad \
  gstreamer-plugins-libav \
  gstreamer-plugins-ugly \
  gstreamer-plugins-ugly-orig-addon \
  htop \
  icoutils \
  inkscape \
  iotop \
  kcachegrind \
  kolourpaint \
  kwrite \
  lame \
  libdvdcss2 \
  libqt5-qdbus \
  libreoffice \
  libreoffice-kde4 \
  mlocate \
  mc \
  mp3gain \
  nmap \
  noto-coloremoji-fonts \
  noto-emoji-fonts \
  okteta \
  pam_kwallet \
  PlayOnLinux \
  poedit \
  pwgen \
  python-mutagen \
  signon-kwallet-extension \
  snapd \
  unar \
  unrar \
  unzip \
  virtualbox \
  vlc \
  vlc-codecs \
  wget \
  whois \
  wine \
  wireshark \
  zip

# Настройка клавиатуры.
api__ini_set "$HOME/.config/kxkbrc" DisplayNames '\xd0\x90\xd0\x9d\xd0\x93,\xd0\xa0\xd0\xa3\xd0\xa1'
api__ini_set "$HOME/.config/kxkbrc" Options 'terminate:ctrl_alt_bksp,lv3:ralt_switch,misc:typo,grp:caps_toggle'
api__ini_set "$HOME/.config/kxkbrc" Model pc101
api__ini_set "$HOME/.config/kxkbrc" ResetOldOptions true

api__ini_set "$HOME/.config/kglobalshortcutsrc" '{24bfa1fc-6c9f-4ed3-ba8b-b49386aa962e}' 'Alt+`,none,Launch Konsole'
api__ini_set "$HOME/.config/kglobalshortcutsrc" 'Lock Session' 'Meta+L\\t\\tScreensaver,Meta+L\\tCtrl+Alt+L\\tScreensaver,Заблокировать сеанс'
api__ini_set "$HOME/.config/kglobalshortcutsrc" 'Walk Through Windows of Current Application' ',,На одно окно вперёд текущего приложения'

##
## Утилиты
##
api__opensuse_repo "https://mega.nz/linux/MEGAsync/openSUSE_Leap_$VERSION/" "MEGAsync"
api__opensuse_repo "http://repo.yandex.ru/yandex-disk/rpm/stable/x86_64/" "yandex-disk"
api__packages_install \
  megasync \
  yandex-disk

##
## Интернет
##
api__packages_install \
  chromium \
  firefox \
  MozillaThunderbird \
  telegram-desktop \
  yandex-browser-beta

##
## Teams
##
api__opensuse_repo "https://packages.microsoft.com/yumrepos/ms-teams" "teams"
api__packages_remove teams-insiders
api__packages_install teams

api__opensuse_repo "https://repo.skype.com/rpm/stable/" "skype"
api__packages_install skypeforlinux

#print_check 'etckeeper включен и настроен'
#if [ -d /etc/.git ]; then
#    print_checked
#else
#    print_check_failed
#    confirm 'Настроить?'
#    sudo git config --global core.editor mcedit
#    sudo git config --global user.name root
#    sudo git config --global user.email "root@$(hostname)"
#    sudo etckeeper init
#    sudo etckeeper commit -m 'Начальное состояние'
#fi

#install_file etc/polkit-1/rules.d/00-local.rules 'Правила PolicyKit установлены'
##sysctl_setting 50-inotify_limits 'Ограничение inotify для PhpStorm увеличено'
#
#print_check 'Ограничение на количество открытых файлов увеличено'
#filename='nofiles.conf'
#if [ "$(ulimit -n)" == "65535" ]; then
#    print_checked
#else
#    print_check_failed
#    confirm 'Увеличить?'
#    sudo cp -f etc/security/limits.d/${filename} /etc/security/limits.d/${filename}
#    print_fixed
#    isRebootNeeded=1
#fi
#
#
#
##print_check 'Ограничение на дампы памяти отсутствует'
##filename='core.conf'
##if [ $(ulimit -c) == "unlimited" ]; then
##    print_checked
##else
##    print_check_failed
##    sudo cp -f etc/security/limits.d/${filename} /etc/security/limits.d/${filename}
##    print_fixed
##    isRebootNeeded=1
##fi
#
##apply_patch patch/grub.verbose-boot.patch 'Подробный вывод во время загрузки'
##apply_patch patch/pam.auto_login.patch 'Автоматическая разблокировка хранилизщ паролей'

#filename=$(realpath /sbin/mount.davfs)
#mode=$(stat --format '%#a' "${filename}")
#print_check 'Обычные пользователи могут монтировать dsvfs'
#if [ "${mode}" = "04755" ]; then
#    print_checked
#else
#    print_check_failed
#    confirm 'Изменить права доступа?'
#    sudo chmod 4755 "${filename}"
#    print_fixed
#fi
#print_check "Пользователь ${USER} входит в группу vboxusers"
#if id -nG "${USER}" | grep vboxusers > /dev/null; then
#    print_checked
#else
#    print_check_failed
#    confirm 'Добавить?'
#    sudo usermod --append --groups=vboxusers "${USER}"
#    print_fixed
#    api__session_request_restart
#fi
#
#checkNeededActions
#
#print_check 'fusermount доступен для обычных пользователей'
#if  [ "$(stat --format=%u:%a /usr/bin/fusermount)" == "0:4755" ]; then
#    print_checked
#else
#    # Для JetBrains Toolbox
#    # https://github.com/AppImage/AppImageKit/wiki/FUSE
#    print_check_failed
#    confirm 'Разрешить?'
#    sudo chmod a+x /usr/bin/fusermount && sudo chown root /usr/bin/fusermount && sudo chmod u+s /usr/bin/fusermount
#fi

#install_npm_packages \
#    standard

##sudo zypper dup --from packman

# Браузер по умолчанию.
# Единый список пакетов с указанием зависимостей.

## Obsidian.md
api__packages_install obsidian

##
## Разработка
##
api__packages_install \
  composer \
  docker \
  docker-compose \
  jetbrains-toolbox \
  jpegoptim \
  npm \
  optipng \
  php8 \
  php8-bcmath \
  php8-bz2 \
  php8-ctype \
  php8-curl \
  php8-devel \
  php8-dom \
  php8-fileinfo \
  php8-ftp \
  php8-gd \
  php8-gettext \
  php8-gmp \
  php8-iconv \
  php8-intl \
  php8-mbstring \
  php8-mysql \
  php8-opcache \
  php8-openssl \
  php8-pcntl \
  php8-pdo \
  php8-pecl \
  php8-phar \
  php8-posix \
  php8-sockets \
  php8-sqlite \
  php8-tokenizer \
  php8-xmlreader \
  php8-xmlwriter \
  php8-zip \
  php8-zlib \
  php-redis \
  ShellCheck

##
## Мультимедиа
##
api__opensuse_repo "http://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Leap_$VERSION/" "Packman Repository"
api__opensuse_repo "http://opensuse-guide.org/repo/openSUSE_Leap_$VERSION/" "dvd"
api__packages_install \
  amarok \
  audacity \
  digikam \
  kdenlive \
  kid3
#    avidemux-qt

##
## Деньги
##
api__packages_install \
  tradingview

##
## Игры
##
api__opensuse_repo "https://download.opensuse.org/repositories/games/openSUSE_Leap_$VERSION/" "games"

api__packages_install \
  steam \
  freeciv-qt

##
## 3D
##
api__packages_install \
  blender

##
## Рецепты
##

recipe__composer_installed() {
  command -v composer >/dev/null
}

recipe__composer_install() {
  wget https://raw.githubusercontent.com/composer/getcomposer.org/76a7060ccb93902cd7576b67264ad91c8a2700e2/web/installer -O - | php
  mv composer.phar "${HOME}/bin/composer"
  "${HOME}/bin/composer" self-update
}

recipe__drweb_installed() {
  [ -d /opt/drweb.com ]
}

recipe__drweb_install() {
  DRWEB_VERSION='11.1'
  DRWEB_VERSION_FULL="$DRWEB_VERSION.3"
  distrib='drweb.run'
  installer="$HOME/Загрузки/$distrib"
  if [ ! -f "$installer" ]; then
    wget -O "$installer" \
      "https://download.geo.drweb.com/pub/drweb/unix/workstation/$DRWEB_VERSION/drweb-$DRWEB_VERSION_FULL-av-linux-amd64.run"
  fi
  chmod a+x "$installer"
  "$installer"
}

recipe__fish_after_install() {
  if ! sudo grep -quiet "$(command -v fish)" /etc/shells; then
    which fish | sudo tee -a /etc/shells >/dev/null
  fi

  if [ "$(getent passwd "${USER}" | cut -d: -f7)" != "$(command -v fish)" ]; then
    sudo usermod -s "$(command -v fish)" "${USER}"
    api__session_request_restart
  fi

  if [ "$(getent passwd root | cut -d: -f7)" != "$(command -v fish)" ]; then
    sudo usermod -s "$(command -v fish)" root
    api__session_request_restart
  fi

  echo "set COMPOSER_MEMORY_LIMIT -1
set UID (id -u)
set EDITOR /usr/bin/mcedit
set PATH \$HOME/bin /usr/local/bin /usr/bin /bin /usr/local/sbin /usr/sbin /sbin
set GOPATH \$HOME/workspace/go
set GOBIN \$GOPATH/bin
" >"$HOME/.config/fish/config.fish"
}

recipe__git_after_install() {
  sudo git config --global init.defaultBranch master
  sudo git config --global user.name "root"
  sudo git config --global user.email root@localhost

  git config --global init.defaultBranch master
  git config --global user.name "Михаил Красильников"
  git config --global user.email m.krasilnikov@yandex.ru

}

recipe__jetbrains_toolbox_installed() {
  [ -f "$HOME/opt/jetbrains-toolbox/jetbrains-toolbox" ]
}

recipe__jetbrains_toolbox_install() {
  distrib="jetbrains-toolbox-1.19.7784"
  archive="$distrib.tar.gz"
  binary="jetbrains-toolbox"
  target="$HOME/opt/jetbrains-toolbox/$binary"
  if [ ! -f "$HOME/Загрузки/$archive" ]; then
    wget -O "$HOME/Загрузки/$archive" "https://download.jetbrains.com/toolbox/$archive"
  fi
  cd "$HOME/Загрузки"
  if [ ! -f "$distrib/$binary" ]; then
    tar -xf "$archive"
  fi
  if [ ! -d "$(dirname $target)" ]; then
    mkdir -p "$(dirname $target)"
  fi
  mv "$HOME/Загрузки/$distrib/$binary" "$target"

  if [ -d "$HOME/Загрузки/$distrib" ]; then
    rm -r "$HOME/Загрузки/$distrib"
  fi
  if [ -f "$HOME/Загрузки/$archive" ]; then
    rm "$HOME/Загрузки/$archive"
  fi
}

recipe__mc_after_install() {
  ini="$HOME/.config/mc/ini"
  sed -i '/confirm_exit=false/c\confirm_exit=true' "$ini"
  sed -i '/wrap_mode=true/c\wrap_mode=false' "$ini"
  sed -i '/editor_fill_tabs_with_spaces=false/c\editor_fill_tabs_with_spaces=true' "$ini"
  sed -i '/editor_tab_spacing=8/c\editor_tab_spacing=4' "$ini"
  sed -i '/editor_fake_half_tabs=true/c\editor_fake_half_tabs=false' "$ini"
  sed -i '/skin=default/c\skin=modarin256-defbg' "$ini"

  ini="/root/.config/mc/ini"
  if [ -f "$ini" ]; then
    sudo sed -i '/confirm_exit=false/c\confirm_exit=true' "$ini"
    sudo sed -i '/wrap_mode=true/c\wrap_mode=false' "$ini"
    sudo sed -i '/editor_fill_tabs_with_spaces=false/c\editor_fill_tabs_with_spaces=true' "$ini"
    sudo sed -i '/editor_tab_spacing=8/c\editor_tab_spacing=4' "$ini"
    sudo sed -i '/editor_fake_half_tabs=true/c\editor_fake_half_tabs=false' "$ini"
    sudo sed -i '/skin=default/c\skin=modarcon16root-defbg' "$ini"
  fi
}

recipe__obsidian_installed() {
  [ -f "$HOME/opt/Obsidian/Obsidian" ]
}

recipe__obsidian_install() {
  appDir="$HOME/opt/Obsidian"
  appBin="$appDir/Obsidian"
  if [ -d "$appDir" ]; then
    mkdir -p "$appDir"
  fi

  if [ ! -f "$appDir/logo.png" ]; then
    print__check_failed "Нет логотипа Obsidian."
    if confirm 'Скачать?'; then
      wget -O "$appDir/logo.png" https://newreleases.io/icon/github/obsidianmd
    fi
  fi

  desktopFile="$HOME/.local/share/applications/obsidian.desktop"
  touch "$desktopFile"
  desktop-file-install \
    --dir="$(dirname $desktopFile)" \
    --set-name="Obsidian" \
    --set-key=Type --set-value=Application \
    --set-key=Comment --set-value="Программа для управления заметками" \
    --set-key=Exec --set-value="$appBin" \
    --set-key=Icon --set-value="$appDir/logo.png" \
    --set-key=Categories --set-value=Office \
    --remove-key=Path \
    "$desktopFile"
}

recipe__tradingview_installed() {
  snap info tradingview | grep installed >/dev/null
}

recipe__tradingview_install() {
  sudo snap install tradingview
}

recipe__wireshark_after_install() {
  sudo usermod -a -G wireshark "$USER"
  api__session_request_restart
}

recipe__yandex_browser_beta_install() {
  rpm="$HOME/Загрузки/Yandex.rpm"
  if [ ! -f "$rpm" ]; then
    wget -O "$rpm" 'https://browser.yandex.ru/download/?zih=1&beta=1&os=linux&x64=1&package=rpm&full=1'
  fi
  sudo zypper install "$rpm"
  rm "$rpm"
}

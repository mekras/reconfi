api__variables OS_VERSION 15.2

api__group_contains wheel "${USER}"
api__session restart-if-needed

api__check_sudo

api__opensuse_repo "http://download.opensuse.org/distribution/leap/${OS_VERSION}/repo/oss/" "Основной репозиторий"
api__opensuse_repo "http://download.opensuse.org/update/leap/${OS_VERSION}/oss" "Основной репозиторий обновлений"
api__opensuse_repo "http://download.opensuse.org/debug/distribution/leap/${OS_VERSION}/repo/oss" "Debug Repository"
api__opensuse_repo "http://download.opensuse.org/debug/update/leap/${OS_VERSION}/oss/" "Update Repository (Debug)"
api__opensuse_repo "http://download.opensuse.org/source/distribution/leap/${OS_VERSION}/repo/oss/" "Source Repository"

api__opensuse_repo "http://download.opensuse.org/distribution/leap/${OS_VERSION}/repo/non-oss/" "Репозиторий Non-OSS"
api__opensuse_repo "http://download.opensuse.org/update/leap/${OS_VERSION}/non-oss/" "Репозиторий обновлений (Non-Oss)"
api__opensuse_repo "http://download.opensuse.org/debug/distribution/leap/${OS_VERSION}/repo/non-oss/" "Debug Repository (Non-OSS)"
api__opensuse_repo "http://download.opensuse.org/debug/update/leap/${OS_VERSION}/non-oss/" "Update Repository (Debug, Non-OSS)"
api__opensuse_repo "http://download.opensuse.org/source/distribution/leap/${OS_VERSION}/repo/non-oss/" "Source Repository (Non-OSS)"

api__opensuse_repo "http://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Leap_${OS_VERSION}/" "Packman Repository"
api__opensuse_repo "http://opensuse-guide.org/repo/openSUSE_Leap_${OS_VERSION}/" "dvd"

api__opensuse_repo "https://download.opensuse.org/repositories/filesystems/openSUSE_Leap_${OS_VERSION}/" "filesystems"
api__opensuse_repo "http://download.nvidia.com/opensuse/leap/${OS_VERSION}/" "nvidia"

api__opensuse_repo "https://download.opensuse.org/repositories/system:/snappy/openSUSE_Leap_${OS_VERSION}" "snappy"
api__opensuse_repo "http://download.opensuse.org/repositories/mozilla/openSUSE_Leap_${OS_VERSION}/" "mozilla"
api__opensuse_repo "http://repo.yandex.ru/yandex-disk/rpm/stable/x86_64/" "yandex-disk"
api__opensuse_repo "https://linux.teamviewer.com/yum/stable/main/binary-x86_64/" "TeamViewer"
api__opensuse_repo "https://packages.microsoft.com/yumrepos/ms-teams" "teams"

api__opensuse_repo "https://download.opensuse.org/repositories/devel:/languages:/php/openSUSE_Leap_${OS_VERSION}/" "devel:languages:php"

api__opensuse_repo "https://download.opensuse.org/repositories/games/openSUSE_Leap_${OS_VERSION}/" "games"

api__opensuse_repo "https://download.opensuse.org/repositories/home:/Sauerland:/hardware/openSUSE_Leap_${OS_VERSION}/" "home:Sauerland:hardware"

api__packages git
# Настроить Git

api__packages etckeeper
#
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
#
#
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
#
#
#checkNeededActions
#
##/usr/bin/fish:
##	$(call install,fish)
##	sudo grep -quiet $(shell which fish) /etc/shells || which fish | sudo tee -a /etc/shells >/dev/null
##	sudo usermod -s /usr/bin/fish $(USER)
##	sudo usermod -s /usr/bin/fish root
#
#add_software_repo 'packman' "http://ftp.gwdg.de/pub/linux/packman/suse/openSUSE_Leap_${OS_VERSION}/"
#add_software_repo 'dvd' "http://opensuse-guide.org/repo/openSUSE_Leap_${OS_VERSION}/"
#add_software_repo 'kde-extra' "https://download.opensuse.org/repositories/KDE:/Extra/openSUSE_Leap_${OS_VERSION}/"
#
#remove_packages \
#    akregator \
#    arphic-bsmi00lp-fonts \
#    arphic-fonts \
#    arphic-gbsn00lp-fonts \
#    baekmuk-ttf-fonts \
#    dragonplayer \
#    gitk \
#    git-gui \
#    indic-fonts \
#    ipa-gothic-fonts \
#    ipa-pgothic-fonts \
#    ipa-pmincho-fonts \
#    jomolhari-fonts \
#    khmeros-fonts \
#    lklug-fonts \
#    noto-coloremoji-fonts \
#    noto-emoji-fonts \
#    pothana2000-fonts \
#    sil-padauk-fonts

##
## Основная система.
##

api__packages \
  curl \
  davfs2 \
  fuse \
  htop \
  iotop \
  kwrite \
  mc \
  mlocate \
  nmap \
  pam_kwallet \
  PlayOnLinux \
  pwgen \
  signon-kwallet-extension \
  unar \
  unrar \
  unzip \
  wget \
  whois \
  wine \
  zip

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

##
## Офис и графика.
##

api__opensuse_repo "https://repo.skype.com/rpm/stable/" "skype"
api__opensuse_repo "https://mega.nz/linux/MEGAsync/openSUSE_Leap_15.0/" "MEGAsync"

api__packages \
  skypeforlinux \
  megasync \
  libreoffice \
  libreoffice-kde4 \
  gimp \
  gimp-save-for-web \
  inkscape \
  icoutils \
  kolourpaint

##
## Разработка.
##

api__packages \
  chromium \
  ShellCheck \
  docker \
  docker-compose \
  php8 \
  php8-bcmath \
  php8-bz2 \
  php8-ctype \
  php8-curl \
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
  php8-phar \
  php8-posix \
  php8-sockets \
  php8-sqlite \
  php8-tokenizer \
  php8-xmlreader \
  php8-xmlwriter \
  php8-zip \
  php8-zlib \
  npm \
  optipng \
  jpegoptim \
  virtualbox \
  kcachegrind \
  poedit \
  gcc \
  gcc-c++ \
  cmake \
  okteta \
  wireshark

#print_check "Пользователь ${USER} входит в группу vboxusers"
#if id -nG "${USER}" | grep vboxusers > /dev/null; then
#    print_checked
#else
#    print_check_failed
#    confirm 'Добавить?'
#    sudo usermod --append --groups=vboxusers "${USER}"
#    print_fixed
#    isReloginNeeded=1
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
#
#print_check "JetBrains Toolbox установлен"
#if [ -d ~/.local/share/JetBrains/Toolbox ]; then
#    print_checked
#else
#    print_check_failed
#    #TODO curl https://www.jetbrains.com/toolbox/download/download-thanks.html
#fi
#
#install_npm_packages \
#    standard

##
## Мультимедиа и развлечения
##

api__packages \
  amarok \
  ffmpeg \
  gstreamer-plugins-bad \
  gstreamer-plugins-libav \
  gstreamer-plugins-ugly \
  gstreamer-plugins-ugly-orig-addon \
  libdvdcss2 \
  ffmpeg \
  lame \
  gstreamer-plugins-libav \
  gstreamer-plugins-bad \
  gstreamer-plugins-ugly \
  gstreamer-plugins-ugly-orig-addon \
  vlc \
  vlc-codecs \
  amarok \
  filelight \
  kdenlive \
  digikam \
  audacity \
  avidemux-qt \
  mp3gain \
  python-mutagen \
  lame \
  libdvdcss2 \
  kid3 \
  kamoso \
  blender \
  steam \
  freeciv-qt \
  vlc \
  vlc-codecs

##sudo zypper dup --from packman

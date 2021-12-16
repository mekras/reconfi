api__group_contains wheel $USER

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

api__opensuse_repo "http://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Leap_$VERSION/" "Packman Repository"
api__opensuse_repo "http://opensuse-guide.org/repo/openSUSE_Leap_$VERSION/" "dvd"

api__opensuse_repo "https://download.opensuse.org/repositories/filesystems/openSUSE_Leap_$VERSION/" "filesystems"
api__opensuse_repo "http://download.nvidia.com/opensuse/leap/$VERSION/" "nvidia"

api__opensuse_repo "https://download.opensuse.org/repositories/system:/snappy/openSUSE_Leap_$VERSION" "snappy"
api__opensuse_repo "http://download.opensuse.org/repositories/mozilla/openSUSE_Leap_$VERSION/" "mozilla"
api__opensuse_repo "http://repo.yandex.ru/yandex-disk/rpm/stable/x86_64/" "yandex-disk"
api__opensuse_repo "https://linux.teamviewer.com/yum/stable/main/binary-x86_64/" "TeamViewer"

api__opensuse_repo "https://download.opensuse.org/repositories/devel:/languages:/php/openSUSE_Leap_$VERSION/" "devel:languages:php"

api__opensuse_repo "https://download.opensuse.org/repositories/home:/Sauerland:/hardware/openSUSE_Leap_$VERSION/" "home:Sauerland:hardware"


api__packages_remove \
    akregator \
    arphic-bsmi00lp-fonts \
    arphic-fonts \
    arphic-gbsn00lp-fonts \
    baekmuk-ttf-fonts \
    dragonplayer \
    gitk \
    git-gui \
    indic-fonts \
    ipa-gothic-fonts \
    ipa-pgothic-fonts \
    ipa-pmincho-fonts \
    jomolhari-fonts \
    khmeros-fonts \
    lklug-fonts \
    noto-coloremoji-fonts \
    noto-emoji-fonts \
    pothana2000-fonts \
    sil-padauk-fonts

##
## Основная система
##
api__packages_install \
  git

recipe__git_after() {
  sudo git config --global init.defaultBranch master
  sudo git config --global user.name "root"
  sudo git config --global user.email root@localhost

  git config --global init.defaultBranch master
  git config --global user.name "Михаил Красильников"
  git config --global user.email m.krasilnikov@yandex.ru

}

api__packages_install \
    git \
    etckeeper \
    fish \
    curl \
    davfs2 \
    fuse \
    htop \
    iotop \
    kwrite \
    libqt5-qdbus \
    mlocate \
    nmap \
    obsidian \
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
    zip \
    megasync \
    libreoffice \
    libreoffice-kde4 \
    gimp \
    gimp-save-for-web \
    inkscape \
    icoutils \
    kolourpaint \
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
    wireshark \
    amarok \
    ffmpeg \
    gstreamer-plugins-bad \
    gstreamer-plugins-libav \
    gstreamer-plugins-ugly \
    gstreamer-plugins-ugly-orig-addon \
    libdvdcss2 \
    ffmpeg \
    lame \
    vlc \
    vlc-codecs \
    filelight \
    kdenlive \
    digikam \
    audacity \
    mp3gain \
    python-mutagen \
    lame \
    libdvdcss2 \
    kid3 \
    kamoso

api__packages_install mc
recipe__mc_after(){
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

# Настройка клавиатуры.
api__ini_set "$HOME/.config/kxkbrc" DisplayNames '\xd0\x90\xd0\x9d\xd0\x93,\xd0\xa0\xd0\xa3\xd0\xa1'
api__ini_set "$HOME/.config/kxkbrc" Options 'terminate:ctrl_alt_bksp,lv3:ralt_switch,misc:typo,grp:caps_toggle'
api__ini_set "$HOME/.config/kxkbrc" Model pc101
api__ini_set "$HOME/.config/kxkbrc" ResetOldOptions true

api__ini_set "$HOME/.config/kglobalshortcutsrc" '{24bfa1fc-6c9f-4ed3-ba8b-b49386aa962e}' 'Alt+`,none,Launch Konsole'
api__ini_set "$HOME/.config/kglobalshortcutsrc" 'Lock Session' 'Meta+L\\t\\tScreensaver,Meta+L\\tCtrl+Alt+L\\tScreensaver,Заблокировать сеанс'
api__ini_set "$HOME/.config/kglobalshortcutsrc" 'Walk Through Windows of Current Application' ',,На одно окно вперёд текущего приложения'

api__opensuse_repo "https://packages.microsoft.com/yumrepos/ms-teams" "teams"
api__packages_remove teams-insiders
api__packages_install teams

#api__opensuse_repo "https://mega.nz/linux/MEGAsync/openSUSE_Leap_15.0/" "MEGAsync"

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

#print_check 'fish добавлена в /etc/shells'
#if sudo grep -quiet $(which fish) /etc/shells; then
#    print_checked
#else
#    print_check_failed
#    confirm 'Добавить?'
#    which fish | sudo tee -a /etc/shells >/dev/null
#fi

#print_check "У пользователя ${USER} оболочка fish"
#if [ "$(getent passwd "${USER}" | cut -d: -f7)" = "$(which fish)" ]; then
#    print_checked
#else
#    print_check_failed
#    confirm 'Изменить?'
#    sudo usermod -s $(which fish) ${USER}
#    isReloginNeeded=1
#fi

#print_check "У пользователя root оболочка fish"
#if [ "$(getent passwd root | cut -d: -f7)" = "$(which fish)" ]; then
#    print_checked
#else
#    print_check_failed
#    confirm 'Изменить?'
#    sudo usermod -s $(which fish) root
#    isReloginNeeded=1
#fi

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

##sudo zypper dup --from packman

# Браузер по умолчанию.
# Единый список пакетов с указанием зависимостей.

## Obsidian.md
api__packages_install obsidian    
recipe__obsidian() {
    appDir="$HOME/opt/Obsidian"
    appBin="$appDir/Obsidian"
    if [ -f "$appBin" ]; then
        print__ok 'Obsidian установлен.'
    else
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

##
## Разработка
##
api__packages_install jetbrains-toolbox
recipe__jetbrains_toolbox()
{
    distrib="jetbrains-toolbox-1.19.7784"
    archive="$distrib.tar.gz"
    binary="jetbrains-toolbox"
    target="$HOME/opt/jetbrains-toolbox/$binary"
    if [ ! -f "$target" ]; then
        if [ ! -f "$HOME/Загрузки/$archive" ]; then
            wget -O "$HOME/Загрузки/$archive" "https://download.jetbrains.com/toolbox/$archive"
        fi
        cd "$HOME/Загрузки"
        if [ ! -f "$distrib/$binary" ]; then
            tar -xf "$archive"
        fi;
        if [ ! -d "$(dirname $target)" ]; then
            mkdir -p "$(dirname $target)"
        fi
        mv "$HOME/Загрузки/$distrib/$binary" "$target"
    fi
    if [ -d "$HOME/Загрузки/$distrib" ]; then
        rm -r "$HOME/Загрузки/$distrib"
    fi
    if [ -f "$HOME/Загрузки/$archive" ]; then
        rm "$HOME/Загрузки/$archive"
    fi
}

##
## Мультимедиа
##
#api__packages_install \
#    avidemux-qt

##
## Игры
##
#api__opensuse_repo "https://download.opensuse.org/repositories/games/openSUSE_Leap_$VERSION/" "games"

#api__packages_install \
#    steam \
#    freeciv-qt

##
## 3D
##
#api__packages_install \
#    blender

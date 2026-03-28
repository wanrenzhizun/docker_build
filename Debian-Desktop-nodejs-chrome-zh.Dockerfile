FROM accetto/debian-vnc-xfce-nodejs-g3:chromium as stage_extending_chinese_support

USER 0

# ========== 原有内容保持不变 ==========

# 安装中文支持、Google Chrome 和 Homebrew
RUN \
    DEBIAN_FRONTEND=noninteractive apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        locales \
        fonts-wqy-zenhei \
        fonts-wqy-microhei \
        fonts-noto-cjk \
        fonts-noto-cjk-extra \
        fonts-arphic-uming \
        fonts-arphic-ukai \
        fonts-noto-color-emoji \
        fonts-noto-mono \
        fonts-symbola \
        wget \
        curl \
        gnupg \
        ca-certificates \
        libnss3 \
        libatk-bridge2.0-0 \
        libxss1 \
        libgtk-3-0 \
        libgbm1 \
        libasound2 \
        libu2f-udev \
        libvulkan1 \
        xdg-utils \
        libxcomposite1 \
        libxdamage1 \
        libxfixes3 \
        libxrandr2 \
        libxrender1 \
        libxtst6 \
        libxi6 \
        libpangocairo-1.0-0 \
        libpango-1.0-0 \
        libatk1.0-0 \
        libcairo-gobject2 \
        libcairo2 \
        libgdk-pixbuf-2.0-0 \
        libnspr4 \
        libx11-xcb1 \
        libxcb1 \
        libxcb-dri3-0 \
        libxcb-shm0 \
        libdrm2 \
        libexpat1 \
        libxshmfence1 \
        fcitx5 \
        fcitx5-frontend-gtk2 \
        fcitx5-frontend-gtk3 \
        fcitx5-frontend-gtk4 \
        fcitx5-frontend-qt5 \
        fcitx5-frontend-qt6 \
        fcitx5-module-xorg \
        fcitx5-module-wayland \
        fcitx5-config-qt \
        fcitx5-chinese-addons \
        fcitx5-pinyin \
        libime-data \
        sudo \
        # 搜狗拼音依赖（Debian 11 修正版）
        libqt5widgets5 \
        libqt5network5 \
        libqt5qml5 \
        libqt5quick5 \
        libqt5quickwidgets5 \
        libqt5positioning5 \
        libqt5webchannel5 \
        libqt5webengine5 \
        libqt5webenginecore5 \
        libqt5webenginewidgets5 \
        libqt5dbus5 \
        libqt5x11extras5 \
        libqt5xml5 \
        libqt5svg5 \
        libqt5concurrent5 \
        libqt5sql5 \
        libqt5sql5-sqlite \
        libgsettings-qt1 \
        libfcitx5-qt1 \
        libfcitx5-qt-data \
        libopencc1.1 \
        libcurl4 \
        libxkbcommon-x11-0 \
        libxkbfile1 \
        libssl3 \
        libsecret-1-0 \
        libnotify4 \
        libnss3 \
        libxss1 \
        libasound2 \
        libfuse2 \
        fuse \
        libappindicator3-1 \
        desktop-file-utils \
        hicolor-icon-theme \
        shared-mime-info \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && sed -i -e 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen \
    && sed -i -e 's/# zh_TW.UTF-8 UTF-8/zh_TW.UTF-8 UTF-8/' /etc/locale.gen \
    && sed -i -e 's/# zh_HK.UTF-8 UTF-8/zh_HK.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/*

ENV LANGUAGE=zh_CN:zh LANG=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8 LC_MESSAGES=zh_CN.UTF-8

RUN \
    apt-get purge -y chromium* || true \
    && apt-get autoremove -y \
    && rm -rf /usr/bin/chromium* /usr/lib/chromium* /etc/chromium* /usr/share/chromium* \
    && rm -f /usr/local/bin/chromium-wrapper || true

RUN \
    install -d -m 0755 /etc/apt/keyrings \
    && curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg \
    && chmod 644 /etc/apt/keyrings/google-chrome.gpg \
    && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends google-chrome-stable \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN \
    if [ -f /usr/bin/google-chrome-stable ]; then \
        ln -sf /usr/bin/google-chrome-stable /usr/bin/google-chrome; \
    elif [ -f /opt/google/chrome/google-chrome ]; then \
        ln -sf /opt/google/chrome/google-chrome /usr/bin/google-chrome-stable; \
        ln -sf /opt/google/chrome/google-chrome /usr/bin/google-chrome; \
    fi \
    && ln -sf /usr/bin/google-chrome /usr/bin/chrome \
    && chmod 4755 /opt/google/chrome/chrome-sandbox 2>/dev/null || true

RUN \
    mkdir -p /etc/fonts/conf.d \
    && echo '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE fontconfig SYSTEM "fonts.dtd"><fontconfig><match><test name="family"><string>sans-serif</string></test><edit name="family" mode="prepend" binding="strong"><string>Noto Color Emoji</string></edit></match><match><test name="family"><string>serif</string></test><edit name="family" mode="prepend" binding="strong"><string>Noto Color Emoji</string></edit></match><match><test name="family"><string>monospace</string></test><edit name="family" mode="prepend" binding="strong"><string>Noto Color Emoji</string></edit></match></fontconfig>' > /etc/fonts/conf.d/70-noto-color-emoji.conf \
    && fc-cache -fv

ENV GTK_IM_MODULE=fcitx QT_IM_MODULE=fcitx XMODIFIERS=@im=fcitx SDL_IM_MODULE=fcitx

RUN \
    HEADLESS_USER_NAME=$(id -nu "${HEADLESS_USER_ID}" 2>/dev/null || echo "headless") \
    && echo "HEADLESS_USER_NAME=${HEADLESS_USER_NAME}" > /etc/docker-headless-user \
    && echo "HEADLESS_USER_ID=${HEADLESS_USER_ID}" >> /etc/docker-headless-user \
    && echo "HEADLESS_USER_GROUP_ID=${HEADLESS_USER_GROUP_ID}" >> /etc/docker-headless-user

RUN \
    . /etc/docker-headless-user \
    && groupadd -r brew || true \
    && usermod -aG brew "${HEADLESS_USER_NAME}" \
    && mkdir -p "${HOME}" \
    && chown -R "${HEADLESS_USER_NAME}:${HEADLESS_USER_GROUP_ID}" "${HOME}" \
    && mkdir -p "${HOME}/.cache" \
    && chown -R "${HEADLESS_USER_NAME}:${HEADLESS_USER_GROUP_ID}" "${HOME}/.cache" \
    && mkdir -p /home/linuxbrew/.linuxbrew \
    && chown -R "${HEADLESS_USER_NAME}":brew /home/linuxbrew \
    && su "${HEADLESS_USER_NAME}" -c 'NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"' \
    && /home/linuxbrew/.linuxbrew/bin/brew --version

ENV HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_INSTALL_CLEANUP=1 HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew" HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar" HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew" PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin${PATH+:$PATH}" MANPATH="/home/linuxbrew/.linuxbrew/share/man${MANPATH+:$MANPATH}:" INFOPATH="/home/linuxbrew/.linuxbrew/share/info${INFOPATH+:$INFOPATH}"

RUN \
    . /etc/docker-headless-user \
    && mkdir -p "${HOME}/.config/google-chrome/Default" \
    && mkdir -p "${HOME}/.cache/google-chrome" \
    && echo '{"intl": {"accept_languages": "zh-CN,zh,en-US,en", "selected_languages": "zh-CN,zh,en-US,en"}, "default_content_setting_values": {"notifications": 1}}' > "${HOME}/.config/google-chrome/Default/Preferences" \
    && echo '{"intl": {"selected_languages": "zh-CN,zh,en-US,en"}}' > "${HOME}/.config/google-chrome/Local State" \
    && chown -R "${HEADLESS_USER_NAME}:${HEADLESS_USER_GROUP_ID}" "${HOME}/.config" \
    && chown -R "${HEADLESS_USER_NAME}:${HEADLESS_USER_GROUP_ID}" "${HOME}/.cache" \
    && chown -R "${HEADLESS_USER_NAME}:${HEADLESS_USER_GROUP_ID}" /home/linuxbrew

RUN \
    echo '#!/bin/bash' > /usr/local/bin/google-chrome-wrapper \
    && echo 'export LANGUAGE=zh_CN:zh; export LANG=zh_CN.UTF-8; export LC_ALL=zh_CN.UTF-8' >> /usr/local/bin/google-chrome-wrapper \
    && echo 'export GTK_IM_MODULE=fcitx; export QT_IM_MODULE=fcitx; export XMODIFIERS=@im=fcitx; export SDL_IM_MODULE=fcitx' >> /usr/local/bin/google-chrome-wrapper \
    && echo 'mkdir -p "${HOME}/.config/google-chrome" "${HOME}/.cache/google-chrome"' >> /usr/local/bin/google-chrome-wrapper \
    && echo 'if ! pgrep -x "fcitx5" > /dev/null 2>&1; then fcitx5 -d -r 2>/dev/null || true; sleep 1; fi' >> /usr/local/bin/google-chrome-wrapper \
    && echo 'if [ -x "/usr/bin/google-chrome-stable" ]; then CHROME_BIN="/usr/bin/google-chrome-stable"; elif [ -x "/opt/google/chrome/google-chrome" ]; then CHROME_BIN="/opt/google/chrome/google-chrome"; elif [ -x "/opt/google/chrome/chrome" ]; then CHROME_BIN="/opt/google/chrome/chrome"; else echo "Error: Chrome not found"; exit 1; fi' >> /usr/local/bin/google-chrome-wrapper \
    && echo 'exec "$CHROME_BIN" --no-sandbox --disable-setuid-sandbox --no-first-run --no-default-browser-check --disable-background-timer-throttling --disable-backgrounding-occluded-windows --disable-renderer-backgrounding --disable-features=TranslateUI --disable-ipc-flooding-protection --enable-features=ColorEmoji,FontAccess --force-color-profile=srgb "$@"' >> /usr/local/bin/google-chrome-wrapper \
    && chmod +x /usr/local/bin/google-chrome-wrapper \
    && ln -sf /usr/local/bin/google-chrome-wrapper /usr/local/bin/google-chrome \
    && ln -sf /usr/local/bin/google-chrome-wrapper /usr/local/bin/chrome

# ========== 新增：安装搜狗拼音输入法 ==========

# 下载并安装搜狗拼音（使用官方最新版）
RUN \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        # 额外依赖
        libqt5gui5 \
        libqt5core5a \
        libqt5network5 \
        libqt5widgets5 \
        libqt5qml5 \
        libqt5quick5 \
        libqt5quickwidgets5 \
        libqt5positioning5 \
        libqt5webchannel5 \
        libqt5webengine5 \
        libqt5webenginecore5 \
        libqt5webenginewidgets5 \
        libqt5dbus5 \
        libqt5x11extras5 \
        libqt5xml5 \
        libqt5svg5 \
        libqt5concurrent5 \
        libqt5sql5 \
        libqt5sql5-sqlite \
        libgsettings-qt1 \
        libfcitx5-qt1 \
        libfcitx5-qt-data \
        libopencc1.1 \
        libcurl4 \
        libxkbcommon-x11-0 \
        libxkbfile1 \
        libssl3 \
        libsecret-1-0 \
        libnotify4 \
        libappindicator3-1 \
        desktop-file-utils \
        hicolor-icon-theme \
        shared-mime-info \
        xdg-utils \
        # 下载工具
        wget \
        ca-certificates \
    && cd /tmp \
    # 下载搜狗拼音官方包（amd64 架构）
    && wget -q --show-progress "https://shurufa.sogou.com/linux/download.php?f=linux&bit=64" -O sogoupinyin_amd64.deb \
    || wget -q --show-progress "https://ime.sogoucdn.com/sogou_pinyin_linux_1.0.0.0033_amd64.deb" -O sogoupinyin_amd64.deb \
    || wget -q --show-progress "https://pinyin.sogou.com/linux/download.php?f=linux&bit=64" -O sogoupinyin_amd64.deb \
    # 备用下载地址
    || wget -q --show-progress "https://github.com/whistmazel/sogoupinyin-releases/releases/download/4.2.1.145/sogoupinyin_4.2.1.145_amd64.deb" -O sogoupinyin_amd64.deb \
    # 安装搜狗拼音
    && dpkg -i sogoupinyin_amd64.deb || apt-get install -f -y --no-install-recommends \
    && apt-get install -f -y --no-install-recommends \
    && rm -f sogoupinyin_amd64.deb \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/* \
    # 验证安装
    && dpkg -l | grep sogoupinyin || echo "Warning: sogoupinyin may not be installed correctly"

# 配置搜狗拼音环境
RUN \
    . /etc/docker-headless-user \
    # 创建搜狗拼音配置目录
    && mkdir -p "${HOME}/.config/sogoupinyin" \
    && mkdir -p "${HOME}/.config/fcitx5/conf" \
    && mkdir -p "${HOME}/.local/share/fcitx5" \
    # 配置 fcitx5 使用搜狗拼音（优先）
    && printf '[Groups/0]\nName=Default\nDefault Layout=us\nDefaultIM=sogoupinyin\n\n[Groups/0/Items/0]\nName=keyboard-us\nLayout=\n\n[Groups/0/Items/1]\nName=sogoupinyin\nLayout=\n\n[GroupOrder]\n0=Default\n' > "${HOME}/.config/fcitx5/profile" \
    # 配置 fcitx5 行为
    && printf '[Behavior]\nActiveByDefault=False\nShowPreedit=True\nShowPreeditInApplications=True\nShowInputMethodInformation=True\nShowTrayIcon=True\n\n[Hotkey/TriggerKeys]\n0=Control+space\n\n[Hotkey/AltTriggerKeys]\n0=Shift_L\n\n[Hotkey/EnumerateForwardKeys]\n0=Super+space\n\n[Hotkey/PrevPage]\n0=Up\n\n[Hotkey/NextPage]\n0=Down\n\n[Hotkey/PrevCandidate]\n0=Shift+Tab\n\n[Hotkey/NextCandidate]\n0=Tab\n' > "${HOME}/.config/fcitx5/config" \
    # 设置权限
    && chown -R "${HEADLESS_USER_NAME}:${HEADLESS_USER_GROUP_ID}" "${HOME}/.config/fcitx5" \
    && chown -R "${HEADLESS_USER_NAME}:${HEADLESS_USER_GROUP_ID}" "${HOME}/.config/sogoupinyin" \
    && chown -R "${HEADLESS_USER_NAME}:${HEADLESS_USER_GROUP_ID}" "${HOME}/.local"

# 修复搜狗拼音库文件链接问题
RUN \
    # 修复可能的库链接问题
    if [ -d /usr/lib/x86_64-linux-gnu/sogoupinyin ]; then \
        cd /usr/lib/x86_64-linux-gnu/sogoupinyin && \
        for f in *.so*; do \
            if [ -L "$f" ]; then \
                target=$(readlink "$f"); \
                if [ ! -f "$target" ] && [ -f "/usr/lib/x86_64-linux-gnu/$target" ]; then \
                    ln -sf "/usr/lib/x86_64-linux-gnu/$target" "$f"; \
                fi; \
            fi; \
        done; \
    fi \
    # 确保 sogoupinyin 在 fcitx5 的搜索路径中
    && mkdir -p /usr/share/fcitx5/inputmethod \
    && ln -sf /usr/lib/x86_64-linux-gnu/fcitx5/sogoupinyin.so /usr/share/fcitx5/inputmethod/ 2>/dev/null || true

# ========== 结束新增 ==========

RUN \
    . /etc/docker-headless-user \
    && mkdir -p "${HOME}/.vnc" \
    && if [ -f "${HOME}/.vnc/xstartup" ]; then \
        cp "${HOME}/.vnc/xstartup" "${HOME}/.vnc/xstartup.bak"; \
    fi \
    && echo '#!/bin/bash' > "${HOME}/.vnc/xstartup" \
    && echo '' >> "${HOME}/.vnc/xstartup" \
    && echo 'unset SESSION_MANAGER' >> "${HOME}/.vnc/xstartup" \
    && echo 'unset DBUS_SESSION_BUS_ADDRESS' >> "${HOME}/.vnc/xstartup" \
    && echo 'export XKL_XMODMAP_DISABLE=1' >> "${HOME}/.vnc/xstartup" \
    && echo '' >> "${HOME}/.vnc/xstartup" \
    && echo '# 中文环境' >> "${HOME}/.vnc/xstartup" \
    && echo 'export LANGUAGE=zh_CN:zh' >> "${HOME}/.vnc/xstartup" \
    && echo 'export LANG=zh_CN.UTF-8' >> "${HOME}/.vnc/xstartup" \
    && echo 'export LC_ALL=zh_CN.UTF-8' >> "${HOME}/.vnc/xstartup" \
    && echo '' >> "${HOME}/.vnc/xstartup" \
    && echo '# 输入法' >> "${HOME}/.vnc/xstartup" \
    && echo 'export GTK_IM_MODULE=fcitx' >> "${HOME}/.vnc/xstartup" \
    && echo 'export QT_IM_MODULE=fcitx' >> "${HOME}/.vnc/xstartup" \
    && echo 'export XMODIFIERS=@im=fcitx' >> "${HOME}/.vnc/xstartup" \
    && echo 'export SDL_IM_MODULE=fcitx' >> "${HOME}/.vnc/xstartup" \
    && echo '' >> "${HOME}/.vnc/xstartup" \
    && echo '# 启动 dbus' >> "${HOME}/.vnc/xstartup" \
    && echo 'if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then' >> "${HOME}/.vnc/xstartup" \
    && echo '    eval $(dbus-launch --sh-syntax --exit-with-session)' >> "${HOME}/.vnc/xstartup" \
    && echo 'fi' >> "${HOME}/.vnc/xstartup" \
    && echo '' >> "${HOME}/.vnc/xstartup" \
    && echo '# 启动输入法' >> "${HOME}/.vnc/xstartup" \
    && echo 'fcitx5 -d -r 2>/dev/null &' >> "${HOME}/.vnc/xstartup" \
    && echo 'sleep 2' >> "${HOME}/.vnc/xstartup" \
    && echo '' >> "${HOME}/.vnc/xstartup" \
    && echo '# 启动桌面' >> "${HOME}/.vnc/xstartup" \
    && echo 'exec startxfce4' >> "${HOME}/.vnc/xstartup" \
    && chmod +x "${HOME}/.vnc/xstartup" \
    && chown -R "${HEADLESS_USER_NAME}:${HEADLESS_USER_GROUP_ID}" "${HOME}/.vnc"

RUN \
    . /etc/docker-headless-user \
    && echo "${HEADLESS_USER_NAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/"${HEADLESS_USER_NAME}" \
    && chmod 0440 /etc/sudoers.d/"${HEADLESS_USER_NAME}"

RUN \
    . /etc/docker-headless-user \
    && mkdir -p "${HOME}/.cache" \
    && echo '' >> "${HOME}/.bashrc" \
    && echo '# Homebrew' >> "${HOME}/.bashrc" \
    && echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "${HOME}/.bashrc" \
    && echo '' >> "${HOME}/.bashrc" \
    && echo '# 中文输入法' >> "${HOME}/.bashrc" \
    && echo 'export GTK_IM_MODULE=fcitx' >> "${HOME}/.bashrc" \
    && echo 'export QT_IM_MODULE=fcitx' >> "${HOME}/.bashrc" \
    && echo 'export XMODIFIERS=@im=fcitx' >> "${HOME}/.bashrc" \
    && echo 'export SDL_IM_MODULE=fcitx' >> "${HOME}/.bashrc" \
    && echo '' >> "${HOME}/.bashrc" \
    && echo '# 中文环境' >> "${HOME}/.bashrc" \
    && echo 'export LANGUAGE=zh_CN:zh' >> "${HOME}/.bashrc" \
    && echo 'export LANG=zh_CN.UTF-8' >> "${HOME}/.bashrc" \
    && echo 'export LC_ALL=zh_CN.UTF-8' >> "${HOME}/.bashrc" \
    && chown -R "${HEADLESS_USER_NAME}:${HEADLESS_USER_GROUP_ID}" "${HOME}" \
    && su "${HEADLESS_USER_NAME}" -c '/home/linuxbrew/.linuxbrew/bin/brew --version' || true

# ========== 新增：PM2 开机自启 ==========

# 安装 PM2
RUN npm install -g pm2

# 确保 PM2 目录权限正确
RUN \
    . /etc/docker-headless-user \
    && mkdir -p "${HOME}/.pm2" \
    && chown -R "${HEADLESS_USER_NAME}:${HEADLESS_USER_GROUP_ID}" "${HOME}/.pm2"

# 备份原启动脚本
RUN \
    . /etc/docker-headless-user \
    && cp "${STARTUPDIR}/startup.sh" "${STARTUPDIR}/startup_original.sh"

# 创建 wrapper 脚本（用 printf 避免 HEREDOC 问题）
RUN \
    . /etc/docker-headless-user \
    && printf '%s\n' \
        '#!/bin/bash' \
        'set -e' \
        '' \
        '# PM2 自动恢复' \
        'export PM2_HOME="${HOME}/.pm2"' \
        'export PATH="/usr/local/bin:$PATH"' \
        '' \
        'if [ -f "${HOME}/.pm2/dump.pm2" ]; then' \
        '    echo "[startup-wrapper] PM2 resurrect..."' \
        '    pm2 resurrect &' \
        '    sleep 2' \
        'else' \
        '    echo "[startup-wrapper] No PM2 dump found"' \
        'fi' \
        '' \
        '# 执行原启动脚本' \
        'exec /dockerstartup/startup_original.sh "$@"' \
    > "${STARTUPDIR}/startup.sh" \
    && chmod +x "${STARTUPDIR}/startup.sh"

# ========== 结束新增 ==========

USER ${HEADLESS_USER_ID}:${HEADLESS_USER_GROUP_ID}

WORKDIR ${HOME}
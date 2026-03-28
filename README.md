# Debian VNC Node.js Chrome 中文桌面环境

基于 [accetto/debian-vnc-xfce-nodejs-g3](https://hub.docker.com/r/accetto/debian-vnc-xfce-nodejs-g3) 构建的完整中文桌面开发环境，集成 Google Chrome、搜狗拼音输入法、Fcitx5 输入法框架、Homebrew 包管理器及 PM2 进程管理工具。

## 镜像地址

- Docker Hub: `wanrenzhizun/debian-vnc-nodejs-chrome-zh:main`

---

## 功能特性

### 桌面环境
| 组件 | 说明 |
|------|------|
| **XFCE4** | 轻量级桌面环境，资源占用低 |
| **TigerVNC** | 高性能 VNC 服务器，默认端口 5901 |
| **noVNC** | 基于 Web 的 VNC 客户端，默认端口 6901 |

### 浏览器
| 组件 | 说明 |
|------|------|
| **Google Chrome** | 官方稳定版，已配置中文语言和 Emoji 支持 |
| **启动参数优化** | `--no-sandbox` 等参数适配容器环境 |

### 中文输入法
| 组件 | 说明 |
|------|------|
| **Fcitx5** | 新一代输入法框架 |
| **搜狗拼音** | 智能拼音输入，云词库同步 |
| **预配置优化** | 默认启用搜狗拼音，Ctrl+Space 切换 |

### 开发工具
| 组件 | 说明 |
|------|------|
| **Node.js** | 基础镜像自带，支持 npm/yarn |
| **PM2** | 进程管理工具，支持开机自启 |
| **Homebrew** | Linuxbrew 包管理器 |
| **Jekyll** | 静态网站生成器，端口 4000 |

### 字体支持
- 文泉驿正黑 / 文泉驿微米黑
- Noto CJK 全系列
- 文鼎 PL 细上海宋 / 文鼎 PL 简报宋
- Noto Color Emoji 彩色表情符号

---

## 快速启动

### Docker Compose（推荐）

```yaml
services:
  debian-desktop:
    deploy:
      resources:
        limits:
          memory: 4g          # 建议最小 2G，推荐 4G+
    image: wanrenzhizun/debian-vnc-nodejs-chrome-zh:main
    container_name: debian-desktop
    hostname: debian-desktop
    shm_size: "2g"            # Chrome 需要足够共享内存
    environment:
      - TZ=Asia/Shanghai
      - VNC_RESOLUTION=1360x768   # 桌面分辨率
      - VNC_COL_DEPTH=24          # 颜色深度
      - VNC_PW=yourpassword       # 自定义 VNC 密码（可选）
    ports:
      - "44002:4000"   # Jekyll 开发服务器
      - "45902:5901"   # VNC 连接端口
      - "46902:6901"   # noVNC Web 访问
      - "1420:1420"    # 自定义应用端口
    volumes:
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
      - type: volume
        source: debian-desktop
        target: /home/headless    # 用户数据持久化
      - type: volume
        source: debian-desktop-opt
        target: /opt              # 可选软件安装目录
volumes:
  debian-desktop:
  debian-desktop-opt:
```

### Docker Run

```bash
docker run -d \
  --name debian-desktop \
  --hostname debian-desktop \
  --shm-size=2g \
  -e TZ=Asia/Shanghai \
  -e VNC_RESOLUTION=1360x768 \
  -p 44002:4000 \
  -p 45902:5901 \
  -p 46902:6901 \
  -p 1420:1420 \
  -v debian-desktop:/home/headless \
  wanrenzhizun/debian-vnc-nodejs-chrome-zh:main
```

---

## 访问方式

| 方式 | 地址 | 说明 |
|------|------|------|
| **noVNC (Web)** | `http://localhost:46902/vnc.html` | 无需客户端，浏览器直接访问 |
| **VNC 客户端** | `localhost:45902` | 推荐 TigerVNC/RealVNC/TightVNC |
| **Jekyll** | `http://localhost:44002` | 静态网站预览 |

### 默认凭证
| 项目 | 值 |
|------|-----|
| VNC 密码 | `headless` |
| 系统用户 | `headless` (UID 1000) |
| sudo 权限 | 免密码 sudo |

---

## 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `TZ` | `Asia/Shanghai` | 时区设置 |
| `VNC_RESOLUTION` | `1360x768` | 桌面分辨率 |
| `VNC_COL_DEPTH` | `24` | 颜色深度 (16/24/32) |
| `VNC_PW` | `headless` | VNC 连接密码 |
| `VNC_VIEW_ONLY` | `false` | 只读模式 |
| `LANGUAGE` | `zh_CN:zh` | 系统语言 |
| `LANG` | `zh_CN.UTF-8` | 系统编码 |
| `LC_ALL` | `zh_CN.UTF-8` | 全局编码设置 |
| `GTK_IM_MODULE` | `fcitx` | GTK 输入法模块 |
| `QT_IM_MODULE` | `fcitx` | Qt 输入法模块 |
| `XMODIFIERS` | `@im=fcitx` | X11 输入法修饰键 |

---

## 输入法使用指南

### 默认快捷键
| 快捷键 | 功能 |
|--------|------|
| `Ctrl + Space` | 切换输入法开关 |
| `Shift` | 中英文切换 |
| `Super + Space` | 输入法列表循环 |
| `Tab` | 下一候选词 |
| `Shift + Tab` | 上一候选词 |
| `↑ / ↓` | 翻页 |

### 搜狗拼音配置
配置文件位置：`~/.config/fcitx5/profile`

如需重新配置：
```bash
fcitx5-configtool  # 图形化配置工具
```

---

## PM2 进程管理

### 开机自启
容器启动时会自动执行 `pm2 resurrect`，恢复上次保存的进程列表。

### 常用命令
```bash
# 启动应用
pm2 start app.js --name myapp

# 保存进程列表（下次自动恢复）
pm2 save

# 查看状态
pm2 status

# 查看日志
pm2 logs

# 重启/停止/删除
pm2 restart myapp
pm2 stop myapp
pm2 delete myapp
```

### 持久化配置
PM2 配置保存在 `~/.pm2/` 目录，已通过 volume 持久化。

---

## Homebrew 使用

```bash
# 已自动配置环境变量
brew --version

# 安装软件
brew install tree htop

# 注意：编译软件需要 build-essential
```

---

## 目录结构

```
/home/headless/          # 用户主目录（持久化）
├── .config/             # 应用配置
│   ├── fcitx5/         # 输入法配置
│   ├── sogoupinyin/    # 搜狗拼音配置
│   └── google-chrome/  # Chrome 配置
├── .pm2/               # PM2 进程数据
├── .vnc/               # VNC 配置
├── .cache/             # 缓存目录
└── .linuxbrew/         # Homebrew 安装目录

/opt/                    # 可选软件目录（持久化）
/usr/local/bin/          # 自定义脚本
├── google-chrome-wrapper    # Chrome 启动包装器
└── ...
```

---

## 性能优化建议

### 内存配置
| 使用场景 | 建议内存 |
|---------|---------|
| 基础桌面 + 浏览器 | 2 GB |
| 开发环境 + 多标签 | 4 GB |
| 重度使用 / 多应用 | 8 GB+ |

### Chrome 优化
已预配置以下参数减少资源占用：
- `--disable-background-timer-throttling`
- `--disable-backgrounding-occluded-windows`
- `--disable-renderer-backgrounding`

### shm_size 说明
Chrome 使用 `/dev/shm` 作为共享内存，容器默认 64MB 不足，建议设置 `--shm-size=2g` 或更大。

---

## 故障排查

### VNC 连接失败
```bash
# 检查容器状态
docker logs debian-desktop

# 进入容器检查 VNC 服务
docker exec -it debian-desktop ps aux | grep vnc

# 手动重启 VNC
docker exec -it debian-desktop vncserver -kill :1
docker exec -it debian-desktop vncserver :1 -geometry 1360x768 -depth 24
```

### 输入法不工作
```bash
# 检查 Fcitx5 是否运行
docker exec -it debian-desktop pgrep -a fcitx5

# 手动启动
docker exec -it debian-desktop fcitx5 -d -r

# 检查环境变量
docker exec -it debian-desktop env | grep IM
```

### Chrome 崩溃或无法启动
```bash
# 检查共享内存
docker exec -it debian-desktop df -h /dev/shm

# 清理 Chrome 配置
docker exec -it debian-desktop rm -rf ~/.config/google-chrome/Singleton*
```

---

## 构建信息

- **基础镜像**: `accetto/debian-vnc-xfce-nodejs-g3:chromium`
- **Debian 版本**: 11 (bullseye)
- **构建平台**: `linux/amd64`
- **自动构建**: GitHub Actions → Docker Hub

---

## 许可证

- 基础镜像遵循 [accetto/debian-vnc-xfce-nodejs-g3 许可](https://github.com/accetto/xubuntu-vnc-novnc/blob/master/LICENSE)
- 搜狗拼音输入法遵循 [搜狗用户协议](https://pinyin.sogou.com/help.php?list=8&q=1)

---

## 更新日志

| 版本 | 日期 | 更新内容 |
|------|------|---------|
| main | 2026-03-28 | 初始版本，集成搜狗拼音、Chrome、PM2、Homebrew |


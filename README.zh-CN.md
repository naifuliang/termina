# Termina

一个简洁、有审美的 macOS 原生终端 —— 界面设计致敬最新版 **Windows Terminal**。

[English →](README.md)

- **标题栏内嵌标签页**：圆角标签、hover 关闭按钮、相邻标签分隔线、`+` 新建与 `⌄` 配置下拉菜单；空白处拖动窗口、双击缩放
- **深色亚克力材质**：标签行使用 `NSVisualEffectView` 毛玻璃，内容区为 Campbell 黑（`#0C0C0C`）
- **Campbell 配色**：Windows Terminal 默认 ANSI 16 色方案
- **字体**：优先 Cascadia Mono / CaskaydiaCove Nerd Font，自动回退到 SF Mono
- **原生实现**：SwiftUI + AppKit，终端仿真核心为 [SwiftTerm](https://github.com/migueldeicaza/SwiftTerm)（登录 shell、真彩色、鼠标上报、滚动回看）
- **SSH 远程连接**：自动读取 `~/.ssh/config` 中的 Host 列表，一键连接或连接后附加 tmux 会话（`tmux new-session -A -s termina`）；也可通过「自定义 SSH 连接…」临时输入 `user@host[:port]`
- **多语言界面**：默认英文，支持简体中文、繁體中文、日语、韩语、法语、德语、西语、葡语（巴西）、俄语、意大利语，跟随系统语言自动切换

## 构建

```sh
./scripts/make-app.sh          # 产出 dist/Termina.app 与 dist/Termina.dmg
open dist/Termina.app
```

开发调试：

```sh
swift run                      # debug 直接运行
```

要求 macOS 14+，Swift 5.9+（Command Line Tools 即可，无需完整 Xcode）。

## 快捷键

| 快捷键 | 功能 |
| --- | --- |
| ⌘T | 新建标签页 |
| ⌘W | 关闭当前标签页（最后一个标签关闭即退出） |
| ⌘⇧] / ⌘⇧[ | 下一个 / 上一个标签页 |
| ⌘1 … ⌘9 | 切换到第 N 个标签页 |
| ⌘+ / ⌘− / ⌘0 | 放大 / 缩小 / 重置字体 |

## 结构

```
Sources/Termina/
  TerminaApp.swift      # 入口、菜单与快捷键
  ContentView.swift     # 布局、亚克力背景、窗口样式
  TabBarView.swift      # Windows Terminal 风格标签栏
  TabManager.swift      # 标签生命周期与选中状态
  TerminalTab.swift     # 单个终端会话（SwiftTerm + shell/SSH 进程）
  ShellProfile.swift    # 可用 shell 检测（zsh/bash/fish/…）
  SSHHost.swift         # 解析 ~/.ssh/config 中的 Host 列表
  SSHConnectSheet.swift # 自定义 SSH 连接输入框
  Theme.swift           # Campbell 配色与字体
scripts/
  make-app.sh           # 打包 .app 与 .dmg
  gen_icon.swift        # 程序化生成应用图标
```

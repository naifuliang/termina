# Termina

A minimal, aesthetic native macOS terminal — its interface pays homage to the latest **Windows Terminal**.

[中文文档 (Chinese) →](README.zh-CN.md)

- **Tabs in the title bar**: rounded tabs, hover-to-close, separators between idle tabs, `+` button and a `⌄` profile dropdown; drag the empty area to move the window, double-click it to zoom
- **Dark acrylic material**: the tab row uses an `NSVisualEffectView` blur; the pane is Campbell black (`#0C0C0C`)
- **Campbell color scheme**: the Windows Terminal default ANSI-16 palette
- **Fonts**: prefers Cascadia Mono / CaskaydiaCove Nerd Font, falls back to SF Mono
- **Native implementation**: SwiftUI + AppKit with [SwiftTerm](https://github.com/migueldeicaza/SwiftTerm) as the emulation core (login shell, true color, mouse reporting, scrollback)
- **SSH remote connections**: reads Host entries from `~/.ssh/config` for one-click connect, optionally attaching a remote tmux session (`tmux new-session -A -s termina`); ad-hoc `user@host[:port]` connections are also supported
- **Localized UI**: English (default), 简体中文, 繁體中文, 日本語, 한국어, Français, Deutsch, Español, Português (BR), Русский, Italiano — follows the system language

## Install

One-liner — downloads the latest release and launches it directly, with no
Gatekeeper prompt (curl does not set the quarantine attribute browsers do):

```sh
curl -fsSL https://raw.githubusercontent.com/naifuliang/termina/main/install.sh | sh
```

Alternatively grab the DMG from [Releases](https://github.com/naifuliang/termina/releases); since preview builds are not notarized, macOS will ask you to allow the app under System Settings → Privacy & Security on first launch.

## Build

```sh
./scripts/make-app.sh          # produces dist/Termina.app and dist/Termina.dmg
open dist/Termina.app
```

For development:

```sh
swift run                      # debug run
```

Requires macOS 14+ and Swift 5.9+ (Command Line Tools are enough — full Xcode not needed).

## Shortcuts

| Shortcut | Action |
| --- | --- |
| ⌘T | New tab |
| ⌘W | Close current tab (closing the last tab quits) |
| ⌘⇧] / ⌘⇧[ | Next / previous tab |
| ⌘1 … ⌘9 | Jump to tab N |
| ⌘+ / ⌘− / ⌘0 | Increase / decrease / reset font size |

## Layout

```
Sources/Termina/
  TerminaApp.swift      # entry point, menus and shortcuts
  ContentView.swift     # layout, acrylic background, window styling
  TabBarView.swift      # Windows Terminal style tab strip
  TabManager.swift      # tab lifecycle and selection
  TerminalTab.swift     # one terminal session (SwiftTerm + shell/SSH process)
  ShellProfile.swift    # installed shell detection (zsh/bash/fish/…)
  SSHHost.swift         # ~/.ssh/config Host parsing
  SSHConnectSheet.swift # ad-hoc SSH connection sheet
  Theme.swift           # Campbell palette and fonts
scripts/
  make-app.sh           # .app + .dmg packaging
  gen_icon.swift        # programmatic app icon generation
```

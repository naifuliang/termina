import AppKit
import SwiftTerm

enum LaunchTarget {
    case shell(ShellProfile)
    case ssh(destination: String, port: String?, useTmux: Bool)
}

/// One terminal session: owns the SwiftTerm view and its shell process.
final class TerminalTab: ObservableObject, Identifiable {
    let id = UUID()
    let target: LaunchTarget
    let iconName: String
    @Published var title: String

    let terminalView: LocalProcessTerminalView
    weak var manager: TabManager?

    /// Set once the shell emits an OSC 0/2 title; from then on we stop
    /// deriving the title from the working directory.
    private var hasExplicitTitle = false

    init(target: LaunchTarget, fontSize: CGFloat) {
        self.target = target
        switch target {
        case .shell(let profile):
            self.title = profile.name
            self.iconName = "chevron.right.square"
        case .ssh(let destination, _, let useTmux):
            self.title = useTmux ? "\(destination) · tmux" : destination
            self.iconName = "network"
        }
        self.terminalView = LocalProcessTerminalView(
            frame: NSRect(x: 0, y: 0, width: 800, height: 480))
        configure(fontSize: fontSize)
        launch()
    }

    private var defaultTitle: String {
        switch target {
        case .shell(let profile): return profile.name
        case .ssh(let destination, _, _): return destination
        }
    }

    private func configure(fontSize: CGFloat) {
        let tv = terminalView
        tv.processDelegate = self
        tv.font = Theme.terminalFont(size: fontSize)
        tv.installColors(Theme.ansi.map { $0.swiftTermColor })
        tv.nativeForegroundColor = Theme.foreground
        tv.nativeBackgroundColor = Theme.background
        tv.caretColor = Theme.cursor
        tv.selectedTextBackgroundColor = Theme.selection
        tv.optionAsMetaKey = true
    }

    private func launch() {
        var env = ProcessInfo.processInfo.environment
        env["TERM"] = "xterm-256color"
        env["COLORTERM"] = "truecolor"
        env["TERM_PROGRAM"] = "Termina"
        if env["LANG"] == nil { env["LANG"] = "en_US.UTF-8" }

        let home = FileManager.default.homeDirectoryForCurrentUser.path

        switch target {
        case .shell(let profile):
            terminalView.startProcess(
                executable: profile.path,
                args: [],
                environment: env.map { "\($0.key)=\($0.value)" },
                // leading dash marks it as a login shell
                execName: "-" + profile.name,
                currentDirectory: home
            )
        case .ssh(let destination, let port, let useTmux):
            var args: [String] = []
            if let port { args += ["-p", port] }
            if useTmux { args += ["-t", destination, "tmux new-session -A -s termina"] }
            else { args.append(destination) }
            terminalView.startProcess(executable: "/usr/bin/ssh", args: args,
                environment: env.map { "\($0.key)=\($0.value)" },
                currentDirectory: home)
        }
    }
}

extension TerminalTab: LocalProcessTerminalViewDelegate {
    func sizeChanged(source: LocalProcessTerminalView, newCols: Int, newRows: Int) {}

    func setTerminalTitle(source: LocalProcessTerminalView, title: String) {
        DispatchQueue.main.async {
            self.hasExplicitTitle = !title.isEmpty
            self.title = title.isEmpty ? self.defaultTitle : title
        }
    }

    func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {
        guard !hasExplicitTitle,
              let directory,
              let url = URL(string: directory) else { return }
        DispatchQueue.main.async {
            let home = FileManager.default.homeDirectoryForCurrentUser.path
            let path = url.path
            self.title = path == home ? "~" : url.lastPathComponent
        }
    }

    func processTerminated(source: TerminalView, exitCode: Int32?) {
        DispatchQueue.main.async {
            self.manager?.tabDidTerminate(self)
        }
    }
}

extension NSColor {
    /// SwiftTerm colors use 16-bit components.
    var swiftTermColor: SwiftTerm.Color {
        let c = usingColorSpace(.sRGB) ?? self
        return SwiftTerm.Color(
            red: UInt16(max(0, min(1, c.redComponent)) * 65535),
            green: UInt16(max(0, min(1, c.greenComponent)) * 65535),
            blue: UInt16(max(0, min(1, c.blueComponent)) * 65535)
        )
    }
}

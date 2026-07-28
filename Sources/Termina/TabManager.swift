import AppKit
import SwiftUI

/// Owns the list of terminal tabs and the selection, like Windows
/// Terminal's tab row. Single window app → a shared instance keeps
/// menu commands trivial.
final class TabManager: ObservableObject {
    static let shared = TabManager()

    @Published private(set) var tabs: [TerminalTab] = []
    @Published var selectedID: UUID?
    @Published private(set) var fontSize: CGFloat = TabManager.defaultFontSize
    @Published var sshSheetVisible = false

    private static let defaultFontSize: CGFloat = 13

    var selectedTab: TerminalTab? {
        tabs.first { $0.id == selectedID }
    }

    /// Called once when the window appears.
    func bootstrap() {
        if tabs.isEmpty { newTab() }
    }

    // MARK: - Tab lifecycle

    func newTab(profile: ShellProfile = .default) {
        newTab(target: .shell(profile))
    }

    func newTab(target: LaunchTarget) {
        let tab = TerminalTab(target: target, fontSize: fontSize)
        tab.manager = self
        tabs.append(tab)
        selectedID = tab.id
    }

    func newSSHTab(destination: String, port: String? = nil, useTmux: Bool) {
        newTab(target: .ssh(destination: destination, port: port, useTmux: useTmux))
    }

    func select(_ tab: TerminalTab) {
        selectedID = tab.id
    }

    func selectTab(at index: Int) {
        guard tabs.indices.contains(index) else { return }
        selectedID = tabs[index].id
    }

    func selectNext() { step(by: 1) }
    func selectPrevious() { step(by: -1) }

    private func step(by delta: Int) {
        guard tabs.count > 1,
              let current = tabs.firstIndex(where: { $0.id == selectedID }) else { return }
        let next = (current + delta + tabs.count) % tabs.count
        selectedID = tabs[next].id
    }

    /// User closed the tab: kill the shell, then drop it.
    func close(_ tab: TerminalTab) {
        tab.terminalView.processDelegate = nil
        tab.terminalView.terminate()
        remove(tab)
    }

    /// The shell exited on its own (e.g. `exit`).
    func tabDidTerminate(_ tab: TerminalTab) {
        remove(tab)
    }

    private func remove(_ tab: TerminalTab) {
        guard let index = tabs.firstIndex(where: { $0.id == tab.id }) else { return }
        tabs.remove(at: index)
        if selectedID == tab.id {
            selectedID = tabs.isEmpty ? nil : tabs[min(index, tabs.count - 1)].id
        }
        if tabs.isEmpty {
            // Windows Terminal closes the window with its last tab.
            NSApp.terminate(nil)
        }
    }

    // MARK: - Font size

    func adjustFontSize(_ delta: CGFloat) {
        setFontSize(fontSize + delta)
    }

    func resetFontSize() {
        setFontSize(TabManager.defaultFontSize)
    }

    private func setFontSize(_ size: CGFloat) {
        fontSize = min(max(size, 9), 32)
        let font = Theme.terminalFont(size: fontSize)
        tabs.forEach { $0.terminalView.font = font }
    }
}

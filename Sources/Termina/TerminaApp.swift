import AppKit
import SwiftUI

@main
struct TerminaApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Window("Termina", id: "main") {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1060, height: 680)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button(tr("new_tab")) { TabManager.shared.newTab() }
                    .keyboardShortcut("t", modifiers: .command)

                Menu(tr("new_tab_with_profile")) {
                    ForEach(ShellProfile.available) { profile in
                        Button(profile.name) { TabManager.shared.newTab(profile: profile) }
                    }
                }
            }

            CommandGroup(replacing: .saveItem) {
                Button(tr("close_tab")) {
                    if let tab = TabManager.shared.selectedTab {
                        TabManager.shared.close(tab)
                    }
                }
                .keyboardShortcut("w", modifiers: .command)
            }

            CommandMenu(tr("tabs_menu")) {
                Button(tr("next_tab")) { TabManager.shared.selectNext() }
                    .keyboardShortcut("]", modifiers: [.command, .shift])
                Button(tr("previous_tab")) { TabManager.shared.selectPrevious() }
                    .keyboardShortcut("[", modifiers: [.command, .shift])

                Divider()

                ForEach(1...9, id: \.self) { number in
                    Button(tr("tab_n", number)) {
                        TabManager.shared.selectTab(at: number - 1)
                    }
                    .keyboardShortcut(
                        KeyEquivalent(Character("\(number)")), modifiers: .command)
                }
            }

            CommandGroup(after: .toolbar) {
                Button(tr("font_bigger")) { TabManager.shared.adjustFontSize(+1) }
                    .keyboardShortcut("+", modifiers: .command)
                Button(tr("font_smaller")) { TabManager.shared.adjustFontSize(-1) }
                    .keyboardShortcut("-", modifiers: .command)
                Button(tr("font_reset")) { TabManager.shared.resetFontSize() }
                    .keyboardShortcut("0", modifiers: .command)
            }
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

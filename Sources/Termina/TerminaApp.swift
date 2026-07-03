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
                Button("新建标签页") { TabManager.shared.newTab() }
                    .keyboardShortcut("t", modifiers: .command)

                Menu("使用配置新建") {
                    ForEach(ShellProfile.available) { profile in
                        Button(profile.name) { TabManager.shared.newTab(profile: profile) }
                    }
                }
            }

            CommandGroup(replacing: .saveItem) {
                Button("关闭标签页") {
                    if let tab = TabManager.shared.selectedTab {
                        TabManager.shared.close(tab)
                    }
                }
                .keyboardShortcut("w", modifiers: .command)
            }

            CommandMenu("标签页") {
                Button("下一个标签页") { TabManager.shared.selectNext() }
                    .keyboardShortcut("]", modifiers: [.command, .shift])
                Button("上一个标签页") { TabManager.shared.selectPrevious() }
                    .keyboardShortcut("[", modifiers: [.command, .shift])

                Divider()

                ForEach(1...9, id: \.self) { number in
                    Button("标签页 \(number)") {
                        TabManager.shared.selectTab(at: number - 1)
                    }
                    .keyboardShortcut(
                        KeyEquivalent(Character("\(number)")), modifiers: .command)
                }
            }

            CommandGroup(after: .toolbar) {
                Button("放大字体") { TabManager.shared.adjustFontSize(+1) }
                    .keyboardShortcut("+", modifiers: .command)
                Button("缩小字体") { TabManager.shared.adjustFontSize(-1) }
                    .keyboardShortcut("-", modifiers: .command)
                Button("实际大小") { TabManager.shared.resetFontSize() }
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

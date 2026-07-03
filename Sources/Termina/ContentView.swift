import AppKit
import SwiftTerm
import SwiftUI

struct ContentView: View {
    @ObservedObject var manager = TabManager.shared

    var body: some View {
        VStack(spacing: 0) {
            TabBarView(manager: manager)

            ZStack {
                // The pane background — Campbell black, square top edge,
                // flush with the tab row like Windows Terminal.
                Color(hex: 0x0C0C0C)

                ForEach(manager.tabs) { tab in
                    TerminalHostView(
                        terminalView: tab.terminalView,
                        isActive: manager.selectedID == tab.id
                    )
                    .padding(.leading, 10)
                    .padding(.trailing, 4)
                    .padding(.vertical, 6)
                    .opacity(manager.selectedID == tab.id ? 1 : 0)
                    .allowsHitTesting(manager.selectedID == tab.id)
                }
            }
        }
        .background {
            AcrylicBackground()
                .overlay(Color(hex: 0x0C0C0C, opacity: 0.62))
        }
        .ignoresSafeArea()
        .background(WindowConfigurator())
        .onAppear { manager.bootstrap() }
        .preferredColorScheme(.dark)
    }
}

/// Hosts a SwiftTerm view. The view is owned by the tab (created once,
/// never recreated), so switching tabs preserves the session.
struct TerminalHostView: NSViewRepresentable {
    let terminalView: LocalProcessTerminalView
    let isActive: Bool

    func makeNSView(context: Context) -> LocalProcessTerminalView {
        terminalView
    }

    func updateNSView(_ nsView: LocalProcessTerminalView, context: Context) {
        guard isActive else { return }
        DispatchQueue.main.async {
            guard let window = nsView.window,
                  window.firstResponder !== nsView else { return }
            window.makeFirstResponder(nsView)
        }
    }
}

/// Dark acrylic, i.e. an NSVisualEffectView blurring whatever is behind
/// the window — the Windows Terminal tab-row material.
struct AcrylicBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .hudWindow
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

/// One-shot window styling: hide the title, let content flow under the
/// title bar, allow dragging by the tab-row background.
struct WindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let probe = NSView()
        DispatchQueue.main.async {
            guard let window = probe.window else { return }
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.styleMask.insert(.fullSizeContentView)
            window.isMovableByWindowBackground = true
            window.minSize = NSSize(width: 600, height: 400)
            window.appearance = NSAppearance(named: .darkAqua)
            window.tabbingMode = .disallowed
        }
        return probe
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

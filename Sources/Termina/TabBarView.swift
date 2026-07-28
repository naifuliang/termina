import SwiftUI

/// The title-bar tab strip, styled after Windows Terminal:
/// compact rounded tabs, separators between idle tabs, a "+" button
/// and a chevron dropdown for profiles.
struct TabBarView: View {
    @ObservedObject var manager: TabManager

    var body: some View {
        HStack(spacing: 4) {
            // room for the macOS traffic lights
            Spacer().frame(width: 70)

            HStack(spacing: 0) {
                ForEach(Array(manager.tabs.enumerated()), id: \.element.id) { index, tab in
                    HStack(spacing: 0) {
                        TabItemView(
                            tab: tab,
                            isSelected: manager.selectedID == tab.id,
                            select: { manager.select(tab) },
                            close: { manager.close(tab) }
                        )
                        if showsSeparator(after: index) {
                            Rectangle()
                                .fill(Color.white.opacity(0.18))
                                .frame(width: 1, height: 14)
                                .padding(.horizontal, 2)
                        } else {
                            Spacer().frame(width: 5)
                        }
                    }
                }
            }

            NewTabButton(manager: manager)

            Spacer(minLength: 8)
        }
        .padding(.top, 6)
        .padding(.bottom, 4)
        .padding(.horizontal, 8)
        .frame(height: Theme.tabBarHeight)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .background(TitleBarGestureView())
    }

    /// Windows Terminal draws a thin separator between two adjacent
    /// unselected tabs, but not next to the selected one.
    private func showsSeparator(after index: Int) -> Bool {
        guard index < manager.tabs.count - 1 else { return false }
        let current = manager.tabs[index]
        let next = manager.tabs[index + 1]
        return current.id != manager.selectedID && next.id != manager.selectedID
    }
}

private struct TabItemView: View {
    @ObservedObject var tab: TerminalTab
    let isSelected: Bool
    let select: () -> Void
    let close: () -> Void

    @State private var hovering = false
    @State private var hoveringClose = false

    var body: some View {
        Button(action: select) {
        HStack(spacing: 6) {
            Image(systemName: tab.iconName)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(isSelected ? Color.white.opacity(0.85) : Color.white.opacity(0.45))

            Text(tab.title)
                .font(.system(size: 12, weight: isSelected ? .medium : .regular))
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundStyle(isSelected ? Color.white.opacity(0.95) : Color.white.opacity(0.55))

            Spacer(minLength: 4)

            if isSelected || hovering {
                Button(action: close) {
                    Image(systemName: "xmark")
                        .font(.system(size: 8.5, weight: .bold))
                        .foregroundStyle(Color.white.opacity(hoveringClose ? 0.95 : 0.55))
                        .frame(width: 18, height: 18)
                        .background(
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(Color.white.opacity(hoveringClose ? 0.16 : 0))
                        )
                }
                .buttonStyle(.plain)
                .onHover { hoveringClose = $0 }
            } else {
                Spacer().frame(width: 18, height: 18)
            }
        }
        .padding(.leading, 10)
        .padding(.trailing, 5)
        .frame(minWidth: Theme.tabMinWidth, maxWidth: Theme.tabMaxWidth)
        .frame(height: Theme.tabHeight)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(backgroundColor)
        )
        .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .animation(.easeOut(duration: 0.12), value: hovering)
        .animation(.easeOut(duration: 0.12), value: isSelected)
    }

    private var backgroundColor: Color {
        if isSelected { return Color.white.opacity(0.14) }
        if hovering { return Color.white.opacity(0.06) }
        return .clear
    }
}

private struct NewTabButton: View {
    @ObservedObject var manager: TabManager
    @State private var hoveringPlus = false
    @State private var hoveringChevron = false

    var body: some View {
        HStack(spacing: 0) {
            Button(action: { manager.newTab() }) {
                Image(systemName: "plus")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.white.opacity(hoveringPlus ? 0.95 : 0.6))
                    .frame(width: 28, height: Theme.tabHeight - 4)
                    .background(
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(Color.white.opacity(hoveringPlus ? 0.12 : 0))
                    )
            }
            .buttonStyle(.plain)
            .onHover { hoveringPlus = $0 }
            .help(tr("new_tab_help"))

            Menu {
                ForEach(ShellProfile.available) { profile in
                    Button(profile.name) { manager.newTab(profile: profile) }
                }
                if !SSHHost.all.isEmpty {
                    Divider()
                    Menu(tr("ssh_connections")) {
                        ForEach(SSHHost.all) { host in
                            Menu(host.alias) {
                                Button(tr("ssh_connect")) { manager.newSSHTab(destination: host.alias, useTmux: false) }
                                Button(tr("ssh_connect_tmux")) { manager.newSSHTab(destination: host.alias, useTmux: true) }
                            }
                        }
                    }
                }
                Button(tr("ssh_custom")) { manager.sshSheetVisible = true }
                Divider()
                Button(tr("font_bigger") + "  ⌘+") { manager.adjustFontSize(+1) }
                Button(tr("font_smaller") + "  ⌘−") { manager.adjustFontSize(-1) }
                Button(tr("font_reset") + "  ⌘0") { manager.resetFontSize() }
            } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(hoveringChevron ? 0.95 : 0.6))
                    .frame(width: 22, height: Theme.tabHeight - 4)
                    .background(
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(Color.white.opacity(hoveringChevron ? 0.12 : 0))
                    )
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()
            .onHover { hoveringChevron = $0 }
        }
        .padding(.leading, 4)
    }
}

import SwiftUI

/// A minimal sheet for connecting to an ad-hoc SSH destination that
/// isn't necessarily in ~/.ssh/config.
struct SSHConnectSheet: View {
    @ObservedObject var manager: TabManager
    @Environment(\.dismiss) private var dismiss

    @State private var destination = ""
    @State private var useTmux = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(tr("ssh_sheet_title"))
                .font(.headline)

            TextField("user@host[:port]", text: $destination)
                .textFieldStyle(.roundedBorder)
                .onSubmit { connect() }

            VStack(alignment: .leading, spacing: 4) {
                Toggle(tr("ssh_tmux_toggle"), isOn: $useTmux)
                Text(tr("ssh_tmux_caption"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Spacer()
                Button(tr("cancel")) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button(tr("ssh_connect")) { connect() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(destination.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(20)
        .frame(width: 380)
    }

    private func connect() {
        let trimmed = destination.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        var host = trimmed
        var port: String?

        // Only split on ":" when it appears exactly once, so we don't
        // mangle bare (bracket-less) IPv6 addresses.
        let parts = trimmed.split(separator: ":", omittingEmptySubsequences: false)
        if parts.count == 2 {
            let candidatePort = String(parts[1])
            if !candidatePort.isEmpty, candidatePort.allSatisfy({ $0.isNumber }) {
                host = String(parts[0])
                port = candidatePort
            }
        }

        manager.newSSHTab(destination: host, port: port, useTmux: useTmux)
        dismiss()
    }
}

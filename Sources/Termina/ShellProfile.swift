import Foundation

/// A launchable shell, akin to a Windows Terminal profile.
struct ShellProfile: Identifiable, Hashable {
    let name: String
    let path: String

    var id: String { path }

    /// The user's login shell, as reported by the environment.
    static var `default`: ShellProfile {
        let path = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"
        return ShellProfile(name: displayName(for: path), path: path)
    }

    /// Shells actually present on this machine, login shell first.
    static let available: [ShellProfile] = {
        var seen = Set<String>()
        var result: [ShellProfile] = []
        let candidates = [ShellProfile.default.path,
                          "/bin/zsh", "/bin/bash", "/bin/dash", "/bin/sh",
                          "/opt/homebrew/bin/fish", "/usr/local/bin/fish",
                          "/opt/homebrew/bin/nu", "/usr/local/bin/nu"]
        for path in candidates {
            guard !seen.contains(path),
                  FileManager.default.isExecutableFile(atPath: path) else { continue }
            seen.insert(path)
            result.append(ShellProfile(name: displayName(for: path), path: path))
        }
        return result
    }()

    private static func displayName(for path: String) -> String {
        (path as NSString).lastPathComponent
    }
}

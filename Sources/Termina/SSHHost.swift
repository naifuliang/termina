import Foundation

/// A concrete Host entry from ~/.ssh/config.
struct SSHHost: Identifiable, Hashable {
    let alias: String
    var id: String { alias }

    static let all: [SSHHost] = loadFromSSHConfig()

    static func loadFromSSHConfig() -> [SSHHost] {
        let path = (NSHomeDirectory() as NSString).appendingPathComponent(".ssh/config")
        guard let text = try? String(contentsOfFile: path, encoding: .utf8) else { return [] }
        var result: [SSHHost] = []
        var seen = Set<String>()
        for line in text.split(separator: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.lowercased().hasPrefix("host "), !trimmed.hasPrefix("#") else { continue }
            let aliases = trimmed.dropFirst(5).split(separator: " ")
            for alias in aliases {
                let name = String(alias)
                // skip patterns and negations
                guard !name.contains("*"), !name.contains("?"), !name.hasPrefix("!"),
                      !seen.contains(name) else { continue }
                seen.insert(name)
                result.append(SSHHost(alias: name))
            }
        }
        return result
    }
}

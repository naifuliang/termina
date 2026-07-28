import Foundation

/// Localized string lookup in the SPM resource bundle.
func tr(_ key: String) -> String {
    NSLocalizedString(key, bundle: .module, comment: "")
}

func tr(_ key: String, _ args: CVarArg...) -> String {
    String(format: tr(key), arguments: args)
}

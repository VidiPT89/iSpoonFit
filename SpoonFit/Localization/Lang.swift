import Foundation
import Observation

enum Lang: String, CaseIterable {
    case pt, en

    var shortLabel: String {
        switch self {
        case .pt: return "PT"
        case .en: return "EN"
        }
    }

    var accessibilityName: String {
        switch self {
        case .pt: return "Português"
        case .en: return "English"
        }
    }

    /// Locale used by the spoken countdown and by date formatting.
    var localeIdentifier: String {
        switch self {
        case .pt: return "pt-PT"
        case .en: return "en-US"
        }
    }

    var locale: Locale { Locale(identifier: localeIdentifier) }
}

/// App language, independent of the device locale and persisted across
/// launches. Defaults to European Portuguese.
@Observable
final class LocalizationManager {
    static let shared = LocalizationManager()

    private let key = "app.language"

    var current: Lang {
        didSet { UserDefaults.standard.set(current.rawValue, forKey: key) }
    }

    private init() {
        if let raw = UserDefaults.standard.string(forKey: key), let lang = Lang(rawValue: raw) {
            current = lang
        } else {
            current = .pt
        }
    }

    func toggle() {
        current = current == .pt ? .en : .pt
    }

    func t(_ key: String) -> String {
        Translations.table[key]?[current] ?? key
    }

    func t(_ key: String, _ arguments: CVarArg...) -> String {
        String(format: t(key), locale: current.locale, arguments: arguments)
    }
}

/// Global shorthand used by every view. Reading it inside a `body` makes that
/// view re-render when the language changes, because `LocalizationManager` is
/// observable and `current` is read on each lookup.
func t(_ key: String) -> String {
    LocalizationManager.shared.t(key)
}

func t(_ key: String, _ arguments: CVarArg...) -> String {
    String(
        format: LocalizationManager.shared.t(key),
        locale: LocalizationManager.shared.current.locale,
        arguments: arguments
    )
}

/// Nil when the key has no entry, which is how optional coaching sections
/// (a common mistake, a caution note) decide whether to show at all.
func tIfPresent(_ key: String) -> String? {
    Translations.table[key]?[LocalizationManager.shared.current]
}

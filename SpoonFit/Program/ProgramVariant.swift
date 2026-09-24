import Foundation

/// Which version of the 28-day program an account follows. Every account
/// starts on `standard`; the admin can assign another one, either ahead of
/// time through an invite or later from the admin panel.
enum ProgramVariant: String, CaseIterable, Identifiable {
    /// The app's own program: the same four stretches, two minutes, every day.
    case standard
    /// Ana's "Desafio 28 dias", exactly as written: the same workouts, but
    /// week 1 closes with two one-minute stretches chosen for each day, and
    /// from day 5 the stretches are held 30 seconds per side.
    case anaChallenge

    var id: String { rawValue }
    var titleKey: String { "variant.\(rawValue)" }
    var descriptionKey: String { "variant.\(rawValue).desc" }

    /// Unknown or missing ids fall back to the standard program.
    init(id: String?) {
        self = id.flatMap(ProgramVariant.init(rawValue:)) ?? .standard
    }

    var days: [ProgramDay] {
        switch self {
        case .standard: return ProgramData.days
        case .anaChallenge: return Self.anaChallengeDays
        }
    }

    func day(at index: Int) -> ProgramDay? {
        guard index >= 1, index <= days.count else { return nil }
        return days[index - 1]
    }

    func days(inWeek week: Int) -> [ProgramDay] {
        days.filter { $0.week == week }
    }

    // MARK: - Ana's challenge

    private static let anaChallengeDays: [ProgramDay] = ProgramData.days.map { day in
        var copy = day
        copy.cooldown = anaCooldown(forDay: day.index)
        return copy
    }

    private static func step(_ id: ExerciseID, _ seconds: Int) -> CooldownStep {
        CooldownStep(ref: ExerciseRef(id), seconds: seconds)
    }

    /// The stretches exactly as the plan lists them.
    static func anaCooldown(forDay index: Int) -> [CooldownStep] {
        switch index {
        case 1: return [step(.childsPose, 60), step(.hamstringStretch, 60)]
        case 2: return [step(.figureFour, 60), step(.quadStretch, 60)]
        case 3: return [step(.childsPose, 60), step(.hipFlexorStretch, 60)]
        case 4: return [step(.sideStretch, 60), step(.hamstringStretch, 60)]
        // "Termina com 2 minutos de alongamentos completos."
        case ProgramData.totalDays: return ProgramData.cooldown
        // "Posição da criança 30 s; figura 4, quadríceps e posterior da
        // coxa 30 s por lado."
        default:
            return [
                step(.childsPose, 30),
                step(.figureFour, 60),
                step(.quadStretch, 60),
                step(.hamstringStretch, 60)
            ]
        }
    }
}

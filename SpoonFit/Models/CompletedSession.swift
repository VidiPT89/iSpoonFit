import Foundation
import SwiftData

/// One finished workout. Repeating a day adds another row, so the history is
/// a full log rather than a set of flags.
@Model
final class CompletedSession {
    var dayIndex: Int
    var date: Date
    var durationSeconds: Int
    var lowEnergy: Bool
    var energy: Int?
    var discomfort: Int?
    var note: String?

    init(
        dayIndex: Int,
        date: Date = Date(),
        durationSeconds: Int,
        lowEnergy: Bool = false,
        energy: Int? = nil,
        discomfort: Int? = nil,
        note: String? = nil
    ) {
        self.dayIndex = dayIndex
        self.date = date
        self.durationSeconds = durationSeconds
        self.lowEnergy = lowEnergy
        self.energy = energy
        self.discomfort = discomfort
        self.note = note
    }

    var minutes: Int { max(1, Int((Double(durationSeconds) / 60).rounded())) }
}

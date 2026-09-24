import Foundation

/// Renders a day or a week as plain text for the system share sheet, in
/// whichever language the app is currently showing.
enum PlanTextExporter {
    static func text(for day: ProgramDay, lowEnergy: Bool = false) -> String {
        let params = SessionBuilder.params(for: day, lowEnergy: lowEnergy)
        var lines: [String] = []

        lines.append("\(t("app.name")) · \(t("week.n", day.week)) · \(t("day.n", day.index))")
        lines.append(t(day.titleKey))
        lines.append("")
        lines.append("\(t("params.work")) \(params.work)s · \(t("params.rest")) \(params.rest)s · \(t("params.rounds")) \(params.rounds)")
        lines.append("\(SessionBuilder.estimatedMinutes(for: day, lowEnergy: lowEnergy)) min")
        if lowEnergy {
            lines.append(t("lowEnergy.title"))
        }
        lines.append("")

        lines.append(t("block.warmup"))
        for exercise in ProgramData.warmup {
            lines.append("· \(exercise.displayName) — \(ProgramData.warmupSeconds)s")
        }
        lines.append("")

        lines.append(t("block.workout"))
        for exercise in day.exercises {
            let entry = lowEnergy ? exercise.softened : exercise
            lines.append("· \(entry.displayName) — \(params.work)s")
        }
        lines.append("")

        lines.append(t("block.cooldown"))
        for entry in day.cooldown {
            lines.append("· \(entry.ref.displayName) — \(entry.seconds)s")
        }
        lines.append("")
        lines.append(t("share.footer"))

        return lines.joined(separator: "\n")
    }

    static func text(forWeek week: Int, variant: ProgramVariant = .standard) -> String {
        let params = ProgramData.params(forWeek: week)
        var lines: [String] = []

        lines.append("\(t("app.name")) · \(t("week.n", week))")
        lines.append("\(t(params.phaseKey)) — \(t(params.phaseDescriptionKey))")
        lines.append("\(t("params.work")) \(params.work)s · \(t("params.rest")) \(params.rest)s · \(t("params.rounds")) \(params.rounds)")
        lines.append("")

        for day in variant.days(inWeek: week) {
            lines.append("\(t(day.weekdayKey)) · \(t("day.n", day.index)) — \(t(day.titleKey))")
            for exercise in day.exercises {
                lines.append("   · \(exercise.displayName)")
            }
            lines.append("")
        }

        lines.append(t("share.footer"))
        return lines.joined(separator: "\n")
    }
}

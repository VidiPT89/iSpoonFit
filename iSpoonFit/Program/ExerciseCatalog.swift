import Foundation

/// Every exercise the program can use. The catalog is static data: names and
/// coaching text live in the translation table, keyed off each `ExerciseID`.
enum ExerciseCatalog {
    static let all: [Exercise] = [
        // MARK: Warm-up
        Exercise(
            id: .marchInPlace, nameKey: "exercise.marchInPlace", category: .warmup,
            motion: .marchInPlace, isUnilateral: false, isAlternating: true,
            muscleKeys: ["muscle.hipFlexors", "muscle.core"]
        ),
        Exercise(
            id: .gentleSquat, nameKey: "exercise.gentleSquat", category: .warmup,
            motion: .gentleSquat, isUnilateral: false, isAlternating: false,
            muscleKeys: ["muscle.quads", "muscle.glutes"]
        ),
        Exercise(
            id: .hipCircles, nameKey: "exercise.hipCircles", category: .warmup,
            motion: .hipCircle, isUnilateral: false, isAlternating: false,
            muscleKeys: ["muscle.hipFlexors", "muscle.core"]
        ),
        Exercise(
            id: .armSwings, nameKey: "exercise.armSwings", category: .warmup,
            motion: .armSwing, isUnilateral: false, isAlternating: false,
            muscleKeys: ["muscle.shoulders", "muscle.chest"]
        ),

        // MARK: Legs and glutes
        Exercise(
            id: .sumoSquat, nameKey: "exercise.sumoSquat", category: .legsGlutes,
            motion: .sumoSquat, isUnilateral: false, isAlternating: false,
            muscleKeys: ["muscle.adductors", "muscle.glutes", "muscle.quads"]
        ),
        Exercise(
            id: .squat, nameKey: "exercise.squat", category: .legsGlutes,
            motion: .squat, isUnilateral: false, isAlternating: false,
            muscleKeys: ["muscle.quads", "muscle.glutes"]
        ),
        Exercise(
            id: .shortLunge, nameKey: "exercise.shortLunge", category: .legsGlutes,
            motion: .shortLunge, isUnilateral: false, isAlternating: true,
            muscleKeys: ["muscle.quads", "muscle.glutes"]
        ),
        Exercise(
            id: .alternatingLunge, nameKey: "exercise.alternatingLunge", category: .legsGlutes,
            motion: .lunge, isUnilateral: false, isAlternating: true,
            muscleKeys: ["muscle.quads", "muscle.glutes"]
        ),
        Exercise(
            id: .wallSit, nameKey: "exercise.wallSit", category: .legsGlutes,
            motion: .wallSit, isUnilateral: false, isAlternating: false,
            muscleKeys: ["muscle.quads", "muscle.glutes"]
        ),
        Exercise(
            id: .calfRaise, nameKey: "exercise.calfRaise", category: .legsGlutes,
            motion: .calfRaise, isUnilateral: false, isAlternating: false,
            muscleKeys: ["muscle.calves"]
        ),
        Exercise(
            id: .sideLegRaise, nameKey: "exercise.sideLegRaise", category: .legsGlutes,
            motion: .sideLegRaise, isUnilateral: true, isAlternating: false,
            muscleKeys: ["muscle.gluteMedius", "muscle.abductors"]
        ),

        // MARK: Core and glutes on the floor
        Exercise(
            id: .gluteBridge, nameKey: "exercise.gluteBridge", category: .core,
            motion: .bridge, isUnilateral: false, isAlternating: false,
            muscleKeys: ["muscle.glutes", "muscle.hamstrings", "muscle.deepCore"]
        ),
        Exercise(
            id: .marchingBridge, nameKey: "exercise.marchingBridge", category: .core,
            motion: .marchingBridge, isUnilateral: false, isAlternating: true,
            muscleKeys: ["muscle.glutes", "muscle.deepCore", "muscle.hamstrings"]
        ),
        Exercise(
            id: .birdDog, nameKey: "exercise.birdDog", category: .core,
            motion: .birdDog, isUnilateral: false, isAlternating: true,
            muscleKeys: ["muscle.deepCore", "muscle.glutes", "muscle.lowerBack"]
        ),
        Exercise(
            id: .deadBug, nameKey: "exercise.deadBug", category: .core,
            motion: .deadBug, isUnilateral: false, isAlternating: true,
            muscleKeys: ["muscle.deepCore", "muscle.transverseAbdominis"]
        ),
        Exercise(
            id: .heelTaps, nameKey: "exercise.heelTaps", category: .core,
            motion: .heelTap, isUnilateral: false, isAlternating: true,
            muscleKeys: ["muscle.deepCore", "muscle.transverseAbdominis"]
        ),
        Exercise(
            id: .pelvicTilt, nameKey: "exercise.pelvicTilt", category: .core,
            motion: .pelvicTilt, isUnilateral: false, isAlternating: false,
            muscleKeys: ["muscle.transverseAbdominis", "muscle.pelvicFloor"]
        ),

        // MARK: Stretches
        Exercise(
            id: .childsPose, nameKey: "stretch.childsPose", category: .stretch,
            motion: .childsPose, isUnilateral: false, isAlternating: false,
            muscleKeys: ["muscle.lowerBack", "muscle.spine"]
        ),
        Exercise(
            id: .figureFour, nameKey: "stretch.figureFour", category: .stretch,
            motion: .figureFour, isUnilateral: true, isAlternating: false,
            muscleKeys: ["muscle.glutes", "muscle.gluteMedius"]
        ),
        Exercise(
            id: .quadStretch, nameKey: "stretch.quad", category: .stretch,
            motion: .quadStretch, isUnilateral: true, isAlternating: false,
            muscleKeys: ["muscle.quads"]
        ),
        Exercise(
            id: .hamstringStretch, nameKey: "stretch.hamstring", category: .stretch,
            motion: .hamstringStretch, isUnilateral: true, isAlternating: false,
            muscleKeys: ["muscle.hamstrings"]
        ),
        Exercise(
            id: .hipFlexorStretch, nameKey: "stretch.hipFlexor", category: .stretch,
            motion: .hipFlexorStretch, isUnilateral: true, isAlternating: false,
            muscleKeys: ["muscle.hipFlexors", "muscle.quads"]
        ),
        Exercise(
            id: .sideStretch, nameKey: "stretch.side", category: .stretch,
            motion: .sideStretch, isUnilateral: true, isAlternating: false,
            muscleKeys: ["muscle.obliques", "muscle.lowerBack"]
        )
    ]

    private static let byID: [ExerciseID: Exercise] = Dictionary(
        uniqueKeysWithValues: all.map { ($0.id, $0) }
    )

    static func exercise(_ id: ExerciseID) -> Exercise {
        // Every ID has an entry; the fallback only keeps the API non-optional.
        byID[id] ?? all[0]
    }

    static func exercises(in category: ExerciseCategory) -> [Exercise] {
        all.filter { $0.category == category }
    }
}

extension ExerciseRef {
    /// The animation to play, after the day's modifiers are taken into account.
    /// A pulsed squat gets its own short-travel motion rather than the full one.
    var motion: ExerciseMotionKind {
        let base = catalogEntry.motion
        if modifiers.contains(.pulse), base == .squat { return .pulseSquat }
        return base
    }
}

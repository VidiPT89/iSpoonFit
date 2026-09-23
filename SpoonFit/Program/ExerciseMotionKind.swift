import Foundation

/// One stick-figure motion archetype per exercise. Every drawing in the app
/// goes through this enum, so there are no bundled videos or images and the
/// whole catalog stays offline and weightless.
enum ExerciseMotionKind: String, CaseIterable {
    // Standing
    case marchInPlace
    case squat
    case sumoSquat
    case pulseSquat
    case hipCircle
    case armSwing
    case lunge
    case wallSit
    case calfRaise
    case quadStretch

    // On the floor
    case sideLegRaise
    case bridge
    case marchingBridge
    case birdDog
    case deadBug
    case heelTap
    case pelvicTilt
    case childsPose
    case figureFour
    case hamstringStretch

    /// Floor exercises are drawn lying along the x-axis, which also raises the
    /// ground line so the figure still sits on it.
    var isHorizontal: Bool {
        switch self {
        case .marchInPlace, .squat, .sumoSquat, .pulseSquat, .hipCircle,
             .armSwing, .lunge, .wallSit, .calfRaise, .quadStretch:
            return false
        default:
            return true
        }
    }

    /// Floor work is drawn on a mat; standing work is not.
    var usesMat: Bool { isHorizontal }

    var prop: ExerciseProp? {
        switch self {
        case .wallSit: return .wall
        case .calfRaise, .lunge, .quadStretch: return .chair
        case .hamstringStretch: return .towel
        default: return nil
        }
    }

    /// Isometric holds get a slow halo that expands and contracts, standing in
    /// for the breath the instructions ask for.
    var hasBreathingGlow: Bool {
        switch self {
        case .wallSit, .childsPose: return true
        default: return false
        }
    }

    var defaultCycleDuration: Double {
        switch self {
        case .pulseSquat: return 0.6
        case .wallSit, .childsPose: return 4.0
        case .hipCircle: return 3.0
        case .marchInPlace: return 1.2
        default: return 2.0
        }
    }
}

/// Simple scene furniture drawn behind or beside the figure.
enum ExerciseProp {
    case chair
    case wall
    case towel
}

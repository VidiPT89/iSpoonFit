import AVFoundation
import Foundation
#if canImport(AudioToolbox)
import AudioToolbox
#endif

/// Cues for the guided session. Sounds are system sounds and the countdown is
/// spoken by the system voice, so the app ships no audio files and stays
/// completely offline. Everything mixes with whatever music is already playing.
@MainActor
final class SessionAudio {
    static let shared = SessionAudio()

    private let synthesizer = AVSpeechSynthesizer()
    private var sessionConfigured = false

    private init() {}

    // MARK: Preferences

    private static let soundKey = "soundsEnabled"
    private static let voiceKey = "voiceEnabled"

    static var soundsEnabled: Bool {
        get { UserDefaults.standard.object(forKey: soundKey) == nil ? true : UserDefaults.standard.bool(forKey: soundKey) }
        set { UserDefaults.standard.set(newValue, forKey: soundKey) }
    }

    static var voiceEnabled: Bool {
        get { UserDefaults.standard.object(forKey: voiceKey) == nil ? true : UserDefaults.standard.bool(forKey: voiceKey) }
        set { UserDefaults.standard.set(newValue, forKey: voiceKey) }
    }

    // MARK: Lifecycle

    func activate() {
        guard !sessionConfigured else { return }
        sessionConfigured = true
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, mode: .default, options: [.mixWithOthers, .duckOthers])
        try? session.setActive(true)
    }

    func deactivate() {
        synthesizer.stopSpeaking(at: .immediate)
        sessionConfigured = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    // MARK: Cues

    enum Cue {
        case countdownTick
        case workStart
        case restStart
        case switchSide
        case finished

        /// Identifiers from the system sound library, so nothing is bundled.
        var systemSoundID: SystemSoundID {
            switch self {
            case .countdownTick: return 1103
            case .workStart: return 1113
            case .restStart: return 1114
            case .switchSide: return 1306
            case .finished: return 1025
            }
        }
    }

    func play(_ cue: Cue) {
        guard Self.soundsEnabled else { return }
        #if canImport(AudioToolbox)
        AudioServicesPlaySystemSound(cue.systemSoundID)
        #endif
    }

    func speak(_ text: String) {
        guard Self.voiceEnabled, !text.isEmpty else { return }
        activate()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: LocalizationManager.shared.current.localeIdentifier)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.96
        utterance.preUtteranceDelay = 0
        synthesizer.speak(utterance)
    }

    func speak(key: String) {
        speak(t(key))
    }

    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}

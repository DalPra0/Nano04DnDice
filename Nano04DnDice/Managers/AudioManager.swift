
import AVFoundation
import SwiftUI
import Combine

// MARK: - Sound Types
/// Enumeration of all available sound effects in the app
enum SoundType: String, CaseIterable, Codable {
    case diceRoll = "dice_roll"
    case critical = "critical"
    case fumble = "fumble"
    case successChime = "success_chime"
    case failureDrone = "failure_drone"
    
    var displayName: String {
        switch self {
        case .diceRoll: return "Dice Roll"
        case .critical: return "Critical Hit"
        case .fumble: return "Fumble"
        case .successChime: return "Success"
        case .failureDrone: return "Failure"
        }
    }
    
    var defaultFileName: String {
        return self.rawValue
    }
}

struct CustomSound: Codable, Identifiable {
    let id: UUID
    let type: SoundType
    let fileName: String
    let isCustom: Bool
    
    init(type: SoundType, fileName: String? = nil, isCustom: Bool = false) {
        self.id = UUID()
        self.type = type
        self.fileName = fileName ?? type.defaultFileName
        self.isCustom = isCustom
    }
}

// MARK: - AudioManager
/// Singleton manager for all audio playback in the app
/// Handles sound preloading, custom sounds, and volume control
/// Uses AVAudioSession for background audio support
class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    /// Dictionary of preloaded AVAudioPlayer instances for instant playback
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    
    @Published var isSFXEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSFXEnabled, forKey: "isSFXEnabled")
        }
    }
    
    @Published var masterVolume: Float {
        didSet {
            UserDefaults.standard.set(masterVolume, forKey: "masterVolume")
            updateAllPlayersVolume()
        }
    }
    
    @Published var customSounds: [SoundType: CustomSound] = [:] {
        didSet {
            saveCustomSounds()
        }
    }
    
    private let userDefaultsKey = "customSounds"
    
    init() {
        self.isSFXEnabled = UserDefaults.standard.object(forKey: "isSFXEnabled") as? Bool ?? true
        self.masterVolume = UserDefaults.standard.object(forKey: "masterVolume") as? Float ?? 0.7
        
        loadCustomSounds()
        setupAudioSession()
        preloadSounds()
    }
    
    private func setupAudioSession() {
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("⚠️ Erro ao configurar sessão de áudio: \(error)")
        }
        #endif
    }
    
    /// Preload all sound files into memory for instant playback
    /// Called on init and when custom sounds change
    private func preloadSounds() {
        // Clear existing players to free memory
        audioPlayers.removeAll()
        
        for type in SoundType.allCases {
            let soundFileName = customSounds[type]?.fileName ?? type.defaultFileName
            if let player = createPlayer(for: soundFileName) {
                audioPlayers[type.rawValue] = player
                print("✅ Preloaded sound: \(soundFileName) for \(type.displayName)")
            }
        }
    }
    
    private func loadCustomSounds() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([SoundType: CustomSound].self, from: data) {
            customSounds = decoded
        } else {
            // Initialize with default sounds
            for type in SoundType.allCases {
                customSounds[type] = CustomSound(type: type)
            }
        }
    }
    
    private func saveCustomSounds() {
        if let encoded = try? JSONEncoder().encode(customSounds) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func updateAllPlayersVolume() {
        for player in audioPlayers.values {
            player.volume = masterVolume
        }
    }
    
    func setCustomSound(for type: SoundType, fileName: String) {
        customSounds[type] = CustomSound(type: type, fileName: fileName, isCustom: true)
        preloadSounds()
    }
    
    func resetToDefault(for type: SoundType) {
        customSounds[type] = CustomSound(type: type)
        preloadSounds()
    }
    
    func resetAllToDefaults() {
        for type in SoundType.allCases {
            customSounds[type] = CustomSound(type: type)
        }
        preloadSounds()
    }
    
    private func createPlayer(for soundName: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3", subdirectory: "Audio") ??
                        Bundle.main.url(forResource: soundName, withExtension: "wav", subdirectory: "Audio") ??
                        Bundle.main.url(forResource: soundName, withExtension: "mp3") ??
                        Bundle.main.url(forResource: soundName, withExtension: "wav") else {
            print("⚠️ SFX não encontrado: \(soundName)")
            return nil
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            return player
        } catch {
            print("⚠️ Erro ao carregar SFX \(soundName): \(error)")
            return nil
        }
    }
    
    func playSFX(_ soundType: SoundType, volume: Float = 1.0) {
        guard isSFXEnabled else { return }
        
        if let player = audioPlayers[soundType.rawValue] {
            player.volume = masterVolume * volume
            player.currentTime = 0
            player.play()
            print("🔊 Playing SFX: \(soundType.displayName)")
        } else {
            print("⚠️ SFX não foi preloaded: \(soundType.rawValue)")
            let soundFileName = customSounds[soundType]?.fileName ?? soundType.defaultFileName
            if let newPlayer = createPlayer(for: soundFileName) {
                audioPlayers[soundType.rawValue] = newPlayer
                newPlayer.volume = masterVolume * volume
                newPlayer.play()
            }
        }
    }
    
    
    func playDiceRoll() {
        playSFX(.diceRoll, volume: 0.8)
    }
    
    func playCritical() {
        playSFX(.successChime, volume: 1.0)
    }
    
    func playFumble() {
        playSFX(.failureDrone, volume: 1.0)
    }
}

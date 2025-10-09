//
//  AudioManager.swift
//  Nano04DnDice
//
//  Sistema de áudio para dados de RPG
//

import AVFoundation
import SwiftUI
import Combine

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    private var sfxPlayer: AVAudioPlayer?
    
    @Published var isSFXEnabled = true
    @Published var masterVolume: Float = 0.7
    
    init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("⚠️ Erro ao configurar sessão de áudio: \(error)")
        }
    }
    
    // MARK: - Dice Sounds
    
    func playSFX(_ soundName: String, volume: Float = 1.0) {
        guard isSFXEnabled else { return }
        
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3", subdirectory: "Audio") ??
                        Bundle.main.url(forResource: soundName, withExtension: "wav", subdirectory: "Audio") ??
                        Bundle.main.url(forResource: soundName, withExtension: "mp3") ??
                        Bundle.main.url(forResource: soundName, withExtension: "wav") else {
            print("⚠️ SFX não encontrado: \(soundName)")
            return
        }
        
        do {
            sfxPlayer = try AVAudioPlayer(contentsOf: url)
            sfxPlayer?.volume = masterVolume * volume
            sfxPlayer?.play()
            
            print("Playing SFX: \(soundName)")
        } catch {
            print("⚠️ Erro ao tocar SFX: \(error)")
        }
    }
    
    // MARK: - Specific Dice Sounds
    
    func playDiceRoll() {
        playSFX("dice_roll", volume: 0.8)
    }
    
    func playDiceResult(success: Bool) {
        playSFX(success ? "success_chime" : "failure_drone", volume: 0.9)
    }
    
    func playCritical() {
        playSFX("critical", volume: 1.0)
    }
    
    func playFumble() {
        playSFX("fumble", volume: 1.0)
    }
}


import SwiftUI

struct AudioSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var audioManager = AudioManager.shared
    @ObservedObject var themeManager: ThemeManager
    
    @State private var showingSoundPicker = false
    @State private var selectedSoundType: SoundType?
    
    private var accentColor: Color {
        themeManager.currentTheme.accentColor.color
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            RadialGradient(
                colors: [Color.black.opacity(0.8), Color.black],
                center: .center,
                startRadius: 100,
                endRadius: 500
            ).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Header
                customHeader
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        mainIconHeader
                        
                        // Master Controls
                        VStack(alignment: .leading, spacing: 16) {
                            sectionLabel("MASTER CONTROLS")
                            
                            VStack(spacing: 1) {
                                sfxToggleRow
                                volumeSliderRow
                            }
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                        }
                        
                        // Sound Customization
                        VStack(alignment: .leading, spacing: 16) {
                            sectionLabel("SOUNDSCAPES")
                            
                            VStack(spacing: 12) {
                                ForEach(SoundType.allCases, id: \.self) { soundType in
                                    SoundCustomRow(
                                        soundType: soundType,
                                        customSound: audioManager.customSounds[soundType],
                                        accentColor: accentColor,
                                        onTest: { audioManager.playSFX(soundType) },
                                        onCustomize: {
                                            selectedSoundType = soundType
                                            showingSoundPicker = true
                                        },
                                        onReset: { audioManager.resetToDefault(for: soundType) }
                                    )
                                }
                            }
                        }
                        
                        resetAllButton
                            .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private var customHeader: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(accentColor)
                        .frame(width: 44, height: 44)
                }
                
                Spacer()
                
                Text("AUDIO SETTINGS")
                    .font(.custom("PlayfairDisplay-Black", size: 18))
                    .foregroundColor(.white)
                    .tracking(2)
                
                Spacer()
                
                // Placeholder to balance HStack
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            LinearGradient(
                colors: [Color.clear, accentColor.opacity(0.5), Color.clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 1)
        }
        .background(Color.black.opacity(0.8))
    }
    
    private var mainIconHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(accentColor)
                    .shadow(color: accentColor.opacity(0.5), radius: 15)
            }
            
            VStack(spacing: 4) {
                Text("Sonic Experience")
                    .font(.custom("PlayfairDisplay-Bold", size: 24))
                    .foregroundColor(.white)
                
                Text("Fine-tune the sounds of your destiny")
                    .font(.custom("PlayfairDisplay-Regular", size: 14))
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
        }
    }
    
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.custom("PlayfairDisplay-Bold", size: 12))
            .foregroundColor(accentColor.opacity(0.8))
            .tracking(3)
            .padding(.leading, 8)
    }
    
    private var sfxToggleRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Sound Effects")
                    .font(.custom("PlayfairDisplay-Bold", size: 18))
                    .foregroundColor(.white)
                Text(audioManager.isSFXEnabled ? "Magic sounds active" : "Silent rolling")
                    .font(.custom("PlayfairDisplay-Regular", size: 12))
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
            Spacer()
            Toggle("", isOn: $audioManager.isSFXEnabled)
                .tint(accentColor)
                .labelsHidden()
        }
        .padding(20)
        .background(Color.white.opacity(0.02))
    }
    
    private var volumeSliderRow: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Master Volume")
                    .font(.custom("PlayfairDisplay-Bold", size: 18))
                    .foregroundColor(.white)
                Spacer()
                Text("\(Int(audioManager.masterVolume * 100))%")
                    .font(.custom("PlayfairDisplay-Black", size: 16))
                    .foregroundColor(accentColor)
            }
            
            HStack(spacing: 16) {
                Image(systemName: "speaker.fill")
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                
                Slider(value: $audioManager.masterVolume, in: 0...1)
                    .tint(accentColor)
                
                Image(systemName: "speaker.wave.3.fill")
                    .foregroundColor(accentColor)
            }
            
            Button(action: { audioManager.playDiceRoll() }) {
                HStack {
                    Image(systemName: "play.circle.fill")
                    Text("Test Current Volume")
                }
                .font(.custom("PlayfairDisplay-Bold", size: 14))
                .foregroundColor(accentColor)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(accentColor.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(20)
    }
    
    private var resetAllButton: some View {
        Button(action: { audioManager.resetAllToDefaults() }) {
            Text("RESET ALL TO DEFAULTS")
                .font(.custom("PlayfairDisplay-Bold", size: 14))
                .foregroundColor(.red.opacity(0.8))
                .tracking(1)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

struct SoundCustomRow: View {
    let soundType: SoundType
    let customSound: CustomSound?
    let accentColor: Color
    let onTest: () -> Void
    let onCustomize: () -> Void
    let onReset: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(soundType.displayName)
                        .font(.custom("PlayfairDisplay-Bold", size: 16))
                        .foregroundColor(.white)
                    
                    Text(customSound?.isCustom == true ? "Modified: \(customSound?.fileName ?? "")" : "Original Essence")
                        .font(.custom("PlayfairDisplay-Regular", size: 12))
                        .foregroundColor(customSound?.isCustom == true ? accentColor : DesignSystem.Colors.textTertiary)
                }
                
                Spacer()
                
                if customSound?.isCustom == true {
                    Button(action: onReset) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.orange)
                            .frame(width: 32, height: 32)
                            .background(Color.orange.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
            }
            
            HStack(spacing: 12) {
                Button(action: onTest) {
                    Label("Preview", systemImage: "play.fill")
                        .font(.custom("PlayfairDisplay-Bold", size: 13))
                        .foregroundColor(accentColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(accentColor.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Button(action: onCustomize) {
                    Label("Custom", systemImage: "music.note.list")
                        .font(.custom("PlayfairDisplay-Bold", size: 13))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

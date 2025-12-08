
import SwiftUI

struct AudioSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var audioManager = AudioManager.shared
    @ObservedObject var themeManager: ThemeManager
    
    @State private var showingSoundPicker = false
    @State private var selectedSoundType: SoundType?
    
    private var currentTheme: DiceCustomization {
        themeManager.currentTheme
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.opacity(0.95)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        headerView
                        
                        // Master Controls
                        masterControlsSection
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                            .padding(.vertical, 10)
                        
                        // Sound Customization
                        soundCustomizationSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Audio Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(currentTheme.accentColor.color)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        audioManager.resetAllToDefaults()
                    }) {
                        Text("Reset All")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            Image(systemName: "speaker.wave.3.fill")
                .font(.system(size: 60))
                .foregroundColor(currentTheme.accentColor.color)
            
            Text("Audio & Sound Effects")
                .font(.custom("PlayfairDisplay-Bold", size: 24))
                .foregroundColor(.white)
            
            Text("Customize your dice rolling experience")
                .font(.custom("PlayfairDisplay-Regular", size: 14))
                .foregroundColor(DesignSystem.Colors.textTertiary)
        }
        .padding(.bottom, 20)
    }
    
    private var masterControlsSection: some View {
        VStack(spacing: 20) {
            Text("MASTER CONTROLS")
                .font(.custom("PlayfairDisplay-Bold", size: 16))
                .foregroundColor(currentTheme.accentColor.color)
                .tracking(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // SFX Toggle
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sound Effects")
                        .font(.custom("PlayfairDisplay-Bold", size: 18))
                        .foregroundColor(.white)
                    
                    Text(audioManager.isSFXEnabled ? "Enabled" : "Disabled")
                        .font(.custom("PlayfairDisplay-Regular", size: 14))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
                
                Spacer()
                
                Toggle("", isOn: $audioManager.isSFXEnabled)
                    .tint(currentTheme.accentColor.color)
            }
            .padding(DesignSystem.Spacing.md)  // 16pt
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusMedium)
                    .fill(Color.white.opacity(0.05))
            )
            
            // Volume Slider
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Master Volume")
                        .font(.custom("PlayfairDisplay-Bold", size: 18))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(Int(audioManager.masterVolume * 100))%")
                        .font(.custom("PlayfairDisplay-Bold", size: 16))
                        .foregroundColor(currentTheme.accentColor.color)
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "speaker.fill")
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                    
                    Slider(value: $audioManager.masterVolume, in: 0...1)
                        .tint(currentTheme.accentColor.color)
                    
                    Image(systemName: "speaker.wave.3.fill")
                        .foregroundColor(currentTheme.accentColor.color)
                }
                
                Button(action: {
                    audioManager.playDiceRoll()
                }) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                        Text("Test Volume")
                    }
                    .font(.custom("PlayfairDisplay-Regular", size: 14))
                    .foregroundColor(currentTheme.accentColor.color)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusSmall)
                            .fill(currentTheme.accentColor.color.opacity(0.15))
                    )
                }
            }
            .padding(DesignSystem.Spacing.md)  // 16pt
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusMedium)
                    .fill(Color.white.opacity(0.05))
            )
        }
    }
    
    private var soundCustomizationSection: some View {
        VStack(spacing: 20) {
            Text("SOUND CUSTOMIZATION")
                .font(.custom("PlayfairDisplay-Bold", size: 16))
                .foregroundColor(currentTheme.accentColor.color)
                .tracking(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(SoundType.allCases, id: \.self) { soundType in
                SoundCustomizationRow(
                    soundType: soundType,
                    customSound: audioManager.customSounds[soundType],
                    accentColor: currentTheme.accentColor.color,
                    onTest: {
                        audioManager.playSFX(soundType)
                    },
                    onCustomize: {
                        selectedSoundType = soundType
                        showingSoundPicker = true
                    },
                    onReset: {
                        audioManager.resetToDefault(for: soundType)
                    }
                )
            }
        }
    }
}

struct SoundCustomizationRow: View {
    let soundType: SoundType
    let customSound: CustomSound?
    let accentColor: Color
    let onTest: () -> Void
    let onCustomize: () -> Void
    let onReset: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(soundType.displayName)
                        .font(.custom("PlayfairDisplay-Bold", size: 16))
                        .foregroundColor(.white)
                    
                    Text(customSound?.isCustom == true ? "Custom: \(customSound?.fileName ?? "")" : "Default")
                        .font(.custom("PlayfairDisplay-Regular", size: 12))
                        .foregroundColor(customSound?.isCustom == true ? accentColor : .white.opacity(0.6))
                }
                
                Spacer()
                
                if customSound?.isCustom == true {
                    Button(action: onReset) {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundColor(.orange)
                            .padding(DesignSystem.Spacing.xs)  // 8pt
                            .background(
                                Circle()
                                    .fill(Color.orange.opacity(0.15))
                            )
                    }
                }
            }
            
            HStack(spacing: 12) {
                Button(action: onTest) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Test")
                    }
                    .font(.custom("PlayfairDisplay-Regular", size: 14))
                    .foregroundColor(accentColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusSmall)
                            .fill(accentColor.opacity(0.15))
                    )
                }
                
                Button(action: onCustomize) {
                    HStack {
                        Image(systemName: "waveform")
                        Text("Customize")
                    }
                    .font(.custom("PlayfairDisplay-Regular", size: 14))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusSmall)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
        .padding(DesignSystem.Spacing.md)  // 16pt
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusMedium)
                .fill(Color.white.opacity(0.05))
        )
    }
}

#Preview {
    AudioSettingsView(themeManager: ThemeManager.shared)
}

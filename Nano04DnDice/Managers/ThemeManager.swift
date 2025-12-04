
import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: DiceCustomization
    @Published var savedThemes: [DiceCustomization] = []
    
    private let userDefaultsKey = "savedThemes"
    private let currentThemeKey = "currentTheme"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: currentThemeKey),
           let theme = try? JSONDecoder().decode(DiceCustomization.self, from: data) {
            self.currentTheme = theme
        } else {
            self.currentTheme = PresetThemes.classic
        }
        
        loadSavedThemes()
    }
    
    
    func applyTheme(_ theme: DiceCustomization) {
        currentTheme = theme
        saveCurrentTheme()
    }
    
    func saveCustomTheme(_ theme: DiceCustomization) {
        if let index = savedThemes.firstIndex(where: { $0.id == theme.id }) {
            savedThemes[index] = theme
        } else {
            savedThemes.append(theme)
        }
        saveToDisk()
    }
    
    func deleteTheme(_ theme: DiceCustomization) {
        savedThemes.removeAll { $0.id == theme.id }
        saveToDisk()
    }
    
    func duplicateTheme(_ theme: DiceCustomization) -> DiceCustomization {
        var newTheme = theme
        newTheme.id = UUID()
        newTheme.name = "\(theme.name) (Cópia)"
        return newTheme
    }
    
    
    private func saveCurrentTheme() {
        if let encoded = try? JSONEncoder().encode(currentTheme) {
            UserDefaults.standard.set(encoded, forKey: currentThemeKey)
        }
    }
    
    private func saveToDisk() {
        if let encoded = try? JSONEncoder().encode(savedThemes) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadSavedThemes() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let themes = try? JSONDecoder().decode([DiceCustomization].self, from: data) {
            self.savedThemes = themes
        } else {
            self.savedThemes = PresetThemes.allThemes
            saveToDisk()
        }
    }
    
    
    func loadPresetThemes() {
        let presets = PresetThemes.allThemes
        for preset in presets {
            if !savedThemes.contains(where: { $0.name == preset.name }) {
                savedThemes.append(preset)
            }
        }
        saveToDisk()
    }
}

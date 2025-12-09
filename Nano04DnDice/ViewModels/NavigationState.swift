
import SwiftUI
import Combine

/// Manages navigation state for the dice roller app
/// Extracted from DiceRollerViewModel to follow Single Responsibility Principle
@MainActor
class NavigationState: ObservableObject {
    @Published var showThemesList = false
    @Published var showCustomizer = false
    @Published var showCustomDice = false
    @Published var showARDice = false
    @Published var showMultipleDice = false
    @Published var showHistory = false
    @Published var showDetailedStats = false
    @Published var showAudioSettings = false
    @Published var showCampaignManager = false
    @Published var showCharacterSheet = false
}

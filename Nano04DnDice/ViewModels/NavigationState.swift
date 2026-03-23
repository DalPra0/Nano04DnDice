
import SwiftUI

/// Manages navigation state for the dice roller app
/// Extracted from DiceRollerViewModel to follow Single Responsibility Principle
struct NavigationState {
    var showThemesList = false
    var showCustomizer = false
    var showCustomDice = false
    var showARDice = false
    var showMultipleDice = false
    var showHistory = false
    var showDetailedStats = false
    var showAudioSettings = false
    var showCampaignManager = false
    var showCharacterSheet = false
}

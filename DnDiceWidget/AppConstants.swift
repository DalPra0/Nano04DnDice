
import Foundation

/// Centralized constants to avoid hardcoded values and magic strings
/// Note: This file is duplicated in both app and widget targets
enum AppConstants {
    // MARK: - App Groups & Containers
    
    /// App Group identifier for sharing data between app and extensions (Widget, Watch)
    static let appGroup = "group.com.DalPra.DiceAndDragons"
    
    // MARK: - UserDefaults Keys
    
    enum UserDefaultsKeys {
        static let lastDiceResult = "lastDiceResult"
        static let lastDiceType = "lastDiceType"
        static let lastRollDate = "lastRollDate"
    }
}

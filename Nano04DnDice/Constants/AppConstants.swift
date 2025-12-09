
import Foundation

/// Centralized constants to avoid hardcoded values and magic strings
enum AppConstants {
    // MARK: - App Groups & Containers
    
    /// App Group identifier for sharing data between app and extensions (Widget, Watch)
    static let appGroup = "group.com.DalPra.DiceAndDragons"
    
    /// iCloud container identifier (currently not in use - see ThemeManager)
    static let iCloudContainer = "iCloud.dalpra.Nano04DnDice"
    
    // MARK: - UserDefaults Keys
    
    enum UserDefaultsKeys {
        static let lastDiceResult = "lastDiceResult"
        static let lastDiceType = "lastDiceType"
        static let lastRollDate = "lastRollDate"
    }
    
    // MARK: - Dice Physics (AR)
    
    enum DicePhysics {
        static let mass: Float = 0.05
        static let staticFriction: Float = 1.0
        static let dynamicFriction: Float = 0.8
        static let restitution: Float = 0.2
        static let spawnHeight: Float = 0.3
    }
    
    // MARK: - Animation Durations
    
    enum AnimationDuration {
        static let diceRoll: TimeInterval = 3.0
        static let resultDisplay: TimeInterval = 4.0
        static let glowFade: TimeInterval = 0.5
    }
    
    // MARK: - Dice Dimensions
    
    enum DiceDimensions {
        static let scale3D: Float = 0.1
        static let collisionBoxSize: Float = 0.1
        static let fallbackSphereRadius: Float = 0.05
        static let planeSize: Float = 10.0
        static let planeHeight: Float = 0.05
    }
}

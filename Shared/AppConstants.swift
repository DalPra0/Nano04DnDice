import Foundation

enum AppConstants {
    nonisolated static let appGroup = "group.com.DalPra.DiceAndDragons"
    static let iCloudContainer = "iCloud.dalpra.Nano04DnDice"
    
    enum UserDefaultsKeys {
        nonisolated static let lastDiceResult = "lastDiceResult"
        nonisolated static let lastDiceType = "lastDiceType"
        nonisolated static let lastRollDate = "lastRollDate"
    }
    
    enum DicePhysics {
        static let mass: Float = 0.05
        static let staticFriction: Float = 1.0
        static let dynamicFriction: Float = 0.8
        static let restitution: Float = 0.2
        static let spawnHeight: Float = 0.3
    }
    
    enum AnimationDuration {
        static let diceRoll: TimeInterval = 3.0
        static let resultDisplay: TimeInterval = 4.0
        static let glowFade: TimeInterval = 0.5
    }
    
    enum DiceDimensions {
        static let scale3D: Float = 0.1
        static let collisionBoxSize: Float = 0.1
        static let fallbackSphereRadius: Float = 0.05
        static let planeSize: Float = 10.0
        static let planeHeight: Float = 0.05
    }
}

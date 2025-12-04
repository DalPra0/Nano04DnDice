import Foundation

enum RollMode: String, CaseIterable, Codable {
    case normal = "Normal"
    case blessed = "Blessed"
    case cursed = "Cursed"
    
    var displayName: String {
        return self.rawValue
    }
}

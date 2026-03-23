import Foundation

struct Currency: Codable {
    var copper: Int
    var silver: Int
    var electrum: Int
    var gold: Int
    var platinum: Int
    
    init(copper: Int = 0, silver: Int = 0, electrum: Int = 0, gold: Int = 0, platinum: Int = 0) {
        self.copper = copper
        self.silver = silver
        self.electrum = electrum
        self.gold = gold
        self.platinum = platinum
    }
}

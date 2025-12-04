
import XCTest
@testable import Nano04DnDice

final class DiceRollHistoryTests: XCTestCase {
    
    var historyManager: DiceRollHistoryManager!
    
    override func setUpWithError() throws {
        historyManager = DiceRollHistoryManager()
        historyManager.clearHistory()
    }
    
    override func tearDownWithError() throws {
        historyManager.clearHistory()
        historyManager = nil
    }
    
    // MARK: - DiceRollEntry Tests
    
    func testDiceRollEntryCreation() {
        let entry = DiceRollEntry(
            diceType: .d20,
            result: 18,
            rollMode: .normal,
            proficiencyBonus: 3
        )
        
        XCTAssertEqual(entry.diceType.sides, 20)
        XCTAssertEqual(entry.result, 18)
        XCTAssertEqual(entry.proficiencyBonus, 3)
        XCTAssertNotNil(entry.id)
        XCTAssertNotNil(entry.timestamp)
    }
    
    func testIsCritical() {
        let critical = DiceRollEntry(
            diceType: .d20,
            result: 20,
            proficiencyBonus: 0
        )
        XCTAssertTrue(critical.isCritical)
        
        let criticalWithBonus = DiceRollEntry(
            diceType: .d20,
            result: 23,
            proficiencyBonus: 3
        )
        XCTAssertTrue(criticalWithBonus.isCritical)
        
        let notCritical = DiceRollEntry(
            diceType: .d20,
            result: 15,
            proficiencyBonus: 0
        )
        XCTAssertFalse(notCritical.isCritical)
    }
    
    func testIsFumble() {
        let fumble = DiceRollEntry(
            diceType: .d20,
            result: 1,
            proficiencyBonus: 0
        )
        XCTAssertTrue(fumble.isFumble)
        
        let fumbleWithBonus = DiceRollEntry(
            diceType: .d20,
            result: 4,
            proficiencyBonus: 3
        )
        XCTAssertTrue(fumbleWithBonus.isFumble)
        
        let notFumble = DiceRollEntry(
            diceType: .d20,
            result: 10,
            proficiencyBonus: 0
        )
        XCTAssertFalse(notFumble.isFumble)
    }
    
    // MARK: - History Manager Tests
    
    func testAddRoll() {
        let entry = DiceRollEntry(diceType: .d20, result: 15)
        historyManager.addRoll(entry)
        
        XCTAssertEqual(historyManager.history.count, 1)
        XCTAssertEqual(historyManager.history.first?.result, 15)
    }
    
    func testAddMultipleRolls() {
        for i in 1...5 {
            let entry = DiceRollEntry(diceType: .d6, result: i)
            historyManager.addRoll(entry)
        }
        
        XCTAssertEqual(historyManager.history.count, 5)
        XCTAssertEqual(historyManager.history.first?.result, 5)
        XCTAssertEqual(historyManager.history.last?.result, 1)
    }
    
    func testMaxHistoryCount() {
        for i in 1...60 {
            let entry = DiceRollEntry(diceType: .d6, result: i % 6 + 1)
            historyManager.addRoll(entry)
        }
        
        XCTAssertEqual(historyManager.history.count, 50)
    }
    
    func testClearHistory() {
        for i in 1...5 {
            let entry = DiceRollEntry(diceType: .d6, result: i)
            historyManager.addRoll(entry)
        }
        
        historyManager.clearHistory()
        
        XCTAssertEqual(historyManager.history.count, 0)
    }
    
    // MARK: - Statistics Tests
    
    func testStatisticsWithEmptyHistory() {
        let stats = historyManager.getStatistics()
        
        XCTAssertEqual(stats.totalRolls, 0)
        XCTAssertEqual(stats.criticals, 0)
        XCTAssertEqual(stats.fumbles, 0)
        XCTAssertEqual(stats.averageRoll, 0)
        XCTAssertEqual(stats.mostUsedDice, "N/A")
    }
    
    func testStatisticsWithRolls() {
        historyManager.addRoll(DiceRollEntry(diceType: .d20, result: 20))
        historyManager.addRoll(DiceRollEntry(diceType: .d20, result: 1))
        historyManager.addRoll(DiceRollEntry(diceType: .d20, result: 10))
        historyManager.addRoll(DiceRollEntry(diceType: .d6, result: 6))
        
        let stats = historyManager.getStatistics()
        
        XCTAssertEqual(stats.totalRolls, 4)
        XCTAssertEqual(stats.criticals, 2)
        XCTAssertEqual(stats.fumbles, 1)
        XCTAssertEqual(stats.highestRoll, 20)
        XCTAssertEqual(stats.lowestRoll, 1)
        XCTAssertEqual(stats.mostUsedDice, "D20")
    }
    
    func testAverageCalculation() {
        historyManager.addRoll(DiceRollEntry(diceType: .d6, result: 2))
        historyManager.addRoll(DiceRollEntry(diceType: .d6, result: 4))
        historyManager.addRoll(DiceRollEntry(diceType: .d6, result: 6))
        
        let stats = historyManager.getStatistics()
        
        XCTAssertEqual(stats.averageRoll, 4.0, accuracy: 0.01)
    }
}

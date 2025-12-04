
import XCTest
@testable import Nano04DnDice

final class DiceRollerViewModelTests: XCTestCase {
    
    var viewModel: DiceRollerViewModel!
    
    override func setUpWithError() throws {
        viewModel = DiceRollerViewModel()
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
    }
    
    // MARK: - Dice Selection Tests
    
    func testSelectDiceType() {
        viewModel.selectDiceType(.d6)
        XCTAssertEqual(viewModel.selectedDiceType.sides, 6)
        
        viewModel.selectDiceType(.d20)
        XCTAssertEqual(viewModel.selectedDiceType.sides, 20)
    }
    
    func testSelectDiceTypeClearsResult() {
        viewModel.result = 15
        viewModel.secondResult = 10
        
        viewModel.selectDiceType(.d6)
        
        XCTAssertNil(viewModel.result)
        XCTAssertNil(viewModel.secondResult)
    }
    
    // MARK: - Roll Mode Tests
    
    func testSelectRollMode() {
        viewModel.selectRollMode(.blessed)
        XCTAssertEqual(viewModel.rollMode, .blessed)
        
        viewModel.selectRollMode(.cursed)
        XCTAssertEqual(viewModel.rollMode, .cursed)
    }
    
    func testSelectRollModeClearsResult() {
        viewModel.result = 15
        viewModel.secondResult = 10
        
        viewModel.selectRollMode(.blessed)
        
        XCTAssertNil(viewModel.result)
        XCTAssertNil(viewModel.secondResult)
    }
    
    // MARK: - Custom Dice Tests
    
    func testConfirmCustomDiceValidSides() {
        viewModel.customDiceSides = "30"
        viewModel.confirmCustomDice()
        
        XCTAssertEqual(viewModel.selectedDiceType.sides, 30)
        XCTAssertFalse(viewModel.showCustomDice)
    }
    
    func testConfirmCustomDiceInvalidSides() {
        viewModel.customDiceSides = "1"
        viewModel.confirmCustomDice()
        
        XCTAssertNotEqual(viewModel.selectedDiceType.sides, 1)
    }
    
    func testConfirmCustomDiceOutOfRange() {
        viewModel.customDiceSides = "150"
        viewModel.confirmCustomDice()
        
        XCTAssertNotEqual(viewModel.selectedDiceType.sides, 150)
    }
    
    // MARK: - Roll Tests
    
    func testRollDiceNormalMode() {
        viewModel.selectedDiceType = .d20
        viewModel.rollMode = .normal
        
        viewModel.rollDice()
        
        XCTAssertTrue(viewModel.rolling)
        XCTAssertNil(viewModel.secondResult)
    }
    
    func testRollDiceBlessedMode() {
        viewModel.selectedDiceType = .d20
        viewModel.rollMode = .blessed
        
        viewModel.rollDice()
        
        XCTAssertTrue(viewModel.rolling)
        XCTAssertNotNil(viewModel.secondResult)
    }
    
    func testRollDiceCursedMode() {
        viewModel.selectedDiceType = .d20
        viewModel.rollMode = .cursed
        
        viewModel.rollDice()
        
        XCTAssertTrue(viewModel.rolling)
        XCTAssertNotNil(viewModel.secondResult)
    }
    
    func testRollDicePreventsRaceCondition() {
        viewModel.rollDice()
        let firstRolling = viewModel.rolling
        
        viewModel.rollDice()
        
        XCTAssertTrue(firstRolling)
    }
    
    // MARK: - Result Tests
    
    func testHandleRollCompleteWithProficiencyBonus() {
        viewModel.proficiencyBonus = 5
        viewModel.handleRollComplete(15)
        
        XCTAssertEqual(viewModel.result, 20)
        XCTAssertFalse(viewModel.rolling)
    }
    
    func testHandleRollCompleteWithoutBonus() {
        viewModel.proficiencyBonus = 0
        viewModel.handleRollComplete(15)
        
        XCTAssertEqual(viewModel.result, 15)
        XCTAssertFalse(viewModel.rolling)
    }
    
    func testIsCritical() {
        viewModel.selectedDiceType = .d20
        viewModel.result = 20
        
        XCTAssertTrue(viewModel.isCritical)
    }
    
    func testIsCriticalWithBonus() {
        viewModel.selectedDiceType = .d20
        viewModel.proficiencyBonus = 5
        viewModel.result = 25
        
        XCTAssertTrue(viewModel.isCritical)
    }
    
    func testIsFumble() {
        viewModel.selectedDiceType = .d20
        viewModel.result = 1
        
        XCTAssertTrue(viewModel.isFumble)
    }
    
    func testIsSuccess() {
        viewModel.selectedDiceType = .d20
        viewModel.result = 15
        
        XCTAssertTrue(viewModel.isSuccess)
    }
    
    // MARK: - Multiple Dice Tests
    
    func testRollMultipleDice() {
        viewModel.multipleDiceQuantity = 3
        viewModel.multipleDiceType = .d6
        
        viewModel.rollMultipleDice()
        
        XCTAssertNotNil(viewModel.multipleDiceResult)
        XCTAssertEqual(viewModel.multipleDiceResult?.results.count, 3)
        XCTAssertFalse(viewModel.rolling)
    }
    
    func testRollMultipleDiceValidRange() {
        viewModel.multipleDiceQuantity = 2
        viewModel.multipleDiceType = .d6
        
        viewModel.rollMultipleDice()
        
        let results = viewModel.multipleDiceResult?.results ?? []
        for result in results {
            XCTAssertGreaterThanOrEqual(result, 1)
            XCTAssertLessThanOrEqual(result, 6)
        }
    }
    
    // MARK: - Continue After Result Tests
    
    func testContinueAfterResult() {
        viewModel.result = 15
        viewModel.secondResult = 10
        viewModel.multipleDiceResult = MultipleDiceRoll(diceType: .d6, quantity: 2, results: [3, 4])
        
        viewModel.continueAfterResult()
        
        XCTAssertNil(viewModel.result)
        XCTAssertNil(viewModel.secondResult)
        XCTAssertNil(viewModel.multipleDiceResult)
    }
}

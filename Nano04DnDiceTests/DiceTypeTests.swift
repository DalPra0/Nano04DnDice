
import XCTest
@testable import Nano04DnDice

final class DiceTypeTests: XCTestCase {
    
    func testStandardDiceSides() {
        XCTAssertEqual(DiceType.d4.sides, 4)
        XCTAssertEqual(DiceType.d6.sides, 6)
        XCTAssertEqual(DiceType.d8.sides, 8)
        XCTAssertEqual(DiceType.d10.sides, 10)
        XCTAssertEqual(DiceType.d12.sides, 12)
        XCTAssertEqual(DiceType.d20.sides, 20)
    }
    
    func testCustomDiceSides() {
        let custom30 = DiceType.custom(sides: 30)
        XCTAssertEqual(custom30.sides, 30)
        
        let custom100 = DiceType.custom(sides: 100)
        XCTAssertEqual(custom100.sides, 100)
    }
    
    func testDiceNames() {
        XCTAssertEqual(DiceType.d4.name, "D4")
        XCTAssertEqual(DiceType.d6.name, "D6")
        XCTAssertEqual(DiceType.d8.name, "D8")
        XCTAssertEqual(DiceType.d10.name, "D10")
        XCTAssertEqual(DiceType.d12.name, "D12")
        XCTAssertEqual(DiceType.d20.name, "D20")
    }
    
    func testCustomDiceName() {
        let custom30 = DiceType.custom(sides: 30)
        XCTAssertEqual(custom30.name, "D30")
    }
    
    func testShortNames() {
        XCTAssertEqual(DiceType.d4.shortName, "D4")
        XCTAssertEqual(DiceType.d20.shortName, "D20")
        
        let custom30 = DiceType.custom(sides: 30)
        XCTAssertEqual(custom30.shortName, "D30")
    }
    
    func testIsCustom() {
        XCTAssertFalse(DiceType.d4.isCustom)
        XCTAssertFalse(DiceType.d6.isCustom)
        XCTAssertFalse(DiceType.d20.isCustom)
        
        let custom30 = DiceType.custom(sides: 30)
        XCTAssertTrue(custom30.isCustom)
    }
    
    func testDiceEquality() {
        XCTAssertEqual(DiceType.d20, DiceType.d20)
        XCTAssertNotEqual(DiceType.d20, DiceType.d6)
        
        let custom1 = DiceType.custom(sides: 30)
        let custom2 = DiceType.custom(sides: 30)
        XCTAssertEqual(custom1, custom2)
        
        let custom3 = DiceType.custom(sides: 40)
        XCTAssertNotEqual(custom1, custom3)
    }
}

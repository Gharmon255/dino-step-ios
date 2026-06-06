import XCTest
@testable import Dino_Step

final class EggRewardLogicTests: XCTestCase {
    func testRollEggReward_boundaryValues() {
        XCTAssertEqual(EggRewardLogic.rollEggReward(rollPercent: 0).rarity, .common)
        XCTAssertEqual(EggRewardLogic.rollEggReward(rollPercent: 64.9).rarity, .common)
        XCTAssertEqual(EggRewardLogic.rollEggReward(rollPercent: 65).rarity, .uncommon)
        XCTAssertEqual(EggRewardLogic.rollEggReward(rollPercent: 86.9).rarity, .uncommon)
        XCTAssertEqual(EggRewardLogic.rollEggReward(rollPercent: 87).rarity, .rare)
        XCTAssertEqual(EggRewardLogic.rollEggReward(rollPercent: 96).rarity, .epic)
        XCTAssertEqual(EggRewardLogic.rollEggReward(rollPercent: 99).rarity, .legendary)
    }
}

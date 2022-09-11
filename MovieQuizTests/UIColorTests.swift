import XCTest
@testable import MovieQuiz

final class UIColorTests: XCTestCase {
    func testAllColorAssets() throws {
        // Given
        let assetNames = UIColor.CustomColorAsset.allCases

        // When
        for asset in assetNames {
            let color = UIColor(colorAsset: asset)

            // Then
            XCTAssertNotEqual(
                color,
                UIColor.clear,
                "Color Asset with name '\(asset.rawValue)' should be present"
            )
        }
    }
}

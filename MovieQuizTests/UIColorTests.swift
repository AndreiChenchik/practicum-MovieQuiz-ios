//
//  UIColorTests.swift
//  MovieQuizTests
//
//  Created by Andrei Chenchik on 27/8/22.
//

import XCTest
@testable import MovieQuiz

final class UIColorTests: XCTestCase {
    func testAllColorAssets() throws {
        // Given
        let assetNames = UIColor.CustomColorAsset.allCases

        for asset in assetNames {
            // When
            let color = UIColor.getCustom(asset)

            // Then
            XCTAssertNotEqual(
                color,
                UIColor.clear,
                "Color Asset with name '\(asset.rawValue)' should be present"
            )
        }
    }
}

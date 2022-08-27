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
        let colors = UIColor.CustomColorAssets.allCases

        // When
        for color in colors {
            // Then
            XCTAssertNoThrow(UIColor.getCustom(color))
        }
    }
}

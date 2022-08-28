//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Andrei Chenchik on 27/8/22.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    let answerAnimationSleep: UInt32 = 1
    let loadingExpectationTimeout = 5.0

    // swiftlint:disable:next implicitly_unwrapped_optional
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()

        app = XCUIApplication()
        app.launch()

        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        app.terminate()
        app = nil
    }

    func waitForProgress() {
        sleep(answerAnimationSleep)

        expectation(
            for: NSPredicate(format: "exists == FALSE"),
            evaluatedWith: app.activityIndicators["Loading Indicator"]
        )
        waitForExpectations(timeout: loadingExpectationTimeout)
    }

    func testYesButton() {
        // Given
        waitForProgress()
        let firstPoster = app.images["Poster"]

        // When
        app.buttons["Yes"].tap()
        waitForProgress()

        // Then
        XCTAssertEqual(app.alerts.count, 0)

        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(indexLabel.label == "2/10")

        let secondPoster = app.images["Poster"]
        XCTAssertFalse(firstPoster == secondPoster)
    }

    func testNoButton() {
        // Given
        waitForProgress()
        let firstPoster = app.images["Poster"]

        // When
        app.buttons["No"].tap()
        waitForProgress()

        // Then
        XCTAssertEqual(app.alerts.count, 0)

        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(indexLabel.label == "2/10")

        let secondPoster = app.images["Poster"]
        XCTAssertFalse(firstPoster == secondPoster)
    }

    func testResultAlert() {
        // Given
        waitForProgress()

        // When
        for _ in 1...10 {
            app.buttons["No"].tap()
            waitForProgress()
        }

        // Then
        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(indexLabel.label == "10/10")

        let resultsAlert = app.alerts.firstMatch
        XCTAssertTrue(
            resultsAlert.label == "Идеальный результат!" ||
            resultsAlert.label == "Этот раунд окончен!",
            "Result alert title should be either " +
            "'Идеальный результат!' OR 'Этот раунд окончен!'"
        )

        let resultsButton = resultsAlert.buttons.firstMatch
        XCTAssertEqual(resultsButton.label, "Сыграть еще раз")

        // When
        resultsButton.tap()
        waitForProgress()

        // Then
        let freshIndexLabel = app.staticTexts["Index"]
        XCTAssertTrue(freshIndexLabel.label == "1/10")
    }
}

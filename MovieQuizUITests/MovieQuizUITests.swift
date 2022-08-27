//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Andrei Chenchik on 27/8/22.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    let imageLoadSleep: UInt32 = 1
    let questionSwitchSleep: UInt32 = 1

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

    @discardableResult
    private func checkForErrors() -> Bool {
        // swiftlint:disable:next empty_count
        if app.alerts.count > 0 {
            app.buttons["Try again"].tap()
            return true
        }

        return false
    }

    func testYesButton() {
        // Given
        sleep(imageLoadSleep)
        let firstPoster = app.images["Poster"]

        // When
        while checkForErrors() { sleep(imageLoadSleep) }

        app.buttons["Yes"].tap()
        sleep(questionSwitchSleep + imageLoadSleep)

        while checkForErrors() { sleep(imageLoadSleep) }

        // Then
        let secondPoster = app.images["Poster"]
        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(indexLabel.label == "2/10")
        XCTAssertFalse(firstPoster == secondPoster)
    }

    func testNoButton() {
        // Given
        sleep(imageLoadSleep)
        let firstPoster = app.images["Poster"]

        // When
        while checkForErrors() { sleep(imageLoadSleep) }

        app.buttons["No"].tap()
        sleep(questionSwitchSleep)

        while checkForErrors() { sleep(imageLoadSleep) }

        // Then
        let secondPoster = app.images["Poster"]
        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(indexLabel.label == "2/10")
        XCTAssertFalse(firstPoster == secondPoster)
    }

    func testResultAlert() {
        // Given
        sleep(imageLoadSleep)

        // When
        for _ in 1...10 {
            while checkForErrors() { sleep(imageLoadSleep) }

            app.buttons["No"].tap()
            sleep(questionSwitchSleep + imageLoadSleep)
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
    }
}

//
//  IngredientConverterUITests.swift
//  IngredientConverterUITests
//
//  Created by Dawn DeMeo on 10/5/25.
//

import XCTest

final class IngredientConverterUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Settings Access Tests

    @MainActor
    func testSettingsButtonExists() throws {
        // Settings button should be visible in navigation bar
        let settingsButton = app.buttons["Settings"]
        XCTAssertTrue(settingsButton.exists, "Settings button should exist")
    }

    @MainActor
    func testOpenSettings() throws {
        // Tap Settings button
        let settingsButton = app.buttons["Settings"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()

        // Verify Settings screen appears
        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 5), "Settings screen should appear")
    }

    @MainActor
    func testCloseSettings() throws {
        // Open Settings
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))

        // Tap Done button
        app.buttons["Done"].tap()

        // Verify back at main screen
        let mainTitle = app.navigationBars["Ingredients"]
        XCTAssertTrue(mainTitle.waitForExistence(timeout: 5), "Should return to main screen")
    }

    // MARK: - Display Preferences Tests

    @MainActor
    func testAppearanceModeSegmentedControl() throws {
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))

        // Verify segmented control exists with all three options
        let segmentedControl = app.segmentedControls.firstMatch
        XCTAssertTrue(segmentedControl.exists, "Appearance segmented control should exist")

        // Verify all three buttons exist
        XCTAssertTrue(segmentedControl.buttons["System"].exists)
        XCTAssertTrue(segmentedControl.buttons["Light"].exists)
        XCTAssertTrue(segmentedControl.buttons["Dark"].exists)
    }

    @MainActor
    func testChangeAppearanceMode() throws {
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))

        let segmentedControl = app.segmentedControls.firstMatch

        // Tap Light mode
        segmentedControl.buttons["Light"].tap()

        // Tap Dark mode
        segmentedControl.buttons["Dark"].tap()

        // Tap System mode
        segmentedControl.buttons["System"].tap()

        // If we got here without crashing, the test passes
        XCTAssertTrue(true)
    }

    // MARK: - Unit Preferences Tests

    @MainActor
    func testUnitPreferencesSectionExists() throws {
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))

        // Verify Unit Preferences header exists
        let unitPreferencesHeader = app.staticTexts["Unit Preferences"]
        XCTAssertTrue(unitPreferencesHeader.exists, "Unit Preferences section should exist")
    }

    @MainActor
    func testFromUnitPickerExists() throws {
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))

        // Scroll to Unit Preferences section if needed
        let fromPicker = app.otherElements["FromUnitPicker"]
        var attempts = 0
        while !fromPicker.exists && attempts < 3 {
            app.swipeUp()
            attempts += 1
            Thread.sleep(forTimeInterval: 0.3)
        }

        XCTAssertTrue(fromPicker.waitForExistence(timeout: 5), "From picker should exist")
    }

    @MainActor
    func testToUnitPickerExists() throws {
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))

        // Scroll to Unit Preferences section
        let toPicker = app.otherElements["ToUnitPicker"]
        var attempts = 0
        while !toPicker.exists && attempts < 3 {
            app.swipeUp()
            attempts += 1
            Thread.sleep(forTimeInterval: 0.3)
        }

        XCTAssertTrue(toPicker.waitForExistence(timeout: 5), "To picker should exist")
    }

    // MARK: - Data Management Tests

    @MainActor
    func testExportButtonExists() throws {
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))

        // Scroll to Data section
        let exportButton = app.buttons["Export Custom Ingredients"]
        if !exportButton.isHittable {
            app.swipeUp()
        }

        XCTAssertTrue(exportButton.waitForExistence(timeout: 5), "Export button should exist")
    }

    @MainActor
    func testImportButtonExists() throws {
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))

        // Scroll to Data section
        let importButton = app.buttons["Import Custom Ingredients"]
        if !importButton.isHittable {
            app.swipeUp()
        }

        XCTAssertTrue(importButton.waitForExistence(timeout: 5), "Import button should exist")
    }

    @MainActor
    func testResetButtonExists() throws {
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))

        // Scroll to Data section
        let resetButton = app.buttons["Reset to Default Ingredients"]
        if !resetButton.isHittable {
            app.swipeUp()
        }

        XCTAssertTrue(resetButton.waitForExistence(timeout: 5), "Reset button should exist")
    }

    @MainActor
    func testResetConfirmationDialog() throws {
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))

        // Scroll to find the reset button
        let resetButton = app.buttons["Reset to Default Ingredients"]
        if !resetButton.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(resetButton.waitForExistence(timeout: 5), "Reset button should exist")

        // Tap reset button
        resetButton.tap()

        // Verify confirmation alert appears
        let alert = app.alerts["Reset to Default Ingredients?"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Confirmation alert should appear")

        // Verify Cancel button exists
        XCTAssertTrue(alert.buttons["Cancel"].exists, "Cancel button should exist")

        // Verify Reset button exists
        XCTAssertTrue(alert.buttons["Reset Database"].exists, "Reset Database button should exist")

        // Tap Cancel to dismiss
        alert.buttons["Cancel"].tap()
    }

    // MARK: - About Section Tests

    @MainActor
    func testAboutSectionExists() throws {
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))

        // Scroll to bottom to see About section - may need multiple swipes
        let aboutHeader = app.staticTexts["About"]
        var attempts = 0
        while !aboutHeader.isHittable && attempts < 5 {
            app.swipeUp()
            attempts += 1
        }

        XCTAssertTrue(aboutHeader.waitForExistence(timeout: 5), "About section should exist")
    }

    @MainActor
    func testVersionInformationExists() throws {
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))

        // Scroll to bottom - may need multiple swipes
        let versionLabel = app.staticTexts["Version"]
        var attempts = 0
        while !versionLabel.isHittable && attempts < 5 {
            app.swipeUp()
            attempts += 1
        }

        XCTAssertTrue(versionLabel.waitForExistence(timeout: 5), "Version label should exist")
    }

    @MainActor
    func testCopyrightTextExists() throws {
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))

        // Scroll to bottom - may need multiple swipes
        var attempts = 0
        while attempts < 5 {
            app.swipeUp()
            attempts += 1
        }

        // Give time for rendering after scrolling
        let copyrightText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] '2025 Dawn DeMeo'")).firstMatch
        XCTAssertTrue(copyrightText.waitForExistence(timeout: 5), "Copyright text should exist")
    }

    // MARK: - Performance Tests

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    @MainActor
    func testSettingsOpenPerformance() throws {
        measure(metrics: [XCTClockMetric()]) {
            app.buttons["Settings"].tap()
            XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))
            app.buttons["Done"].tap()
        }
    }
}

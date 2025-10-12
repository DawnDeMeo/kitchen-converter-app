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

        // Look for From picker label
        let fromLabel = app.staticTexts["From"]
        XCTAssertTrue(fromLabel.exists, "From picker should exist")
    }

    @MainActor
    func testToUnitPickerExists() throws {
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))

        // Look for To picker label
        let toLabel = app.staticTexts["To"]
        XCTAssertTrue(toLabel.exists, "To picker should exist")
    }

    // MARK: - Data Management Tests

    @MainActor
    func testExportButtonExists() throws {
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))

        let exportButton = app.buttons["Export Custom Ingredients"]
        XCTAssertTrue(exportButton.exists, "Export button should exist")
    }

    @MainActor
    func testImportButtonExists() throws {
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))

        let importButton = app.buttons["Import Custom Ingredients"]
        XCTAssertTrue(importButton.exists, "Import button should exist")
    }

    @MainActor
    func testResetButtonExists() throws {
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))

        let resetButton = app.buttons["Reset to Default Ingredients"]
        XCTAssertTrue(resetButton.exists, "Reset button should exist")
    }

    @MainActor
    func testResetConfirmationDialog() throws {
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))

        // Tap reset button
        app.buttons["Reset to Default Ingredients"].tap()

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

        // Scroll to bottom to see About section
        let aboutHeader = app.staticTexts["About"]
        if !aboutHeader.isHittable {
            app.swipeUp()
        }

        XCTAssertTrue(aboutHeader.exists, "About section should exist")
    }

    @MainActor
    func testVersionInformationExists() throws {
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))

        // Scroll to bottom
        app.swipeUp()

        let versionLabel = app.staticTexts["Version"]
        XCTAssertTrue(versionLabel.exists, "Version label should exist")
    }

    @MainActor
    func testCopyrightTextExists() throws {
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))

        // Scroll to bottom
        app.swipeUp()

        let copyrightText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] '2025 Dawn DeMeo'")).firstMatch
        XCTAssertTrue(copyrightText.exists, "Copyright text should exist")
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

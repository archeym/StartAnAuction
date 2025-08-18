//
//  StartAnAuctionUITests.swift
//  StartAnAuctionUITests
//
//  Created by Arkadijs Makarenko on 15/08/2025.
//

import XCTest

final class StartAnAuctionUITests: XCTestCase {
    
    override func setUp() {
        continueAfterFailure = false
    }
    
    func test_NonEmptyName_Navigates() {
        let app = XCUIApplication()
        app.launchArguments += ["UITESTS"]
        app.launch()
        // 1) Enter name
        let nameField = app.textFields["userNameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5), "Name field not found")
        nameField.tap()
        nameField.typeText("Archie")
        
        // Dismiss keyboard just in case it covers the start button
        if app.keyboards.firstMatch.exists {
            // Try tapping return if available; otherwise tap outside
            if app.keyboards.buttons["return"].exists {
                app.keyboards.buttons["return"].tap()
            } else {
                app.otherElements.firstMatch.tap()
            }
        }
        
        // 2) Tap Start
        let startButton = app.buttons["startAuctionButton"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 3))
        XCTAssertTrue(startButton.isEnabled)
        startButton.tap()
        
        // 3) Assert on AuctionView by waiting for the "Place Bid" button
        let placeBidButton = app.buttons["placeBidButton"]
        XCTAssertTrue(placeBidButton.waitForExistence(timeout: 5), "Did not navigate to AuctionView")
        
        let auctionRoot = app.otherElements["auctionScreenRoot"]
        XCTAssertTrue(auctionRoot.waitForExistence(timeout: 5))
    }
}

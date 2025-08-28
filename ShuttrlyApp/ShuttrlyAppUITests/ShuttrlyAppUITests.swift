//
//  ShuttrlyAppUITests.swift
//  ShuttrlyAppUITests
//
//  Created by Jules Antoine on 27/08/2025.
//

import XCTest

final class ShuttrlyAppUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch the application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
    
    // MARK: - Mock Data Tests
    
    func testMockProfileData() throws {
        // Test that our mock data is properly structured
        let sampleProfile = MockProfileData.sampleProfile
        
        // Verify basic info
        XCTAssertEqual(sampleProfile.basicInfo.username, "jules_antoine")
        XCTAssertEqual(sampleProfile.basicInfo.fullName, "Jules Antoine")
        XCTAssertEqual(sampleProfile.basicInfo.email, "jules.antoine@shuttrly.com")
        
        // Verify statistics
        XCTAssertEqual(sampleProfile.photoStatistics.totalPhotos, 1247)
        XCTAssertEqual(sampleProfile.collectionStatistics.totalCollections, 23)
        
        // Verify trusted devices
        XCTAssertEqual(sampleProfile.trustedDevices.devices.count, 3)
        
        // Verify first device
        let firstDevice = sampleProfile.trustedDevices.devices.first
        XCTAssertNotNil(firstDevice)
        XCTAssertEqual(firstDevice?.deviceType, "iPhone 15 Pro Max")
        XCTAssertEqual(firstDevice?.deviceFamily, "iOS")
    }
    
    func testEmptyProfileData() throws {
        // Test empty profile data
        let emptyProfile = MockProfileData.emptyProfile
        
        // Verify it's truly empty
        XCTAssertNil(emptyProfile.basicInfo.firstName)
        XCTAssertNil(emptyProfile.basicInfo.lastName)
        XCTAssertNil(emptyProfile.basicInfo.fullName)
        XCTAssertEqual(emptyProfile.photoStatistics.totalPhotos, 0)
        XCTAssertEqual(emptyProfile.trustedDevices.devices.count, 0)
    }
    
    func testPrivateProfileData() throws {
        // Test private profile data
        let privateProfile = MockProfileData.privateProfile
        
        // Verify privacy settings
        XCTAssertTrue(privateProfile.basicInfo.isPrivate)
        XCTAssertEqual(privateProfile.photoStatistics.publicPhotos, 0)
        XCTAssertEqual(privateProfile.photoStatistics.privatePhotos, 50)
    }
    
    // MARK: - Mock Service Tests
    
    func testMockProfileService() throws {
        let mockService = MockProfileService(profileType: "sample")
        
        // Test initial state
        XCTAssertTrue(mockService.isLoading)
        XCTAssertNil(mockService.currentProfile)
        
        // Wait for loading to complete
        let expectation = XCTestExpectation(description: "Profile loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        // Verify final state
        XCTAssertFalse(mockService.isLoading)
        XCTAssertNotNil(mockService.currentProfile)
        XCTAssertEqual(mockService.currentProfile?.basicInfo.username, "jules_antoine")
    }
    
    func testMockServiceProfileSwitching() throws {
        let mockService = MockProfileService(profileType: "sample")
        
        // Wait for initial load
        let expectation1 = XCTestExpectation(description: "Initial profile loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation1.fulfill()
        }
        wait(for: [expectation1], timeout: 2.0)
        
        // Switch to empty profile
        mockService.switchToProfile("empty")
        
        let expectation2 = XCTestExpectation(description: "Profile switched")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 2.0)
        
        // Verify switch
        XCTAssertEqual(mockService.currentProfile?.basicInfo.username, "new_user")
    }
}

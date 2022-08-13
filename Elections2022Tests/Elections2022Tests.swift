//
//  Elections2022Tests.swift
//  Elections2022Tests
//
//  Created by Dominique Berre on 29/06/2022.
//

import XCTest
@testable import Elections2022
import TabularData

// All the test classes inherit from this one
class Elections2022Tests: XCTestCase {

    var dataModel: DataModel!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        dataModel = DataModel()
        
        let start = Date.now
        try dataModel.loadSync()
        let duration = Date().timeIntervalSince(start)
        print("loadSync took: \(duration)")
        
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
}

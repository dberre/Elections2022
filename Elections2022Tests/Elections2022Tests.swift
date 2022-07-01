//
//  Elections2022Tests.swift
//  Elections2022Tests
//
//  Created by Dominique Berre on 29/06/2022.
//

import XCTest
@testable import Elections2022

class Elections2022Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDataModel() throws {
        let dataModel = DataModel()
        
        XCTAssert(dataModel.departments.count == 107)
        XCTAssert(dataModel.cities(for: "95").count == 186)
        XCTAssert(dataModel.result(department: "95", city: "Ermont").count == 1)
        XCTAssert(dataModel.result(department: "95", circoCode: 4).count == 6)
        XCTAssert(dataModel.circos(for: "95").count == 10)
    }
}

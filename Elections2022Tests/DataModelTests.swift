//
//  DataModelTests.swift
//  Elections2022Tests
//
//  Created by Dominique Berre on 13/08/2022.
//

import XCTest
@testable import Elections2022

class DataModelTests: Elections2022Tests {
    
    func testDataModel() throws {
        XCTAssertTrue(dataModel.departments.count == 107)
        XCTAssertTrue(dataModel.cities(for: "95 - Val-d'Oise").count == 186)
        XCTAssertTrue(dataModel.result(department: "95 - Val-d'Oise", city: "Ermont").count == 1)
        XCTAssertTrue(dataModel.result(department: "95 - Val-d'Oise", circoCode: 4).count == 6)
        XCTAssertTrue(dataModel.circos(for: "95 - Val-d'Oise").count == 10)
    }
}

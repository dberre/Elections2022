//
//  AutoCompletionTests.swift
//  Elections2022Tests
//
//  Created by Dominique Berre on 13/08/2022.
//

import XCTest
@testable import Elections2022
import TabularData

class AutoCompletionTests: Elections2022Tests {
    
    @MainActor
    func testAutoCompletion() async {
        let autocompleteObject = AutoCompleteObject<RadixTree>()
        await autocompleteObject.update(dataModel: dataModel)
        
        let cities = dataModel.cities(for: "95 - Val-d'Oise")
        XCTAssertTrue(cities.count > 0, "No city found")
        
        for city in cities {
            for length in 1..<city.count {
                autocompleteObject.autocomplete(String(city.prefix(length)))
                XCTAssertTrue(
                    autocompleteObject.suggestions.filter({ $0.city == city }).count > 0,
                    "Failed for \(city) and \(city.prefix(length))")
            }
        }
    }
}

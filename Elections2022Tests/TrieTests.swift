//
//  TrieTests.swift
//  Elections2022Tests
//
//  Created by Dominique Berre on 13/08/2022.
//

import XCTest
@testable import Elections2022
import TabularData

class TrieTests: Elections2022Tests {
    
    func testTrie() {
        let trie = buildTrie()
        let entries = dataModel.entries()

        XCTAssertTrue(entries.count == 35325)
        for entry in entries {
            let result = trie.search(["\(entry.city)"])
            XCTAssertTrue(result.filter { $0.city == entry.city }.count > 0, "\(entry.city)")
        }
    }
    
    func buildTrie() -> TrieDatastruct<SearchableCityItem> {
        let entries = dataModel.entries()
        let trie = TrieDatastruct<SearchableCityItem>()
        
        for entry in entries {
            let newItem =  SearchableCityItem(
                city: entry.city,
                department: entry.department,
                circo: entry.circo,
                keywords: [entry.city])

            trie.insert(newItem)
        }
        return trie
    }
}

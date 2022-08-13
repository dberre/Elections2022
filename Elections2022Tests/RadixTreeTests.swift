//
//  RadixTreeTests.swift
//  Elections2022Tests
//
//  Created by Dominique Berre on 13/08/2022.
//

import XCTest
@testable import Elections2022
import TabularData

class RadixTreeTests: Elections2022Tests {

    func testRadixTree() {                
        let radixTree = buildRadixTree(tokenizer: { word in
            Set([Substring(word)])
        })
        
        let entries = dataModel.entries()
        XCTAssertTrue(entries.count == 35325)
        for entry in entries {
            XCTAssertTrue(radixTree.searchWord("\(entry.city)"), "\(entry.city)")
        }
    }
    
    func testDumpRadixTree() {
        let tree = buildRadixTree(tokenizer: keywordsTokenizer)
        let nbColumns = tree.calcDepth()
        let nbRow = tree.countLeafs()
        
        XCTAssert(nbColumns > 0)
        XCTAssert(nbRow > 0)
        
        var columns = [Column(ColumnID("num", String.self), capacity: 0).eraseToAnyColumn()]
        for icol in 0..<nbColumns {
            columns.append(Column(ColumnID("col\(icol)", String.self), capacity: 0).eraseToAnyColumn())
        }
        
        var dataFrame = DataFrame(columns: columns)
        
        var currentRow = 0
        var rowData = Dictionary(uniqueKeysWithValues: columns.map { ($0.name, "") })
        tree.dumpRadixTree { row, col, label in
            if row != currentRow {
                dataFrame.append(valuesByColumn: rowData)
                rowData = Dictionary(uniqueKeysWithValues: columns.map { ($0.name, "") })
                rowData["num"] = "\(row)"
                currentRow = row
            }
            rowData["col\(col)"] = label
        }
        
        let fileURL = FileManager.documentDirectory.appendingPathComponent("radixTreeDump.csv")
        do {
            try dataFrame.writeCSV(to: fileURL)
            print("saved to: \(fileURL.absoluteString)")
        } catch {
            print("failed to save: \(fileURL.absoluteString)")
        }
    }
    
    func buildRadixTree(tokenizer: (String) -> Set<Substring>) -> RadixTree<SearchableCityItem> {
        let entries = dataModel.entries()
        let radixTree = RadixTree<SearchableCityItem>()
        
        for entry in entries {
            let newItem =  SearchableCityItem(
                city: entry.city,
                department: entry.department,
                circo: entry.circo,
                keywords: tokenizer(entry.city).union(tokenizer(entry.department)).map { String($0) })

            radixTree.insert(newItem)
        }
        return radixTree
    }
}

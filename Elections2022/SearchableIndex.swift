//
//  SearchableIndex.swift
//  Elections2022
//
//  Created by Dominique Berre on 10/08/2022.
//

import Foundation

protocol SearchableIndex {
    associatedtype S: Searchable
    
    init()
    func insert(_ object: S)
    func insert(_ set: [S])
    func search(_ keywords: [String]) -> [S]
    func calculateSize() -> Int
    func countNodes() -> Int
}

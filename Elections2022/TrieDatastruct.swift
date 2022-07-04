//
//  TrieDatastruct.swift
//  Elections2022
//
//  Created by Dominique Berre on 02/07/2022.
//

import Foundation

protocol Searchable: Hashable {
    var keywords: [String] { get }
}

class TrieDatastruct<T: Searchable> {
    lazy var nodes = [Character: TrieDatastruct<T>]()
    lazy var items = [T]()

    public init() { }

    // MARK: - Insert / index

    public func insert(_ object: T) {
        for string in object.keywords {
            var tokens = tokenize(string)
            var currentIndex = 0
            var maxIndex = tokens.count
            insert(tokens: &tokens, at: &currentIndex, max: &maxIndex, object: object)
        }
    }

    private func insert(tokens: inout [Character],
                        at currentIndex: inout Int,
                        max maxIndex: inout Int,
                        object: T) {
        if currentIndex < maxIndex {
            let current = tokens[currentIndex]
            currentIndex += 1

            if nodes[current] == nil {
                nodes[current] = TrieDatastruct<T>()
            }

            nodes[current]?.insert(tokens: &tokens, at: &currentIndex, max: &maxIndex, object: object)
        } else {
            items.append(object)
        }
    }

    public func insert(_ set: [T]) {
        for object in set {
            insert(object)
        }
    }

    // MARK: - Search

    public func search(_ keywords: [String]) -> [T] {
        var merged: Set<T>?

        for word in keywords {
            var wordResults = Set<T>()
            var tokens = tokenize(word)
            var maxIndex = tokens.count
            var currentIndex = 0
            find(tokens: &tokens, at: &currentIndex, max: &maxIndex, into: &wordResults)
            if let results = merged {
                merged = results.intersection(wordResults)
            } else {
                merged = wordResults
            }
        }

        if let results = merged {
            return Array(results)
        }
        return []
    }

    private func find(tokens: inout [Character],
                      at currentIndex: inout Int,
                      max maxIndex: inout Int,
                      into results: inout Set<T>) {
        if currentIndex < maxIndex {
            let current = tokens[currentIndex]
            currentIndex += 1
            nodes[current]?.find(tokens: &tokens, at: &currentIndex, max: &maxIndex, into: &results)
        } else {
            insertAll(into: &results)
        }
    }

    func insertAll(into results: inout Set<T>) {
        for t in items {
            results.insert(t)
        }

        for (_, child) in nodes {
            child.insertAll(into: &results)
        }
    }

    private func tokenize(_ string: String) -> [Character] {
        return Array(string.lowercased())
    }
}

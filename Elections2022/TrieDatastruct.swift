//
//  TrieDatastruct.swift
//  Elections2022
//
//  Created by Dominique Berre on 02/07/2022.
//

import Foundation

class TrieDatastruct<S: Searchable>: SearchableIndex {
    
    lazy var nodes = [Character: TrieDatastruct<S>]()
    lazy var items = [S]()

    public required init() { }

    // MARK: - Insert / index

    public func insert(_ object: S) {
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
                        object: S) {
        if currentIndex < maxIndex {
            let current = tokens[currentIndex]
            currentIndex += 1

            if nodes[current] == nil {
                nodes[current] = TrieDatastruct<S>()
            }

            nodes[current]?.insert(tokens: &tokens, at: &currentIndex, max: &maxIndex, object: object)
        } else {
            items.append(object)
        }
    }

    public func insert(_ set: [S]) {
        for object in set {
            insert(object)
        }
    }

    // MARK: - Search

    public func search(_ keywords: [String]) -> [S] {
        var merged: Set<S>?

        for word in keywords {
            var wordResults = Set<S>()
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
    
    public func calculateSize() -> Int {
        calculateTrieSize(item: self)
    }
    
    public func countNodes() -> Int {
        countNodesR(self)
    }
    
    private func calculateTrieSize(item: TrieDatastruct<S>) -> Int {
        var size: Int = 0
        
        size += MemoryLayout.size(ofValue: item.nodes)
        size += MemoryLayout.size(ofValue: item.items)

        for subItem in items {
            size += MemoryLayout.size(ofValue: subItem)
        }
        
        for subNode in item.nodes.values {
            size += calculateTrieSize(item: subNode)
        }
        return size
    }
    
    private func countNodesR(_ item: TrieDatastruct<S>) -> Int {
        var count: Int = 1
        for subNode in item.nodes.values {
            count += countNodesR(subNode)
        }
        return count
    }

    private func find(tokens: inout [Character],
                      at currentIndex: inout Int,
                      max maxIndex: inout Int,
                      into results: inout Set<S>) {
        if currentIndex < maxIndex {
            let current = tokens[currentIndex]
            currentIndex += 1
            nodes[current]?.find(tokens: &tokens, at: &currentIndex, max: &maxIndex, into: &results)
        } else {
            insertAll(into: &results)
        }
    }

    func insertAll(into results: inout Set<S>) {
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

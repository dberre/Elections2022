//
//  RadixTree.swift
//  Elections2022
//
//  Created by Dominique Berre on 09/08/2022.
//

import Foundation

private class Node<S: Searchable> {
    var edges: [Character: Edge<S>]
    var items: [S]
    var isLeaf: Bool

    init(isLeaf: Bool = false, edges: [Character : Edge<S>] = [:]) {
        self.isLeaf = isLeaf
        self.edges = edges
        self.items = []
    }
}


private class Edge<S: Searchable> {
    var label: String
    var next: Node<S>
    
    init(label: String, next: Node<S>) {
        self.label = label
        self.next = next
    }
}


class RadixTree<S: Searchable>: SearchableIndex {
    
    fileprivate var root: Node = Node<S>()
    
    required init() {
        
    }
    
    func insert(_ object: S) {
        for keyword in object.keywords {
            insertItem(key: keyword, item: object)
        }
    }
    
    func insert(_ set: [S]) {
        for object in set {
            insert(object)
        }
    }
    
    func search(_ keywords: [String]) -> [S] {
        var merged: Set<S>?

        for word in keywords {
            if let node = searchNode(word) {
                var allMatches = Set<S>()
                getAllChildren(node: node, &allMatches)
                if let results = merged {
                    merged = results.intersection(allMatches)
                } else {
                    merged = Set(allMatches)
                }
            }
        }

        if let results = merged {
            return Array(results)
        }
        return []
    }
    
    func calculateSize() -> Int {
        calculateTrieSize(node: root)
    }
    
    func insertWord(_ word: String) {
        _ = inserEntry(word)
    }
    
    func insertItem(key word: String, item: S) {
        let node = inserEntry(word)
        node.items.append(item)
    }
     
    func delete(_ word: String) {
        _ = delete(current: root, word: word[...])
    }
    
    func countNodes() -> Int {
        countNodesR(root)
    }

    func printAllWords() {
        printAllWords(from: root, result: "")
    }

    func searchWord(_ word: String) -> Bool {
        if let node = searchNode(word) {
            return node.isLeaf
        }
        return false
    }
    
    private func getAllChildren(node: Node<S>, _ result: inout Set<S>) {
        for item in node.items {
            result.insert(item)
        }
        
        for edge in node.edges.values {
            getAllChildren(node: edge.next, &result)
        }
    }
    
    private func inserEntry(_ word: String) -> Node<S> {
        var current = root
        
        var wordRemainder = word
        while !wordRemainder.isEmpty {
            guard let currentEdge = current.edges[wordRemainder.first!] else {
                // no entry matching the current character in the dictionnary -> create one
                let newNode = Node<S>(isLeaf: true)
                current.edges[wordRemainder.first!] = Edge(label: wordRemainder, next: newNode)
                return newNode
            }
            
            let splitIndex = getFirstMismatchIndex(of: currentEdge.label, in: wordRemainder)
            if splitIndex == nil {
                if wordRemainder.count == currentEdge.label.count {
                    currentEdge.next.isLeaf = true
                    return currentEdge.next
                } else if wordRemainder.count < currentEdge.label.count {
                    // word remainder is shorter than the edge label
                    // split the edge by adding a new node
                    let suffix = String(currentEdge.label.dropFirst(wordRemainder.count))
                    currentEdge.label = wordRemainder
                    let prevNext = currentEdge.next
                    currentEdge.next = Node(isLeaf: true, edges: [suffix.first! : Edge<S>(label: suffix, next: prevNext)])
                    return currentEdge.next
                } else {
                    // word remainder is longer than the edge label.
                    // remove the edge label from remainder and continue
                    wordRemainder = String(wordRemainder.dropFirst(currentEdge.label.count))
                }
            } else {
                // need to split the current edge to insert a new node
                let prefix = String(wordRemainder.prefix(upTo: splitIndex!))
                let suffix = String(currentEdge.label.dropFirst(prefix.count))
                currentEdge.label = prefix
                let prevNext = currentEdge.next
                currentEdge.next = Node(isLeaf: false)
                currentEdge.next.edges[suffix.first!] = Edge(label: suffix, next: prevNext)
                wordRemainder = String(wordRemainder.dropFirst(prefix.count))
            }
            current = currentEdge.next
        }
        return current
    }
    
    private func delete(current: Node<S>, word: Substring) -> Node<S>? {

        if word.isEmpty {
            if current.edges.isEmpty {
                return current
            } else {
                current.isLeaf = false
                return nil
            }
        } else {
            guard let currentEdge = current.edges[word.first!] else {
                // if the current node don't contains an entry with that character
                // search result must be false
                return nil
            }
            
            if !word.starts(with: currentEdge.label) {
                return nil
            }
            
            if let node = delete(current: currentEdge.next, word: word.dropFirst(currentEdge.label.count)) {
                node.edges.removeValue(forKey: word.first!)
            }
            return nil
        }
    }
    
    private func calculateTrieSize(node: Node<S>) -> Int {
        var size = 0
        
        size += MemoryLayout.size(ofValue: node)
        size += MemoryLayout.size(ofValue: node.edges)
        size += MemoryLayout.size(ofValue: node.isLeaf)
        size += MemoryLayout.size(ofValue: node.items)

        for item in node.items {
            size += MemoryLayout.size(ofValue: item)
        }
        
        for edge in node.edges.values {
            size += MemoryLayout.size(ofValue: edge)
            size += MemoryLayout.size(ofValue: edge.label)
            size += MemoryLayout.size(ofValue: edge)
            size += calculateTrieSize(node: edge.next)
        }
        
        return size
    }
    
    private func searchNode(_ word: String) -> Node<S>? {
        var current = root
        
        var wordRemainder = word
        while !wordRemainder.isEmpty {
            guard let currentEdge = current.edges[wordRemainder.first!] else {
                // if the current node don't contains an entry with that character
                // search result must be false
                return nil
            }
            
            if wordRemainder.count < currentEdge.label.count {
                if !currentEdge.label.starts(with: wordRemainder) {
                    return nil
                }
            } else {
                if !wordRemainder.starts(with: currentEdge.label) {
                    return nil
                }
            }
            
            wordRemainder = String(wordRemainder.dropFirst(currentEdge.label.count))
            
            current = currentEdge.next
        }
        return current
    }
    
    private func countNodesR(_ node: Node<S>) -> Int {
        var sum = node.isLeaf ? 1 : 0
        for edge in node.edges.values {
            sum += countNodesR(edge.next)
        }
        return sum
    }
    
    private func printAllWords(from node: Node<S>, result: String) {
        if node.isLeaf {
            print(result)
        }
        
        for edge in node.edges.values {
            printAllWords(from: edge.next, result: result.appending(edge.label))
        }
    }
    
    private func getFirstMismatchIndex(of radixWord: String, in word: String) -> String.Index? {
        var radixWordIndex = word.startIndex
        var wordIndex = radixWord.startIndex
        while radixWordIndex < radixWord.endIndex && wordIndex < word.endIndex {
            if radixWord[radixWordIndex] != word[wordIndex]  {
                return wordIndex
            }
            radixWord.formIndex(after: &radixWordIndex)
            word.formIndex(after: &wordIndex)
        }
        return nil
    }
}

// These extension are dedicated to unit tests
extension RadixTree {
    
    func calcDepth() -> Int {
        var level: Int = 0
        var maxLevel: Int = 0
        calcDepth(node: root, level: &level, maxLevel: &maxLevel)
        return maxLevel
    }
    
    func countLeafs() -> Int {
        var nbEntries: Int = 0
        countLeafs(node: root, nbEntries: &nbEntries)
        return nbEntries
    }
    
    func dumpTree(action: (Int, Int, String) -> Void) {
        var row: Int = 0
        var col: Int = 0
        dumpTree(node: root, row: &row, col: &col, action: action)
    }
    
    private func calcDepth(node: Node<S>, level: inout Int, maxLevel: inout Int) {
        level += 1
        if node.edges.isEmpty {
            maxLevel = max(level, maxLevel)
        } else {
            for edge in node.edges.values {
                calcDepth(node: edge.next, level: &level, maxLevel: &maxLevel)
            }
        }
        level -= 1
    }
    
    private func countLeafs(node: Node<S>, nbEntries: inout Int) {
        if node.isLeaf {
            nbEntries += 1
        }
        
        for edge in node.edges.values {
            countLeafs(node: edge.next, nbEntries: &nbEntries)
        }
    }
    
    private func dumpTree(node: Node<S>, row: inout Int, col: inout Int, action: (Int, Int, String) -> Void) {
        if node.edges.isEmpty {
            row += 1
        } else {
            for edge in node.edges.values {
                action(row, col, edge.label)
                col += 1
                dumpTree(node: edge.next, row: &row, col: &col, action: action)
                col -= 1
            }
        }
    }
}

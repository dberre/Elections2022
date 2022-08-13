//
//  SearchIndex.swift
//  Elections2022
//
//  Created by Dominique Berre on 02/07/2022.
//

import Foundation

struct SearchableCityItem: Searchable {
    let city: String
    let department: String
    let circo: Int
    
    internal init(city: String, department: String, circo: Int, keywords: [String]) {
        self.city = city
        self.department = department
        self.circo = circo
        self.keywords_ = keywords
    }
    
    private var keywords_: [String] = []
    internal var keywords: [String] {
        get { keywords_ }
    }
}


actor AutoCompleteIndexBuilder<I: SearchableIndex> where I.S == SearchableCityItem{
     
    func build(from dataModel: DataModel) -> some SearchableIndex {
        let index = self.buildIndex(dataModel: dataModel)
        print("Size: \(index.calculateSize())")
        print("Nodes: \(index.countNodes())")
        return index
    }
    
    private func buildIndex(dataModel: DataModel) -> some SearchableIndex  {
        let entries = dataModel.entries()
        let trieIndex = I()
        let tstart = Date.now
        for entry in entries {
            // TODO adding departement as below has a very bad effect on the performances
            let kwords = keywordsTokenizer(from: entry.city).union(keywordsTokenizer(from: entry.department)).map { String($0) }
            //            let kwords = keywords(from: entry.city).map { String($0) }

            let newItem =  SearchableCityItem(
                city: entry.city,
                department: entry.department,
                circo: entry.circo,
                keywords: kwords)

            trieIndex.insert(newItem)
        }
        print("\(Date.now.timeIntervalSince(tstart)) to build an index of \(entries.count) entries")
        
        return trieIndex
    }
}


@MainActor
final class AutoCompleteObject<I: SearchableIndex>: ObservableObject where I.S == SearchableCityItem {
    
    @Published var suggestions: [SearchableCityItem] = []
    
    private var trieIndex: I?
    
    func update(dataModel: DataModel) async {
        trieIndex = await AutoCompleteIndexBuilder<I>().build(from: dataModel) as? I
    }
    
    func autocomplete(_ search: String) {
        suggestions.removeAll()
        guard !search.isEmpty, let trieIndex = trieIndex else { return }
        suggestions = trieIndex.search(keywordsTokenizer(from: search).map { String($0) })
    }
}

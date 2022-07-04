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

@MainActor
final class AutoCompleteObject: ObservableObject {
    
    @Published var suggestions: [SearchableCityItem] = []
    
    // define an index dedicated to a search by City
    private var trieIndex: TrieDatastruct<SearchableCityItem>? = nil
    
    func update(dataModel: DataModel) {
        Task {
            trieIndex = buildIndex(dataModel: dataModel)
        }
    }
    
    private func buildIndex(dataModel: DataModel) -> TrieDatastruct<SearchableCityItem> {
        let entries = dataModel.entries()
        let trieIndex = TrieDatastruct<SearchableCityItem>()
        let tstart = Date.now
        for entry in entries {
            let keywords = keywords(from: entry.city).map { String($0) }
            
            trieIndex.insert(
                SearchableCityItem(
                    city: entry.city,
                    department: entry.department,
                    circo: entry.circo,
                    keywords: keywords))
        }
        print("\(Date.now.timeIntervalSince(tstart)) to build an index of \(entries.count) entries")
        
        return trieIndex
    }
    
    func autocomplete(_ search: String) {
        guard !search.isEmpty, let trieIndex = trieIndex else { return }

        suggestions = trieIndex.search(keywords(from: search).map { String($0) })
    }
    
    let separators: [Character] = [" ", "'", "-"]
    
    private func keywords(from text: String) -> [Substring] {
        let tokens =
            (text as NSString)
                .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
                .split { char in
                    separators.contains(char)
                }
        return tokens
    }
}

//
//  TablarResultView.swift
//  Elections2022
//
//  Created by Dominique Berre on 30/06/2022.
//

import SwiftUI
import Combine

struct TablarResultView: View {
    let department: String
    let circo: Int
    
    @EnvironmentObject var dataModel: DataModel
    
    @State private var data: [PoolingResult] = []
    
    @State private var cancellables = Set<AnyCancellable>()
    
    @ViewBuilder
    private var headerRow: some View {
        Text("Commune")
        Text("Votants")
        Text("Abstention")
        // next 3 hearders are not a static text and are extracted from the first row of data
        if data.count > 0 {
            let resu = data[0].results[0]
            VStack(alignment: .center) {
                Text(resu.name.capitalized)
                Text(resu.group)
            }
            
            if data[0].results.count > 1 {
                let resu = data[0].results[1]
                VStack(alignment: .center) {
                    Text(resu.name.capitalized)
                    Text(resu.group)
                }
            } else {
                Text("")
            }
            
            if data[0].results.count > 2 {
                let resu = data[0].results[2]
                VStack(alignment: .center) {
                    Text(resu.name.capitalized)
                    Text(resu.group)
                }
            } else {
                Text("")
            }
        }
    }
    
    @ViewBuilder
    private func ResultsRow(_ row: PoolingResult) -> some View {
        Text(row.cityName)
        Text(String(row.votants))
        Text(String(row.abstention))
        Text(String(row.results[0].votes))
        if row.results.count > 1 {
            Text(String(row.results[1].votesVsExpr))
        } else {
            Text("")
        }
        if row.results.count > 2 {
            Text(String(row.results[2].votesVsExpr))
        } else {
            Text("")
        }
    }
    
    @ViewBuilder
    private var bottomRow: some View {
        Text("")
        Text(String(totalExprimes() ?? 0))
        Text("")
        Text(totalVotesVsExpr(candidate: 0))
        Text(totalVotesVsExpr(candidate: 1))
        Text(totalVotesVsExpr(candidate: 2))
    }
    
    private var resultView: some View {
        ScrollView(.horizontal) {
            LazyVGrid(columns: gridColumns) {
                headerRow
            }
            ScrollView(.vertical) {
                LazyVGrid(columns: gridColumns) {
                    ForEach(data) { row in
                        ResultsRow(row)
                    }
                    bottomRow
                }
            }
        }
        .padding()
        .navigationTitle("Resultats departement: \(data[0].department) circonsription \(data[0].circoCode)")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var body: some View {
        if data.isEmpty {
            ProgressView()
                .onAppear {
                    DataModelPublisher(dataModel: dataModel, department: department, circo: circo)
                        .subscribe(on: DispatchQueue.global())
                        .receive(on: DispatchQueue.main)
                        .sink { status in
                            // nothing here
                        } receiveValue: { result in
                            self.data = result
                        }
                        .store(in: &cancellables)
                }
        } else {
            resultView
        }
    }
    
    private let gridColumns: [GridItem] = [
        .init(.fixed(200), alignment: .leading),  // City
        .init(.fixed(60), alignment: .center),  // Votant
        .init(.fixed(90), alignment: .center),  // Abstention
        .init(.fixed(150), alignment: .center),  // result1
        .init(.fixed(150), alignment: .center),  // result2
        .init(.fixed(150), alignment: .center),  // result3
    ]
    
    private func totalVotesVsExpr(candidate: Int) -> String {
        guard let total = totalExprimes(), let votes = totalVotes(candidate: candidate) else { return "" }
        guard total > 0 else { return "" }
        
        return String(format: "%.1f", (Double(votes * 100) / Double(total)))
    }
    
    private func totalVotes(candidate: Int) -> Int? {
        guard data.count > 0 else { return nil }
        guard candidate < data[0].results.count else { return nil}
        
        return data.reduce(into: Int(0)) { total, elt in
            total += elt.results[candidate].votes
        }
    }
    
    private func totalExprimes() -> Int? {
        guard data.count > 0 else { return nil }
        
        return data.reduce(into: Int(0)) { total, elt in
            total += elt.votants
        }
    }
}
    

struct TablarResultView_Previews: PreviewProvider {
    static var previews: some View {
        TablarResultView(department: "01", circo: 1)
    }
}

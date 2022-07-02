//
//  DataFrameView.swift
//  Elections2022
//
//  Created by Dominique Berre on 29/06/2022.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var dataModel: DataModel
    
    @State private var selection: String? = nil
    @State private var searchText: String = ""
    
    @State private var suggestions: [String] = []
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(dataModel.departments, id: \.self) { dept in
                        NavigationLink(tag: dept, selection: $selection) {
                            DepartmentView(department: dept)
                        } label: {
                            Text(dept)
                        }
                    }
                }
            }
            
            Text("Select one department from the list")
        }
        .searchable(text: $searchText) {
            suggestionView
        }
        .onSubmit(of: .search) {
            // TODO : build suggestion using the search
        }
    }
    
    @ViewBuilder
    private var suggestionView: some View {
        if suggestions.isEmpty {
            ForEach(suggestions, id: \.self) {
                Text($0)
            }
        } else {
            Text("No result")
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(DataModel())
    }
}

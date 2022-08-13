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
        
    @StateObject private var autoCompleteObject = AutoCompleteObject<RadixTree>()
    
    var body: some View {
        NavigationView {
            VStack {
                if searchText.isEmpty {
                    List {
                        ForEach(dataModel.departments, id: \.self) { dept in
                            NavigationLink(tag: dept, selection: $selection) {
                                DepartmentView(department: dept)
                            } label: {
                                Text(dept)
                            }
                        }
                    }
                } else {
                    if !autoCompleteObject.suggestions.isEmpty {
                        List {
                            ForEach(autoCompleteObject.suggestions.prefix(15), id: \.self) { suggestion in
                                NavigationLink {
                                    TablarResultView(department: suggestion.department, circo: suggestion.circo)
                                } label: {
                                    Text("\(suggestion.city) - \(suggestion.department)")
                                }
                            }
                            let remainder = autoCompleteObject.suggestions.count
                            if remainder > 15 {
                                Text("\(remainder - 15) more ...")
                            }
                        }
                    } else {
                        Text("No result")
                    }
                }
            }
            
            Text("Select one department from the list")
        }
        .searchable(text: $searchText) { }
        .disableAutocorrection(true)
        .autocapitalization(.none)
        .onChange(of: searchText) { newValue in
            autoCompleteObject.autocomplete(newValue)
        }
        .task {
            await autoCompleteObject.update(dataModel: dataModel)
            print("Leave task bloc")
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(DataModel())
    }
}

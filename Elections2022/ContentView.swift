//
//  ContentView.swift
//  Elections2022
//
//  Created by Dominique Berre on 29/06/2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataModel = DataModel()
        
    var body: some View {
        EmptyView()
        switch dataModel.state {
        case .loading:
            ProgressView()
        case .complete:
            MainView()
                .environmentObject(dataModel)
        case .idle:
            Text("Welcome to Election 2022")
                .onAppear {
                    dataModel.loadAsync { _ in
                        print("Data model loaded")
                    }
                }
        default:
            Text("Can't load data")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

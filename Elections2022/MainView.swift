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
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(dataModel.departments, id: \.self) { dept in
                        NavigationLink(dept, tag: dept, selection: $selection) {
                            DepartmentView(department: dept)
                        }
                    }
                }
            }
            
            Text("Select a department from the list")
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(DataModel())
    }
}

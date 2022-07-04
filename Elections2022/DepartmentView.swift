//
//  DepartmentView.swift
//  Elections2022
//
//  Created by Dominique Berre on 30/06/2022.
//

import SwiftUI

struct DepartmentView: View {
    let department: String
    
    @EnvironmentObject private var dataModel: DataModel
    @State private var selection: Int? = nil
    
    var circos: [Int] {
        dataModel.circos(for: department)
    }
    
    var body: some View {
        List {
            ForEach(circos, id: \.self) { circo in
                NavigationLink("\(circo)", tag: circo, selection: $selection) {
                    TablarResultView(department: department, circo: circo)
                }
            }
        }
        .padding()
        .navigationTitle("Circonscriptions of departement: \(department)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DepartmentView_Previews: PreviewProvider {
    static var previews: some View {
        DepartmentView(department: "")
    }
}

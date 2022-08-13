//
//  Searchable.swift
//  Elections2022
//
//  Created by Dominique Berre on 09/08/2022.
//

import Foundation

protocol Searchable: Hashable {
    var keywords: [String] { get }
}

//
//  FilleManager-DocumentsDirectory.swift
//  SimpleScores
//
//  Created by Dominique Berre on 01/05/2022.
//

import Foundation

extension FileManager {
    static var documentDirectory: URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0]
    }
}

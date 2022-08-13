//
//  FileManager-DocumentDirectory.swift
//  PingPong
//
//  Created by Dominique Berre on 03/07/2022.
//

import Foundation

extension FileManager {
    static var documentDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(paths)
        return paths[0]
    }
}

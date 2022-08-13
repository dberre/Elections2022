//
//  KeywordsTokenizer.swift
//  Elections2022
//
//  Created by Dominique Berre on 13/08/2022.
//

import Foundation

func keywordsTokenizer(from text: String) -> Set<Substring> {
    let tokens =
        (text as NSString)
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
            .split { char in
                char.isWhitespace || char.isPunctuation
            }

    return Set(tokens)
}

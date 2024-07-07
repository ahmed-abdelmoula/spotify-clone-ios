//
//  Category.swift
//  spotifyClone
//
//  Created by Ahmed Mac on 24/6/2023.
//

import Foundation

struct CategoryItems: Codable {
    let items: [Category]
    
}

struct Category: Codable {
    let id: String
    let name: String
    let icons: [APIImage]
}

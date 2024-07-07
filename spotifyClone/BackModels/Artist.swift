//
//  Artist.swift
//  spotifyClone
//
//  Created by Ahmed Mac on 13/6/2023.
//

import Foundation

struct Artist: Codable {
    let id: String
    let name: String
    let type: String
    let images: [APIImage]?
    let external_urls: [String : String]

}


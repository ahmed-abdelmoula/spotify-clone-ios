//
//  Playlist.swift
//  spotifyClone
//
//  Created by Ahmed Mac on 13/6/2023.
//

import Foundation
struct Playlist: Codable {
    let description: String
    let external_urls: [String : String]
    let id: String
    let images: [APIImage]
    let name: String
    let owner: User
}

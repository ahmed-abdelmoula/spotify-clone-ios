//
//  LibraryAlbumsResponse.swift
//  spotifyClone
//
//  Created by Ahmed Mac on 30/6/2023.
//

import Foundation

struct LibraryAlbumsResponse  : Codable {
    let items : [SavedAlbum]
}

struct SavedAlbum : Codable{
    let added_at : String
    let album : Album
}

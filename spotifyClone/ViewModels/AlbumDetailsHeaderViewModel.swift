//
//  AlbumDetailsHeaderViewModel.swift
//  spotifyClone
//
//  Created by Ahmed Mac on 23/6/2023.
//

import Foundation

struct AlbumDetailsHeaderViewModel: Codable {
    let albumCoverImage: URL?
    let albumName: String
    let releaseDate: String
    let artistName: String
    
}

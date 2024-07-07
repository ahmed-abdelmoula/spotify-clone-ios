//
//  SearchResultResponse.swift
//  spotifyClone
//
//  Created by Ahmed Mac on 25/6/2023.
//

import Foundation

struct SearchResultResponse : Codable {
    let albums : AlbumResponse
    let artists : SearchArtistsResponse
    let tracks : TracksResponse
    let playlists : PlaylistResponse
}

struct SearchArtistsResponse :Codable{
    let items : [Artist]
}

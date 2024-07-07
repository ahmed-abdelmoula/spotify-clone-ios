//
//  SearchResultEnum.swift
//  spotifyClone
//
//  Created by Ahmed Mac on 25/6/2023.
//

import Foundation
// we used this approch when setup our browse collection view section
enum SearchResult {
    case artist(model: Artist)
    case album(model: Album)
    case track(model: AudioTrack)
    case playlist(model: Playlist)
    
}

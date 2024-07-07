//
//  NewReleasesResponse.swift
//  spotifyClone
//
//  Created by Ahmed Mac on 19/6/2023.
//

import Foundation

struct NewReleasesResponse: Codable {
    let albums: AlbumResponse
}

struct AlbumResponse: Codable {
    let items: [Album]
}
struct Album: Codable {
    let album_type: String
    let available_markets: [String]
    var id: String
    var images: [APIImage]
    let name: String
    let release_date: String
    let total_tracks: Int
    let artists: [Artist]
}




/*
 albums =     {
     href = "https://api.spotify.com/v1/browse/new-releases?country=TN&locale=fr-FR%2Cfr%3Bq%3D0.9&offset=0&limit=50";
     items =         (
                     {
             "album_type" = single;
             artists =                 (
                                     {
                     "external_urls" =                         {
                         spotify = "https://open.spotify.com/artist/0CaWnepnGfVPs8uNwOzav6";
                     };
                     href = "https://api.spotify.com/v1/artists/0CaWnepnGfVPs8uNwOzav6";
                     id = 0CaWnepnGfVPs8uNwOzav6;
                     name = "Zouhair Bahaoui";
                     type = artist;
                     uri = "spotify:artist:0CaWnepnGfVPs8uNwOzav6";
                 }
             );
             "available_markets" =                 (
                 ZM,
                 ZW
             );
             "external_urls" =                 {
                 spotify = "https://open.spotify.com/album/5wkvSfHw9t6Vien59gb48s";
             };
             href = "https://api.spotify.com/v1/albums/5wkvSfHw9t6Vien59gb48s";
             id = 5wkvSfHw9t6Vien59gb48s;
             images =                 (
                                     {
                     height = 640;
                     url = "https://i.scdn.co/image/ab67616d0000b273a1a9ca54a87acdfbc121b3e4";
                     width = 640;
                 },
                                     {
                     height = 300;
                     url = "https://i.scdn.co/image/ab67616d00001e02a1a9ca54a87acdfbc121b3e4";
                     width = 300;
                 },
                                     {
                     height = 64;
                     url = "https://i.scdn.co/image/ab67616d00004851a1a9ca54a87acdfbc121b3e4";
                     width = 64;
                 }
             );
             name = "YA LE3DOUWA";
             "release_date" = "2022-11-05";
             "release_date_precision" = day;
             "total_tracks" = 1;
             type = album;
             uri = "spotify:album:5wkvSfHw9t6Vien59gb48s";
         },
 
 
 
 */

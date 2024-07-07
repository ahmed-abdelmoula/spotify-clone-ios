//
//  UserProfile.swift
//  spotifyClone
//
//  Created by Ahmed Mac on 13/6/2023.
//

import Foundation

struct UserProfile: Codable {
    let country: String
    let display_name: String
//    let email: String
 //   let explicit_content: [String : Int]
   // let external_urls: [String : String]
    let id: String
    let product: String
    let images: [APIImage]
}



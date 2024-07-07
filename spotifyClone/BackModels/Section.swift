//
//  Section.swift
//  spotifyClone
//
//  Created by Ahmed Mac on 17/6/2023.
//

import Foundation

struct Section  {
   let  title : String
   let  options  : [Option]
}
struct Option  {
  let  title : String
  let  handler : () -> Void
}

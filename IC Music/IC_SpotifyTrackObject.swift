//
//  SpotifyTrackObject.swift
//  es
//
//  Created by Richard Smith on 2023-04-25.
//

import Foundation

struct IC_SpotifyTrackObject: Codable {

    enum CodingKeys: String, CodingKey {
        case name, uri, duration_ms
    }
    
    let name: String?
    let uri: String?
  let duration_ms: Int?
}

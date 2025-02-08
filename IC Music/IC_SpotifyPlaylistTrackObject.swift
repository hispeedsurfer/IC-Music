//
//  SpotifyPlaylistTrackObject.swift
//  es
//
//  Created by Richard Smith on 2023-04-25.
//

import Foundation

struct IC_SpotifyPlaylistTrackObject: Codable {

    enum CodingKeys: String, CodingKey {
        case track, name, uri//, nDurationMs
        case addedAt = "added_at"
        case isLocal = "is_local"
    }
    
    let addedAt: String?
    let isLocal: Bool?
    let track: IC_SpotifyTrackObject?
    let name: String?
    let uri: String?
  //let nDurationMs: Int?
}

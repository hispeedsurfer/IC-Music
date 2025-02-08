//
//  SpotifyTracks.swift
//  es
//
//  Created by Richard Smith on 2023-04-20.
//

import Foundation

struct IC_SpotifyTracks: Codable {

    enum CodingKeys: String, CodingKey {
        case href, total, items//, nTotalDuration
    }

    let href: String?
    let total: Int?
  let items: [IC_SpotifyPlaylistTrackObject?]
  //let nTotalDuration: Int?
}


//
//  SimplifiedPlaylistObject.swift
//  es
//
//  Created by Richard Smith on 2023-04-20.
//

import Foundation

struct IC_SimplifiedPlaylistObject: Codable {

    enum CodingKeys: String, CodingKey {
        case collaborative, description, href, id, images, name, type, uri, tracks, owner//, nTotalDuration
        case externalURLs = "external_urls"
        case `public` = "public"
        case snapshotID = "snapshot_id"
        case primaryColor = "primary_color"
    }
    
    let collaborative: Bool?
    let description: String?
    let externalURLs: IC_SpotifyExternalURLs?
    let href: String?
    let id: String?
    let images: [IC_SpotifyImages?]
    let name: String?
    let owner: IC_SpotifyOwner?
    let `public`: Bool?
    let snapshotID: String?
    let tracks: IC_SpotifyTracks?
    let type: String?
    let uri: String?
    let primaryColor: Double?
  //let nTotalDuration: Int?
}


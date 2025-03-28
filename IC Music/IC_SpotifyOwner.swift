//
//  SpotifyOwner.swift
//  es
//
//  Created by Richard Smith on 2023-04-20.
//

import Foundation

struct IC_SpotifyOwner: Codable {

    enum CodingKeys: String, CodingKey {
        case href, id, type, uri, followers
        case externalURLs = "external_urls"
        case displayName = "display_name"
    }
    
    let externalURLs: IC_SpotifyExternalURLs?
    let followers: IC_SpotifyFollowers?
    let href: String?
    let id: String?
    let type: String?
    let uri: String?
    let displayName: String?
}

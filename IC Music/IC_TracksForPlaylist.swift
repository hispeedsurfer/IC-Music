//
//  TracksForPlaylist.swift
//  es
//
//  Created by Richard Smith on 2023-04-25.
//

import Foundation

struct IC_TracksForPlaylist: Identifiable {
    let id = UUID()
    
    var name: String
    var total: Int
    var trackObject: [IC_TrackObject]
}

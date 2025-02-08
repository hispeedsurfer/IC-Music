//
//  TrackObject.swift
//  es
//
//  Created by Richard Smith on 2023-04-25.
//

import Foundation

struct IC_TrackObject: Identifiable {

    let id = UUID()
    
    var name: String
    var uri: String
    var nDurationMs: Int
}

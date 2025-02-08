//
//  SearchResult.swift
//  IC Music
//
//  Created by Andreas Franke on 21.01.25.
//



struct IC_SearchResult {
  let tracks: SearchResultTracks
  let playList: String
  let nTotalDurationMSec: Int
}

struct SearchResultTracks: Hashable {
  let searchResultIdx: SearchResultIdx
}

struct SearchResultIdx: Hashable {
  let items: [Int: IC_TrackInfo]
  let dictUriIdx: [String : Int]
}

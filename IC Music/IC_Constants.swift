//
//  Constants.swift
//  es
//
//  Created by Richard Smith on 2023-04-18.
//

import Foundation

let accessTokenKey = "access-token-key"
#if DEBUG
let redirectURI = URL(
  string: "hispeedsurfericmusicdev://devcallback"
)!
#else
let redirectURI = URL(
  string: "hispeedsurfericmusic://callback"
)!
#endif
let spotifyClientID = ""
let spotifyCLientSecretKey = ""

let scopes: SPTScope = [
  .userReadEmail,
  .userReadPrivate,
  .userReadPlaybackState,
  .userModifyPlaybackState,
  .userReadCurrentlyPlaying,
  .streaming,
  .appRemoteControl,
  .playlistReadCollaborative,
  .playlistModifyPublic,
  .playlistReadPrivate,
  .playlistModifyPrivate,
  .userLibraryModify,
  .userLibraryRead,
  .userTopRead,
  .userReadPlaybackState,
  .userReadCurrentlyPlaying,
  .userFollowRead,
  .userFollowModify
]
let stringScopes = ["user-read-email", "user-read-private",
                    "user-read-playback-state", "user-modify-playback-state", "user-read-currently-playing",
                    "streaming", "app-remote-control",
                    "playlist-read-collaborative", "playlist-modify-public", "playlist-read-private", "playlist-modify-private",
                    "user-library-modify", "user-library-read",
                    "user-top-read", "user-read-playback-position", "user-read-recently-played",
                    "user-follow-read", "user-follow-modify"]

enum UserKeys: String, CaseIterable{
  case initialImport = "InitialImport"
  case fontoSize = "FontoSize"
  case prestige = "USER_PRESTIGE"
  case glory = "USER_GLORY"
  case armor = "USER_ARMOR"
  case speed = "USER_SPEED"
  case damage = "USER_DAMAGE"
}

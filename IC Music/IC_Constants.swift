//
//  Constants.swift
//  es
//
//  Created by Richard Smith on 2023-04-18.
//

import Foundation

let accessTokenKey = "access-token-key"
let redirectURI = URL(string: "hispeedsurfericmusic://callback")!//URL(string: "es://hispeedsurfer")!
let spotifyClientID = "5f308760d35546d3aa83003c0958af66"//"f99de9449183486c9d106b5f36a39e1b"
let spotifyCLientSecretKey = "ed0ba77269f14dc2baae58cbdbccd298"// "08b56e0806d54767a8975772161006bf"

let scopes: SPTScope = [.userReadEmail, .userReadPrivate, .userReadPlaybackState, .userModifyPlaybackState, .userReadCurrentlyPlaying, .streaming, .appRemoteControl, .playlistReadCollaborative, .playlistModifyPublic, .playlistReadPrivate, .playlistModifyPrivate, .userLibraryModify, .userLibraryRead, .userTopRead, .userReadPlaybackState, .userReadCurrentlyPlaying, .userFollowRead, .userFollowModify]
let stringScopes = ["user-read-email", "user-read-private",
                    "user-read-playback-state", "user-modify-playback-state", "user-read-currently-playing",
                    "streaming", "app-remote-control",
                    "playlist-read-collaborative", "playlist-modify-public", "playlist-read-private", "playlist-modify-private",
                    "user-library-modify", "user-library-read",
                    "user-top-read", "user-read-playback-position", "user-read-recently-played",
                    "user-follow-read", "user-follow-modify"]

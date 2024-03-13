//
//  SpotifyLoginView.swift
//  es
//
//  Created by Richard Smith on 2023-04-17.
//

import SwiftUI

struct IC_SpotifyLoginView: View {
    
    @ObservedObject var spotifyDefaultViewModel: IC_SpotifyDefaultViewModel
    @ObservedObject var spotifyLoginViewModel: IC_SpotifyLoginViewModel
    
    /*
    init(spotifyDefaultViewModel: IC_SpotifyDefaultViewModel) {
        self.spotifyDefaultViewModel = spotifyDefaultViewModel
        self.spotifyLoginViewModel = IC_SpotifyLoginViewModel(spotifyDefaultViewModel: spotifyDefaultViewModel)
    }
    */
    
    /* only to clear the accessTokenKey
     */
    init(spotifyDefaultViewModel: IC_SpotifyDefaultViewModel) {
        self.spotifyDefaultViewModel = spotifyDefaultViewModel
        self.spotifyLoginViewModel = IC_SpotifyLoginViewModel(spotifyDefaultViewModel: spotifyDefaultViewModel)
        //UserDefaults.standard.set(nil, forKey: accessTokenKey)
    }
    
    
    var body: some View {
        switch spotifyLoginViewModel.authState {
        case .idle:
            LazyVStack {
                Text(spotifyLoginViewModel.loginTitle)
                    .font(.title)
                    .padding()
                Button {
                    self.spotifyLoginViewModel.connectUser()
                } label: {
                    Text(self.spotifyLoginViewModel.userConnectionButtonTitle)
                }
                Spacer()
                Button(action: {
                    UserDefaults.standard.removeObject(forKey: accessTokenKey)
                }) {
                    Text("Clear UserDefault accessTokenKey")
                }
                Spacer()
                Button(action: {
                    spotifyDefaultViewModel.connect()
                }) {
                    Text("authoriye and play")
                }
            }
        case .loading:
            ProgressView()
        case .error:
            Text("ERROR")
        case .authorized:
            IC_SpinningPlaylistView(/*spotifyDefaultViewModel: spotifyDefaultViewModel*/)
        }
    }
}

/*
 struct IC_SpotifyLoginView_Previews: PreviewProvider {
 static var previews: some View {
 IC_SpotifyLoginView(spotifyDefaultViewModel: spotifyDefaultViewModel)
 }
 }
 */

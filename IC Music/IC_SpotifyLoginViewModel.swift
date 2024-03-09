//
//  SpotifyLoginViewModel.swift
//  es
//
//  Created by Richard Smith on 2023-04-17.
//

import Foundation
import Combine
import SwiftUI

class IC_SpotifyLoginViewModel: ObservableObject {
    
    @ObservedObject var spotifyDefaultViewModel: IC_SpotifyDefaultViewModel// = { IC_SpotifyDefaultViewModel.shared } ()
    
    @Published var authState: AuthenticationState = AuthenticationState.idle
    
    var loginTitle = String(localized: "loginTextFieldTitleForNotConnected")
    var userConnectionButtonTitle = String(localized: "loginUserConnectionButtonTitleForNotConnected")
    
    private var bag = Set<AnyCancellable>()
    
    init(spotifyDefaultViewModel: IC_SpotifyDefaultViewModel) {
        self.spotifyDefaultViewModel = spotifyDefaultViewModel
        bind()
    }
    
    deinit {
        bag.removeAll()
    }
    
    func connectUser() {
        self.spotifyDefaultViewModel.connectUser()
    }
    
    private func bind() {
        spotifyDefaultViewModel.$authenticationState
            .sink { [weak self] authState in
                self?.authState = authState
            }.store(in: &bag)
    }
}

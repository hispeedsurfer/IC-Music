//
//  IC_SliderMusic.swift
//  IC Music
//
//  Created by Andreas Franke on 10.03.24.
//

import SwiftUI

struct IC_SliderMusic: View {

  @StateObject var spotifyDefaultViewModel: IC_SpotifyDefaultViewModel = { IC_SpotifyDefaultViewModel.shared }()

  @AppStorage(UserKeys.fontoSize.rawValue) var fontoSize: Double = 22.0

  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 5) {
        Text("\(spotifyDefaultViewModel.formatElapsedTime(seconds: self.spotifyDefaultViewModel.nCurrentPlaylistElapsedTimeSeconds))")
          .font(.system(size: fontoSize * 0.9))

        Slider(
          value: $spotifyDefaultViewModel.playbackPositionPlaylistMs,
          in: 0.0...Double(spotifyDefaultViewModel.nTotalDurationMSec)
        )
        .gesture(DragGesture(minimumDistance: 0))
        .onAppear {
          let progressCircleConfig = UIImage.SymbolConfiguration(scale: .small)
          UISlider.appearance().setThumbImage(
            UIImage(systemName: "circle.fill", withConfiguration: progressCircleConfig),
            for: .normal
          )
        }

        Text("\(spotifyDefaultViewModel.formatElapsedTime(seconds: (self.spotifyDefaultViewModel.nTotalDurationMSec / 1000)))")
          .font(.system(size: fontoSize * 0.9))
      }

      HStack(spacing: 5) {
        Text("\(spotifyDefaultViewModel.formatElapsedTime(seconds: self.spotifyDefaultViewModel.currentElapsedTimeSec))")
          .font(.system(size: fontoSize * 0.9))

        Slider(
          value: $spotifyDefaultViewModel.playbackPositionMs,
          in: 0.0...Double(spotifyDefaultViewModel.currentDurationMs)
        )
        .gesture(DragGesture(minimumDistance: 0))
        .onAppear {
          let progressCircleConfig = UIImage.SymbolConfiguration(scale: .small)
          UISlider.appearance().setThumbImage(
            UIImage(systemName: "circle.fill", withConfiguration: progressCircleConfig),
            for: .normal
          )
        }

        Text("\(spotifyDefaultViewModel.currentDurationLabel)")
          .font(.system(size: fontoSize * 0.9))
      }
    }
  }
}

#Preview {
  IC_SliderMusic()
}

//
//  IC_SliderMusic.swift
//  IC Music
//
//  Created by Andreas Franke on 10.03.24.
//

import SwiftUI

struct IC_SliderMusic: View {

  @StateObject var spotifyDefaultViewModel: IC_SpotifyDefaultViewModel = { IC_SpotifyDefaultViewModel.shared } ()

  @AppStorage(UserKeys.fontoSize.rawValue) var fontoSize: Double = 22.0

  var body: some View {
    HStack(spacing:10){
      Text("\(spotifyDefaultViewModel.elapsedTimeLabel)")
        .font(.system(size: fontoSize*0.9))
      //.padding()

      Slider(
        value: $spotifyDefaultViewModel.playbackPosition,
        in: 0.0...Double(spotifyDefaultViewModel.currentDuration)
      )
      .onReceive(spotifyDefaultViewModel.$currentTimeInSecondsPass) { _ in
        // here I changed the value every second
        spotifyDefaultViewModel.playbackPosition = spotifyDefaultViewModel.currentTimeInSecondsPass
      }
      // controlling rewind
      .gesture(DragGesture(minimumDistance: 0))
      .onAppear { //for a smaler slider
        let progressCircleConfig = UIImage.SymbolConfiguration(scale: .small)
        UISlider.appearance()
          .setThumbImage(UIImage(systemName: "circle.fill",
                                 withConfiguration: progressCircleConfig), for: .normal)
      }

      Text("\(spotifyDefaultViewModel.currentDurationLabel)")
        .font(.system(size: fontoSize*0.9))
      //.padding()
    }
    .padding(5)
  }
}

#Preview {
  IC_SliderMusic()
}

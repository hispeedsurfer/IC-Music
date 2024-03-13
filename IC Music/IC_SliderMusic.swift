//
//  IC_SliderMusic.swift
//  IC Music
//
//  Created by Andreas Franke on 10.03.24.
//

import SwiftUI

struct IC_SliderMusic: View {
    
    @StateObject var spotifyDefaultViewModel: IC_SpotifyDefaultViewModel = { IC_SpotifyDefaultViewModel.shared } ()
    
    var body: some View {
        HStack(spacing:10){
            Text("\(spotifyDefaultViewModel.elapsedTimeLabel)")
            //.padding()
            
            Slider(value: $spotifyDefaultViewModel.playbackPosition, in: 0.0...Double(spotifyDefaultViewModel.currentDuration))
                .onReceive(spotifyDefaultViewModel.$currentTimeInSecondsPass) { _ in
                    // here I changed the value every second
                    spotifyDefaultViewModel.playbackPosition = spotifyDefaultViewModel.currentTimeInSecondsPass
                }
            // controlling rewind
                .gesture(DragGesture(minimumDistance: 0))
            
            Text("\(spotifyDefaultViewModel.currentDurationLabel)")
            //.padding()
        }
        .padding(5)
    }
}

#Preview {
    IC_SliderMusic()
}

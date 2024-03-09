//
//  TrackDetailView.swift
//  NowPlayingView
//
//  Created by Andreas Franke on 21.02.24.
//  Copyright © 2024 Spotify. All rights reserved.
//

import SwiftUI
import CoreData

// create a swiftui view with a TextEditor that is read-only by default and can be switch do edit mode. Above the TextEditor there are two vertical fields, one read-only named "BPM Spotify" the other is named "BPM user" can switched to edit mode with the TextEditor.

struct IC_TrackDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var trackInfo: IC_TrackInfo
    
    @Binding var isEditable: Bool
    
    @ObservedObject var trackInfoAfter: IC_TrackInfo
    
    var body: some View {
        VStack (spacing: 5) {
            
            TextEditor(text: Binding($trackInfo.customInfo)!)
                .disabled(!isEditable)
                .foregroundColor(Color.gray)
                .font(.custom("HelveticaNeue", size: 25))
                .lineSpacing(5)
            //.padding()
            Divider()
            VStack {
                Text("RPM User: \(trackInfoAfter.rpmUser ?? "")")
                TextEditor(text: Binding($trackInfoAfter.customInfo)!)
                    .disabled(!isEditable)
                    .foregroundColor(Color.gray)
                    .font(.custom("HelveticaNeue", size: 20))
                    .lineSpacing(3)
                //.padding()
            }
        }
        .navigationTitle("\(trackInfo.trackTitle ?? "Unknown track")")
        .navigationBarItems(leading:
                                VStack {
            HStack (spacing: 5) {
                Text("BPM User: ")
                if trackInfoAfter.rpmUser != nil {
                    TextField("RPM User", text: Binding($trackInfo.rpmUser)!).disabled(!isEditable)
                }
            }
            HStack (spacing: 5) {
                Text("BPM Spotify: \(String(format: "%.0f", trackInfo.bpmSpotify))")
                Spacer()
            }
        }
                            //.padding()
                            //.frame(width: geometry.size.width)
        )
    }
}

struct IC_TrackDetailView_Previews: PreviewProvider {
    static var previews: some View {
        IC_TrackDetailView(trackInfo: IC_TrackInfo(), isEditable: .constant(false), trackInfoAfter: IC_TrackInfo())
    }
}


// Create a detail view that shows the track information and allows the user to enter and save custom information
struct IC_TrackDetailViewOld: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var trackInfo: IC_TrackInfo
    
    var body: some View {
        VStack {
            TextField("Enter custom information", text: Binding($trackInfo.customInfo)!)
                .padding()
                .border(Color.gray)
            
            TextEditor(text: Binding($trackInfo.customInfo)!)
                .foregroundColor(Color.gray)
                .font(.custom("HelveticaNeue", size: 25))
                .lineSpacing(5)
            Button("Save") {
                //trackInfo.customInfo = customInfo
                try? viewContext.save()
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.green)
            .cornerRadius(10)
            Button("Delete") {
                // Delete the TrackInfo object from Core Data
                //viewContext.delete(trackInfo.first!)
                //try? viewContext.save()
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.red)
            .cornerRadius(10)
        }
    }
}


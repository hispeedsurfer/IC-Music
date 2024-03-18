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
    @StateObject var trackInfo: IC_TrackInfo
    
    @State var refreshID = UUID()
    
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    @Binding var isEditable: Bool
    
    @StateObject var trackInfoAfter: IC_TrackInfo
    
    let amountFormatter: NumberFormatter = {
         let formatter = NumberFormatter()
         formatter.zeroSymbol = ""
         return formatter
    }()
    
    var body: some View {
        VStack (spacing: 5) {
            
            TextEditor(text: Binding($trackInfo.customInfo)!)
                .disabled(!isEditable)
                .font(.system(size: 25))
                .foregroundColor(Color.blue)
                //.padding()
                .cornerRadius(10)
                .lineSpacing(5)
                .multilineTextAlignment(.leading)
                //.padding()
            Divider()
            VStack {
                ZStack {
                    HStack {
                        Text("RPM User: \(trackInfoAfter.rpmUser ?? "")").font(.system(size: 15)).padding([.leading])
                        Spacer()
                    }
                    
                    HStack{
                        Text("\(trackInfoAfter.trackTitle ?? "")")
                    }

                    HStack {
                        Spacer()
                        Text("BPM Spotify: \(String(format: "%.0f", trackInfoAfter.bpmSpotify))").font(.system(size: 15)).padding([.trailing])
                    }
                }
                    .padding(0)
                TextEditor(text: Binding($trackInfoAfter.customInfo)!)
                    .disabled(!isEditable)
                    .font(.system(size: 22))
                    .foregroundColor(Color.blue)
                    .cornerRadius(10)
                    .lineSpacing(5)
                    .multilineTextAlignment(.leading)
                //.padding()
            }
        }.onChange(of: verticalSizeClass, { oldValue, newValue in
            refreshID = UUID()
        })
        .onChange(of: horizontalSizeClass, { oldValue, newValue in
            refreshID = UUID()
        })
        .toolbarBackground(Color(UIColor.lightGray), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar (content: ) {
            ToolbarItem(placement:.topBarLeading){
                HStack {
                    VStack {
                        HStack (spacing: 0) {
                            Text("Dancebility: \(String(format: "%.3f", trackInfo.danceability))")
                        }
                        HStack (spacing: 0) {
                            Text("Energy: \(String(format: "%.3f", trackInfo.energy))")
                            Spacer()
                        }
                    }.padding([.trailing])
                }
                //.padding()
                //.frame(width: geometry.size.width)
            }
            
            ToolbarItem(placement:.topBarTrailing){
                HStack {
                    VStack {
                        HStack (spacing: 0) {
                            Text("RPM User: ")
                            TextField("RPM User", text: Binding($trackInfo.rpmUser)!).disabled(!isEditable).disableAutocorrection(true)
                        }
                        HStack (spacing: 0) {
                            Text("BPM Spotify: \(String(format: "%.0f", trackInfo.bpmSpotify))")
                            //TextField("BPM Spotify", value: $trackInfo.bpmSpotify, formatter: amountFormatter).keyboardType(.decimalPad).disabled(!isEditable)
                            Spacer()
                        }
                    }.padding([.trailing])
                }
                //.padding()
                //.frame(width: geometry.size.width)
            }
        }
        .id(refreshID)// Work around to get disappearing tool bar items visible >> https://stackoverflow.com/questions/77399056/swiftui-toolbaritem-button-disappears-after-rotation-in-ios17
        .navigationTitle("\(trackInfo.trackTitle ?? "Unknown track")")
        .toolbarTitleDisplayMode(.inline) // for a smaller toolbar
    }
}

struct IC_TrackDetailView_Previews: PreviewProvider {
    static var previews: some View {
        IC_TrackDetailView(trackInfo: IC_TrackInfo(), isEditable: .constant(false), trackInfoAfter: IC_TrackInfo())
    }
}



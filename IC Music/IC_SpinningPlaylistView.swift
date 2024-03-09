//
//  SpinningPlaylistView.swift
//  NowPlayingView
//
//  Created by Andreas Franke on 21.02.24.
//  Copyright © 2024 Spotify. All rights reserved.
//

import SwiftUI
import CoreData


// a SwiftUI view to hold the playlist data
// For this view i need an input field for an spotify uri and an button to read this input into a variable.
// After reading the input from uri and load the content of the playlist, i want to display the playlist title and the tracks in a list of a NavigationSplitView and show details on selection of an item of the track list. Each track is identified by an string based identifier named spotifyURI.

struct TrackInit {
    var trackUri: String
    var trackTitle: String
    //var spotifyId: String
    //var tempo: Double
}

struct ItemCard: View {
    @ObservedObject var item: IC_TrackInfo
    var body: some View {
        Text("\(item.trackTitle ?? "")") // The ?? value is just to work around NavigationLink hanging on to this View and body being run after it was deleted which crashes if it was force unwrapped.
    }
}

struct IC_SpinningPlaylistView: View {
    @ObservedObject var spotifyDefaultViewModel: IC_SpotifyDefaultViewModel
    
    init(spotifyDefaultViewModel: IC_SpotifyDefaultViewModel) {
        self.spotifyDefaultViewModel = spotifyDefaultViewModel
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont.preferredFont(forTextStyle: .subheadline)]
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont.preferredFont(forTextStyle: .subheadline)]
    }
    
    @AppStorage("InitialImport") var importShouldBeShown = true
    
    //@StateObject var spinningPlaylistsViewModel = IC_SpinningPlaylistViewModel()
    
    @Environment(\.managedObjectContext) var viewContext
    @State var playlistURI = ""
    @State var contentItem: SPTAppRemoteContentItem?
    @State var trackItmems = [Int : IC_TrackInfo]()
    @State var dictUriIdx = [String : Int]()
    @State var error: Error?
    @State var currentSongBeingPlayed: String = ""
    //@State  var trackInfo: IC_TrackInfo?
    @State private var playerState: SPTAppRemotePlayerState?
    
    @State private var document = ""
    
    var trackInfoEmpty: IC_TrackInfo {
        let trackInfo = IC_TrackInfo(context: viewContext)
        trackInfo.trackTitle = "Unknown Track"
        trackInfo.bpmSpotify = 0
        trackInfo.rpmUser = "Unknown"
        return trackInfo
    }
    
    private func binding(for key: String) -> Binding<Int?> {
        return .init(
            get: { self.dictUriIdx[key, default: 0] },
            set: { _ in self.dictUriIdx[key] = self.dictUriIdx[key] })
    }
    
    private func getPlayerState() {
        spotifyDefaultViewModel.appRemote.playerAPI?.getPlayerState { (result, error) -> Void in
            guard error == nil else { return }
            
            //let playerState = result as! SPTAppRemotePlayerState
            //self.updateViewWithPlayerState(playerState)
        }
    }
    
    func appRemoteConnected() {
        getPlayerState()
        
        //enableInterface(true)
    }
    
    func updatePlayerState(playerState: SPTAppRemotePlayerState) {
        self.playerState = playerState
        self.currentSongBeingPlayed = playerState.track.name
        //let duration: UInt = playerState.track.duration
        //playerState.playbackPosition
        //updateViewWithPlayerState(playerState)
    }
    
    
    @State var isEditable = false
    @State private var isImporting: Bool = false
    @State private var isExorting: Bool = false
    
    @State
    private var isExporting = false
    
    @State
    private var zipFile: ZipFile?
    
    @State private var showingConfirmationDialog = false
    private func export()
    {
        Task { @MainActor in
            do
            {
                let zipPath = spotifyDefaultViewModel.copyPersistentStore()
                let zipURL = URL(fileURLWithPath: zipPath)
                
                self.zipFile = try ZipFile(zipURL: zipURL)
                self.isExporting = true
            }
            catch
            {
                print("Could not export .zip:", error)
            }
        }
    }
    
    func fetchPlayerState() {
        spotifyDefaultViewModel.appRemote.playerAPI?.getPlayerState({ (playerState, error) in
            if let error = error {
                print(APIError.fetchingPlayerStateFailedWithError(error))
            } else if let playerState = playerState as? SPTAppRemotePlayerState {
                self.update(playerState: playerState)
            }
        })
    }
    
    func update(playerState: SPTAppRemotePlayerState) {
        let playlistUri = playerState.contextURI.absoluteString
        
        if playlistUri != self.playlistURI {
            //if false {
            self.playlistURI = playlistUri
            
            if self.playlistURI != "" {
                spotifyDefaultViewModel.getSearch(playlistURI: playlistURI, playTrack: false){ result in
                    //self.query = txt
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let success):
                            self.trackItmems = success.tracks.searchResultIdx.items
                            self.dictUriIdx = success.tracks.searchResultIdx.dictUriIdx
                            //self.playlistURI = ""
                            self.contentItem = success.playList
                        case .failure(let error):
                            print( "tes \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
    
    var body: some View {
        
        HStack {
            
            Button(action: {
                self.showingConfirmationDialog = true
            }) {
                Text("Import File")
            }
            .disabled(!importShouldBeShown)
            .confirmationDialog("Are you sure you want to disable the import button?", isPresented: $showingConfirmationDialog) {
                Button("Disable", role: .destructive) {
                    self.importShouldBeShown = false
                }
                Button("Cancel", role: .cancel) {}
                Button("Import") {
                    self.isImporting = true
                }
            }
            
            Button(action: export) {
                Label("Export ZIP", systemImage: "square.and.arrow.up")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
            }.fileExporter(isPresented: self.$isExporting, document: self.zipFile, contentType: .zip) { result in
                print("Exported ZIP:", result)
            }
        }
        .fileImporter(isPresented: $isImporting,
                      allowedContentTypes: [.zip],
                      onCompletion: { result in
            
            switch result {
            case .success(let url):
                // url contains the URL of the chosen file.
                //let newImage = createImage(imageFile: url)
                print("url: \(url)")
                spotifyDefaultViewModel.restorePersistentStore(url: url)
                self.importShouldBeShown = false
            case .failure(let error):
                print(error)
            }
        })
        //}
        
        VStack(spacing:5) {
            HStack(spacing:5){
                TextField("Enter Spotify URI", text: $playlistURI)
                //.padding()
                    .border(Color.gray)
                Button("Fetch Content Item") {
                    //fetchContent()
                    spotifyDefaultViewModel.getSearch(playlistURI: playlistURI, playTrack: true){ result in
                        //self.query = txt
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let success):
                                self.trackItmems = success.tracks.searchResultIdx.items
                                self.dictUriIdx = success.tracks.searchResultIdx.dictUriIdx
                                self.playlistURI = ""
                                self.contentItem = success.playList
                            case .failure(let error):
                                print( "tes \(error.localizedDescription)")
                            }
                        }
                    }
                }
                //.padding()
                .foregroundColor(.white)
                .background(Color.green)
                .cornerRadius(5)
            }
        }
        
        HStack(spacing:10){
            Button(action: {
                spotifyDefaultViewModel.didPressPlayPauseButton()
            }) {
                HStack {
                    Image(systemName: spotifyDefaultViewModel.playerState?.isPaused ?? true ? "play.circle.fill" : "pause.circle.fill")
                    Text(spotifyDefaultViewModel.playerState?.isPaused ?? true ? "Resume" : "Pause")
                }
            }
            
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
        
        NavigationView {
            ScrollViewReader { reader in
                Toggle(isEditable ? "Edit Mode" : "Read Mode", isOn: $isEditable)
                    .onChange(of: isEditable) {
                        if !isEditable && viewContext.hasChanges {
                            do {
                                try viewContext.save()
                            } catch {
                                let nsError = error as NSError
                                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                            }
                        }
                    }
                List (selection: binding(for: spotifyDefaultViewModel.currentTrackUri)){
                    let sortedKeysAndValues = trackItmems.sorted() { $0.0 < $1.0 }
                    ForEach(sortedKeysAndValues, id: \.key) { idx, trackInfo in
                        NavigationLink(destination: IC_TrackDetailView(trackInfo: trackInfo, isEditable: self.$isEditable, trackInfoAfter: trackItmems[idx+1] ?? trackInfoEmpty), tag: idx, selection: binding(for: spotifyDefaultViewModel.currentTrackUri)) {
                            Label(
                                title: { ItemCard(item:trackInfo) },
                                icon: { Image(systemName: "star") }
                            )
                            .id(idx)
                            .foregroundColor(trackInfo.trackURI==spotifyDefaultViewModel.currentTrackUri ? .white : .black)
                        }
                    }
                }
                .onChange(of: spotifyDefaultViewModel.currentTrackUri) { oldValue, newValue in
                    //print("currentSongBeingPlayed: \(newValue)")
                    //fetchPlayerState()
                    var idx = dictUriIdx[newValue] ?? -2
                    if idx != -2 {
                        if idx < dictUriIdx.count {
                            idx = idx - 1
                        }
                        reader.scrollTo(idx, anchor: .top)
                    }
                }
                .navigationTitle(contentItem?.title ?? "")
                //.listStyle(GroupedListStyle()).navigationBarTitle("Settings")
            }
        }
        .onChange(of: spotifyDefaultViewModel.currentSongBeingPlayed) { oldValue, newValue in
            //print("currentSongBeingPlayed: \(newValue)")
            fetchPlayerState()
        }
        .padding(0)
    }
}

/*
 struct SpinningPlaylist_Previews: PreviewProvider {
 static var previews: some View {
 IC_SpinningPlaylistView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
 }
 }
 */

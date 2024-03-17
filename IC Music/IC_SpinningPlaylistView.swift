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
    var durationSeconds: Int32
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
    @StateObject var spotifyDefaultViewModel: IC_SpotifyDefaultViewModel = { IC_SpotifyDefaultViewModel.shared } ()
    
    init(/*spotifyDefaultViewModel: IC_SpotifyDefaultViewModel*/) {
        //self.spotifyDefaultViewModel = spotifyDefaultViewModel
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont.preferredFont(forTextStyle: .subheadline)]
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont.preferredFont(forTextStyle: .subheadline)]
    }
    
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
    
    @StateObject var fileImportExportCtrl: FileImportExportCtrl = FileImportExportCtrl()
    
    @State private var document = ""
    
    private var bDep: Bool = true
    
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
    
    
    @State var isEditable = false
    
    @State private var selectedTrackInfoIdx: Int?
    
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
    
    var sortedTrackItems: [(key: Int, value: IC_TrackInfo)] {
        trackItmems.sorted { $0.key < $1.key }
    }
    
    @State private var scrollToIndex: Int = 1
    
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    
    var body: some View {
        
        //IC_FileImporter()
        
        VStack(spacing:5) {
            HStack(spacing:5){
                TextField("Enter Spotify URI", text: $playlistURI)
                //.padding()
                    .border(Color.gray)
                HStack (spacing:2) {
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
                    
                    OptionsView(fileImportExportCtrl: fileImportExportCtrl)
                    .fileExporter(isPresented: self.$fileImportExportCtrl.showFileExporter, document: self.fileImportExportCtrl.zipFile, contentType: .zip) { result in
                        print("Exported ZIP:", result)
                    }
                    .fileImporter(isPresented: $fileImportExportCtrl.isImporting,
                                      allowedContentTypes: [.zip],
                                      onCompletion: { result in
                            
                            switch result {
                            case .success(let url):
                                // url contains the URL of the chosen file.
                                //let newImage = createImage(imageFile: url)
                                print("url: \(url)")
                                spotifyDefaultViewModel.restorePersistentStore(url: url)
                                self.fileImportExportCtrl.importShouldBeShown = false
                            case .failure(let error):
                                print(error)
                            }
                        })
                }
            }
        }
        
        IC_SliderMusic()
        
        //if(bDep) {
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
                            Text("\(trackInfo.trackTitle ?? "")")
                                .id(idx)
                                .foregroundColor(trackInfo.trackURI==spotifyDefaultViewModel.currentTrackUri ? .white : .black)
                        }
                    }
                }
                //.listStyle(.sidebar) if active sidebar in this case is nomore hidding when in split view expanded
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
        /*}
         else {
         NavigationSplitView(columnVisibility: $columnVisibility) {
         ScrollViewReader { reader in
         
         IC_ToggleEdit(isEditable: isEditable)
         
         List(sortedTrackItems, id: \.key, selection: $selectedTrackInfoIdx) { key, trackInfo in
         NavigationLink(trackInfo.trackTitle ?? "", selection: $selectedTrackInfoIdx) {
         IC_TrackDetailView(trackInfo: trackInfo, isEditable: self.$isEditable, trackInfoAfter: trackInfoEmpty)
         }
         .tag(key)
         .id(key)
         }
         .onChange(of: spotifyDefaultViewModel.currentTrackUri) { oldValue, newValue in
         //print("currentSongBeingPlayed: \(newValue)")
         //fetchPlayerState()
         var idx = dictUriIdx[newValue] ?? -2
         if idx != -2 {
         
         selectedTrackInfoIdx = idx
         
         if idx < dictUriIdx.count {
         idx = idx - 1
         }
         reader.scrollTo(idx, anchor: .top)
         }
         }
         .navigationTitle(contentItem?.title ?? "")
         }
         } detail: {
         Text("Select a track")
         }
         .navigationSplitViewStyle(.balanced)
         .onChange(of: spotifyDefaultViewModel.currentSongBeingPlayed) { oldValue, newValue in
         fetchPlayerState()
         }
         //.padding(0)
         }*/
    }
    
}

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
  var durationMSeconds: Int32
}

struct IC_SpinningPlaylistView: View {
  @StateObject var spotifyDefaultViewModel: IC_SpotifyDefaultViewModel = { IC_SpotifyDefaultViewModel.shared } ()

  init() {
    UINavigationBar
      .appearance().largeTitleTextAttributes = [.font : UIFont.preferredFont(
        forTextStyle: .subheadline
      )]
    UINavigationBar
      .appearance().titleTextAttributes = [.font : UIFont.preferredFont(forTextStyle: .subheadline)]
  }

  @Environment(\.managedObjectContext) var viewContext
  @State var playlistURI = ""
  @State var playlistId = ""
  @State var sPlaylistTitle: String?
  @State var trackItmems = [Int : IC_TrackInfo]()
  @State var dictUriIdx = [String : Int]()
  @State var error: Error?
  @State var currentTrackUri: String = ""
  @State private var playerState: SPTAppRemotePlayerState?
  @State var isEditable = false
  @State private var selectedTrackInfoIdx: Int?
  @State private var showingSettings = false
  @State private var selectedTrackIdx: Int? = nil
  @State private var selectedTrackObject: IC_TrackInfo? = nil

  @State var refreshID = UUID()
    
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    @State private var showSaveToast = false
    @State private var saveToastMessage = ""

  @AppStorage(UserKeys.fontoSize.rawValue) var fontoSize: Double = 22.0

  var trackInfoEmpty: IC_TrackInfo {
    let result = PersistenceController(inMemory: true)
    let viewContextMemory = result.container.viewContext
    let trackInfo = IC_TrackInfo(context: viewContextMemory)
    trackInfo.trackTitle = "Unknown Track"
    trackInfo.bpmSpotify = 0
    trackInfo.rpmUser = "Unknown"
    trackInfo.trackURI = "spotify:track:0"
    trackInfo.energy = 0
    trackInfo.danceability = 0
    trackInfo.durationSeconds = 0
    trackInfo.customInfo = "Unknown"
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
    }
  }

  func appRemoteConnected() {
    getPlayerState()
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

  func fetchedData(searchResult: IC_SearchResult) {
    self.trackItmems = searchResult.tracks.searchResultIdx.items
    self.dictUriIdx = searchResult.tracks.searchResultIdx.dictUriIdx
    //self.playlistURI = ""
    self.sPlaylistTitle = searchResult.playList
    self.spotifyDefaultViewModel.nTotalDurationMSec = (searchResult.nTotalDurationMSec)
    self.spotifyDefaultViewModel.objectWillChange.send() //to force view update

    refreshID = UUID()
  }

  // export the info of trackItmens to a csv file
  func exportToCSV() {
    let csvData = convertToCSV()

    saveCSVFile(data: csvData, fileName: "\(sPlaylistTitle ?? "exportCSV″").csv")

  }

  func escapeCSVField(_ field: String) -> String {
    var escapedField = field.replacingOccurrences(of: "\"", with: "\"\"")
    if field.contains(",") || field.contains("\n") || field.contains("\r") {
      escapedField = "\"\(escapedField)\""
    }
    return escapedField
  }


  func convertToCSV() -> String {
    var csvText = "Track Title;Duration;BPM;Custom Info\r" // headers of the csv file
    // sort the track items by the index
    let trackItmems = trackItmems.sorted { $0.key < $1.key }

    for (_, trackInfo) in trackItmems {
      let tracktitle = escapeCSVField(trackInfo.trackTitle ?? "")
      let customInfo = escapeCSVField(trackInfo.customInfo ?? "")
      let newLine = "\(tracktitle);\(trackInfo.durationSeconds);\(trackInfo.bpmSpotify);\(customInfo)\r" // content of the csv file
      csvText.append(contentsOf: newLine) // append the content to the csv file
    }
    return csvText
  }

    func saveCSVFile(data: String, fileName: String) {
      let fileManager = FileManager.default
      do {
        let documentDirectory = try fileManager.url(
          for: .documentDirectory,
          in: .userDomainMask,
          appropriateFor: nil,
          create: true
        )
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        try data.write(to: fileURL, atomically: true, encoding: .utf8)
        print("File saved: \(fileURL)")

        // show transient toast on main thread
        DispatchQueue.main.async {
          self.saveToastMessage = "Saved: \(fileURL.lastPathComponent)"
          withAnimation { self.showSaveToast = true }
          DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation { self.showSaveToast = false }
          }
        }
      } catch {
        print("Error saving file: \(error)")
        DispatchQueue.main.async {
          self.saveToastMessage = "Save failed"
          withAnimation { self.showSaveToast = true }
          DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation { self.showSaveToast = false }
          }
        }
      }
    }

    



  func update(playerState: SPTAppRemotePlayerState) {
    let playlistUri = playerState.contextURI.absoluteString

    var playlistId = ""
    var listType = ""

    if playlistUri != "spotify:search", let sIdx = playlistUri.lastIndex(of: ":") {
      //let lastPart = sportifyId[idx>..]
      playlistId = String(playlistUri.suffix(from: sIdx).dropFirst())
      var sIdxType = playlistUri.index(before: sIdx)
      let range = ...sIdxType
      let playlistUri2 = String(playlistUri[range])
      sIdxType = playlistUri2.lastIndex(of: ":") ?? playlistUri2.startIndex
      listType = String(playlistUri2.suffix(from: sIdxType).dropFirst())

      if listType != "" && !listType.hasSuffix(String("s")) {
        listType = listType + "s"
      }

      if listType != "" {
        playlistId = "\(listType)/\(playlistId)"
      }
      else {
        playlistId = ""
      }
    }

    if playlistId != "" && playlistId != self.playlistId {
      self.playlistURI = playlistUri
      self.playlistId = playlistId
      trackItmems.removeAll()
      spotifyDefaultViewModel.getUserPlayListTracks(playlistID: String(playlistId)){ result in
        DispatchQueue.main.async {
          switch result {
          case .success(let success):
            self.fetchedData(searchResult: success)
          case .failure(let error):
            print( "tes \(error.localizedDescription)")
          }
        }
      }
    }
    else if playlistUri != self.playlistURI || playlistUri == "spotify:search"{
      self.playlistURI = playlistUri

      if self.playlistURI != "" && self.playlistURI != "spotify:search" {
        trackItmems.removeAll()
        spotifyDefaultViewModel.getSearch(playlistURI: playlistURI, playTrack: false){ result in
          DispatchQueue.main.async {
            switch result {
            case .success(let success):
              self.fetchedData(searchResult: success)
            case .failure(let error):
              print( "tes \(error.localizedDescription)")
            }
          }
        }
      }
      else {
        if self.currentTrackUri != playerState.track.uri {
          self.currentTrackUri = playerState.track.uri
          if self.currentTrackUri != "" {
            trackItmems.removeAll()
            spotifyDefaultViewModel
              .getSearch(playlistURI: currentTrackUri, playTrack: false){ result in
                DispatchQueue.main.async {
                  switch result {
                  case .success(let success):
                    self.fetchedData(searchResult: success)
                  case .failure(let error):
                    print( "tes \(error.localizedDescription)")
                  }
                }
              }
          }
        }
      }
    }

    if !trackItmems.isEmpty {
      if let idx = dictUriIdx[playerState.track.uri] {
        var nCurrentPlaylistDurationSeconds = 0
        var sCurrentPlaylistTitle = ""
        for x in 0..<idx {
          if let trackInfo = trackItmems[x] {
            nCurrentPlaylistDurationSeconds += Int(trackInfo.durationSeconds)
            sCurrentPlaylistTitle = trackInfo.trackTitle ?? ""
          }
        }

        print (
          "Playlist duration \(nCurrentPlaylistDurationSeconds) up to including title: \(sCurrentPlaylistTitle)"
        )
        spotifyDefaultViewModel.nCurrentPlaylistDurationSeconds = nCurrentPlaylistDurationSeconds
      }
    }
  }

  var body: some View {

    HStack(spacing: 2) {
      IC_SliderMusic()

      Spacer(minLength: 50)

      IC_ToggleEdit(isEditable: $isEditable)
        .frame(maxWidth: 180)
    }

      NavigationSplitView (columnVisibility: $columnVisibility){
      // Sidebar
      ScrollViewReader { reader in
        List(selection: $selectedTrackIdx) {
          let sortedKeysAndValues = trackItmems.sorted { $0.0 < $1.0 }

          ForEach(sortedKeysAndValues, id: \.key) {
            idx,
            trackInfo in
            NavigationLink(
              value: idx
            ) {
              Text("\(trackInfo.trackTitle ?? "")")
                .id(idx)
                .foregroundColor(
                  trackInfo.trackURI == spotifyDefaultViewModel.currentTrackUri ? .blue : .black
                )
            }
          }
        }
        .onChange(of: spotifyDefaultViewModel.currentTrackUri) { oldValue, newValue in
          guard let idx = dictUriIdx[newValue] else {
            selectedTrackIdx = nil
            selectedTrackObject = nil
            return }
          var idx2 = idx
          if idx < dictUriIdx.count {
            idx2 = idx - 1
          }
          reader.scrollTo(idx2, anchor: .top)
          selectedTrackIdx = idx
          selectedTrackObject = trackItmems[idx] ?? nil
          refreshID = UUID()
        }
        .navigationTitle(sPlaylistTitle?.isEmpty ?? true ? "No playlist title" : sPlaylistTitle!)
        .foregroundColor(.orange)
        VStack(spacing:0) {
          HStack(spacing: 5){
            IC_SliderFontSize(fontoSize: $fontoSize)
          }
            HStack (spacing:2) {

              Button(action: {
                showingSettings.toggle()
              }) {
                Image(systemName: "gearshape.fill")
                  .resizable()
                  .frame(width: 24, height: 24)
                  .padding()
              }
              .buttonStyle(PlainButtonStyle())
              .sheet(isPresented: $showingSettings) {
                IC_SettingsDialog()
              }

              Spacer()

              Button("Export Playlist CSV") {
                exportToCSV()
              }
              .foregroundColor(.white)
              .background(Color.green)
              .cornerRadius(5)
            }
        }
      }
    } detail: {
      // Detail view
      if let selectedTrack = selectedTrackIdx, let _ = selectedTrackObject {
        IC_TrackDetailView(
          trackInfo: selectedTrackObject ?? trackInfoEmpty,
          isEditable: self.$isEditable,
          trackInfoAfter: trackItmems[selectedTrack + 1] ?? trackInfoEmpty
        )
      } else {
        Text("Select a track")
      }
    }
    .id(
      selectedTrackIdx //refreshID
    )// .id is used to force the view to be recreated when the selectedTrackIdx changes
    .onChange(of: spotifyDefaultViewModel.currentSongBeingPlayed) { oldValue, newValue in
      if !isEditable && viewContext.hasChanges {
        do {
          try viewContext.save()
        } catch {
          let nsError = error as NSError
          fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
      }
      fetchPlayerState()
    }
    .onAppear {
      fetchPlayerState()
    }
      // Add this overlay to the end of your view's body (for example, before .padding(0)):
      .overlay(alignment: .bottom) {
        if showSaveToast {
          HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
              .foregroundColor(.white)
            Text(saveToastMessage)
              .foregroundColor(.white)
              .lineLimit(1)
              .truncationMode(.middle)
          }
          .padding(.horizontal, 14)
          .padding(.vertical, 10)
          .background(Color.black.opacity(0.8))
          .cornerRadius(12)
          .padding(.bottom, 20)
          .transition(.move(edge: .bottom).combined(with: .opacity))
          .shadow(radius: 6)
        }
      }
      .animation(.easeInOut, value: showSaveToast)
    .padding(0)

  }
}


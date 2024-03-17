//
//  IC_SpotifyDefaultViewModel.swift
//  es
//
//  Created by Richard Smith on 2023-05-02.
//

import Foundation
import Combine
import CoreData
import StoreKit

enum AuthenticationState: Equatable, CaseIterable {
    case idle
    case loading
    case error
    case authorized
}

//@MainActor
final class IC_SpotifyDefaultViewModel: NSObject, ObservableObject {
    
    //var managedObjectContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext
    private var viewContext = PersistenceController.shared.container.viewContext
    
    static let shared = IC_SpotifyDefaultViewModel()
    
    @Published var authenticationState: AuthenticationState = .idle
    @Published var currentSongBeingPlayed: String = ""
    @Published var currentTrackUri = ""
    @Published var currentDuration: UInt = 0
    @Published var currentDurationLabel = ""
    @Published var currentTimeInSecondsPass: Double = 0
    @Published var position:Float = 0.0
    @Published var elapsedTimeLabel = ""
    @Published var playbackPosition: Double = 0.0
    @Published var playerState: SPTAppRemotePlayerState?
    @Published var contextUri: URL?
    @Published var trackItem: IC_TrackInfo?
    @Published var accessToken = UserDefaults.standard.string(forKey: accessTokenKey) {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(accessToken, forKey: accessTokenKey)
        }
    }
    
    @Published private var responseCode: String = "" {
        didSet {
#if !USE_API
            spotifyDefaultAPIHandler.fetchAccessToken(responseCode: responseCode)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print(APIError.fetchingTokenRequestError(error))
                        //print("failture fetchAccessToken.receiveCompletion")
                    }
                }, receiveValue: { [weak self] spotifyAccessToken in
                    if let accessToken = spotifyAccessToken.accessToken {
                        /* not in original */
                        if self?.accessToken != accessToken {
                            self?.accessToken = accessToken
                        }
                        
                        
                        self?.appRemote.connectionParameters.accessToken = accessToken
                        self?.appRemote.connect()
                    }
                }).store(in: &bag)
#endif
        }
    }
#if !USE_API
    private let spotifyDefaultAPIHandler = { IC_SpotifyAPIDefaultHandler.shared }()
#endif
    private var bag = Set<AnyCancellable>()
    
    lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: spotifyClientID, redirectURL: redirectURI)
        // Set the playURI to a non-nil value so that Spotify plays music after authenticating and App Remote can connect
        // otherwise another app switch will be required
        configuration.playURI = ""
        
        // Set these url's to your backend which contains the secret to exchange for an access token
        // You can use the provided ruby script spotify_token_swap.rb for testing purposes
        
        /* !!! without tokenSwapURL and tokenRefreshURL configuration with session manager not working !!! */
        configuration.tokenSwapURL = URL(string: "http://localhost:1234/swap")
        configuration.tokenRefreshURL = URL(string: "http://localhost:1234/refresh")
        return configuration
    }()
    
    lazy var sessionManager: SPTSessionManager = {
        let manager = SPTSessionManager(configuration: configuration, delegate: self)
        print("sessionManager init")
        return manager
    }()
    
    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .error)
        // not in original //appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        print("appRemote initialized")
        return appRemote
    }()
    
    private var lastPlayerState: SPTAppRemotePlayerState?
    
    
    lazy var backupURL: URL = {
        let appSupportDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let destinationDirectoryURL = appSupportDirectory.appendingPathComponent("IC_Music")
        return destinationDirectoryURL
    }()
    
    @objc
    func restorePersistentStore(url: URL? = nil) {
        let container = PersistenceController.shared.container
        
        do {
            if url != nil {
                try container.restorePersistentStore(from: url!, destination: backupURL)
            }
            else {
                try container.restorePersistentStore(from: backupURL)
            }
        } catch {
            print("Restore error: \(error)")
        }
    }
    
    @objc
    func copyPersistentStore() -> String {
        let container = PersistenceController.shared.container
        var sUrl = ""
        do {
            try sUrl = container.copyPersistentStores(to: backupURL, overwriting: true)
        } catch {
            print("Copy error: \(error)")
        }
        
        return sUrl
    }
    func fetchPlayerState() {
        appRemote.playerAPI?.getPlayerState({ [weak self] (playerState, error) in
            if let error = error {
#if !USE_API
                print(APIError.fetchingPlayerStateFailedWithError(error))
#endif
            } else if let playerState = playerState as? SPTAppRemotePlayerState {
                self?.update(playerState: playerState)
            }
        })
    }
    
    func update(playerState: SPTAppRemotePlayerState) {
        lastPlayerState = playerState
    }
    
    func onOpenURL(url: URL) {
        let parameters = appRemote.authorizationParameters(from: url)
        
        if let code = parameters?["code"] {
            print("'code' from authorizationParameters(from: url)")
            responseCode = code
        } else if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            print("'accessToken' from authorizationParameters(from: url)")
            self.accessToken = access_token
            appRemote.connectionParameters.accessToken = accessToken
        } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
#if !USE_API
            print(APIError.noAccessTokenError(error_description))
#endif
        }
    }
    
    func didBecomeActive() {
        if let accessToken = appRemote.connectionParameters.accessToken {
            print("accessToken from appRemote.connectionParameters")
            appRemote.connectionParameters.accessToken = accessToken
            //appRemote.connect()
        } else if let accessToken = accessToken {
            print("accessToken from userdefault")
            appRemote.connectionParameters.accessToken = accessToken
            //appRemote.connect()
        }
        else {
            print("no valid accessToken")
        }
        
        print("appRemote.connect")
        appRemote.connect()
    }
    
    func willResignActive() {
        if self.appRemote.isConnected {
            self.appRemote.disconnect()
        }
    }
    
    func connect() {
        guard let _ = self.appRemote.connectionParameters.accessToken else {
            self.appRemote.authorizeAndPlayURI("")
            
            self.authenticationState = .loading
            
            self.appRemote.connect()
            
            self.authenticationState = .authorized
            
            return
        }
        
        appRemote.connect()
    }
    
    func connectUser() {
        print("connectUser using sessionManager")
        guard let sessionManager = try? sessionManager else { return }
        sessionManager.initiateSession(with: scopes, options: .clientOnly)
        self.authenticationState = .loading
        
        appRemote.connect()
    }
    
    func didPressPlayPauseButton() {
        if appRemote.isConnected == false {
            if appRemote.authorizeAndPlayURI(""/*playURI*/) == false {
                // The Spotify app is not installed, present the user with an App Store page
                //showAppStoreInstall()
            }
        }
    }
    
    // A function to format the elapsed time in mm:ss format
    func formatElapsedTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }// A variable to store the current elapsed time in seconds
    
    var currentElapsedTime = 0
    
    // A variable to store the timer object
    var timer: Timer?
    
    // A function to start the timer
    func startTimer() {
        // Invalidate any existing timer
        timer?.invalidate()
        
        // Create a new timer that fires every second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            // Increment the current elapsed time by one
            self.currentElapsedTime += 1
            self.playbackPosition += 1000
            
            // Format the current elapsed time and update the label
            let formattedTime = self.formatElapsedTime(seconds: self.currentElapsedTime)
            self.elapsedTimeLabel = formattedTime
        }
    }
    
    // A function to stop the timer
    func stopTimer() {
        // Invalidate the timer
        timer?.invalidate()
    }
    
    func pausePlayback() {
        appRemote.playerAPI?.pause()
    }
    
    func startPlayback() {
        appRemote.playerAPI?.resume()
    }
    
    struct SearchResult {
        let tracks: SearchResultTracks
        let playList: SPTAppRemoteContentItem
    }
    
    struct SearchResultIdx: Hashable {
        let items: [Int: IC_TrackInfo]
        let dictUriIdx: [String : Int]
    }
    
    struct SearchResultTracks: Hashable {
        let searchResultIdx: SearchResultIdx
    }
    
    func trackItemsLoad(trackUris: [TrackInit]) -> SearchResultIdx
    {
        var trackItems = [Int: IC_TrackInfo]()
        var dictUriIdx = [String : Int]()
        
        for idx in trackUris.indices {
            let item = trackUris[idx]
            let fetchRequest = NSFetchRequest<IC_TrackInfo>(entityName: "IC_TrackInfo")
            var predicate: NSPredicate
            predicate = NSPredicate(format: "trackURI == %@", item.trackUri)
            
            //NSLog("secondPredicate description: %@", predicate);
            fetchRequest.predicate = predicate
            fetchRequest.fetchLimit = 1
            
            do {
                let fetchedCustomers = try viewContext.fetch(fetchRequest)
                if let existingCustomer = fetchedCustomers.first {
                    existingCustomer.trackTitle = item.trackTitle
                    trackItems[idx]  = existingCustomer
                }
                else {
                    let newTrackInfo = IC_TrackInfo(context: viewContext)
                    newTrackInfo.trackURI = item.trackUri
                    newTrackInfo.trackTitle = item.trackTitle
                    newTrackInfo.durationSeconds = item.durationSeconds
                    
                    var sportifyId = item.trackUri
                    
                    if let idx = sportifyId.lastIndex(of: ":") {
                        //let lastPart = sportifyId[idx>..]
                        let afterEqualsTo = String(sportifyId.suffix(from: idx).dropFirst())
                        sportifyId = afterEqualsTo
                    }
                    
                    newTrackInfo.spotifyId = sportifyId
                    trackItems[idx] = newTrackInfo
                    
                    fetchTrackData(trackInfo: newTrackInfo, spotifyId: sportifyId)
                }
                dictUriIdx[item.trackUri] = idx
            } catch {
                print("Error loading customer: \(error)")
            }
            
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return SearchResultIdx(items: trackItems, dictUriIdx: dictUriIdx)
    }
    
    public func getSearch(playlistURI: String, playTrack: Bool, completion: @escaping (Result<SearchResult, Error>) -> Void) {
        
        var playlistURI = playlistURI
        var trackUris = [TrackInit]()
        
        if(playlistURI.contains("playlist"))
        {
            if(playlistURI.contains("?"))
            {
                let endIndex = playlistURI.firstIndex(of: "?")!
                playlistURI = String(playlistURI[..<endIndex])
            }
            appRemote.contentAPI?.fetchContentItem(forURI: playlistURI, callback: { (result, error) in
                if let error = error {
                    //self.error = error
                    print(error.localizedDescription)
                } else if let contentItem = result as? SPTAppRemoteContentItem {
                    print(contentItem.title!) // playlist title
                    /* do not play, but its working with play*/
                    if playTrack {
                        self.appRemote.playerAPI?.play(contentItem.uri, callback: { (result, error) in
                            if let error = error {
                                print(error.localizedDescription)
                            } else {
                                print("Playing \(contentItem.title ?? "No title")")
                            }
                        })
                    }
                    // Fetch the children of the content item
                    self.appRemote.contentAPI?.fetchChildren(of: contentItem, callback: { (result, error) in
                        if let error = error {
                            // Handle error
                            print(error.localizedDescription)
                            completion(.failure(error))
                        } else if let items = result as? [SPTAppRemoteContentItem] {
                            // Do something with the items
                            //self.contentItems = items
                            for item in items {
                                //print(item.title ?? "No title")
                                //print("title \(item.title ?? "No title"), uri \(item.uri)")
                                
                                trackUris.append(TrackInit(trackUri: item.uri, trackTitle: item.title ?? "No title", durationSeconds: 0))
                            }
                            
                            let result: SearchResult = SearchResult(tracks: SearchResultTracks(searchResultIdx: self.trackItemsLoad(trackUris: trackUris)), playList: contentItem)
                            completion(.success(result))
                        }
                    })
                }
            })
            
        }
        else
        {
            //error = NSError(domain: "SpinningPlaylistView", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid Spotify playlist URI"])
        }
    }
    
    func fetchTrackData(trackInfo: IC_TrackInfo, spotifyId: String) {
        // Replace 'TRACK_ID' with the ID of the track you want to fetch data for
        
        let url = URL(string: "https://api.spotify.com/v1/audio-features/\(spotifyId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer " + (appRemote.connectionParameters.accessToken ?? ""), forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                /*
                 let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                 
                 let decoder = JSONDecoder()
                 let dataModel = try decoder.decode(AudioFeatures.self, from: data) {
                 print("Tempo: \(dataModel.tempo)")
                 }*/
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let trackData = json {
                    // Parse and use the track data as needed
                    //print(trackData)
                    
                    if let tempo = trackData["tempo"] as? Double {
                        //print("Tempo for uri: \(trackInfo.trackURI ?? "") \(tempo)")
                        trackInfo.bpmSpotify = tempo
                    }
                    
                    if let duration = trackData["duration_ms"] as? Int {
                        //print("Tempo for uri: \(trackInfo.trackURI ?? "") \(tempo)")
                        trackInfo.durationSeconds = Int32((duration / 1000))
                    }
                    
                    if let danceability = trackData["danceability"] as? Double {
                        //print("Tempo for uri: \(trackInfo.trackURI ?? "") \(tempo)")
                        trackInfo.danceability = danceability
                    }
                    
                    if let energy = trackData["energy"] as? Double {
                        //print("Tempo for uri: \(trackInfo.trackURI ?? "") \(tempo)")
                        trackInfo.energy = energy
                    }
                    
                    DispatchQueue.main.async{
                        do {
                            if self.viewContext.hasChanges {
                                try self.viewContext.save()
                            }
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    }
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
}

extension IC_SpotifyDefaultViewModel: SPTAppRemotePlayerStateDelegate {
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        lastPlayerState = playerState
        currentSongBeingPlayed = playerState.track.name
        currentTrackUri = playerState.track.uri
        self.playerState = playerState
        //self.position = playerState.playbackPosition
        self.contextUri = playerState.contextURI
        
        // Get the elapsed time in seconds
        self.playbackPosition = Double(playerState.playbackPosition)
        let elapsedTime = Int(playerState.playbackPosition / 1000)
        
        // Format the elapsed time and update the label
        //let formattedTime = self.formatElapsedTime(seconds: elapsedTime)
        //self.elapsedTimeLabel.text = formattedTime
        // Update the current elapsed time variable
        self.currentElapsedTime = elapsedTime
        
        self.currentDuration = playerState.track.duration
        
        self.currentDurationLabel = formatElapsedTime(seconds: Int(playerState.track.duration / 1000))
        
        // Start or stop the timer depending on the playback state
        if playerState.isPaused {
            self.stopTimer()
        } else {
            self.startTimer()
        }
    }
}

extension IC_SpotifyDefaultViewModel: SPTAppRemoteDelegate{
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        //self.appRemote = appRemote
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { (success, error) in
            if let error = error {
#if !USE_API
                print(APIError.subscribingToPlayerStateError(error.localizedDescription))
#endif
                self.authenticationState = .error
            }
            
            self.authenticationState = .authorized
        })
        
        fetchPlayerState()
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        // not in original // appRemote.connect()
        connectUser()
        if let error {
#if !USE_API
            print(APIError.appRemoteDisconnectedWithError(error))
#endif
        }
        
        lastPlayerState = nil
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        if error != nil {
#if !USE_API
            //print(APIError.appRemoteDidFailConnectionAttemptWithError(error!))
#endif
        }
	
        print("didFailConnectionAttemptWithError")
	
        connectUser()
        
        lastPlayerState = nil
    }
    
    
}

extension IC_SpotifyDefaultViewModel: SPTSessionManagerDelegate {
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        
    }
    
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
    }
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        //appRemote.connectionParameters.accessToken = session.accessToken
        
        //appRemote.connect()
        if session.isExpired && false {
            sessionManager.renewSession()
        } else {
            // Store session and credentials
            appRemote.connectionParameters.accessToken = session.accessToken
            appRemote.connect()
        }
        
    }
}

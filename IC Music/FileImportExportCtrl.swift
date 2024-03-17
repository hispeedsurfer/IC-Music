//
//  FileImportExportCtrl.swift
//  IC Music
//
//  Created by Andreas Franke on 16.03.24.
//

import Foundation

import SwiftUI

class FileImportExportCtrl: ObservableObject {
    
    @StateObject var spotifyDefaultViewModel: IC_SpotifyDefaultViewModel = { IC_SpotifyDefaultViewModel.shared } ()
    
    @AppStorage("InitialImport") var importShouldBeShown = true
    
    @Published var showFileExporter = false
    
    @Published var isImporting: Bool = false
    
    @Published var zipFile: ZipFile?
    
    @Published var showingConfirmationDialog = false

    
    func export()
    {
        Task { @MainActor in
            do
            {
                let zipPath = spotifyDefaultViewModel.copyPersistentStore()
                let zipURL = URL(fileURLWithPath: zipPath)
                
                self.zipFile = try ZipFile(zipURL: zipURL)
                self.showFileExporter = true
            }
            catch
            {
                print("Could not export .zip:", error)
            }
        }
    }
}

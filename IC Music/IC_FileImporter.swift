//
//  IC_FileImporter.swift
//  IC Music
//
//  Created by Andreas Franke on 10.03.24.
//

import SwiftUI

struct IC_FileImporter: View {
    
    @AppStorage("InitialImport") var importShouldBeShown = true
    
    @StateObject var spotifyDefaultViewModel: IC_SpotifyDefaultViewModel = { IC_SpotifyDefaultViewModel.shared } ()
    
    
    @State
    private var isExporting = false
    @State private var isImporting: Bool = false
    
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
    
    var body: some View {
        
        HStack {
            Button(action: {
                UserDefaults.standard.removeObject(forKey: accessTokenKey)
            }) {
                Text("Clear UserDefault accessTokenKey")
            }
            
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
    }
}

#Preview {
    IC_FileImporter()
}

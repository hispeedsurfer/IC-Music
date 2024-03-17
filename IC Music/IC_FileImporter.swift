//
//  IC_FileImporter.swift
//  IC Music
//
//  Created by Andreas Franke on 10.03.24.
//

import SwiftUI

struct IC_FileImporter: View {
    
    @StateObject var spotifyDefaultViewModel: IC_SpotifyDefaultViewModel = { IC_SpotifyDefaultViewModel.shared } ()
    
    @ObservedObject var fileImportExportCtrl: FileImportExportCtrl
    
    var body: some View {
        
        HStack {
            Button(action: {
                UserDefaults.standard.removeObject(forKey: accessTokenKey)
            }) {
                Text("Clear UserDefault accessTokenKey")
            }
            
            //if importShouldBeShown {
                Button(action: {
                    self.fileImportExportCtrl.showingConfirmationDialog = true
                }) {
                    Text("Import File")
                }
                .disabled(!fileImportExportCtrl.importShouldBeShown)
                .confirmationDialog("Are you sure you want to disable the import button?", isPresented: $fileImportExportCtrl.showingConfirmationDialog) {
                    Button("Disable", role: .destructive) {
                        self.fileImportExportCtrl.importShouldBeShown = false
                    }
                    Button("Cancel", role: .cancel) {}
                    Button("Import") {
                        self.fileImportExportCtrl.isImporting = true
                    }
                }
            //}
            
            Button(action: fileImportExportCtrl.export) {
                Label("Export ZIP", systemImage: "square.and.arrow.up")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
            }
        }
    }
}

#Preview {
    IC_FileImporter(fileImportExportCtrl: FileImportExportCtrl())
}

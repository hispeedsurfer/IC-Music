//
//  IC.swift
//  IC Music
//
//  Created by Andreas Franke on 28.01.25.
//


import SwiftUI

struct IC_SettingsDialog: View {
  @Environment(\.presentationMode) var presentationMode

  @StateObject var spotifyDefaultViewModel = { IC_SpotifyDefaultViewModel.shared } ()

  @StateObject var fileImportExportCtrl: IC_FileImportExportCtrl = IC_FileImportExportCtrl()

  var body: some View {
    VStack {
      Text("Settings")
        .font(.headline)
        .padding()


      IC_OptionsView(fileImportExportCtrl: fileImportExportCtrl)
        .fileExporter(
          isPresented: self.$fileImportExportCtrl.showFileExporter,
          document: self.fileImportExportCtrl.zipFile,
          contentType: .zip
        ) { result in
          print("Exported ZIP:", result)
        }
        .fileImporter(isPresented: self.$fileImportExportCtrl.isImporting,
                      allowedContentTypes: [.zip],
                      onCompletion: { result in

          switch result {
          case .success(let url):
            // url contains the URL of the chosen file.
            //let newImage = createImage(imageFile: url)
            print("url: \(url)")
            spotifyDefaultViewModel.restorePersistentStore(url: url)
            //self.fileImportExportCtrl.importShouldBeShown = false
          case .failure(let error):
            print(error)
          }
        })

      Button("Close") {
        presentationMode.wrappedValue.dismiss()
      }
      .padding()
    }
    .frame(width: 300, height: 200)
  }
}

//
//  IC_FileImporter.swift
//  IC Music
//
//  Created by Andreas Franke on 10.03.24.
//

import SwiftUI

extension UserDefaults {
  func resetUser(){
    UserKeys.allCases.forEach{
      removeObject(forKey: $0.rawValue)
    }
  }
}


struct IC_FileImporter: View {

  @ObservedObject var fileImportExportCtrl: IC_FileImportExportCtrl

  var body: some View {

    HStack {
      Button(action: {
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
      }) {
        Text("Clear UserDefault accessTokenKey")
      }

      Button(action: {
        self.fileImportExportCtrl.isImporting = true
      }) {
        Text("Import File")
      }
      .disabled(!fileImportExportCtrl.importShouldBeShown)
      .confirmationDialog(
        "Are you sure you want to disable the import button?",
        isPresented: $fileImportExportCtrl.showingConfirmationDialog
      ) {
        Button("Disable", role: .destructive) {
          self.fileImportExportCtrl.importShouldBeShown = false
        }
        Button("Cancel", role: .cancel) {}
        Button("Import") {
          self.fileImportExportCtrl.isImporting = true
        }
      } message: {
        Text("Select a new color")
      }

      Button(action: fileImportExportCtrl.export) {
        Label("Export ZIP", systemImage: "square.and.arrow.up")
          .imageScale(.large)
          .foregroundColor(.accentColor)
      }

      Button(action:{
        UserDefaults.standard.resetUser()
      }){
        Text("Reset File")
      }

    }
  }
}

#Preview {
  IC_FileImporter(fileImportExportCtrl: IC_FileImportExportCtrl())
}

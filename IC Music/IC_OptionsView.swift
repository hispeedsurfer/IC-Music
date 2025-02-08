//
//  OptionsView.swift
//  IC Music
//
//  Created by Andreas Franke on 15.03.24.
//

import SwiftUI

struct IC_OptionsView: View {
    
    @ObservedObject var fileImportExportCtrl: IC_FileImportExportCtrl
    
    var body: some View {
        
        Menu {
            IC_FileImporter(fileImportExportCtrl: fileImportExportCtrl)
        } label: {
            Label("Options", systemImage: "plus")
        }
      Text("Import only working from own").foregroundColor(.red)
      Text("local APP folder").foregroundColor(.red)
      Text("(IC-Music/IC-MusicDev)").foregroundColor(.red)

      Button(action: {
        let shared = PersistenceController()
        shared.queryCoreDate()
      }) {
        Text("queryCoreDate")
      }
    }
}

#Preview {
    IC_OptionsView(fileImportExportCtrl: IC_FileImportExportCtrl())
}

//
//  OptionsView.swift
//  IC Music
//
//  Created by Andreas Franke on 15.03.24.
//

import SwiftUI

struct OptionsView: View {
    
    @ObservedObject var fileImportExportCtrl: FileImportExportCtrl
    
    var body: some View {
        
        Menu {
            IC_FileImporter(fileImportExportCtrl: fileImportExportCtrl)
        } label: {
            Label("Options", systemImage: "plus")
        }
      Text("Import only working from own").foregroundColor(.red)
      Text("local APP folder").foregroundColor(.red)
      Text("(IC-Music/IC-MusicDev)").foregroundColor(.red)
    }
}

#Preview {
    OptionsView(fileImportExportCtrl: FileImportExportCtrl())
}

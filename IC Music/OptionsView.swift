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
    }
}

#Preview {
    OptionsView(fileImportExportCtrl: FileImportExportCtrl())
}

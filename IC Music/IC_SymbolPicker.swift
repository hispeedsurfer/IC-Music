//
//  IC_SymbolPicker.swift
//  IC Music
//
//  Created by Andreas Franke on 15.03.25.
//

import SwiftUI

struct IC_SymbolPicker: View {
  //@Binding var trackInfo: IC_TrackInfo
  @StateObject var trackInfo: IC_TrackInfo
  @Binding var isEditable: Bool

  let icons = ["", "SeatedFlat", "StandingFlat", "SeatedClimb", "RunningWithResistance", "Jumps", "StandingClimb", "JumpsOnAHill", "Sprints", "SprintOnAHill"]

  var body: some View {


      Picker(selection: $trackInfo.spinningSymbol, label: HStack {
        if ((trackInfo.spinningSymbol?.isEmpty) != nil) {
              Text("Keine Auswahl")
          } else {
            if let sps = trackInfo.spinningSymbol {

              Image(sps)
                .resizable()
                .scaledToFit()
                .frame(width: 10, height: 10) // Kleinere Größe für das ausgewählte Bild
            }
            else {
              Text("Keine Auswahl")
            }
          }
      }) {
          ForEach(icons, id: \.self) { icon in
              HStack {
                  if icon.isEmpty {
                      Text("Keine Auswahl") // Text für das leere Feld
                  } else {
                      Image(icon)
                          .resizable()
                          .scaledToFit()
                          .frame(width: 10, height: 10) // Kleinere Größe für das Bild im Picker
                      Text(icon)
                  }
              }
              .tag(icon)
          }
      }
      .pickerStyle(MenuPickerStyle())
      .disabled(!isEditable)
    }
}

#Preview {
  @Previewable @State var ti = IC_TrackInfo()
  IC_SymbolPicker(trackInfo: ti, isEditable: .constant(false))
}

//
//  IC_SliderFontSize.swift
//  IC Music
//
//  Created by Andreas Franke on 02.01.25.
//

import SwiftUI

struct IC_SliderFontSize: View {
  @Binding var fontoSize: Double

  var body: some View {
    Slider(value: $fontoSize, in: 0 ... 60, step: 1).padding()
      .onAppear {//for a smaler slider
        let progressCircleConfig = UIImage.SymbolConfiguration(scale: .small)
        UISlider.appearance()
          .setThumbImage(UIImage(systemName: "circle.fill",
                                 withConfiguration: progressCircleConfig), for: .normal)
      }
  }
}

//
//  TrackDetailView.swift
//  NowPlayingView
//
//  Created by Andreas Franke on 21.02.24.
//  Copyright © 2024 Spotify. All rights reserved.
//

import SwiftUI
import CoreData
import SwiftUIIntrospect

// create a swiftui view with a TextEditor that is read-only by default and can be switch do edit mode. Above the TextEditor there are two vertical fields, one read-only named "BPM Spotify" the other is named "BPM user" can switched to edit mode with the TextEditor.

// https://stackoverflow.com/a/57041232
extension Optional where Wrapped == String {
  var _bound: String? {
    get {
      return self
    }
    set {
      self = newValue
    }
  }
  public var bound: String {
    get {
      return _bound ?? ""
    }
    set {
      _bound = newValue.isEmpty ? nil : newValue
    }
  }
}

struct IC_TrackDetailView: View {
  @Environment(\.managedObjectContext) private var viewContext

  @StateObject var spotifyDefaultViewModel: IC_SpotifyDefaultViewModel = { IC_SpotifyDefaultViewModel.shared } ()

  @StateObject var trackInfo: IC_TrackInfo

  @Binding var isEditable: Bool

  @StateObject var trackInfoAfter: IC_TrackInfo

  @State var refreshID = UUID()

  @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
  @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?

  @AppStorage(UserKeys.fontoSize.rawValue) var fontoSize: Double = 22.0

  @StateObject var fileImportExportCtrl: IC_FileImportExportCtrl = IC_FileImportExportCtrl()

  let amountFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.zeroSymbol = ""
    return formatter
  }()

  // tapForBPM
  @State private var count: Int = 0
  @State private var timeLast: TimeInterval = 0
  @State private var times: [TimeInterval] = []
  @State private var next: Int = 0
  @State private var bpmNow: Double = 0
  @State private var bpmAvg: Double = 0
  @State private var timeChange: TimeInterval = 0
  // end tapForBPM

  // another solution for bpm button
  @State private var tapTimes: [TimeInterval] = []
  @State private var lastTapTime: TimeInterval = 0
  //@State private var averageBPM: Double = 0
  @State private var resetTimer: Timer?


  @State private var textView: UITextView?

  // Max count for average calculation
  private let maxCount = 5
  // Timeout value
  private let timeout: TimeInterval = 2.0 // seconds

  var body: some View {
    VStack (spacing: 5) {

      ZStack {
        // set TextEditor to read-only on variable isEditable
        TextEditor(text: isEditable ? $trackInfo.customInfo.bound : .constant(trackInfo.customInfo.bound))
          .introspect(.textEditor, on: .iOS(.v14, .v15, .v16, .v17, .v18, .v26)) { textView in
            //print(type(of: $0)) // UITextView
            self.textView = textView
          }
          .font(.system(size: fontoSize))
          .foregroundColor(Color.blue)
          .cornerRadius(10)
          .lineSpacing(5)
          .multilineTextAlignment(.leading)
        VStack {
          HStack {
            Spacer()
            VStack {
              // but a small space at the upper side of the button stack
              Spacer()
              HStack {
                Button(action: {
                  // Insert text at the current cursor position
                  insertTextAtCursor("\(spotifyDefaultViewModel.formatElapsedTime(seconds: self.spotifyDefaultViewModel.currentElapsedTimeSec)) ")
                }) {
                  Image(systemName: "timelapse")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding()
                    .background(isEditable ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .opacity(isEditable ? 1.0 : 0.5) // Change opacity when disabled
                    .clipShape(Circle())
                    .shadow(radius: 10)
                }
                .disabled(!isEditable)
                Button(action: {
                  // Insert text at the current cursor position
                  insertTextAtCursor("==================================\n")
                }) {
                  Image(systemName: "textformat.characters.dottedunderline")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding()
                    .background(isEditable ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .opacity(isEditable ? 1.0 : 0.5) // Change opacity when disabled
                    .clipShape(Circle())
                    .shadow(radius: 10)
                }
                .disabled(!isEditable)
              }
              HStack {
                Button(action: {
                  // Insert text at the current cursor position
                  insertTextAtCursor("R+", keepInLine: true)
                }) {
                  Image(systemName: "convertible.side.hill.up")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding()
                    .background(isEditable ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .opacity(isEditable ? 1.0 : 0.5) // Change opacity when disabled
                    .clipShape(Circle())
                    .shadow(radius: 10)
                }
                .disabled(!isEditable)
                Button(action: {
                  // Insert text at the current cursor position
                  insertTextAtCursor("R-", keepInLine: true)
                }) {
                  Image(systemName: "convertible.side.hill.down")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding()
                    .background(isEditable ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .opacity(isEditable ? 1.0 : 0.5) // Change opacity when disabled
                    .clipShape(Circle())
                    .shadow(radius: 10)
                }
                .disabled(!isEditable)
              }
              HStack {
                Button(action: {
                  // Insert text at the current cursor position
                  insertTextAtCursor("S+", keepInLine: true)
                }) {
                  Image(systemName: "hare")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding()
                    .background(isEditable ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .opacity(isEditable ? 1.0 : 0.5) // Change opacity when disabled
                    .clipShape(Circle())
                    .shadow(radius: 10)
                }
                .disabled(!isEditable)
                Button(action: {
                  // Insert text at the current cursor position
                  insertTextAtCursor("S-", keepInLine: true)
                }) {
                  Image(systemName: "tortoise")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding()
                    .background(isEditable ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .opacity(isEditable ? 1.0 : 0.5) // Change opacity when disabled
                    .clipShape(Circle())
                    .shadow(radius: 10)
                }
                .disabled(!isEditable)
              }
              HStack {
                Button(action: {
                  // Insert text at the current cursor position
                  insertTextAtCursor(" aus dem Sattel ", keepInLine: true)
                }){
                  Text("UP")
                    .font(.system(size: 15))
                    .frame(width: 50, height: 50)
                      .padding(2)
                      .background(isEditable ? Color.blue : Color.gray)
                      .foregroundColor(.white)
                      .opacity(isEditable ? 1.0 : 0.5) // Change opacity when disabled
                      .clipShape(Circle())
                      .shadow(radius: 10)
              }
                .disabled(!isEditable)

                Button(action: {
                  // Insert text at the current cursor position
                  insertTextAtCursor(" setzen ", keepInLine: true)
                }){
                  Text("DOWN")
                    .font(.system(size: 15))
                    .frame(width: 50, height: 50)
                      .padding(2)
                      .background(isEditable ? Color.blue : Color.gray)
                      .foregroundColor(.white)
                      .opacity(isEditable ? 1.0 : 0.5) // Change opacity when disabled
                      .clipShape(Circle())
                      .shadow(radius: 10)
              }
                .disabled(!isEditable)

                Button(action: {
                  // Insert text at the current cursor position
                  insertTextAtCursor(" HP", keepInLine: true)
                }){
                  Text("HP")
                    .font(.system(size: 15))
                    .frame(width: 50, height: 50)
                      .padding(2)
                      .background(isEditable ? Color.blue : Color.gray)
                      .foregroundColor(.white)
                      .opacity(isEditable ? 1.0 : 0.5) // Change opacity when disabled
                      .clipShape(Circle())
                      .shadow(radius: 10)
              }
                .disabled(!isEditable)

              }
              HStack {

                Button(action: {
                  // Insert text at the current cursor position
                  insertTextAtCursor(" Oberkoerper still ", keepInLine: true)
                }){
                  Text("CALM")
                    .font(.system(size: 15))
                    .frame(width: 50, height: 50)
                      .padding(2)
                      .background(isEditable ? Color.blue : Color.gray)
                      .foregroundColor(.white)
                      .opacity(isEditable ? 1.0 : 0.5) // Change opacity when disabled
                      .clipShape(Circle())
                      .shadow(radius: 10)
              }
                .disabled(!isEditable)

                Button(action: {
                  // Insert text at the current cursor position
                  insertTextAtCursor(" Jumps ", keepInLine: true)
                }){
                  Text("JUMP")
                    .font(.system(size: 15))
                    .frame(width: 50, height: 50)
                      .padding(2)
                      .background(isEditable ? Color.blue : Color.gray)
                      .foregroundColor(.white)
                      .opacity(isEditable ? 1.0 : 0.5) // Change opacity when disabled
                      .clipShape(Circle())
                      .shadow(radius: 10)
              }
                .disabled(!isEditable)

                Button(action: {
                  // Insert text at the current cursor position
                  insertTextAtCursor(" RnB ", keepInLine: true)
                }){
                  Text("RnB")
                    .font(.system(size: 15))
                    .frame(width: 50, height: 50)
                      .padding(2)
                      .background(isEditable ? Color.blue : Color.gray)
                      .foregroundColor(.white)
                      .opacity(isEditable ? 1.0 : 0.5) // Change opacity when disabled
                      .clipShape(Circle())
                      .shadow(radius: 10)
              }
                .disabled(!isEditable)
              }
            }
            .padding([.trailing])
          }
          Spacer()
        }
      }

      Divider()

      VStack {
        ZStack {
          HStack {
            Text("RPM User: \(trackInfoAfter.rpmUser ?? "")")
              .font(.system(size: 15))
              .padding([.leading])

            // symbal picker
            IC_SymbolPicker(trackInfo: trackInfoAfter, isEditable: $isEditable)
              //.padding([.trailing])


            Spacer()
          }

          HStack{
            Text("\(trackInfoAfter.trackTitle ?? "")")
          }

          HStack {
            Spacer()
            Text("BPM Spotify: \(String(format: "%.0f", trackInfoAfter.bpmSpotify))")
              .font(.system(size: 15))
              .padding([.trailing])
          }
        }
        .padding(0)
        TextEditor(text: isEditable ? $trackInfoAfter.customInfo.bound : .constant(trackInfoAfter.customInfo.bound))
          .font(.system(size: fontoSize * 0.9))
          .foregroundColor(Color.blue)
          .scrollContentBackground(.hidden) // <- Hide it for background color
          .background(Color(UIColor.systemGray5))
          .cornerRadius(10)
          .lineSpacing(5)
          .multilineTextAlignment(.leading)
      }
    }.onChange(of: verticalSizeClass, { oldValue, newValue in
      refreshID = UUID()
    })
    .onChange(of: horizontalSizeClass, { oldValue, newValue in
      refreshID = UUID()
    })
    .toolbarBackground(Color(UIColor.lightGray), for: .navigationBar)
    .toolbarBackground(.visible, for: .navigationBar)
    .toolbar (content: ) {
      ToolbarItem(placement:.navigationBarLeading){
        HStack (spacing: 0){
          IC_SymbolPicker(trackInfo: trackInfo, isEditable: $isEditable)
            .padding([.leading])
          Spacer()
        }
        .frame(minWidth: 300, maxWidth: 300, minHeight: 20, maxHeight: 20, alignment: .leading)
        .padding([.leading])
      }

      ToolbarItem(placement:.navigationBarTrailing){
        HStack (spacing: 0){

          HStack (spacing: 0) {
            Text("RPM: ")
            TextField("", text: Binding($trackInfo.rpmUser)!)
              .disabled(!isEditable)
              .disableAutocorrection(true)
          }
          .frame(minWidth: 100, maxWidth: 100, minHeight: 20, maxHeight: 20, alignment: .center)
          .padding([.trailing])

          HStack (spacing: 0) {
            Text("BPM: ")
              .frame(minWidth: 50, maxWidth: 50, minHeight: 20, maxHeight: 20, alignment: .center)
            TextField("Tap", value: $trackInfo.bpmSpotify, formatter: amountFormatter)
              .keyboardType(.decimalPad)
              .disabled(!isEditable)
              .frame(minWidth: 50, maxWidth: 50, minHeight: 20, maxHeight: 20, alignment: .center)

            Button(action: buttonTapped) {
              Image(systemName: "hand.tap")
              .resizable()
              .frame(width: 24, height: 24)
              .padding()
              .background(isEditable ? Color.blue : Color.gray)
              .foregroundColor(.white)
              .opacity(isEditable ? 1.0 : 0.5) // Change opacity when disabled
              .clipShape(Circle())
              .shadow(radius: 10)
            }
            //.buttonStyle(.bordered)
            .disabled(!isEditable)
          }
          /*.onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
           let now = Date()
           if let lastTapDate = lastTapDate, now.timeIntervalSince(lastTapDate) > 2 {
           taps.removeAll()
           //trackInfo.bpmSpotify = 0
           }
           }*/
          .frame(minWidth: 150, maxWidth: 150, minHeight: 20, maxHeight: 20, alignment: .center)
          .padding([.trailing])
          //}
        }
        .frame(minWidth: 300, maxWidth: 300, minHeight: 30, maxHeight: 30, alignment: .center)
        .padding([.trailing])
      }
    }
    .id(
      refreshID
    )// Work around to get disappearing tool bar items visible >> https://stackoverflow.com/questions/77399056/swiftui-toolbaritem-button-disappears-after-rotation-in-ios17
    .navigationTitle("\(trackInfo.trackTitle ?? "No track")")
    .toolbarTitleDisplayMode(.inline) // for a smaller toolbar

  }

  func buttonTapped() {
    let currentTime = Date().timeIntervalSince1970

    if let lastTap = tapTimes.last, currentTime - lastTap > 2 {
        // Reset if more than 2 seconds have passed since the last tap
        tapTimes.removeAll()
    }

    tapTimes.append(currentTime)

    if tapTimes.count > 1 {
        let intervals = zip(tapTimes.dropFirst(), tapTimes).map(-)
        let averageInterval = intervals.reduce(0, +) / Double(intervals.count)
      trackInfo.bpmSpotify = Double(Int((60 / averageInterval)+0.5))
    }

    //print("tapTimmes count: \(tapTimes.count) with average BPM: \(trackInfo.bpmSpotify)")

    //resetAfterPause()
}

  func insertTextAtCursor(_ newText: String, keepInLine: Bool = false) {
    guard let textView = textView else { return }
    /* working
     if let selectedRange = textView.selectedTextRange {
     textView.replace(selectedRange, withText: newText)
     }
     */


    if let selectedRange = textView.selectedTextRange {
      let cursorPosition = selectedRange.start
      //let beginningOfLine = textView.position(from: cursorPosition, offset: -textView.offset(from: textView.beginningOfDocument, to: cursorPosition))

      // Determine the beginning of the line by traversing backwards until a newline or the beginning is found
      var position = cursorPosition
      while position != textView.beginningOfDocument {
        let prevPosition = textView.position(from: position, offset: -1)
        let range = textView.textRange(from: prevPosition!, to: position)
        if textView.text(in: range!) == "\n" {
          break
        }
        position = prevPosition!
      }
      if position != cursorPosition && !keepInLine {
        textView.replace(selectedRange, withText: "\n" + newText)
      } else {
        textView.replace(selectedRange, withText: newText)
      }
    }
  }
  /* another solution for bpm button
   private func tapForBPM() {
   let timeNow = Date().timeIntervalSince1970
   timeChange = timeNow - timeLast

   // Timeout? Start again
   if timeChange > timeout {
   count = 0
   next = 0
   bpmNow = 0
   bpmAvg = 0
   trackInfo.bpmSpotify = 0
   }

   count += 1

   // Enough beats to make a measurement (2 or more)?
   if count > 1 {
   bpmNow = 60 / timeChange // Instantaneous measurement

   // Enough to make an average measurement
   if count > maxCount { // Average over maxCount
   trackInfo.bpmSpotify = 60 * Double(maxCount) / (timeNow - times[next % maxCount])
   }
   }

   timeLast = timeNow // For instant measurement and for timeout
   if times.count < maxCount {
   times.append(timeNow)
   } else {
   times[next % maxCount] = timeNow
   }
   next += 1
   }
   another solution for bpm button */

}


struct IC_TrackDetailView_Previews: PreviewProvider {
  static var previews: some View {
    IC_TrackDetailView(
      trackInfo: IC_TrackInfo(),
      isEditable: .constant(false),
      trackInfoAfter: IC_TrackInfo()
    )
  }
}

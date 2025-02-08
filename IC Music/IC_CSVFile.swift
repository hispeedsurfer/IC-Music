//
//  CSVFile.swift
//  IC Music
//
//  Created by Andreas Franke on 30.01.25.
//


import SwiftUI
import UniformTypeIdentifiers

struct IC_CSVFile: FileDocument {
    static var readableContentTypes = [UTType.plainText]
    var text: String

    init(text: String = "") {
        self.text = text
    }

    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        } else {
            text = ""
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}

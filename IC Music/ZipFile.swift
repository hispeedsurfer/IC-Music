//
//  ZipFile.swift
//  IC Music
//
//  Created by Andreas Franke on 03.03.24.
//

// Example exportIPA() usage

import SwiftUI
import UniformTypeIdentifiers

extension UTType
{
    static let zip = UTType(filenameExtension: "zip")!
}

struct ZipFile: FileDocument
{
    let file: FileWrapper
    
    static var readableContentTypes: [UTType] { [.zip] }
    static var writableContentTypes: [UTType] { [.zip] }
    
    init(zipURL: URL) throws
    {
        self.file = try FileWrapper(url: zipURL, options: .immediate)
    }
    
    init(configuration: ReadConfiguration) throws
    {
        self.file = configuration.file
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper
    {
        return self.file
    }

}

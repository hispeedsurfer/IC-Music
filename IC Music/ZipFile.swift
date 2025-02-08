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

// Wrapper class for FileWrapper
final class FileWrapperContainer: @unchecked Sendable {
    let file: FileWrapper

    init(file: FileWrapper) {
        self.file = file
    }
}

struct ZipFile: FileDocument {
    let container: FileWrapperContainer

    static var readableContentTypes: [UTType] { [.zip] }
    static var writableContentTypes: [UTType] { [.zip] }

    init(zipURL: URL) throws {
        let fileWrapper = try FileWrapper(url: zipURL, options: .immediate)
        self.container = FileWrapperContainer(file: fileWrapper)
    }

    init(configuration: ReadConfiguration) throws {
        self.container = FileWrapperContainer(file: configuration.file)
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return self.container.file
    }
}

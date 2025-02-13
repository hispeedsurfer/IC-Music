//
//  NSPersistentContainer+extension.swift
//  CDMoveDemo
//
//  Created by Tom Harrington on 5/12/20.
//  Copyright © 2020 Atomic Bird LLC. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import ZIPFoundation
import Zip

extension NSPersistentContainer {
  enum CopyPersistentStoreErrors: Error {
    case invalidDestination(String)
    case destinationError(String)
    case destinationNotRemoved(String)
    case copyStoreError(String)
    case invalidSource(String)
  }

  /// Restore backup persistent stores located in the directory referenced by `backupURL`.
  ///
  /// **Be very careful with this**. To restore a persistent store, the current persistent store must be removed from the container. When that happens, **all currently loaded Core Data objects** will become invalid. Using them after restoring will cause your app to crash. When calling this method you **must** ensure that you do not continue to use any previously fetched managed objects or existing fetched results controllers. **If this method does not throw, that does not mean your app is safe.** You need to take extra steps to prevent crashes. The details vary depending on the nature of your app.
  /// - Parameter backupURL: A file URL containing backup copies of all currently loaded persistent stores.
  /// - Throws: `CopyPersistentStoreError` in various situations.
  /// - Returns: Nothing. If no errors are thrown, the restore is complete.
  func restorePersistentStore(from backupURL: URL, destination: URL? = nil) throws -> Void {
    guard backupURL.isFileURL else {
      throw CopyPersistentStoreErrors.invalidSource("Backup URL must be a file URL")
    }

    var destinationURL = destination?.deletingLastPathComponent()
    if backupURL.pathExtension == "zip" {
      //destinationURL!.appendPathComponent("directory")
      do {
        // If we're overwriting, remove the destination.
        if FileManager.default.fileExists(atPath: destination!.path) {
          do {
            try FileManager.default.removeItem(at: destination!)
          } catch {
            throw CopyPersistentStoreErrors
              .destinationNotRemoved(
                "Can't overwrite destination at \(String(describing: destination))"
              )
          }
        }
        try FileManager.default
          .createDirectory(at: destinationURL!, withIntermediateDirectories: true, attributes: nil)
        //try Zip.unzipFile(backupURL, destination: destinationURL!, overwrite: true, password: "") // Unzip
        try FileManager.default.unzipItem(at: backupURL, to: destinationURL!)
      } catch {
        print("Extraction of ZIP archive failed with error:\(error)")
      }
    }
    else {
      destinationURL = backupURL
    }

    var isDirectory: ObjCBool = false
    if FileManager.default.fileExists(atPath: destination!.path, isDirectory: &isDirectory) {
      if !isDirectory.boolValue {
        throw CopyPersistentStoreErrors.invalidSource("Source URL must be a directory")
      }
    } else {
      throw CopyPersistentStoreErrors.invalidSource("Source URL must exist")
    }

    for persistentStoreDescription in persistentStoreDescriptions {
      guard let loadedStoreURL = persistentStoreDescription.url else {
        continue
      }
      let backupStoreURL = destination!.appendingPathComponent(loadedStoreURL.lastPathComponent)
      guard FileManager.default.fileExists(atPath: backupStoreURL.path) else {
        throw CopyPersistentStoreErrors.invalidSource("Missing backup store for \(backupStoreURL)")
      }
      do {
        let storeOptions = persistentStoreDescription.options
        let configurationName = persistentStoreDescription.configuration
        let storeType = persistentStoreDescription.type


        // Replace the current store with the backup copy. This has a side effect of removing the current store from the Core Data stack.
        // When restoring, it's necessary to use the current persistent store coordinator.
        try persistentStoreCoordinator
          .replacePersistentStore(
            at: loadedStoreURL,
            destinationOptions: storeOptions,
            withPersistentStoreFrom: backupStoreURL,
            sourceOptions: storeOptions,
            ofType: storeType
          )
        // Add the persistent store at the same location we've been using, because it was removed in the previous step.
        try persistentStoreCoordinator
          .addPersistentStore(
            ofType: storeType,
            configurationName: configurationName,
            at: loadedStoreURL,
            options: storeOptions
          )
      } catch {
        throw CopyPersistentStoreErrors
          .copyStoreError("Could not restore: \(error.localizedDescription)")
      }
    }
  }

  /// Copy all loaded persistent stores to a new directory. Each currently loaded file-based persistent store will be copied (including journal files, external binary storage, and anything else Core Data needs) into the destination directory to a persistent store with the same name and type as the existing store. In-memory stores, if any, are skipped.
  /// - Parameters:
  ///   - destinationURL: Destination for new persistent store files. Must be a file URL. If `overwriting` is `false` and `destinationURL` exists, it must be a directory.
  ///   - overwriting: If `true`, any existing copies of the persistent store will be replaced or updated. If `false`, existing copies will not be changed or remoted. When this is `false`, the destination persistent store file must not already exist.
  /// - Throws: `CopyPersistentStoreError`
  /// - Returns: Nothing. If no errors are thrown, all loaded persistent stores will be copied to the destination directory.
  func copyPersistentStores(to destinationURL: URL, overwriting: Bool = true) throws -> String {
    // this will hold the URL of the zip file
    var archiveUrl: URL?

    guard destinationURL.isFileURL else {
      throw CopyPersistentStoreErrors.invalidDestination("Destination URL must be a file URL")
    }

    // If the destination exists and we aren't overwriting it, then it must be a directory. (If we are overwriting, we'll remove it anyway, so it doesn't matter whether it's a directory).
    var isDirectory: ObjCBool = false
    if !overwriting && FileManager.default
      .fileExists(atPath: destinationURL.path, isDirectory: &isDirectory) {
      if !isDirectory.boolValue {
        throw CopyPersistentStoreErrors.invalidDestination("Destination URL must be a directory")
      }
      // Don't check if destination stores exist in the destination dir, that comes later on a per-store basis.
    }
    // If we're overwriting, remove the destination.
    if overwriting && FileManager.default.fileExists(atPath: destinationURL.path) {
      do {
        try FileManager.default.removeItem(at: destinationURL)
      } catch {
        throw CopyPersistentStoreErrors
          .destinationNotRemoved("Can't overwrite destination at \(destinationURL)")
      }
    }

    // Create the destination directory
    do {
      try FileManager.default
        .createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
    } catch {
      throw CopyPersistentStoreErrors
        .destinationError("Could not create destination directory at \(destinationURL)")
    }

    for persistentStoreDescription in persistentStoreDescriptions {
      guard let storeURL = persistentStoreDescription.url else {
        continue
      }
      guard persistentStoreDescription.type != NSInMemoryStoreType else {
        continue
      }
      let destinationStoreURL = destinationURL.appendingPathComponent(storeURL.lastPathComponent)

      if !overwriting && FileManager.default.fileExists(atPath: destinationStoreURL.path) {
        // If the destination exists, the replacePersistentStore call will update it in place. That's fine unless we're not overwriting.
        throw CopyPersistentStoreErrors
          .destinationError("Destination already exists at \(destinationStoreURL)")
      }
      do {
        // Replace an existing backup, if any, with a new one with the same options and type. This doesn't affect the current Core Data stack.
        // The function name says "replace", but it works if there's nothing at the destination yet. In that case it creates a new persistent store.
        // Note that for backup, it doesn't matter if the persistent store coordinator is the one currently in use or a different one. It could be a class function, for this use.
        try persistentStoreCoordinator
          .replacePersistentStore(
            at: destinationStoreURL,
            destinationOptions: persistentStoreDescription.options,
            withPersistentStoreFrom: storeURL,
            sourceOptions: persistentStoreDescription.options,
            ofType: persistentStoreDescription.type
          )

        let resourceKeys : [URLResourceKey] = [.creationDateKey, .isDirectoryKey]
        let enumerator = FileManager.default.enumerator(
          at: destinationURL,
          includingPropertiesForKeys: resourceKeys,
          options: [.skipsHiddenFiles],
          errorHandler: { (
            url,
            error
          ) -> Bool in
            print("directoryEnumerator error at \(url): ", error)
            return true
          })!

        for case let fileURL as URL in enumerator {
          let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
          print(fileURL.path, resourceValues.creationDate!, resourceValues.isDirectory!)
        }

#if ZIP_FILE
        // one way to zip files using ZIPFoundation
        // BEGIN ZIPFoundation
        let fm = FileManager.default
        let tmpUrl1 = try! fm.url(
          for: .documentDirectory,
          in: .userDomainMask,
          appropriateFor: destinationURL,
          create: true
        ).appendingPathComponent("IC_test.zip")


        if fm.fileExists(atPath: tmpUrl1.path) {
          try fm.removeItem(at: tmpUrl1)
        }
        try fm.zipItem(at: destinationURL, to: tmpUrl1)
        // if we encounter an error, store it here
        var error: NSError?
        // END ZIPFoundation

        // another way to zip files without 3rd party dependencies
        let coordinator = NSFileCoordinator()
        // zip up the documents directory
        // this method is synchronous and the block will be executed before it returns
        // if the method fails, the block will not be executed though
        // if you expect the archiving process to take long, execute it on another queue
        coordinator
          .coordinate(readingItemAt: destinationURL, options: [.forUploading], error: &error) { (
            zipUrl
          ) in
            // zipUrl points to the zip file created by the coordinator
            // zipUrl is valid only until the end of this block, so we move the file to a temporary folder
            let tmpUrl = try! fm.url(
              for: .documentDirectory,
              in: .userDomainMask,
              appropriateFor: zipUrl,
              create: true
            ).appendingPathComponent(zipUrl.lastPathComponent)
            try? fm.removeItem(at: tmpUrl)
            try! fm.moveItem(at: zipUrl, to: tmpUrl)

            // store the URL so we can use it outside the block
            archiveUrl = tmpUrl
          }

        /*if let archiveUrl = archiveUrl {
         // bring up the share sheet so we can send the archive with AirDrop for example
         //let avc = UIActivityViewController(activityItems: [archiveUrl], applicationActivities: nil)
         //present(avc, animated: true)
         } else {
         print(error!)
         }*/
#endif
      } catch {
        throw CopyPersistentStoreErrors.copyStoreError("\(error.localizedDescription)")
      }
    }

    return archiveUrl?.path ?? ""
  }
}

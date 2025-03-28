//
//  Persistence.swift
//  IC Music
//
//  Created by Andreas Franke on 25.02.24.
//

import CoreData

struct PersistenceController {
  static let shared = PersistenceController()

  static var preview: PersistenceController = {
    let result = PersistenceController(inMemory: true)
    let viewContext = result.container.viewContext
    for _ in 0..<10 {
      let newItem = IC_TrackInfo(context: viewContext)
      newItem.trackURI = "spotify.com/track/123456789"
      newItem.trackTitle = "Test Track"
      newItem.spotifyId = "123456789"
    }
    do {
      try viewContext.save()
    } catch {
      // Replace this implementation with code to handle the error appropriately.
      // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      let nsError = error as NSError
      fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
    return result
  }()

  let container: NSPersistentContainer

  init(inMemory: Bool = false) {
    container = NSPersistentContainer(name: "IC_Music")
    if inMemory {
      container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
    }
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

        /*
         Typical reasons for an error here include:
         * The parent directory does not exist, cannot be created, or disallows writing.
         * The persistent store is not accessible, due to permissions or data protection when the device is locked.
         * The device is out of space.
         * The store could not be migrated to the current model version.
         Check the error message to determine what the actual problem was.
         */
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
#if DEBUG
    // If you have multiple stores saved in different directories, you need to print them out one by one
    if let url = container.persistentStoreCoordinator.persistentStores.first?.url {
      print(url)
    }
#endif
    container.viewContext.automaticallyMergesChangesFromParent = true
  }

  func resetCoreData(){

    guard let firstStore = self.container.persistentStoreCoordinator.persistentStores.first else {
      print("Missing first store URL - could not destroy")
      return
    }

    do {
      try self.container.persistentStoreCoordinator
        .destroyPersistentStore(at: firstStore.url!, ofType: NSSQLiteStoreType, options: nil)
    } catch  {
      print("Unable to destroy persistent store: \(error) - \(error.localizedDescription)")
    }

    self.container.loadPersistentStores(completionHandler: { (storeDescription, error) in

      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
  }

  func queryCoreDate(){
//    let fetchRequest: NSFetchRequest<IC_TrackInfo> = IC_TrackInfo.fetchRequest()
//    do {
//      let tracks = try container.viewContext.fetch(fetchRequest)
//      for track in tracks {
//        print(track.trackTitle)
//      }
//    }

      let result = PersistenceController(inMemory: false)
      let viewContext = result.container.viewContext

    let fetchRequest = NSFetchRequest<IC_TrackInfo>(entityName: "IC_TrackInfo")
    var predicate: NSPredicate
    predicate = NSPredicate(format: "trackURI == %@", "")

    //NSLog("secondPredicate description: %@", predicate);
    fetchRequest.predicate = predicate
    fetchRequest.fetchLimit = 1000
    do {
      let fetchedCustomers = try viewContext.fetch(fetchRequest)
      var customerCount = 0
      for customer in fetchedCustomers {
        print(customer.trackTitle ?? "")
        if (customer.trackTitle == "Unknown Track" && customer.trackURI == "") {
          viewContext.delete(customer)
          customerCount += 1
        }

      }

      if (customerCount > 0) {
        try viewContext.save()
      }
    } catch {
      print("Error loading customer: \(error)")
    }
  }
}

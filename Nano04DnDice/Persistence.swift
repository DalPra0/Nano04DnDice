
// MARK: - CoreData Persistence (Currently Unused)
// This file is kept for potential future use but is not currently integrated.
// The app uses UserDefaults/AppStorage for data persistence instead.
// To enable CoreData:
// 1. Uncomment this file
// 2. Add persistenceController to Nano04DnDiceApp.swift
// 3. Update data models to use CoreData entities

/*
import CoreData

class PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Log error instead of crashing preview
            print("⚠️ Preview data save failed: \(error.localizedDescription)")
        }
        return result
    }()

    let container: NSPersistentContainer
    private(set) var loadError: Error?

    init(inMemory: Bool = false) {
        // Use regular NSPersistentContainer to avoid CloudKit requirements
        // Can be upgraded to NSPersistentCloudKitContainer when properly configured
        container = NSPersistentContainer(name: "Nano04DnDice")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { [weak self] storeDescription, error in
            if let error = error as NSError? {
                // Log error instead of crashing
                print("❌ Core Data error: \(error.localizedDescription)")
                print("   Store: \(storeDescription)")
                print("   User Info: \(error.userInfo)")
                
                // Store error for potential UI handling
                self?.loadError = error
                
                // Attempt recovery by removing corrupted store
                if let storeURL = storeDescription.url {
                    print("⚠️ Attempting to remove corrupted store...")
                    try? FileManager.default.removeItem(at: storeURL)
                    
                    // Try loading again
                    self?.container.loadPersistentStores { _, recoveryError in
                        if let recoveryError = recoveryError {
                            print("❌ Recovery failed: \(recoveryError.localizedDescription)")
                        } else {
                            print("✅ Store recovered successfully")
                            self?.loadError = nil
                        }
                    }
                }
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
*/

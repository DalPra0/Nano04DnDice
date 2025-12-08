
import SwiftUI
import Combine
import CloudKit

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: DiceCustomization
    @Published var savedThemes: [DiceCustomization] = []
    @Published var iCloudSyncEnabled: Bool {
        didSet {
            UserDefaults.standard.set(iCloudSyncEnabled, forKey: "iCloudSyncEnabled")
            // Temporarily disabled - CloudKit requires proper entitlements configuration
            // if iCloudSyncEnabled {
            //     setupiCloudSync()
            //     uploadLocalThemesToiCloud()
            // }
        }
    }
    @Published var syncStatus: SyncStatus = .idle
    
    private let userDefaultsKey = "savedThemes"
    private let currentThemeKey = "currentTheme"
    private let cloudContainer = CKContainer(identifier: "iCloud.com.yourcompany.Nano04DnDice")
    private let recordType = "DiceTheme"
    private var syncTimer: Timer?
    
    init() {
        // Load iCloud sync preference
        self.iCloudSyncEnabled = UserDefaults.standard.bool(forKey: "iCloudSyncEnabled")
        
        if let data = UserDefaults.standard.data(forKey: currentThemeKey),
           let theme = try? JSONDecoder().decode(DiceCustomization.self, from: data) {
            self.currentTheme = theme
        } else {
            self.currentTheme = PresetThemes.classic
        }
        
        loadSavedThemes()
        
        // Temporarily disabled - CloudKit requires proper entitlements configuration
        // if iCloudSyncEnabled {
        //     setupiCloudSync()
        // }
    }
    
    
    func applyTheme(_ theme: DiceCustomization) {
        currentTheme = theme
        saveCurrentTheme()
    }
    
    func saveCustomTheme(_ theme: DiceCustomization) {
        if let index = savedThemes.firstIndex(where: { $0.id == theme.id }) {
            savedThemes[index] = theme
        } else {
            savedThemes.append(theme)
        }
        saveToDisk()
    }
    
    func deleteTheme(_ theme: DiceCustomization) {
        savedThemes.removeAll { $0.id == theme.id }
        saveToDisk()
    }
    
    func duplicateTheme(_ theme: DiceCustomization) -> DiceCustomization {
        var newTheme = theme
        newTheme.id = UUID()
        newTheme.name = "\(theme.name) (Cópia)"
        return newTheme
    }
    
    
    private func saveCurrentTheme() {
        if let encoded = try? JSONEncoder().encode(currentTheme) {
            UserDefaults.standard.set(encoded, forKey: currentThemeKey)
        }
    }
    
    private func saveToDisk() {
        if let encoded = try? JSONEncoder().encode(savedThemes) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
        
        if iCloudSyncEnabled {
            syncThemesToiCloud()
        }
    }
    
    private func loadSavedThemes() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let themes = try? JSONDecoder().decode([DiceCustomization].self, from: data) {
            self.savedThemes = themes
        } else {
            self.savedThemes = PresetThemes.allThemes
            saveToDisk()
        }
    }
    
    
    func loadPresetThemes() {
        let presets = PresetThemes.allThemes
        for preset in presets {
            if !savedThemes.contains(where: { $0.name == preset.name }) {
                savedThemes.append(preset)
            }
        }
        saveToDisk()
    }
    
    // MARK: - iCloud Sync
    
    private func setupiCloudSync() {
        // Listen for iCloud changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(iCloudDataChanged),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: NSUbiquitousKeyValueStore.default
        )
        
        // Initial sync from iCloud
        fetchThemesFromiCloud()
        
        // Periodic sync every 5 minutes
        syncTimer?.invalidate()
        syncTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.fetchThemesFromiCloud()
        }
    }
    
    @objc private func iCloudDataChanged(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.fetchThemesFromiCloud()
        }
    }
    
    private func syncThemesToiCloud() {
        guard iCloudSyncEnabled else { return }
        
        syncStatus = .syncing
        
        let database = cloudContainer.privateCloudDatabase
        
        // Delete all existing records first (simple approach)
        fetchExistingRecordIDs { [weak self] recordIDs in
            guard let self = self else { return }
            
            if !recordIDs.isEmpty {
                let deleteOperation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIDs)
                deleteOperation.modifyRecordsResultBlock = { _ in
                    // After deletion, upload new themes
                    self.uploadLocalThemesToiCloud()
                }
                database.add(deleteOperation)
            } else {
                self.uploadLocalThemesToiCloud()
            }
        }
    }
    
    private func uploadLocalThemesToiCloud() {
        guard iCloudSyncEnabled else { return }
        
        let database = cloudContainer.privateCloudDatabase
        var records: [CKRecord] = []
        
        for theme in savedThemes where !theme.isPreset {
            let recordID = CKRecord.ID(recordName: theme.id.uuidString)
            let record = CKRecord(recordType: recordType, recordID: recordID)
            
            if let themeData = try? JSONEncoder().encode(theme) {
                record["themeData"] = themeData as CKRecordValue
                record["themeName"] = theme.name as CKRecordValue
                record["modifiedDate"] = Date() as CKRecordValue
                records.append(record)
            }
        }
        
        guard !records.isEmpty else {
            syncStatus = .success
            return
        }
        
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        
        operation.modifyRecordsResultBlock = { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.syncStatus = .success
                    print("✅ Themes synced to iCloud successfully")
                case .failure(let error):
                    self?.syncStatus = .failed(error.localizedDescription)
                    print("❌ iCloud sync failed: \(error)")
                }
            }
        }
        
        database.add(operation)
    }
    
    private func fetchThemesFromiCloud() {
        guard iCloudSyncEnabled else { return }
        
        syncStatus = .syncing
        
        let database = cloudContainer.privateCloudDatabase
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "modifiedDate", ascending: false)]
        
        database.fetch(withQuery: query, inZoneWith: nil) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let result):
                    var cloudThemes: [DiceCustomization] = []
                    
                    for (_, recordResult) in result.matchResults {
                        if case .success(let record) = recordResult,
                           let themeData = record["themeData"] as? Data,
                           let theme = try? JSONDecoder().decode(DiceCustomization.self, from: themeData) {
                            cloudThemes.append(theme)
                        }
                    }
                    
                    self.mergeCloudThemes(cloudThemes)
                    self.syncStatus = .success
                    print("✅ Fetched \(cloudThemes.count) themes from iCloud")
                    
                case .failure(let error):
                    self.syncStatus = .failed(error.localizedDescription)
                    print("❌ iCloud fetch failed: \(error)")
                }
            }
        }
    }
    
    private func mergeCloudThemes(_ cloudThemes: [DiceCustomization]) {
        // Merge cloud themes with local themes
        var merged = savedThemes
        
        for cloudTheme in cloudThemes {
            if let index = merged.firstIndex(where: { $0.id == cloudTheme.id }) {
                // Update existing theme
                merged[index] = cloudTheme
            } else {
                // Add new theme from cloud
                merged.append(cloudTheme)
            }
        }
        
        savedThemes = merged
        
        // Save to local storage
        if let encoded = try? JSONEncoder().encode(savedThemes) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func fetchExistingRecordIDs(completion: @escaping ([CKRecord.ID]) -> Void) {
        let database = cloudContainer.privateCloudDatabase
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        
        database.fetch(withQuery: query, inZoneWith: nil) { result in
            switch result {
            case .success(let result):
                let recordIDs = result.matchResults.compactMap { key, _ in key }
                completion(recordIDs)
            case .failure:
                completion([])
            }
        }
    }
    
    deinit {
        syncTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Supporting Types

enum SyncStatus: Equatable {
    case idle
    case syncing
    case success
    case failed(String)
    
    var description: String {
        switch self {
        case .idle: return "Not syncing"
        case .syncing: return "Syncing..."
        case .success: return "Synced"
        case .failed(let error): return "Failed: \(error)"
        }
    }
}

extension DiceCustomization {
    var isPreset: Bool {
        // Preset themes have specific names
        let presetNames = PresetThemes.allThemes.map { $0.name }
        return presetNames.contains(name)
    }
}

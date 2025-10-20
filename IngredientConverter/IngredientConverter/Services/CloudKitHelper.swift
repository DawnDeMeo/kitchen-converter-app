//
//  CloudKitHelper.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/16/25.
//

import SwiftUI
import CloudKit

/// Helper to check iCloud availability and provide user feedback
@Observable
class CloudKitHelper {
    var iCloudAvailable: Bool = false
    var statusMessage: String = ""

    init() {
        checkiCloudStatus()
    }

    func checkiCloudStatus() {
        CKContainer.default().accountStatus { status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    self.iCloudAvailable = true
                    self.statusMessage = "iCloud sync enabled"
                case .noAccount:
                    self.iCloudAvailable = false
                    self.statusMessage = "Sign in to iCloud to sync across devices"
                case .restricted:
                    self.iCloudAvailable = false
                    self.statusMessage = "iCloud access is restricted"
                case .couldNotDetermine:
                    self.iCloudAvailable = false
                    self.statusMessage = "Could not determine iCloud status"
                case .temporarilyUnavailable:
                    self.iCloudAvailable = false
                    self.statusMessage = "iCloud temporarily unavailable"
                @unknown default:
                    self.iCloudAvailable = false
                    self.statusMessage = "Unknown iCloud status"
                }
            }
        }
    }
}

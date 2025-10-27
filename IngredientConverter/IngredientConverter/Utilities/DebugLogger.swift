//
//  DebugLogger.swift
//  IngredientConverter
//
//  Debug logging utility that can be toggled for production builds
//

import Foundation

struct DebugLogger {
    /// Enable/disable debug logging based on build configuration
    static var isEnabled: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    /// Log a debug message (only in DEBUG builds)
    static func log(_ message: String) {
        guard isEnabled else { return }
        print(message)
    }

    /// Log with a category prefix for easier filtering
    static func log(_ message: String, category: String) {
        guard isEnabled else { return }
        print("[\(category)] \(message)")
    }
}

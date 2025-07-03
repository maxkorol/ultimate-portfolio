//
//  Shortcuts.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 03/07/2025.
//

import AppIntents

struct ShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddIssueIntent(),
            phrases: [
                "Add an \(.applicationName) issue"
            ],
            shortTitle: "Add an issue",
            systemImageName: "pencil"
        )
    }
}

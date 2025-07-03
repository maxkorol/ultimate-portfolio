//
//  AddIssueIntent.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 03/07/2025.
//

import AppIntents

struct AddIssueIntent: AppIntent {
    static let title: LocalizedStringResource = "Add Issue"
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Enter issue title")
    var title: String

    func perform() async throws -> some IntentResult {
        DataController.shared.newIssue(title: title)
        return .result()
    }
}

//
//  NoIssueView.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 25/06/2025.
//

import SwiftUI

struct NoIssueView: View {
    @Environment(DataController.self) var dataController

    var body: some View {
        Text("No Issue Selected")
            .font(.title)
            .foregroundStyle(.secondary)
        Button("New Issue") {
            dataController.newIssue()
        }
    }
}

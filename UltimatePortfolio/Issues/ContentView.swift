//
//  ContentView.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 24/06/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(DataController.self) private var dataController
    var issues: [Issue] { dataController.issuesForSelectedFilter() }

    var body: some View {
        @Bindable var dataController = dataController
        NavigationStack {
            List(selection: $dataController.selectedIssue) {
                ForEach(issues) { issue in
                    IssueRow(issue: issue)
                }
                .onDelete(perform: delete)
                .id(dataController.state)
            }
            .searchable(
                text: $dataController.filterText,
                tokens: $dataController.filterTokens,
                prompt: "Filter issues, or type # to add tags"
            ) { tag in
                Text(tag.tagName)
            }
            .searchSuggestions {
                ForEach(dataController.suggestedFilterTokens) { token in
                    Text(token.tagName).searchCompletion(token)
                }
            }
            .navigationTitle("Issues")
            .toolbar(content: ContentViewToolbar.init)
        }
    }

    func delete(_ offsets: IndexSet) {
        for offset in offsets {
            let item = issues[offset]
            dataController.delete(item)
            if dataController.selectedIssue == item {
                dataController.selectedIssue = nil
            }
        }
    }
}

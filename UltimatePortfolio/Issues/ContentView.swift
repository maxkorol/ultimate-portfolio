//
//  ContentView.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 24/06/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var viewModel: ViewModel

    var body: some View {
        NavigationStack {
            List(selection: $viewModel.selectedIssue) {
                ForEach(viewModel.issues) { issue in
                    IssueRow(issue: issue)
                }
                .onDelete(perform: viewModel.delete)
                .id(viewModel.state)
            }
            .searchable(
                text: $viewModel.filterText,
                tokens: $viewModel.filterTokens,
                prompt: "Filter issues, or type # to add tags"
            ) { tag in
                Text(tag.tagName)
            }
            .searchSuggestions {
                ForEach(viewModel.suggestedFilterTokens) { token in
                    Text(token.tagName).searchCompletion(token)
                }
            }
            .navigationTitle("Issues")
            .toolbar(content: ContentViewToolbar.init)
        }
    }

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = State(initialValue: viewModel)
    }
}

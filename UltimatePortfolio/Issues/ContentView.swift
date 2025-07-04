//
//  ContentView.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 24/06/2025.
//

import SwiftUI
import CoreData
import StoreKit

struct ContentView: View {
    @State private var viewModel: ViewModel
    #if !os(watchOS)
    @Environment(\.requestReview) var requestReview
    #endif

    var body: some View {
        NavigationStack {
            List(selection: $viewModel.selectedIssue) {
                ForEach(viewModel.issues) { issue in
                    #if os(watchOS)
                    IssueRowWatch(issue: issue)
                    #else
                    IssueRow(issue: issue)
                    #endif
                }
                .onDelete(perform: viewModel.delete)
                .id(viewModel.state)
            }
            #if !os(watchOS)
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
            #endif
            .navigationTitle("Issues")
            .toolbar(content: ContentViewToolbar.init)
        }
        .macFrame(minWidth: 220)
        #if !os(watchOS)
        .onAppear(perform: askForReview)
        #endif
        .onOpenURL(perform: viewModel.openURL)
    }

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = State(initialValue: viewModel)
    }

    #if !os(watchOS)
    func askForReview() {
        if viewModel.shouldRequestReview {
            requestReview()
        }
    }
    #endif
}

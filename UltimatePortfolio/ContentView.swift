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
            .toolbar {
                Menu {
                    Button(dataController.filterEnabled ? "Turn Filter Off" : "Turn Filter On") {
                        dataController.filterEnabled.toggle()
                    }
                    #if os(iOS)
                    .menuActionDismissBehavior(dataController.filterEnabled == false ? .disabled : .automatic)
                    #endif
                    
                    Divider()
                    
                    Menu("Sort By") {
                        Picker("Sort By", selection: $dataController.sortType) {
                            Text("Date Created").tag(SortType.dateCreated)
                            Text("Date Modified").tag(SortType.dateModified)
                        }
                        
                        Divider()
                        
                        Picker("Sort Order", selection: $dataController.sortNewestFirst) {
                            Text("Newest to Oldest").tag(true)
                            Text("Oldest to Newest").tag(false)
                        }
                    }
                    
                    Picker("Status", selection: $dataController.filterStatus) {
                        Text("All").tag(Status.all)
                        Text("Open").tag(Status.open)
                        Text("Closed").tag(Status.closed)
                    }
                    .disabled(dataController.filterEnabled == false)
                    
                    Picker("Priority", selection: $dataController.filterPriority) {
                        Text("All").tag(-1)
                        Text("Low").tag(0)
                        Text("Medium").tag(1)
                        Text("High").tag(2)
                    }
                    .disabled(dataController.filterEnabled == false)
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                        .symbolVariant(dataController.filterEnabled ? .fill : .none)
                }
                
                Button(action: dataController.newIssue) {
                    Label("New Issue", systemImage: "square.and.pencil")
                }
            }
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


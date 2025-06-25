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
    var issues: [Issue] {
        let filter = dataController.selectedFilter ?? .all
        var allIssues: [Issue]
        if let tag = filter.tag {
            allIssues = (tag.issues?.allObjects as? [Issue]) ?? []
        } else {
            let request = Issue.fetchRequest()
            request.predicate = NSPredicate(format: "modificationDate > %@", filter.minModificationDate as NSDate)
            allIssues = (try? dataController.container.viewContext.fetch(request)) ?? []
        }
        return allIssues.sorted()
    }
    
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
            .navigationTitle("Issues")
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


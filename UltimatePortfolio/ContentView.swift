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
    @FetchRequest(sortDescriptors: []) var issues: FetchedResults<Issue>
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(issues) { issue in
                    Text(issue.title ?? "")
                }
            }
            .navigationTitle("Issues")
            .toolbar {
                Button("Add Issues") {
                    for i in 1...5 {
                        let issue = Issue(context: dataController.container.viewContext)
                        issue.title = "Issue \(i)"
                        issue.creationDate = Date.now
                        issue.content = "Content Goes Here"
                        issue.priority = 0
                        issue.completed = Bool.random()
                    }
                    dataController.save()
                }
                Button("Delete Data") {
                    dataController.deleteAll()
                }
            }
        }
    }
}


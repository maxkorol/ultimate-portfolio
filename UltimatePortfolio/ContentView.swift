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
        }
    }
}


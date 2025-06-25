//
//  DetailView.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 24/06/2025.
//

import SwiftUI
import CoreData

struct DetailView: View {
    @Environment(DataController.self) var dataController
    
    var body: some View {
        VStack {
            if let issue = dataController.selectedIssue {
                IssueView(issue: issue)
            } else {
                NoIssueView()
            }
        }
        .navigationTitle("Details")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

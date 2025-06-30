//
//  IssueViewToolbar.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 30/06/2025.
//

import SwiftUI

struct IssueViewToolbar: View {
    @ObservedObject var issue: Issue
    @Environment(DataController.self) var dataController
    
    var body: some View {
        Menu {
            Button {
                UIPasteboard.general.string = issue.title
            } label: {
                Label("Copy Issue Title", systemImage: "doc.on.doc")
            }
            
            Button {
                issue.completed.toggle()
                dataController.save()
            } label: {
                Label(issue.completed ? "Re-open Issue" : "Close Issue", systemImage: "bubble.left.and.exclamationmark.bubble.right")
            }
            
            Divider()

            Section("Tags") {
                TagsMenuView(issue: issue)
            }
        } label: {
            Label("Actions", systemImage: "ellipsis.circle")
        }
    }
}

//
//  IssueRowWatch.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 04/07/2025.
//

import SwiftUI

struct IssueRowWatch: View {
    @Environment(DataController.self) var dataController
    @ObservedObject var issue: Issue
    
    var body: some View {
        NavigationLink(value: issue) {
            VStack(alignment: .leading) {
                Text(issue.issueTitle)
                    .font(.headline)
                    .lineLimit(1)
                Text(issue.issueCreationDate.formatted(date: .numeric, time: .omitted))
                    .font(.subheadline)
            }
            .foregroundStyle(issue.completed ? .secondary : .primary)
        }
    }
}

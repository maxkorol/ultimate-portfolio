//
//  TagsMenuView.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 30/06/2025.
//

import SwiftUI

struct TagsMenuView: View {
    @ObservedObject var issue: Issue
    @Environment(DataController.self) var dataController
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Menu {
            ForEach(issue.issueTags) { tag in
                Button {
                    issue.removeFromTags(tag)
                } label: {
                    Label(tag.tagName, systemImage: "checkmark")
                }
            }
            let otherTags = dataController.missingTags(from: issue)
            if otherTags.isEmpty == false {
                Divider()
                
                Section("Add Tags") {
                    ForEach(otherTags) { tag in
                        Button(tag.tagName) {
                            issue.addToTags(tag)
                        }
                    }
                }
            }
        } label: {
            Text(issue.issueTagsList)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .animation(nil, value: issue.issueTagsList)
                #if os(iOS)
                .background(
                    colorScheme == .dark
                        ? Color(.secondarySystemBackground)
                        : Color(.systemBackground)
                )
                #endif
        }
    }
}

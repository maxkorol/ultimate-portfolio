//
//  IssueRowViewModel.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 02/07/2025.
//

import Foundation
import Observation

extension IssueRow {
    @Observable
    @dynamicMemberLookup
    class ViewModel {
        let issue: Issue

        init(issue: Issue) {
            self.issue = issue
        }

        var iconOpacity: Double {
            issue.priority == 2 ? 1 : 0
        }

        var accessibilityIdentifier: String {
            issue.priority == 2 ? "\(issue.issueTitle) High Priority" : ""
        }

        var creationDate: String {
            issue.issueCreationDate.formatted(date: .numeric, time: .omitted)
        }

        var accessibilityCreationDate: String {
            issue.issueCreationDate.formatted(date: .abbreviated, time: .omitted)
        }

        var accessibilityHint: String {
            issue.priority == 2 ? "High priority" : ""
        }

        subscript<Value>(dynamicMember keyPath: KeyPath<Issue, Value>) -> Value {
            issue[keyPath: keyPath]
        }
    }
}

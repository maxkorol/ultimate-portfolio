//
//  ContentViewModel.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 02/07/2025.
//

import Foundation
import Observation

extension ContentView {
    @Observable
    @dynamicMemberLookup
    class ViewModel {
        var dataController: DataController
        var issues: [Issue] { dataController.issuesForSelectedFilter() }

        init(dataController: DataController) {
            self.dataController = dataController
        }

        var shouldRequestReview: Bool {
            dataController.count(for: Tag.fetchRequest()) >= 5
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

        func openURL(url: URL) {
            if url.absoluteString.contains("newIssue") {
                dataController.newIssue()
            } else if let issue = dataController.issue(with: url.absoluteString) {
                dataController.selectedIssue = issue
                dataController.selectedFilter = .all
            }
        }

        subscript<Value>(dynamicMember keyPath: KeyPath<DataController, Value>) -> Value {
            dataController[keyPath: keyPath]
        }

        subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<DataController, Value>) -> Value {
            get { dataController[keyPath: keyPath] }
            set { dataController[keyPath: keyPath] = newValue }
        }
    }
}

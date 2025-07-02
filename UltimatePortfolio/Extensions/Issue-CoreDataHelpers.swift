//
//  Issue-CoreDataHelpers.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 25/06/2025.
//

import Foundation
import CoreData

extension Issue {
    var issueTitle: String {
        get { title ?? "" }
        set { title = newValue }
    }

    var issueContent: String {
        get { content ?? "" }
        set { content = newValue }
    }

    var issueCreationDate: Date {
        creationDate ?? .now
    }

    var issueModificationDate: Date {
        modificationDate ?? .now
    }
    
    var issueReminderTime: Date {
        get { reminderTime ?? .now }
        set { reminderTime = newValue }
    }

    var issueTags: [Tag] {
        let result = tags?.allObjects as? [Tag] ?? []
        return result.sorted()
    }

    var issueStatus: String {
        completed ? NSLocalizedString("Closed", comment: "Closed") : NSLocalizedString("Open", comment: "Open")
    }

    var issueTagsList: String {
        let noTags = NSLocalizedString("No Tags", comment: "No Tags")
        guard let tags else { return noTags }

        if tags.count == 0 {
            return noTags
        } else {
            return issueTags.map(\.tagName).formatted()
        }
    }

    static var example: Issue {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext
        let issue = Issue(context: viewContext)
        issue.title = "Example Issue"
        issue.content = "This is an example issue."
        issue.priority = 1
        issue.creationDate = .now
        return issue
    }
}

extension Issue: Comparable {
    public static func < (lhs: Issue, rhs: Issue) -> Bool {
        let left = lhs.issueTitle.localizedLowercase
        let right = rhs.issueTitle.localizedLowercase
        if left == right {
            return lhs.issueCreationDate < rhs.issueCreationDate
        } else {
            return left < right
        }
    }
}

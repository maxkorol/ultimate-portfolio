//
//  Filter.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 25/06/2025.
//

import Foundation

struct Filter: Identifiable, Hashable {
    var id: UUID
    var name: String
    var icon: String
    var minModificationDate = Date.distantPast
    var tag: Tag?

    static var all = Filter(id: UUID(), name: "All Issues", icon: "tray")
    static var recent = Filter(id: UUID(), name: "Recent Issues", icon: "clock",
                               minModificationDate: .now.addingTimeInterval(86400 * -7))

    var activeIssuesCount: Int {
        tag?.tagActiveIssues.count ?? 0
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Filter, rhs: Filter) -> Bool {
        lhs.id == rhs.id
    }
}

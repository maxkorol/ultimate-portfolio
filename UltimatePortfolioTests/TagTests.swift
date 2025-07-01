//
//  UltimatePortfolioTests.swift
//  UltimatePortfolioTests
//
//  Created by Max Korol on 01/07/2025.
//

import Testing
import CoreData
@testable import UltimatePortfolio

@MainActor
struct TagTests {
    let testDB = TestDatabase()

    @Test func creatingTagsAndIssuesWorks() async throws {
        let count = 10
        let issueCount = count * count
        for _ in 0..<count {
            let tag = Tag(context: testDB.managedObjectContext)
            for _ in 0..<count {
                let issue = Issue(context: testDB.managedObjectContext)
                tag.addToIssues(issue)
            }
        }
        #expect(testDB.dataController.count(for: Tag.fetchRequest()) == count, "Expected \(count) tags.")
        #expect(testDB.dataController.count(for: Issue.fetchRequest()) == issueCount, "Expected \(issueCount) issues.")
    }

    @Test func deletingTagDoesNotDeleteIssues() async throws {
        testDB.dataController.createSampleData()
        let tags = try testDB.managedObjectContext.fetch(Tag.fetchRequest())
        testDB.dataController.delete(tags[0])
        #expect(
            testDB.dataController.count(for: Tag.fetchRequest()) == 4,
            "There should be 4 tags after deletion."
        )
        #expect(
            testDB.dataController.count(for: Issue.fetchRequest()) == 50,
            "There should be 50 issues after tag deletion"
        )
    }
}

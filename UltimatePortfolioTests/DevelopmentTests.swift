//
//  DevelopmentTests.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 01/07/2025.
//

import Testing
import CoreData
@testable import UltimatePortfolio

@MainActor
struct DevelopmentTests {
    let testDB = TestDatabase()

    @Test func sampleDataCreationWorks() async throws {
        testDB.dataController.createSampleData()
        #expect(testDB.dataController.count(for: Tag.fetchRequest()) == 5, "There should be 5 sample tags.")
        #expect(testDB.dataController.count(for: Issue.fetchRequest()) == 50, "There should be 50 sample issues.")
    }

    @Test func deleteAllWorks() async throws {
        testDB.dataController.createSampleData()
        #expect(testDB.dataController.count(for: Tag.fetchRequest()) == 5, "There should be 5 sample tags.")
        #expect(testDB.dataController.count(for: Issue.fetchRequest()) == 50, "There should be 50 sample issues.")
        testDB.dataController.deleteAll()
        #expect(testDB.dataController.count(
            for: Tag.fetchRequest()) == 0,
            "There should be 0 tags after deleting all data."
        )
        #expect(
            testDB.dataController.count(for: Issue.fetchRequest()) == 0,
            "There should be 0 issues after deleting all data."
        )
    }

    @Test func exampleTagHasNoIssues() async throws {
        let tag = Tag.example
        let issuesForTag = tag.issues?.count ?? 0
        #expect(issuesForTag == 0, "Example tag should have no issues associated with it.")
    }

    @Test func exampleIssueHasMediumPriority() async throws {
        let issue = Issue.example
        #expect(issue.priority == 1, "Example issue should have medium priority.")
    }
}

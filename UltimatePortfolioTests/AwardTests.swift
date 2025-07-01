//
//  AwardTests.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 01/07/2025.
//

import Testing
import CoreData
@testable import UltimatePortfolio

@MainActor
struct AwardTests {
    let testDB = TestDatabase()
    let awards = Award.allAwards

    @Test func awardIDMatchesName() async throws {
        for award in awards {
            #expect(award.id == award.name, "Award should have matching ID and name.")
        }
    }

    @Test func newUserHasUnlockedNoAwards() async throws {
        for award in awards {
            #expect(testDB.dataController.hasEarned(award: award) == false, "New user shouldn't have unlocked awards.")
        }
    }

    @Test func creatingIssuesUnlocksAwards() async throws {
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]
        for (count, items) in values.enumerated() {
            var issues = [UltimatePortfolio.Issue]()
            for _ in 0..<items {
                let issue = Issue(context: testDB.managedObjectContext)
                issues.append(issue)
            }
            let earnedAwards = awards.filter {
                $0.criterion == "issues" && testDB.dataController.hasEarned(award: $0)
            }.count
            #expect(earnedAwards == count + 1, "Creating \(items) issues should unlock \(count + 1) awards.")
            for issue in issues {
                testDB.dataController.delete(issue)
            }
        }
    }

    @Test func closingIssuesUnlocksAwards() async throws {
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]
        for (count, items) in values.enumerated() {
            var issues = [UltimatePortfolio.Issue]()
            for _ in 0..<items {
                let issue = Issue(context: testDB.managedObjectContext)
                issue.completed = true
                issues.append(issue)
            }
            let earnedAwards = awards.filter {
                $0.criterion == "closed" && testDB.dataController.hasEarned(award: $0)
            }.count
            #expect(earnedAwards == count + 1, "Closing \(items) issues should unlock \(count + 1) awards.")
            for issue in issues {
                testDB.dataController.delete(issue)
            }
        }
    }
}

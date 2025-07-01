//
//  ExtensionTests.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 01/07/2025.
//

import Testing
import CoreData
@testable import UltimatePortfolio

@MainActor
struct ExtensionTests {
    let testDB = TestDatabase()
    let testBundle = Bundle(identifier: "software.colorful.UltimatePortfolioTests")!

    @Test func issueTitleUnwrap() {
        let issue = Issue(context: testDB.managedObjectContext)
        issue.title = "Example issue"
        #expect(issue.issueTitle == "Example issue", "Changing title should also change issueTitle.")
        issue.issueTitle = "Updated issue"
        #expect(issue.title == "Updated issue", "Changing issueTitle should also change title.")
    }

    @Test func issueContentUnwrap() {
        let issue = Issue(context: testDB.managedObjectContext)
        issue.content = "Example issue"
        #expect(issue.issueContent == "Example issue", "Changing content should also change issueContent.")
        issue.issueContent = "Updated issue"
        #expect(issue.content == "Updated issue", "Changing issueContent should also change content.")
    }

    @Test func issueCreationDateUnwrap() {
        let issue = Issue(context: testDB.managedObjectContext)
        let testDate = Date.now
        issue.creationDate = testDate
        #expect(issue.issueCreationDate == testDate, "Changing creationDate also changes issueCreationDate.")
    }

    @Test func issueTagsList() {
        let tag = Tag(context: testDB.managedObjectContext)
        let issue = Issue(context: testDB.managedObjectContext)
        tag.name = "My Tag"
        issue.addToTags(tag)
        #expect(issue.issueTagsList == "My Tag", "Adding one tag to an issue should make issueTagsList be My Tag.")
    }

    @Test func issueSortingIsStable() {
        let issue1 = Issue(context: testDB.managedObjectContext)
        issue1.title = "B Issue"
        issue1.creationDate = .now

        let issue2 = Issue(context: testDB.managedObjectContext)
        issue2.title = "B Issue"
        issue2.creationDate = .now.addingTimeInterval(1)

        let issue3 = Issue(context: testDB.managedObjectContext)
        issue3.title = "A Issue"
        issue3.creationDate = .now.addingTimeInterval(100)

        let allIssues = [issue1, issue2, issue3].sorted()
        #expect(allIssues == [issue3, issue1, issue2], "Sorting issue array should use name then creation date.")
    }

    @Test func tagIDUnwrap() {
        let tag = Tag(context: testDB.managedObjectContext)
        let id = UUID()
        tag.id = id
        #expect(tag.tagID == id, "Changing id also changes tagID")
    }

    @Test func tagNameUnwrap() {
        let tag = Tag(context: testDB.managedObjectContext)
        tag.name = "Example tag"
        #expect(tag.tagName == "Example tag", "Changing name also changes tagName.")
    }

    @Test func tagActiveIssuesWorks() {
        let tag = Tag(context: testDB.managedObjectContext)
        let issue = Issue(context: testDB.managedObjectContext)
        #expect(tag.tagActiveIssues.count == 0, "New tag should have 0 active issues")
        issue.addToTags(tag)
        #expect(tag.tagActiveIssues.count == 1, "Tag with one new issue should have 1 active issue")
        issue.completed = true
        #expect(tag.tagActiveIssues.count == 0, "Tag with one completed issue should have 0 active issues")
    }

    @Test func tagSortingIsStable() {
        let tag1 = Tag(context: testDB.managedObjectContext)
        tag1.id = UUID(uuidString: "00000000-0000-0000-0000-000000000000")
        tag1.name = "Tag B"

        let tag2 = Tag(context: testDB.managedObjectContext)
        tag2.id = UUID(uuidString: "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF")
        tag2.name = "Tag B"

        let tag3 = Tag(context: testDB.managedObjectContext)
        tag3.name = "Tag A"

        let allTags = [tag1, tag2, tag3].sorted()
        #expect(allTags == [tag3, tag1, tag2], "Sorting tag array should use name then id.")
    }

    @Test func bundleDecodingAwardsWorks() {
        let awards = Bundle.main.decode("Awards.json", as: [Award].self)
        #expect(awards.isEmpty == false, "Awards.json should decode to a non-empty array.")
    }

    @Test func bundleDecodingStringWorks() {
        let string = testBundle.decode("DecodableString.json", as: String.self)
        #expect(string == "Never ask a starfish for directions.", "The string much match DecodableString.json")
    }

    @Test func bundleDecodingDictionaryWorks() {
        let dict = testBundle.decode("DecodableDict.json", as: [String: Int].self)
        #expect(dict.keys.count == 3, "Decoded dictionary should have 3 keys.")
        #expect(dict["one"] == 1, "The key 'one' should map to 1 in the decoded dictionary.")
    }
}

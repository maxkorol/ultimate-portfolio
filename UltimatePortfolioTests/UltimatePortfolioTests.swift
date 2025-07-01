//
//  UltimatePortfolioTests.swift
//  UltimatePortfolioTests
//
//  Created by Max Korol on 01/07/2025.
//

import Testing
import CoreData
@testable import UltimatePortfolio

struct UltimatePortfolioTests {
    var dataController: DataController
    var managedObjectContext: NSManagedObjectContext

    init() {
        dataController = DataController(inMemory: true)
        managedObjectContext = dataController.container.viewContext
    }

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
}

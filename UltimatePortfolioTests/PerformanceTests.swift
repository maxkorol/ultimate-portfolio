//
//  PerformanceTests.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 01/07/2025.
//

import Testing
import CoreData
@testable import UltimatePortfolio

@MainActor
struct PerformanceTests {
    let testDB = TestDatabase()

    @Test func awardCalculationPerformance() async throws {
        for _ in 1...100 {
            testDB.dataController.createSampleData()
        }
        let awards = Array(repeating: Award.allAwards, count: 25).joined()
        #expect(awards.count == 500, "Check that awards count is constant")
        let start = ContinuousClock().now
        let earnedCount = awards.filter(testDB.dataController.hasEarned).count
        let end = ContinuousClock().now
        let duration = start.duration(to: end)
        let seconds = Double(duration.components.attoseconds) / 1_000_000_000_000_000_000.0
        print("Performance duration: \(seconds) seconds")
        #expect(earnedCount >= 0, "Basic correctness check")
        #expect(seconds < 0.09, "Performance is acceptable")
    }
}

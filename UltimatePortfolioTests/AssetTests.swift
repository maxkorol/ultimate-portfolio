//
//  AssetTests.swift
//  UltimatePortfolioTests
//
//  Created by Max Korol on 01/07/2025.
//

import Testing
@testable import UltimatePortfolio
import UIKit

struct AssetTests {
    @Test func colorsExist() async throws {
        let allColors = ["Dark Blue", "Dark Gray", "Gold", "Gray", "Green",
                         "Light Blue", "Midnight", "Orange", "Pink", "Purple", "Red", "Teal"]
        for color in allColors {
            #expect(UIColor(named: color) != nil, "Failed to load '\(color)' color from asset catalog.")
        }
    }

    @Test func awardsLoadCorrectly() {
        #expect(Award.allAwards.isEmpty == false, "Unable to load awards JSON from bundle.")
    }
}

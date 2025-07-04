//
//  DataController-Testing.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 04/07/2025.
//

import SwiftUI

extension DataController {
    func checkForTesting() {
        #if DEBUG
        if CommandLine.arguments.contains("enable-testing") {
            self.deleteAll()
            #if os(iOS)
            UIView.setAnimationsEnabled(false)
            #endif
        }
        #endif
    }
}

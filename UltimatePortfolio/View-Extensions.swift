//
//  View-Extensions.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 25/06/2025.
//

import SwiftUI

extension View {
    func inlineNavBarTitle() -> some View {
        #if os(iOS)
        return self.navigationBarTitleDisplayMode(.inline)
        #else
        return self
        #endif
    }
}

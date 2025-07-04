//
//  View-Extensions.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 25/06/2025.
//

import SwiftUI

extension View {
    func inlineNavigationBar() -> some View {
        #if os(macOS)
        return self
        #else
        return self.navigationBarTitleDisplayMode(.inline)
        #endif
    }

    func macFrame(
        minWidth: CGFloat? = nil,
        maxWidth: CGFloat? = nil,
        minHeight: CGFloat? = nil,
        maxHeight: CGFloat? = nil
    ) -> some View {
        #if os(macOS)
        self.frame(minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight, maxHeight: maxHeight)
        #else
        self
        #endif
    }

    func numberBadge(_ number: Int) -> some View {
        #if os(watchOS)
        return self
        #else
        return self.badge(number)
        #endif
    }
}

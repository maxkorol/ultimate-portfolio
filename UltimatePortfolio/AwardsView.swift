//
//  AwardsView.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 25/06/2025.
//

import SwiftUI

struct AwardsView: View {
    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 100, maximum: 100))]
    }
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(Award.allAwards) { award in
                        Button {
                            // no action yet
                        } label: {
                            Image(systemName: award.image)
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.secondary.opacity(0.5))
                        }
                    }
                }
            }
            .navigationTitle("Awards")
            .inlineNavBarTitle()
        }
    }
}

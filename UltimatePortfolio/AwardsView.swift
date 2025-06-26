//
//  AwardsView.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 25/06/2025.
//

import SwiftUI

struct AwardsView: View {
    @Environment(DataController.self) var dataController
    @State private var selectedAward = Award.example
    @State private var showingAwardDetails = false
    
    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 100, maximum: 100))]
    }
    var awardTitle: String {
        return dataController.hasEarned(award: selectedAward) ? "Unlocked: \(selectedAward.name)" : "Locked"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(Award.allAwards) { award in
                        Button {
                            selectedAward = award
                            showingAwardDetails = true
                        } label: {
                            Image(systemName: award.image)
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width: 80, height: 80)
                                .foregroundColor(
                                    dataController.hasEarned(award: award)
                                        ? Color(award.color) : .secondary.opacity(0.5)
                                )
                        }
                    }
                }
            }
            .navigationTitle("Awards")
            .inlineNavBarTitle()
            .alert(awardTitle, isPresented: $showingAwardDetails) {
            } message: {
                Text(selectedAward.description)
            }
        }
    }
}

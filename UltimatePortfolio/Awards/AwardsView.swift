//
//  AwardsView.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 25/06/2025.
//

import SwiftUI

struct AwardsView: View {
    @Environment(DataController.self) var dataController
    #if os(macOS)
    @Environment(\.dismiss) var dismiss
    #endif
    @State private var selectedAward = Award.example
    @State private var showingAwardDetails = false

    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 100, maximum: 100))]
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
                                .foregroundStyle(color(for: award))
                        }
                        .accessibilityLabel(label(for: award))
                        .accessibilityHint(award.description)
                        .buttonStyle(.borderless)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Awards")
            #if os(macOS)
            .toolbar {
                Button("Close") {
                    dismiss()
                }
            }
            #endif
            .inlineNavigationBar()
            .alert(label(for: selectedAward), isPresented: $showingAwardDetails) {
            } message: {
                Text(selectedAward.description)
            }
        }
        .macFrame(minWidth: 600, maxHeight: 500)
    }

    func color(for award: Award) -> Color {
        dataController.hasEarned(award: award) ? Color(award.color) : .secondary.opacity(0.5)
    }

    func label(for award: Award) -> LocalizedStringKey {
        dataController.hasEarned(award: selectedAward) ? "Unlocked: \(selectedAward.name)" : "Locked"
    }
}

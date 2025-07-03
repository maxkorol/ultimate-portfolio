//
//  SidebarViewToolbar.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 30/06/2025.
//

import SwiftUI

struct SidebarViewToolbar: View {
    @Environment(DataController.self) var dataController
    @Binding var showingAwards: Bool
    @State private var showingStore = false

    var body: some View {
        Button(action: tryAddTag) {
            Label("Add Tag", systemImage: "plus")
        }
        .sheet(isPresented: $showingStore, content: StoreView.init)
        .help("Add Tag")
        Button {
            showingAwards.toggle()
        } label: {
            Label("Show Awards", systemImage: "rosette")
        }
        .help("Show Awards")
        #if DEBUG
        Button {
            dataController.deleteAll()
            dataController.createSampleData()
        } label: {
            Label("Add Samples", systemImage: "flame")
        }
        .help("Add Samples")
        #endif
    }

    func tryAddTag() {
        if !dataController.newTag() {
            showingStore = true
        }
    }
}

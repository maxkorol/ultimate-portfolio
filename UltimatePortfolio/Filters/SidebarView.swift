//
//  SidebarView.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 24/06/2025.
//

import SwiftUI

struct SidebarView: View {
    @State private var viewModel: ViewModel

    var body: some View {
        List(selection: $viewModel.dataController.selectedFilter) {
            Section("Smart Filters") {
                ForEach(viewModel.smartFilters) { filter in
                    SmartFilterRow(filter: filter)
                }
            }
            Section("Tags") {
                ForEach(viewModel.tagFilters) { filter in
                    UserFilterRow(filter: filter, delete: viewModel.delete, rename: viewModel.rename)
                }
                .onDelete(perform: viewModel.delete)
                .id(viewModel.dataController.state)
            }
        }
        .toolbar {
            SidebarViewToolbar(showingAwards: $viewModel.showingAwards)
        }
        .alert("Rename Tag", isPresented: $viewModel.renamingTag) {
            Button("OK", action: viewModel.completeRename)
            Button("Cancel") {}
            TextField("New name", text: $viewModel.tagName)
        }
        .sheet(isPresented: $viewModel.showingAwards, content: AwardsView.init)
        .navigationTitle("Filters")
    }

    init(dataController: DataController) {
        _viewModel = State(initialValue: ViewModel(dataController: dataController))
    }
}

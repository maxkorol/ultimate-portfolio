//
//  UltimatePortfolioApp.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 24/06/2025.
//

import SwiftUI
import CoreData
import CoreSpotlight

@main
struct UltimatePortfolioApp: App {
    @State private var dataController = DataController()
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView(dataController: dataController)
            } content: {
                ContentView(dataController: dataController)
            } detail: {
                DetailView()
            }
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environment(dataController)
            .onChange(of: scenePhase) { _, new in
                if new != .active {
                    dataController.save()
                }
            }
            .onContinueUserActivity(CSSearchableItemActionType, perform: loadSpotlightItem)
        }
    }

    func loadSpotlightItem(_ userActivity: NSUserActivity) {
        if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            dataController.selectedIssue = dataController.issue(with: uniqueIdentifier)
            dataController.selectedFilter = .all
        }
    }
}

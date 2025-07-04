//
//  UltimatePortfolioApp.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 24/06/2025.
//

import SwiftUI
import CoreData
#if canImport(CoreSpotlight)
import CoreSpotlight
#endif

@main
struct UltimatePortfolioApp: App {
    @State private var dataController = DataController.shared
    @Environment(\.scenePhase) var scenePhase
    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif

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
            #if canImport(CoreSpotlight)
            .onContinueUserActivity(CSSearchableItemActionType, perform: loadSpotlightItem)
            #endif
        }
    }

    #if canImport(CoreSpotlight)
    func loadSpotlightItem(_ userActivity: NSUserActivity) {
        if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            dataController.selectedIssue = dataController.issue(with: uniqueIdentifier)
            dataController.selectedFilter = .all
        }
    }
    #endif
}

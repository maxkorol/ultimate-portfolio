//
//  UltimatePortfolioApp.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 24/06/2025.
//

import SwiftUI
import CoreData

@main
struct UltimatePortfolioApp: App {
    @State private var dataController = DataController()
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView()
            } content: {
                ContentView()
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
        }
    }
}

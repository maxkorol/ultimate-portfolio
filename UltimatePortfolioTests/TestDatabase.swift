//
//  TestDatabase.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 01/07/2025.
//

import CoreData
@testable import UltimatePortfolio

struct TestDatabase {
    let dataController: DataController
    let managedObjectContext: NSManagedObjectContext

    init() {
        dataController = DataController(inMemory: true)
        managedObjectContext = dataController.container.viewContext
    }
}

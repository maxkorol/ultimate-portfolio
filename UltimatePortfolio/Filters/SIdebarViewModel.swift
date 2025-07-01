//
//  SIdebarViewModel.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 01/07/2025.
//

import Foundation
import Observation
import CoreData

extension SidebarView {
    @Observable
    class ViewModel: NSObject, NSFetchedResultsControllerDelegate {
        private var resultsController: NSFetchedResultsController<Tag>
        private var tags = [Tag]()
        private var tagToRename: Tag?
        var dataController: DataController
        var tagName = ""
        var renamingTag = false
        var showingAwards = false
        var tagFilters: [Filter] {
            tags.map { tag in
                Filter(id: tag.tagID, name: tag.tagName, icon: "tag", tag: tag)
            }
        }
        let smartFilters: [Filter] = [.all, .recent]

        init(dataController: DataController) {
            self.dataController = dataController
            let request = Tag.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
            resultsController = NSFetchedResultsController<Tag>(
                fetchRequest: request,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            super.init()
            resultsController.delegate = self
            do {
                try resultsController.performFetch()
                tags = resultsController.fetchedObjects ?? []
            } catch {
                print("Unable to fetch data: \(error.localizedDescription)")
            }
        }

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
            tags = controller.fetchedObjects as? [Tag] ?? []
        }

        func delete(_ offsets: IndexSet) {
            for offset in offsets {
                let item = tags[offset]
                dataController.delete(item)
            }
        }

        func delete(_ filter: Filter) {
            guard let tag = filter.tag else { return }
            dataController.delete(tag)
        }

        func rename(_ filter: Filter) {
            tagToRename = filter.tag
            tagName = filter.name
            renamingTag = true
        }

        func completeRename() {
            tagToRename?.name = tagName
            dataController.save()
        }
    }
}

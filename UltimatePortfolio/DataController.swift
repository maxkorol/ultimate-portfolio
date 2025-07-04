//
//  DataController.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 24/06/2025.
//

import CoreData
import Observation
import SwiftUI
import StoreKit
import WidgetKit

enum SortType: String {
    case dateCreated = "creationDate"
    case dateModified = "modificationDate"
}

enum Status {
    case all, open, closed
}

@Observable
class DataController {
    static let shared = DataController()
    let container: NSPersistentCloudKitContainer
    var selectedFilter: Filter? = Filter.all
    var selectedIssue: Issue?
    var filterText = ""
    var filterTokens = [Tag]()
    var filterEnabled = false
    var filterPriority = -1
    var filterStatus = Status.all
    var sortType = SortType.dateCreated
    var sortNewestFirst = true
    var state = 0
    var saveTask: Task<Void, Error>?
    var storeTask: Task<Void, Never>?
    var defaults: UserDefaults
    var fullVersionUnlocked: Bool
    #if canImport(CoreSpotlight)
    private var spotlightDelegate: NSCoreDataCoreSpotlightDelegate?
    #endif
    var products = [Product]()

    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()

    var suggestedFilterTokens: [Tag] {
        guard filterText.starts(with: "#") else {
            return []
        }
        let trimmedFilterText = String(filterText.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines)
        let request = Tag.fetchRequest()
        if trimmedFilterText.isEmpty == false {
            request.predicate = NSPredicate(format: "name CONTAINS[c] %@", trimmedFilterText)
        }
        return (try? container.viewContext.fetch(request).sorted()) ?? []
    }

    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd") else {
            fatalError("Failed to locate model file")
        }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load model file")
        }
        return managedObjectModel
    }()

    init(inMemory: Bool = false, defaults: UserDefaults = .standard) {
        self.defaults = defaults
        container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)
        fullVersionUnlocked = defaults.bool(forKey: "fullVersionUnlocked")
        storeTask = Task {
            await monitorTransactions()
        }
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        } else {
            let group = "group.software.colorful.UltimatePortfolio"
            if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group) {
                container.persistentStoreDescriptions.first?.url = url.appending(path: "Main.sqlite")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.persistentStoreDescriptions.first?.setOption(
            true as NSNumber,
            forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey
        )
        container.persistentStoreDescriptions.first?.setOption(
            true as NSNumber,
            forKey: NSPersistentHistoryTrackingKey
        )
        NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator,
            queue: .main,
            using: remoteStateChanged
        )
        container.loadPersistentStores { [weak self] _, error in
            if let error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }

            #if canImport(CoreSpotlight)
            if let description = self?.container.persistentStoreDescriptions.first {
                description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
                if let coordinator = self?.container.persistentStoreCoordinator {
                    self?.spotlightDelegate = NSCoreDataCoreSpotlightDelegate(
                        forStoreWith: description,
                        coordinator: coordinator
                    )
                    self?.spotlightDelegate?.startSpotlightIndexing()
                }
            }
            #endif

            self?.checkForTesting()
        }
    }

    func remoteStateChanged(_ notification: Notification) {
        state += 1
    }

    func createSampleData() {
        let viewContext = container.viewContext

        for tagNumber in 1...5 {
            let tag = Tag(context: viewContext)
            tag.id = UUID()
            tag.name = "Tag \(tagNumber)"
            for issueNumber in 1...10 {
                let issue = Issue(context: viewContext)
                issue.title = "Issue \(tagNumber)-\(issueNumber)"
                issue.content = "Description goes here"
                issue.creationDate = Date.now
                issue.completed = Bool.random()
                issue.priority = Int16.random(in: 0...2)
                tag.addToIssues(issue)
            }
        }
        try? viewContext.save()
    }

    func missingTags(from issue: Issue) -> [Tag] {
        let request = Tag.fetchRequest()
        let allTags = (try? container.viewContext.fetch(request)) ?? []
        let allTagsSet = Set(allTags)
        let difference = allTagsSet.symmetricDifference(issue.issueTags)
        return difference.sorted()
    }

    func queueSave() {
        saveTask?.cancel()
        saveTask = Task { @MainActor in
            try await Task.sleep(for: .seconds(3))
            save()
        }
    }

    func save() {
        saveTask?.cancel()
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    func delete(_ object: NSManagedObject) {
        container.viewContext.delete(object)
        save()
    }

    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult,
           let objectIDs = delete.result as? [NSManagedObjectID] {
            let changes = [NSDeletedObjectsKey: objectIDs]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        }
    }

    func deleteAll() {
        let request1: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
        delete(request1)
        let request2: NSFetchRequest<NSFetchRequestResult> = Issue.fetchRequest()
        delete(request2)
        save()
    }

    func issuesForSelectedFilter() -> [Issue] {
        let filter = selectedFilter ?? .all
        var predicates = [NSPredicate]()
        if let tag = filter.tag {
            predicates.append(NSPredicate(format: "tags CONTAINS %@", tag))
        } else {
            predicates.append(NSPredicate(format: "modificationDate > %@", filter.minModificationDate as NSDate))
        }
        let trimmedFilterText = filterText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedFilterText.isEmpty == false {
            let titlePredicate = NSPredicate(format: "title CONTAINS[c] %@", trimmedFilterText)
            let contentPredicate = NSPredicate(format: "content CONTAINS[c] %@", trimmedFilterText)
            let combinedPredicate = NSCompoundPredicate(
                orPredicateWithSubpredicates: [titlePredicate, contentPredicate]
            )
            predicates.append(combinedPredicate)
        }
        if filterTokens.isEmpty == false {
            let tokenPredicate = NSPredicate(format: "ANY tags IN %@", filterTokens)
            predicates.append(tokenPredicate)
        }
        if filterEnabled {
            if filterPriority >= 0 {
                let priorityPredicate = NSPredicate(format: "priority = %d", filterPriority)
                predicates.append(priorityPredicate)
            }
            if filterStatus != .all {
                let lookForClosed = filterStatus == .closed
                let statusFilter = NSPredicate(format: "completed = %@", NSNumber(value: lookForClosed))
                predicates.append(statusFilter)
            }
        }
        let request = Issue.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: sortType.rawValue, ascending: !sortNewestFirst)]
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        let allIssues = (try? container.viewContext.fetch(request)) ?? []
        return allIssues
    }

    func newTag() -> Bool {
        var shouldCreate = fullVersionUnlocked
        if shouldCreate == false {
            shouldCreate = count(for: Tag.fetchRequest()) < 3
        }
        guard shouldCreate else {
            return false
        }
        let tag = Tag(context: container.viewContext)
        tag.id = UUID()
        tag.name = NSLocalizedString("New Tag", comment: "Create a new tag")
        save()
        return true
    }

    func newIssue(title: String? = nil) {
        let issue = Issue(context: container.viewContext)
        issue.title = title ?? NSLocalizedString("New Issue", comment: "Create a new issue")
        issue.priority = 1
        issue.creationDate = .now
        if let tag = selectedFilter?.tag {
            issue.addToTags(tag)
        }
        selectedIssue = issue
        save()
    }

    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }

    func issue(with uniqueIdentifier: String) -> Issue? {
        guard let url = URL(string: uniqueIdentifier) else {
            return nil
        }
        guard let id = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url) else {
            return nil
        }
        return try? container.viewContext.existingObject(with: id) as? Issue
    }

    func loadProducts() async throws {
        guard products.isEmpty else { return }
        try await Task.sleep(for: .seconds(0.2))
        products = try await Product.products(for: [Self.unlockPremiumProductID])
    }

    func fetchRequestForTopIssues(count: Int) -> NSFetchRequest<Issue> {
        let request = Issue.fetchRequest()
        request.predicate = NSPredicate(format: "completed = false")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Issue.priority, ascending: false)]
        request.fetchLimit = count
        return request
    }

    func results<T: NSManagedObject>(_ request: NSFetchRequest<T>) -> [T] {
        return (try? container.viewContext.fetch(request)) ?? []
    }
}

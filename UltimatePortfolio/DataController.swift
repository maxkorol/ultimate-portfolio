//
//  DataController.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 24/06/2025.
//

import CoreData
import Observation

enum SortType: String {
    case dateCreated = "creationDate"
    case dateModified = "modificationDate"
}

enum Status {
    case all, open, closed
}

@Observable
class DataController {
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
    var task: Task<Void, Error>?
    
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
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Main")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange, object: container.persistentStoreCoordinator, queue: .main, using: remoteStateChanged)
        container.loadPersistentStores { storeDescripton, error in
            if let error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
        }
    }
    
    func remoteStateChanged(_ notification: Notification) {
        state += 1
    }
    
    func createSampleData() {
        let viewContext = container.viewContext
        
        for i in 1...5 {
            let tag = Tag(context: viewContext)
            tag.id = UUID()
            tag.name = "Tag \(i)"
            
            for j in 1...10 {
                let issue = Issue(context: viewContext)
                issue.title = "Issue \(i)-\(j)"
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
        task?.cancel()
        task = Task { @MainActor in
            try await Task.sleep(for: .seconds(3))
            save()
        }
    }
    
    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
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
            let combinedPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, contentPredicate])
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
        return allIssues.sorted()
    }
    
    func newTag() {
        let tag = Tag(context: container.viewContext)
        tag.id = UUID()
        tag.name = "New Tag"
        save()
    }
    
    func newIssue() {
        let issue = Issue(context: container.viewContext)
        issue.title = "New issue"
        issue.priority = 1
        issue.creationDate = .now
        if let tag = selectedFilter?.tag {
            issue.addToTags(tag)
        }
        selectedIssue = issue
        save()
    }
}

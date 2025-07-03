//
//  DataController-Awards.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 03/07/2025.
//

import CoreData

extension DataController {
    func hasEarned(award: Award) -> Bool {
        switch award.criterion {
        case "issues":
            let fetchRequest = Issue.fetchRequest()
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value
        case "closed":
            let fetchRequest = Issue.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "completed = true")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value
        case "tags":
            let fetchRequest = Tag.fetchRequest()
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value
        case "unlock":
            return fullVersionUnlocked
        default:
            return false
        }
    }
}

//
//  DataController-Reminders.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 02/07/2025.
//

import UserNotifications
import CoreData

extension DataController {
    func addReminder(for issue: Issue) async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        do {
            switch settings.authorizationStatus {
            case .notDetermined:
                let success = try await requestNotifications()
                if success {
                    try await placeReminders(for: issue)
                } else {
                    return false
                }
            case .authorized:
                try await placeReminders(for: issue)
            default:
                return false
            }
            return true
        } catch {
            return false
        }
    }

    func removeReminders(for issue: Issue) {
        let center = UNUserNotificationCenter.current()
        let id = issue.objectID.uriRepresentation().absoluteString
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }

    private func requestNotifications() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        return try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    private func placeReminders(for issue: Issue) async throws {
        let content = UNMutableNotificationContent()
        content.title = issue.issueTitle
        if let subtitle = issue.content {
            content.subtitle = subtitle
        }
        content.sound = .default
        let components = Calendar.current.dateComponents([.hour, .minute], from: issue.issueReminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let notification = UNNotificationRequest(
            identifier: issue.objectID.uriRepresentation().absoluteString,
            content: content,
            trigger: trigger
        )
        let center = UNUserNotificationCenter.current()
        try await center.add(notification)
    }
}

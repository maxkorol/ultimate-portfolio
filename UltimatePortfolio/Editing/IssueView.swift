//
//  IssueView.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 25/06/2025.
//

import SwiftUI
import CoreData

struct IssueView: View {
    @ObservedObject var issue: Issue
    @Environment(DataController.self) var dataController
    @Environment(\.openURL) var openURL
    @State private var showNotificationsError = false

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    TextField("Title", text: $issue.issueTitle, prompt: Text("Enter the issue title here"))
                        .font(.title)
                        .labelsHidden()
                    Text("**Modified:** \(issue.issueModificationDate.formatted(date: .long, time: .shortened))")
                        .foregroundStyle(.secondary)
                    Text("**Status:** \(issue.issueStatus)")
                        .foregroundStyle(.secondary)
                }

                Picker("Priority", selection: $issue.priority) {
                    Text("Low").tag(Int16(0))
                    Text("Medium").tag(Int16(1))
                    Text("High").tag(Int16(2))
                }

                TagsMenuView(issue: issue)
            }

            Section {
                VStack(alignment: .leading) {
                    Text("Basic Information")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    TextField(
                        "Description",
                        text: $issue.issueContent,
                        prompt: Text("Enter the issue description here"),
                        axis: .vertical
                    )
                    .labelsHidden()
                }
            }

            Section {
                Toggle("Show reminders", isOn: $issue.reminderEnabled.animation())
                if issue.reminderEnabled {
                    DatePicker(
                        "Reminder Time",
                        selection: $issue.issueReminderTime,
                        displayedComponents: .hourAndMinute
                    )
                }
            }
        }
        .formStyle(.grouped)
        .disabled(issue.isDeleted)
        .onReceive(issue.objectWillChange) {
            dataController.queueSave()
        }
        .onSubmit(dataController.save)
        .toolbar {
            IssueViewToolbar(issue: issue)
        }
        .alert("Oops!", isPresented: $showNotificationsError) {
            Button("Check Settings", action: showAppNotificationSettings)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("There was a problem setting your notification. Please check you have notifications enabled.")
        }
        .onChange(of: issue.reminderEnabled) {
            updateReminder()
        }
        .onChange(of: issue.reminderTime) {
            updateReminder()
        }
    }

    func showAppNotificationSettings() {
        #if os(macOS)
        let notificationsPath = "x-apple.systempreferences:com.apple.Notifications-Settings.extension"
        let bundleId = Bundle.main.bundleIdentifier
        if let url = URL(string: "\(notificationsPath)?id=\(bundleId ?? "")") {
            NSWorkspace.shared.open(url)
        }
        #else
        guard let settingsURL = URL(string: UIApplication.openNotificationSettingsURLString) else {
            return
        }
        openURL(settingsURL)
        #endif
    }

    func updateReminder() {
        dataController.removeReminders(for: issue)
        Task {
            if issue.reminderEnabled {
                let success = await dataController.addReminder(for: issue)
                if !success {
                    issue.reminderEnabled = false
                    showNotificationsError = true
                }
            }
        }
    }
}

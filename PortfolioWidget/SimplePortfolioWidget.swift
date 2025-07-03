//
//  SimplePortfolioWidget.swift
//  PortfolioWidget
//
//  Created by Max Korol on 03/07/2025.
//

import WidgetKit
import SwiftUI

struct SimpleEntry: TimelineEntry {
    let date: Date
    let issues: [Issue]
}

struct SimplePortfolioWidgetEntryView: View {
    var entry: SimpleEntry
    var body: some View {
        VStack {
            if let issue = entry.issues.first {
                Text("Next up...")
                    .font(.title)
                Text(issue.issueTitle)
            } else {
                Text("Nothing")
                    .font(.title)
            }
        }
    }
}

struct SimpleProvider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: .now, issues: [.example])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: .now, issues: loadIssues())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let entry = SimpleEntry(date: .now, issues: loadIssues())
        completion(Timeline(entries: [entry], policy: .never))
    }

    func loadIssues() -> [Issue] {
        let dataController = DataController()
        return dataController.results(
            dataController.fetchRequestForTopIssues(count: 1)
        )
    }
}

struct SimplePortfolioWidget: Widget {
    let kind: String = "SimplePortfolioWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: SimpleProvider()
        ) { entry in
            SimplePortfolioWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall])
        .configurationDisplayName("Up next...")
        .description("You #1 top-priority issue.")
    }
}

#Preview(as: .systemSmall) {
    SimplePortfolioWidget()
} timeline: {
    SimpleEntry(date: .now, issues: [.example])
}

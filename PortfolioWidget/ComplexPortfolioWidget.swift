//
//  ComplexPortfolioWidget.swift
//  PortfolioWidget
//
//  Created by Max Korol on 03/07/2025.
//

import WidgetKit
import SwiftUI
import CoreData

struct ComplexEntry: TimelineEntry {
    let date: Date
    let issues: [Issue]
}

struct ComplexPortfolioWidgetEntryView: View {
    var entry: ComplexEntry
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    var issues: ArraySlice<Issue> {
        let issueCount: Int
        switch widgetFamily {
        case .systemSmall:
            issueCount = 1
        case .systemLarge, .systemExtraLarge:
            if dynamicTypeSize < .xxLarge {
                issueCount = 6
            } else {
                issueCount = 5
            }
        default:
            if dynamicTypeSize < .xLarge {
                issueCount = 3
            } else {
                issueCount = 2
            }
        }
        return entry.issues.prefix(issueCount)
    }

    var body: some View {
        VStack(spacing: 10) {
            ForEach(issues) { issue in
                Link(destination: issue.objectID.uriRepresentation()) {
                    VStack(alignment: .leading) {
                        Text(issue.issueTitle)
                            .font(.headline)
                            .layoutPriority(1)
                        if issue.issueTags.isEmpty == false {
                            Text(issue.issueTagsList)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

struct ComplexProvider: TimelineProvider {
    func placeholder(in context: Context) -> ComplexEntry {
        ComplexEntry(date: .now, issues: [.example])
    }

    func getSnapshot(in context: Context, completion: @escaping (ComplexEntry) -> Void) {
        let entry = ComplexEntry(date: .now, issues: loadIssues())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ComplexEntry>) -> Void) {
        let entry = ComplexEntry(date: .now, issues: loadIssues())
        completion(Timeline(entries: [entry], policy: .never))
    }

    func loadIssues() -> [Issue] {
        let dataController = DataController()
        return dataController.results(
            dataController.fetchRequestForTopIssues(count: 7)
        )
    }
}

struct ComplexPortfolioWidget: Widget {
    let kind: String = "ComplexPortfolioWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: ComplexProvider()
        ) { entry in
            ComplexPortfolioWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
        .configurationDisplayName("Up next...")
        .description("Your most important issues.")
    }
}

#Preview(as: .systemSmall) {
    ComplexPortfolioWidget()
} timeline: {
    ComplexEntry(date: .now, issues: [.example])
}

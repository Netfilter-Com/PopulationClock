import SwiftUI
import WidgetKit

// The world population, extrapolated from the figure in data.plist the same
// way the app does it: the year's figure plus the growth rate since 31 Dec of
// that year. The widget has no network access and no shared state with the app.
private enum WorldPopulation {
    static let secondsPerYear = 60.0 * 60 * 24 * 365

    static let figures: (population: Double, growthRate: Double, since: Date) = {
        let fallback = (population: 8_215_424_893.0, growthRate: 0.9113, since: DateComponents(
            calendar: .current, year: 2025, month: 12, day: 31).date ?? Date())
        guard let url = Bundle.main.url(forResource: "data", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              let world = plist["world"] as? [String: Any],
              let population = (world["population"] as? NSNumber)?.doubleValue,
              let growthRate = (world["growthRate"] as? NSNumber)?.doubleValue,
              let year = (world["populationYear"] as? NSNumber)?.intValue,
              let since = DateComponents(calendar: .current, year: year, month: 12, day: 31).date
        else { return fallback }
        return (population, growthRate, since)
    }()

    static func estimate(at date: Date) -> Int64 {
        let f = figures
        let perSecond = f.growthRate / 100 * f.population / secondsPerYear
        return Int64(f.population + date.timeIntervalSince(f.since) * perSecond)
    }

    static func perSecond() -> Double {
        figures.growthRate / 100 * figures.population / secondsPerYear
    }
}

struct PopulationEntry: TimelineEntry {
    let date: Date
    let population: Int64
}

struct PopulationProvider: TimelineProvider {
    func placeholder(in context: Context) -> PopulationEntry {
        PopulationEntry(date: Date(), population: WorldPopulation.estimate(at: Date()))
    }

    func getSnapshot(in context: Context, completion: @escaping (PopulationEntry) -> Void) {
        completion(placeholder(in: context))
    }

    // A pre-computed entry every 10 seconds for an hour; the system shows them
    // as their time comes, so the number moves without spending refreshes.
    func getTimeline(in context: Context, completion: @escaping (Timeline<PopulationEntry>) -> Void) {
        let start = Date()
        let entries = (0..<360).map { i -> PopulationEntry in
            let date = start.addingTimeInterval(Double(i) * 10)
            return PopulationEntry(date: date, population: WorldPopulation.estimate(at: date))
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

private func formatted(_ value: Int64) -> String {
    value.formatted(.number.grouping(.automatic))
}

struct PopulationWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: PopulationEntry

    var body: some View {
        switch family {
        case .accessoryInline:
            Text("\(Image(systemName: "globe")) \(formatted(entry.population))")
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Text("World population")
                    .font(.caption2)
                    .widgetAccentable()
                Text(formatted(entry.population))
                    .font(.system(.headline, design: .rounded).monospacedDigit())
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
        default:
            VStack(alignment: .leading, spacing: 6) {
                Label("World population", systemImage: "globe")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color(red: 0.98, green: 0.77, blue: 0.16))
                Spacer(minLength: 0)
                Text(formatted(entry.population))
                    .font(.system(size: 34, weight: .bold, design: .rounded).monospacedDigit())
                    .minimumScaleFactor(0.4)
                    .lineLimit(1)
                    .foregroundStyle(.white)
                Text("+\(String(format: "%.1f", WorldPopulation.perSecond())) / s")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
}

struct PopulationWidget: Widget {
    let kind = "WorldPopulationWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PopulationProvider()) { entry in
            if #available(iOS 17.0, *) {
                PopulationWidgetView(entry: entry)
                    .containerBackground(Color(white: 0.08), for: .widget)
            } else {
                PopulationWidgetView(entry: entry)
                    .padding()
                    .background(Color(white: 0.08))
            }
        }
        .configurationDisplayName("World population")
        .description("The estimated world population, counting in real time.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryInline])
    }
}

@main
struct PopulationWidgetBundle: WidgetBundle {
    var body: some Widget {
        PopulationWidget()
    }
}

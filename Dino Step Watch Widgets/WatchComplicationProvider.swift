//
//  WatchComplicationProvider.swift
//  Dino Step Watch Widgets
//

import WidgetKit

struct WatchComplicationProvider: TimelineProvider {
    func placeholder(in context: Context) -> WatchComplicationEntry {
        .preview
    }

    func getSnapshot(in context: Context, completion: @escaping (WatchComplicationEntry) -> Void) {
        completion(.current)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WatchComplicationEntry>) -> Void) {
        let entry = WatchComplicationEntry.current
        let refresh = Date().addingTimeInterval(60)
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }
}

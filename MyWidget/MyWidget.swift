//
//  MyWidget.swift
//  MyWidget
//
//  Created by masaki on 2023/01/03.
//

import WidgetKit
import SwiftUI

// MODEL VAR
struct Model: TimelineEntry {
    var date: Date  // this line is mandatory, we must put it even the widget don't need it.
    var message: String
}


// PROVIDER
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> Model {
        return Model(date: Date(), message: "")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (Model) -> Void) {
        completion(Model(date: Date(), message: ""))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Model>) -> Void) {
        let entry = Model(date: Date(), message: "Hello Widget")
        completion(Timeline(entries: [entry], policy: .atEnd))
    }
    
    typealias Entry = Model
    
    
}


// DESIGN - VIEW
struct vista: View {
    let entry : Provider.Entry
    
    var body: some View {
        Text(entry.message)
    }
}



// CONFIGURATION
@main // (it will be executed first)
struct HelloWidget : Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "widget", provider: Provider()) { entry in
            vista(entry: entry)
            
        }.description("descripcion del widget")
            .configurationDisplayName("nombre widget")
            .supportedFamilies([.systemLarge, .systemMedium, .systemSmall])
    }
}


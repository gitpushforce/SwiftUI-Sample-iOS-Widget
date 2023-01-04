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
    var widgetData : [JsonData]
}

struct JsonData: Decodable {
    var id : Int
    var name : String
    var email : String
}


// PROVIDER
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> Model {
        return Model(date: Date(), widgetData: Array(repeating: JsonData(id: 0, name: "", email: ""), count: 0))
    }
    
    func getSnapshot(in context: Context, completion: @escaping (Model) -> Void) {
        completion(Model(date: Date(), widgetData: Array(repeating: JsonData(id: 0, name: "", email: ""), count: 0)))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Model>) -> Void) {
//        let entry = Model(date: Date(), message: "Hello Widget")
//        completion(Timeline(entries: [entry], policy: .atEnd))
        getJson { modelData in
            let data = Model(date: Date(), widgetData: modelData)
            
            //widget will update every 30 mins
            guard let update = Calendar.current.date(byAdding: .minute, value: 30,to: Date()) else { return }
            let timeline = Timeline(entries: [data], policy: .after(update))
            completion(timeline)
        }
    }
    
    typealias Entry = Model
}

// get jSON from API
func getJson(completion: @escaping ([JsonData]) -> ()) {
    guard let url = URL(string: "https://jsonplaceholder.typicode.com/comments?postId=1") else { return }
    URLSession.shared.dataTask(with: url) { data,_,_ in
        guard let data = data else { return }
        
        do {
            let json = try JSONDecoder().decode([JsonData].self, from: data)
            DispatchQueue.main.async {
                completion(json)
            }
        } catch let error as NSError {
            print("failed", error.localizedDescription)
        }
        
    }.resume()
}


// DESIGN - VIEW
struct vista: View {
    let entry : Provider.Entry
    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            VStack(alignment: .center) {
                Text("My List")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .bold()
                    .frame(maxWidth: .infinity) // to expand the background from left to right side
                    .background(Color.blue)
                Spacer()
                Text(String(entry.widgetData.count))
                    .font(.custom("Arial", size: 80))
                    .bold()
                Spacer()
            }
        case .systemMedium:
            VStack(alignment: .center) {
                Text("My List")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .bold()
                    .frame(maxWidth: .infinity) // to expand the background from left to right side
                    .background(Color.blue)
                Spacer()
                VStack(alignment: .leading) {
                    if (entry.widgetData.isEmpty) {
                        ProgressView()
                    } else {
                        Text(entry.widgetData[0].name).bold()
                        Text(entry.widgetData[0].email)
                        Text(entry.widgetData[1].name).bold()
                        Text(entry.widgetData[1].email)
                    }
                }.padding(.leading)
                Spacer()
            }
        default:
            // Large
            VStack(alignment: .center) {
                Text("My List")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .bold()
                    .frame(maxWidth: .infinity) // to expand the background from left to right side
                    .background(Color.blue)
                Spacer()
                VStack(alignment: .leading) {
                    ForEach(entry.widgetData, id:\.id) { item in
                        Text(item.name).bold()
                        Text(item.email)
                    }
                }.padding(.leading)
                Spacer()
            }
        }
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
            .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}


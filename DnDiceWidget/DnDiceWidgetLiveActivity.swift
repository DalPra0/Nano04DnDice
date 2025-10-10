//
//  DnDiceWidgetLiveActivity.swift
//  DnDiceWidget
//
//  Created by Lucas Dal Pra Brascher on 10/10/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct DnDiceWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct DnDiceWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DnDiceWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension DnDiceWidgetAttributes {
    fileprivate static var preview: DnDiceWidgetAttributes {
        DnDiceWidgetAttributes(name: "World")
    }
}

extension DnDiceWidgetAttributes.ContentState {
    fileprivate static var smiley: DnDiceWidgetAttributes.ContentState {
        DnDiceWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: DnDiceWidgetAttributes.ContentState {
         DnDiceWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: DnDiceWidgetAttributes.preview) {
   DnDiceWidgetLiveActivity()
} contentStates: {
    DnDiceWidgetAttributes.ContentState.smiley
    DnDiceWidgetAttributes.ContentState.starEyes
}

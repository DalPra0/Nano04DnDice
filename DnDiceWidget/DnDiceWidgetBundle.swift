//
//  DnDiceWidgetBundle.swift
//  DnDiceWidget
//
//  Created by Lucas Dal Pra Brascher on 10/10/25.
//

import WidgetKit
import SwiftUI

@main
struct DnDiceWidgetBundle: WidgetBundle {
    var body: some Widget {
        DnDiceWidget()
        DnDiceWidgetLiveActivity()
    }
}

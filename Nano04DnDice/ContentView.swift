//
//  ContentView.swift
//  Nano04DnDice
//
//  Created by Lucas Dal Pra Brascher on 08/10/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        DiceRollerView()
            .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

#Preview {
    ContentView()
}


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

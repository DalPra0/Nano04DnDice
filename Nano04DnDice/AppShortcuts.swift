import AppIntents

struct DnDiceAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: QuickRollD20Intent(),
            phrases: [
                "Roll a D20 in \(.applicationName)",
                "Quick roll in \(.applicationName)"
            ],
            shortTitle: "Roll D20",
            systemImageName: "dice"
        )
        
        AppShortcut(
            intent: RollDiceIntent(diceType: .d20),
            phrases: [
                "Roll \(\.$diceType) in \(.applicationName)"
            ],
            shortTitle: "Roll Dice",
            systemImageName: "dice.fill"
        )
        
        AppShortcut(
            intent: RollDiceIntent(diceType: .d10),
            phrases: [
                "Roll a D10 in \(.applicationName)"
            ],
            shortTitle: "Roll D10",
            systemImageName: "dice"
        )
        
        AppShortcut(
            intent: RollDiceIntent(diceType: .d6),
            phrases: [
                "Roll a D6 in \(.applicationName)"
            ],
            shortTitle: "Roll D6",
            systemImageName: "dice"
        )
    }
}

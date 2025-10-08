# 🏗️ Arquitetura MVVM - Nano04DnDice

## 📂 Estrutura de Pastas

```
Nano04DnDice/
├── App/
│   ├── Nano04DnDiceApp.swift
│   └── ContentView.swift
│
├── Views/
│   ├── DiceRollerView.swift (View Principal)
│   ├── ThemesListView.swift
│   ├── ThemeCustomizerView.swift
│   └── Components/
│       ├── DiceHeaderView.swift
│       ├── DiceSelectorView.swift
│       ├── RollModeSelectorView.swift
│       ├── DiceDisplayView.swift
│       ├── DiceResultView.swift
│       ├── RollButtonView.swift
│       ├── TopButtonsView.swift
│       ├── ThreeJSWebView.swift
│       └── CustomDiceSheet.swift
│
├── ViewModels/
│   └── DiceRollerViewModel.swift
│
├── Models/
│   ├── DiceType.swift
│   ├── RollMode.swift
│   ├── DiceCustomization.swift
│   └── PresetThemes.swift
│
├── Managers/
│   ├── AudioManager.swift
│   └── ThemeManager.swift
│
└── Resources/
    └── Audio/
```

---

## 🎯 Padrão MVVM

### **Model**
Contém os dados e lógica de negócio:
- `DiceType.swift` - Enum com tipos de dados (D4-D20, Custom)
- `RollMode.swift` - Enum com modos de rolagem
- `DiceCustomization.swift` - Modelo de customização visual
- `PresetThemes.swift` - Temas pré-definidos

### **View**
Interface do usuário (SwiftUI):
- `DiceRollerView.swift` - View principal que orquestra tudo
- `Components/` - Componentes reutilizáveis e isolados

### **ViewModel**
Gerencia estado e lógica de apresentação:
- `DiceRollerViewModel.swift` - Estado do dado, rolagens, animações

---

## 🔄 Fluxo de Dados

```
User Action → View → ViewModel → Model
                ↑                   ↓
                └─── @Published ────┘
```

**Exemplo: Rolar Dado**
1. User toca "ROLAR D20" → `RollButtonView`
2. View chama → `viewModel.rollDice()`
3. ViewModel atualiza → `@Published var result`
4. View reage → Mostra `DiceResultView`

---

## 📦 Componentes

### **DiceHeaderView**
- Exibe "TESTE DE D20"
- Divisórias ornamentais
- **Props**: `diceName`, `accentColor`

### **DiceSelectorView**
- Grid 3x2 de botões (D4-D20)
- Botão de dado customizado
- **Props**: `selectedDiceType`, `accentColor`, `onSelectDice`, `onShowCustomDice`

### **RollModeSelectorView**
- 3 botões verticais (Normal/Abençoado/Amaldiçoado)
- **Props**: `selectedMode`, `accentColor`, `onSelectMode`

### **DiceDisplayView**
- Container do dado 3D
- Bordas, sombras, glow
- **Props**: `diceSize`, `currentNumber`, `isRolling`, etc.

### **DiceResultView**
- Mostra resultado da rolagem
- Detecta críticos/falhas
- **Props**: `result`, `secondResult`, `rollMode`, etc.

### **RollButtonView**
- Botão "ROLAR D20"
- Indicador de modo (abençoado/amaldiçoado)
- **Props**: `diceType`, `rollMode`, `isRolling`, etc.

---

## 🎨 Separação de Responsabilidades

### **View (DiceRollerView)**
✅ **FAZ:**
- Renderiza UI
- Passa dados para componentes
- Observa mudanças do ViewModel (`@StateObject`)

❌ **NÃO FAZ:**
- Lógica de negócio
- Manipulação de estado complexo
- Cálculos

### **ViewModel (DiceRollerViewModel)**
✅ **FAZ:**
- Gerencia estado (`@Published`)
- Lógica de rolagem
- Coordena AudioManager
- Animações

❌ **NÃO FAZ:**
- Renderização
- SwiftUI Views
- Acesso direto a UI

### **Components**
✅ **FAZ:**
- UI específica e isolada
- Recebe dados via props
- Emite ações via closures

❌ **NÃO FAZ:**
- Gerencia estado global
- Conhece outras views
- Lógica de negócio

---

## 🔧 Vantagens dessa Arquitetura

1. **Testabilidade** - ViewModel pode ser testado sem UI
2. **Reusabilidade** - Componentes podem ser reusados
3. **Manutenibilidade** - Código organizado e fácil de encontrar
4. **Escalabilidade** - Fácil adicionar novas features
5. **Separação Clara** - Cada arquivo tem uma responsabilidade

---

## 📝 Como Adicionar Nova Feature

### Exemplo: Adicionar "Histórico de Rolagens"

1. **Model** - Criar `RollHistory.swift`
```swift
struct RollHistory {
    let diceType: DiceType
    let result: Int
    let timestamp: Date
}
```

2. **ViewModel** - Adicionar ao `DiceRollerViewModel.swift`
```swift
@Published var rollHistory: [RollHistory] = []

func saveRoll(_ result: Int) {
    rollHistory.append(RollHistory(
        diceType: selectedDiceType,
        result: result,
        timestamp: Date()
    ))
}
```

3. **View** - Criar `RollHistoryView.swift`
```swift
struct RollHistoryView: View {
    let history: [RollHistory]
    // ...
}
```

4. **Integrar** - Adicionar em `DiceRollerView.swift`
```swift
.sheet(isPresented: $showHistory) {
    RollHistoryView(history: viewModel.rollHistory)
}
```

---

## 🎯 Boas Práticas

1. **Componentes pequenos** - Cada componente tem uma única responsabilidade
2. **Props explícitas** - Sempre declare o que o componente precisa
3. **Closures para ações** - `onSelectDice`, `onRoll`, etc.
4. **@Published para estado** - ViewModel expõe estado via @Published
5. **Sem lógica na View** - Views apenas renderizam e observam
6. **Computed properties** - Para valores derivados (`isCritical`, `isSuccess`)

---

## 🚀 Próximos Passos

- [ ] Adicionar testes unitários para ViewModel
- [ ] Separar ThemeManager em seu próprio ViewModel
- [ ] Criar Repository pattern para Core Data
- [ ] Adicionar Coordinator para navegação

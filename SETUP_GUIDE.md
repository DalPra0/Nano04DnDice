# 🚀 GUIA RÁPIDO - ADICIONAR ARQUIVOS NO XCODE

## ✅ ARQUIVOS CRIADOS (MVVM):

### 📂 **ViewModels/**
- `DiceRollerViewModel.swift`

### 📂 **Views/Components/**
- `DiceHeaderView.swift`
- `DiceSelectorView.swift`
- `RollModeSelectorView.swift`
- `DiceDisplayView.swift`
- `DiceResultView.swift`
- `RollButtonView.swift`
- `TopButtonsView.swift`
- `CustomDiceSheet.swift`

### 📂 **Models/**
- `DiceType.swift`
- `RollMode.swift`

### 📂 **Extensions/**
- `Color+Hex.swift` (pode deletar - duplicado)

---

## 📋 PASSOS NO XCODE:

### 1️⃣ **Criar Grupos (Pastas)**
No Xcode:
- Clique com botão direito no projeto
- New Group
- Crie:
  - `ViewModels`
  - `Views/Components`
  - `Models`
  - `Extensions`

### 2️⃣ **Adicionar Arquivos**
Para cada arquivo `.swift` criado:
1. Arraste para a pasta correta no Xcode
2. OU: File > Add Files to "Nano04DnDice"
3. Selecione o arquivo
4. ✅ Marque "Copy items if needed"
5. ✅ Marque "Add to targets: Nano04DnDice"

### 3️⃣ **Deletar Arquivo Duplicado**
- Delete `Extensions/Color+Hex.swift` (já existe em DiceCustomization.swift)

### 4️⃣ **Atualizar DiceRollerView**
- Substitua o arquivo antigo pelo novo (já está correto)

### 5️⃣ **Build & Run**
- Cmd + B para compilar
- Se der erro, verifique se todos os arquivos estão no target

---

## 🔧 SE DER ERRO DE TARGET MEMBERSHIP:

1. Selecione o arquivo com erro
2. Abra o Inspector (lado direito)
3. Em "Target Membership"
4. ✅ Marque o checkbox "Nano04DnDice"

---

## ✅ RESULTADO ESPERADO:

- ✅ Compila sem erros
- ✅ App funciona EXATAMENTE igual
- ✅ Código organizado em MVVM
- ✅ Componentes reutilizáveis

---

## 📦 ESTRUTURA FINAL:

```
Nano04DnDice/
├── App/
├── Views/
│   ├── DiceRollerView.swift ⭐
│   ├── ThemesListView.swift
│   ├── ThemeCustomizerView.swift
│   └── Components/
│       ├── DiceHeaderView.swift ⭐ NOVO
│       ├── DiceSelectorView.swift ⭐ NOVO
│       ├── RollModeSelectorView.swift ⭐ NOVO
│       ├── DiceDisplayView.swift ⭐ NOVO
│       ├── DiceResultView.swift ⭐ NOVO
│       ├── RollButtonView.swift ⭐ NOVO
│       ├── TopButtonsView.swift ⭐ NOVO
│       ├── CustomDiceSheet.swift ⭐ NOVO
│       └── ThreeJSWebView.swift
├── ViewModels/
│   └── DiceRollerViewModel.swift ⭐ NOVO
├── Models/
│   ├── DiceType.swift ⭐ NOVO
│   ├── RollMode.swift ⭐ NOVO
│   ├── DiceCustomization.swift
│   └── PresetThemes.swift (atualizado)
├── Managers/
│   ├── AudioManager.swift
│   └── ThemeManager.swift
└── Resources/
```

---

## 🎯 COMPILE AGORA:

```bash
# No terminal, vá para a pasta do projeto:
cd /Users/lucasdalprabrascher/Developer/Nano/Nano04DnDice

# Abra o Xcode:
open Nano04DnDice.xcodeproj
```

Depois:
1. Adicione TODOS os arquivos novos
2. Cmd + B (Build)
3. Cmd + R (Run)
4. ✅ Deve funcionar perfeitamente!

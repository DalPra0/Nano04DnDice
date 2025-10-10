# 💾 Sistema de Persistência de Temas

## ✅ **SIM, OS TEMAS SÃO SALVOS!**

O app possui um sistema completo de persistência usando **UserDefaults**.

## 📊 Como Funciona

### **ThemeManager.swift**

```swift
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: DiceCustomization
    @Published var savedThemes: [DiceCustomization] = []
    
    private let userDefaultsKey = "savedThemes"        // ← Chave para temas salvos
    private let currentThemeKey = "currentTheme"       // ← Chave para tema atual
}
```

### **1. Carregar ao Abrir o App** ✅

```swift
init() {
    // Carregar tema atual
    if let data = UserDefaults.standard.data(forKey: currentThemeKey),
       let theme = try? JSONDecoder().decode(DiceCustomization.self, from: data) {
        self.currentTheme = theme  // ✅ RESTAURA TEMA ATUAL
    } else {
        self.currentTheme = PresetThemes.classic
    }
    
    // Carregar temas salvos
    loadSavedThemes()  // ✅ RESTAURA TODOS OS TEMAS CUSTOMIZADOS
}
```

### **2. Salvar Tema Customizado** ✅

```swift
func saveCustomTheme(_ theme: DiceCustomization) {
    if let index = savedThemes.firstIndex(where: { $0.id == theme.id }) {
        savedThemes[index] = theme  // Atualiza existente
    } else {
        savedThemes.append(theme)   // Adiciona novo
    }
    saveToDisk()  // ✅ PERSISTE NO DISCO
}

private func saveToDisk() {
    if let encoded = try? JSONEncoder().encode(savedThemes) {
        UserDefaults.standard.set(encoded, forKey: userDefaultsKey)  // ✅ SALVA
    }
}
```

### **3. Salvar Tema Atual** ✅

```swift
func applyTheme(_ theme: DiceCustomization) {
    currentTheme = theme
    saveCurrentTheme()  // ✅ SALVA AUTOMATICAMENTE
}

private func saveCurrentTheme() {
    if let encoded = try? JSONEncoder().encode(currentTheme) {
        UserDefaults.standard.set(encoded, forKey: currentThemeKey)  // ✅ SALVA
    }
}
```

### **4. Deletar Tema** ✅

```swift
func deleteTheme(_ theme: DiceCustomization) {
    savedThemes.removeAll { $0.id == theme.id }
    saveToDisk()  // ✅ ATUALIZA DISCO
}
```

## 🧪 Como Testar

### **Teste 1: Criar e Salvar Tema**
1. Abra o app
2. Menu → "Create your Theme"
3. Customize as cores
4. Digite um nome (ex: "Meu Tema Azul")
5. Toque em **"SAVE"**
6. ✅ Tema aparece em "MY THEMES"

### **Teste 2: Fechar e Reabrir**
1. **Force quit** do app (arraste para cima)
2. Reabra o app
3. Menu → Lista de temas
4. ✅ "Meu Tema Azul" **ainda está lá**!

### **Teste 3: Tema Atual Persiste**
1. Selecione "Light Mode" (ou qualquer tema)
2. **Force quit** do app
3. Reabra o app
4. ✅ App abre com **"Light Mode"** ativo!

### **Teste 4: Deletar Tema**
1. Menu → Lista de temas
2. Em "MY THEMES", toque no ícone de lixeira
3. Confirme "Delete"
4. **Force quit** e reabra
5. ✅ Tema deletado **não reaparece**!

## 📁 O Que é Persistido

| Dado | Chave UserDefaults | Conteúdo |
|------|-------------------|----------|
| **Tema Atual** | `"currentTheme"` | Tema que está ativo agora |
| **Temas Salvos** | `"savedThemes"` | Array de todos os temas customizados |

## 🔧 Tecnologia Usada

- **UserDefaults** - Armazenamento key-value nativo do iOS
- **Codable** - DiceCustomization implementa Codable para serialização
- **JSONEncoder/JSONDecoder** - Converte objetos para JSON e vice-versa

## ✨ Recursos

### **Funciona:**
- ✅ Criar tema customizado → **SAVE** → Persiste
- ✅ Aplicar tema → **APPLY** → Tema atual salvo
- ✅ Fechar app → Reabrir → Temas restaurados
- ✅ Deletar tema → Remoção permanente
- ✅ Presets sempre disponíveis (nunca deletados)

### **Proteções:**
- ✅ Presets não podem ser deletados (só customizados)
- ✅ Se não houver temas salvos, carrega presets automaticamente
- ✅ Se arquivo corrompido, usa tema clássico como fallback

## 📝 Exemplo de Uso

```swift
// 1. Usuário cria tema
let meuTema = DiceCustomization(
    name: "Tema Roxo",
    backgroundColor: .purple,
    // ...
)

// 2. Salvar
themeManager.saveCustomTheme(meuTema)  
// ✅ Vai para UserDefaults["savedThemes"]

// 3. Aplicar
themeManager.applyTheme(meuTema)       
// ✅ Vai para UserDefaults["currentTheme"]

// 4. Fechar app...
// 5. Reabrir app
// ✅ ThemeManager.init() carrega tudo de volta!
```

## 🎯 Resumo

**SIM**, todos os temas criados são **permanentemente salvos**! 

- Fechar o app → ✅ Temas preservados
- Reiniciar iPhone → ✅ Temas preservados
- Atualizar app → ✅ Temas preservados*

*Exceto se desinstalar completamente o app (aí o UserDefaults é apagado)

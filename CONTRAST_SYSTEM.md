# 🎨 Sistema de Contraste Automático

## 📋 Problema Resolvido

Quando o usuário escolhia um fundo claro (branco/cinza claro), os textos brancos ficavam **invisíveis**, causando péssima experiência de uso.

## ✅ Solução Implementada

### 1. **Color+Contrast.swift** - Extension para Cálculo de Luminância

Criada uma extensão que:
- Calcula a **luminância relativa** da cor usando a fórmula ITU-R BT.709
- Determina se a cor é clara ou escura (threshold: 0.5)
- Retorna automaticamente a cor de texto ideal para contraste

```swift
extension Color {
    var luminance: Double { ... }  // 0.0 = escuro, 1.0 = claro
    var isLight: Bool { ... }      // true se luminância > 0.5
    var contrastText: Color { ... } // Retorna .black ou .white
}
```

### 2. **Propriedades Auxiliares**

- `contrastText` → Retorna `.black` para fundos claros, `.white` para fundos escuros
- `contrastTextSecondary` → Versão com 70% de opacidade
- `contrastTextTertiary` → Versão com 50% de opacidade (texto suave)

## 🔧 Componentes Atualizados

### **DiceHeaderView**
- Agora recebe `backgroundColor` como parâmetro
- Texto "ROLLING" usa `backgroundColor.contrastTextSecondary`

**Antes:**
```swift
.foregroundColor(.white.opacity(0.7))  // ❌ Sumia em fundos claros
```

**Depois:**
```swift
.foregroundColor(backgroundColor.contrastTextSecondary)  // ✅ Adapta automaticamente
```

### **DiceResultView**
- Recebe `backgroundColor` como parâmetro
- Números de resultado blessed/cursed usam contraste
- Aritmética do bonus usa contraste

**Textos adaptados:**
- `[second]` → `backgroundColor.contrastTextTertiary`
- `+bonus` → `backgroundColor.contrastTextSecondary`
- `=` → `backgroundColor.contrastTextTertiary`

### **RollModeSelectorView**
- Recebe `backgroundColor` como parâmetro
- Texto "ROLL MODE" usa `backgroundColor.contrastText`

## 🎨 Novo Tema: Light Mode

Adicionado tema **"Light Mode"** aos presets para demonstrar o sistema:

```swift
static let light = DiceCustomization(
    name: "Light Mode",
    diceFaceColor: .white,
    diceBorderColor: Color(hex: "#2C3E50"),
    diceNumberColor: .black,
    backgroundColor: Color(hex: "#F5F5F5"),  // ← Fundo claro!
    accentColor: Color(hex: "#3498DB"),
    // ...
)
```

## 🧪 Como Testar

1. Abra o app
2. Toque no menu hambúrguer
3. Selecione "Light Mode"
4. **Observe:** Todos os textos agora são **pretos** e visíveis!
5. Teste com customização:
   - Vá em "Create your Theme"
   - Mude o "Background Color" para **branco**
   - Veja os textos adaptarem automaticamente

## 📊 Resultado

| Fundo | Antes | Depois |
|-------|-------|--------|
| Escuro (preto) | ✅ Textos brancos visíveis | ✅ Textos brancos visíveis |
| Claro (branco) | ❌ Textos brancos invisíveis | ✅ Textos pretos visíveis |
| Médio (cinza) | ⚠️ Baixo contraste | ✅ Adapta automaticamente |

## 🔍 Algoritmo de Luminância

Baseado na fórmula **ITU-R BT.709** (padrão internacional para HDTV):

```
L = 0.2126 × R + 0.7152 × G + 0.0722 × B
```

- **L > 0.5** → Cor clara → Usa texto preto
- **L ≤ 0.5** → Cor escura → Usa texto branco

## ✨ Benefícios

1. **Acessibilidade** - Contraste mínimo sempre garantido
2. **Flexibilidade** - Funciona com qualquer cor de fundo
3. **Automático** - Usuário não precisa se preocupar
4. **Consistente** - Mesmo padrão em todo o app

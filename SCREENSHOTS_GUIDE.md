# 📸 GUIA DE SCREENSHOTS - ONDE COLOCAR CADA IMAGEM

## 📂 Estrutura de Pastas

```
Nano04DnDice/
└── Screenshots/
    ├── hero.png              ⭐ PRINCIPAL - Banner do topo
    ├── portrait.png          📱 Modo vertical
    ├── landscape.png         📱 Modo horizontal
    ├── themes.png            🎨 Lista de temas
    ├── customization.png     🎨 Tela de customização
    ├── ar-mode.png           🌟 Modo AR
    ├── multiple-dice.png     🎲 Vários dados
    ├── roll-modes.png        🎲 Blessed/Cursed
    └── dice-roll.gif         🎬 Animação (OPCIONAL)
```

---

## 🎯 ONDE COLOCAR NO README

### 1️⃣ **HERO IMAGE** (Linha ~8)
```markdown
<img src="./Screenshots/hero.png" alt="DnDice Hero" width="100%">
```
**Aparece**: Banner principal no topo
**Tamanho**: Largura total (100%)

---

### 2️⃣ **DICE ROLL GIF** (Linha ~35 - OPCIONAL)
```markdown
<img src="./Screenshots/dice-roll.gif" alt="Dice Rolling Demo" width="600">
```
**Aparece**: Logo após "About"
**Tamanho**: 600px de largura

---

### 3️⃣ **PORTRAIT MODE** (Linha ~70)
```markdown
<img src="./Screenshots/portrait.png" alt="Portrait Mode" width="300">
```
**Aparece**: Seção Screenshots
**Tamanho**: 300px de largura

---

### 4️⃣ **LANDSCAPE MODE** (Linha ~80)
```markdown
<img src="./Screenshots/landscape.png" alt="Landscape Mode" width="600">
```
**Aparece**: Seção Screenshots
**Tamanho**: 600px de largura

---

### 5️⃣ **THEMES** (Linha ~90)
```markdown
<img src="./Screenshots/themes.png" alt="Themes" width="300">
```
**Aparece**: Seção Screenshots
**Tamanho**: 300px de largura

---

### 6️⃣ **CUSTOMIZATION** (Linha ~100)
```markdown
<img src="./Screenshots/customization.png" alt="Customization" width="300">
```
**Aparece**: Seção Screenshots
**Tamanho**: 300px de largura

---

### 7️⃣ **AR MODE** (Linha ~110)
```markdown
<img src="./Screenshots/ar-mode.png" alt="AR Mode" width="600">
```
**Aparece**: Seção Screenshots
**Tamanho**: 600px de largura

---

### 8️⃣ **MULTIPLE DICE + ROLL MODES** (Linha ~120)
```markdown
<img src="./Screenshots/multiple-dice.png" alt="Multiple Dice" width="300">
<img src="./Screenshots/roll-modes.png" alt="Roll Modes" width="300">
```
**Aparecem**: Lado a lado na seção Screenshots
**Tamanho**: 300px cada

---

## ✅ CHECKLIST

Antes de fazer commit, verifique:

- [ ] Pasta `Screenshots/` criada
- [ ] `hero.png` adicionado (1200x600+ recomendado)
- [ ] `portrait.png` adicionado (375x812+)
- [ ] `landscape.png` adicionado (896x414+)
- [ ] `themes.png` adicionado (375x812+)
- [ ] `customization.png` adicionado (375x812+)
- [ ] `ar-mode.png` adicionado (896x414+)
- [ ] `multiple-dice.png` adicionado (375x812+)
- [ ] `roll-modes.png` adicionado (375x812+)
- [ ] `dice-roll.gif` adicionado (OPCIONAL, 600px largura)

---

## 🎨 DICAS DE PRINTS

### **Hero Image (hero.png)**
- **O que mostrar**: Tela inicial em landscape com D20 grande
- **Fundo**: Dark com dourado bem visível
- **Sem**: Notificações, horário, WiFi
- **Resolução**: Mínimo 1200x600px

### **Portrait (portrait.png)**
- **O que mostrar**: Dado grande no topo + grid de seleção embaixo
- **Orientação**: Vertical
- **Resolução**: Nativa do iPhone (375x812+ ou equivalente)

### **Landscape (landscape.png)**
- **O que mostrar**: Dado à esquerda, botões à direita
- **Orientação**: Horizontal
- **Resolução**: Nativa do iPhone horizontal (896x414+)

### **Themes (themes.png)**
- **O que mostrar**: ThemesList aberto com vários temas visíveis
- **Destacar**: Variedade de cores e estilos

### **Customization (customization.png)**
- **O que mostrar**: ThemeCustomizer com paleta de cores
- **Destacar**: Opções de customização

### **AR Mode (ar-mode.png)**
- **O que mostrar**: Dado na mesa/chão real
- **Se possível**: Dado no ar ou rolando
- **Ambiente**: Bem iluminado

### **Multiple Dice (multiple-dice.png)**
- **O que mostrar**: Sheet aberto com múltiplos dados e resultado
- **Destacar**: Total grande + dados individuais

### **Roll Modes (roll-modes.png)**
- **O que mostrar**: Blessed ou Cursed ativo
- **Destacar**: 2 resultados (um riscado)

### **GIF (dice-roll.gif - OPCIONAL)**
- **O que mostrar**: Dado girando e parando
- **Duração**: 2-3 segundos
- **Loop**: Infinito
- **FPS**: 30-60
- **Tamanho**: ~600px largura, <5MB

---

## 🚀 PRÓXIMOS PASSOS

1. **Tire os prints** conforme guia acima
2. **Salve** na pasta `Screenshots/` com os nomes EXATOS
3. **Commit tudo**:
   ```bash
   git add Screenshots/ README.md
   git commit -m "✨ Add epic README with screenshots"
   git push origin main
   ```
4. **Veja no GitHub** - o README vai ficar FODA! 🔥

---

## 📝 NOTAS

- Screenshots podem ser PNG ou JPG
- GIF deve ser otimizado (<5MB)
- Nomes devem ser EXATAMENTE como listados
- Paths são case-sensitive no Linux (GitHub)
- Use device frames para visual profissional (opcional)

---

**Pronto! Agora é só tirar os prints e fazer o commit! 🎉**

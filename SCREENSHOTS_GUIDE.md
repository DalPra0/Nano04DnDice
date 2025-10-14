# 📸 GUIA DE SCREENSHOTS - README ÉPICO

## 🎯 ONDE COLOCAR CADA IMAGEM

### 📂 **Estrutura de Pastas**
```
Screenshots/
├── hero.png              ⭐ Banner principal (1200x600+)
├── portrait.png          📱 Modo vertical (375x812+)
├── landscape.png         🖥️ Modo horizontal (896x414+)
├── themes.png            🎨 Lista de temas (375x812+)
├── customization.png     🎨 Customização (375x812+)
├── ar-mode.png           🌟 AR Mode (896x414+)
├── multiple-dice.png     🎲 Múltiplos dados (375x812+)
├── roll-modes.png        ⚔️ Blessed/Cursed (375x812+)
└── dice-roll.gif         🎬 Animação (600px, <5MB) OPCIONAL
```

---

## 🎨 **CAPTURAS ESPECÍFICAS**

### 1️⃣ **hero.png** (Banner Principal)
**Localização no README**: Linha ~18
```markdown
<img src="./Screenshots/hero.png" alt="DnDice - The Ultimate Dice Roller">
```

**O QUE MOSTRAR:**
- 🎲 Tela em **landscape** com D20 GRANDE visível
- 🌑 Fundo dark com dourado (#FFD700) bem visível
- ✨ Sem notificações, horário ou status bar
- 🎯 Dado centralizado, bem iluminado
- **Resolução**: Mínimo 1200x600px (quanto maior, melhor)

**DICA PRO:** Use o simulador em landscape, aumente o zoom (⌘ + =) e tire print (⌘ + S)

---

### 2️⃣ **dice-roll.gif** (Animação - OPCIONAL)
**Localização no README**: Linha ~34
```markdown
<img src="./Screenshots/dice-roll.gif" alt="Witness the Magic" width="600">
```

**O QUE MOSTRAR:**
- 🎲 Dado girando em 3D
- ⏱️ 2-3 segundos de duração
- 🔄 Loop infinito
- 📏 600px de largura
- 📦 Tamanho: <5MB

**COMO FAZER:**
1. Screen recording (⌘ + Shift + 5)
2. Converter para GIF:
   - App: GIPHY Capture, Gifski
   - Online: ezgif.com, cloudconvert.com
3. Otimizar: gifsicle, ezgif.com/optimize

---

### 3️⃣ **portrait.png** (Modo Vertical)
**Localização no README**: Linha ~73
```markdown
<img src="./Screenshots/portrait.png" width="300">
```

**O QUE MOSTRAR:**
- 📱 Device em **portrait** (vertical)
- 🎲 Dado GRANDE no topo da tela
- 🔲 Grid de seleção de dados embaixo (3x2)
- 🎨 Tema visível (cores douradas)
- ✅ Interface completa e limpa

---

### 4️⃣ **landscape.png** (Modo Horizontal)
**Localização no README**: Linha ~73
```markdown
<img src="./Screenshots/landscape.png" width="500">
```

**O QUE MOSTRAR:**
- 📱 Device em **landscape** (horizontal)
- 🎲 Dado 3D à esquerda (50% da tela)
- 🔘 Botões de seleção à direita (50%)
- ⚡ Interface quick-roll visível
- 🎯 Layout split bem definido

---

### 5️⃣ **themes.png** (Lista de Temas)
**Localização no README**: Linha ~88
```markdown
<img src="./Screenshots/themes.png" alt="7 Preset Themes" width="350">
```

**O QUE MOSTRAR:**
- 🎨 ThemesList screen aberto
- 📋 Pelo menos 4-5 temas visíveis
- 🌈 Cores variadas (Classic, Medieval, Cyberpunk, etc)
- ✨ Cards de tema bem formatados
- 🎯 Destaque no tema ativo (checkmark)

---

### 6️⃣ **customization.png** (Customização)
**Localização no README**: Linha ~112
```markdown
<img src="./Screenshots/customization.png" alt="Customize Everything" width="350">
```

**O QUE MOSTRAR:**
- 🎨 ThemeCustomizer screen aberto
- 🎨 Paleta de cores visível
- 🔧 Várias opções de customização
- 🎭 Preview do tema atual
- ✨ Sliders, toggles e botões visíveis

---

### 7️⃣ **ar-mode.png** (Realidade Aumentada)
**Localização no README**: Linha ~139
```markdown
<img src="./Screenshots/ar-mode.png" alt="AR Dice Magic" width="700">
```

**O QUE MOSTRAR:**
- 📱 Tela AR com câmera ativa
- 🎲 Dado D20 em cima de uma mesa/superfície REAL
- 🌟 Plano de superfície detectado (se visível)
- 🎯 Interface AR visível (botões, instruções)
- 💡 Ambiente bem iluminado

**DICA:** Se possível, capture o dado "no ar" ou rolando!

---

### 8️⃣ **roll-modes.png** (Modos de Rolagem)
**Localização no README**: Linha ~160
```markdown
<img src="./Screenshots/roll-modes.png" width="300">
```

**O QUE MOSTRAR:**
- ⚔️ Roll Mode ativo (Blessed OU Cursed)
- 🎲 Dois resultados visíveis
- ✅ Um resultado destacado (usado)
- ❌ Outro resultado riscado (descartado)
- 🟢 Verde (Blessed) OU 🔴 Vermelho (Cursed)

---

### 9️⃣ **multiple-dice.png** (Múltiplos Dados)
**Localização no README**: Linha ~183
```markdown
<img src="./Screenshots/multiple-dice.png" width="300">
```

**O QUE MOSTRAR:**
- 🎲 Sheet de Multiple Dice aberto
- 📊 Resultado com múltiplos dados (3-8 dados)
- 🔢 Total GRANDE e visível
- 📈 Stats (AVG, MAX, MIN)
- 🎲 Dados individuais em scroll horizontal

---

## ✅ **CHECKLIST PRÉ-COMMIT**

Antes de fazer push, verifique:

### Arquivos:
- [ ] `hero.png` adicionado (1200x600+)
- [ ] `portrait.png` adicionado (375x812+)
- [ ] `landscape.png` adicionado (896x414+)
- [ ] `themes.png` adicionado (375x812+)
- [ ] `customization.png` adicionado (375x812+)
- [ ] `ar-mode.png` adicionado (896x414+)
- [ ] `multiple-dice.png` adicionado (375x812+)
- [ ] `roll-modes.png` adicionado (375x812+)
- [ ] `dice-roll.gif` adicionado (OPCIONAL, 600px, <5MB)

### Qualidade:
- [ ] Sem notificações na tela
- [ ] Sem horário/status bar (use simulador sem)
- [ ] Resolução mínima respeitada
- [ ] Fundo dark visível
- [ ] Dourado (#FFD700) bem visível
- [ ] Imagens nítidas (não borradas)
- [ ] Nomes EXATOS como listados acima

---

## 🚀 **COMANDOS PARA COMMIT**

```bash
# 1. Navegue até o projeto
cd /Users/lucasdalprabrascher/Developer/Nano/Nano04DnDice

# 2. Veja os arquivos novos
git status

# 3. Adicione tudo
git add README.md Screenshots/ LICENSE .gitignore SCREENSHOTS_GUIDE.md

# 4. Commit com mensagem épica
git commit -m "✨ Add epic README with screenshots and documentation"

# 5. Push para GitHub
git push origin main

# 6. Vá no GitHub e veja a MAGIA! 🎉
```

---

## 🎨 **DICAS DE CAPTURA**

### **No Simulador:**
```
1. Abra o simulador (iPhone 15 Pro recomendado)
2. Remova status bar: Debug > Hide Status Bar
3. Rotacione: ⌘ + → (landscape) ou ⌘ + ← (portrait)
4. Zoom: ⌘ + = (aumentar) | ⌘ + - (diminuir)
5. Screenshot: ⌘ + S (salva na Área de Trabalho)
```

### **Em Device Real:**
```
1. Power + Volume Up (screenshot)
2. Abra Fotos
3. Edite para remover elementos indesejados
4. AirDrop para o Mac
```

### **Para GIF:**
```
1. Screen Recording: ⌘ + Shift + 5
2. Grave 3-5 segundos do dado rolando
3. Pare a gravação
4. Abra o vídeo em Gifski ou GIPHY Capture
5. Exporte como GIF (600px width, <5MB)
```

---

## 📏 **RESOLUÇÕES RECOMENDADAS**

| Arquivo | Largura | Altura | Aspect Ratio |
|:---:|:---:|:---:|:---:|
| hero.png | 1200+ | 600+ | 2:1 |
| portrait.png | 375+ | 812+ | 9:19.5 |
| landscape.png | 896+ | 414+ | ~2.16:1 |
| themes.png | 375+ | 812+ | 9:19.5 |
| customization.png | 375+ | 812+ | 9:19.5 |
| ar-mode.png | 896+ | 414+ | ~2.16:1 |
| multiple-dice.png | 375+ | 812+ | 9:19.5 |
| roll-modes.png | 375+ | 812+ | 9:19.5 |
| dice-roll.gif | 600 | auto | any |

---

## 💡 **FRAMES OPCIONAIS (Pro)**

Para deixar AINDA MAIS PROFISSIONAL, use device frames:

**Online:**
- https://mockuphone.com
- https://www.screely.com
- https://shots.so

**Apps Mac:**
- Rotato
- Previewed
- Screenshot Creator

**Como usar:**
1. Tire screenshot limpo
2. Upload no site/app
3. Escolha device frame (iPhone 15 Pro)
4. Download com frame
5. Use no README!

---

## 🎯 **RESULTADO FINAL**

Quando você fizer commit correto:

✅ README vai renderizar PERFEITAMENTE  
✅ Imagens vão carregar rápido  
✅ Layout vai ficar PROFISSIONAL  
✅ Outros devs vão ficar impressionados  
✅ Recrutadores vão dar star  
✅ Você vai dominar o GitHub  

---

**AGORA VAI LÁ E TIRA OS PRINTS! 📸🔥**

*"Every great README starts with a great screenshot"* - Claude, 2025 🎨

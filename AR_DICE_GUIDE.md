# 🎲 AR Dice Feature - Guia de Uso

## ✅ O que foi implementado:

### **Experiência AR estilo Pokémon GO:**

1. **Menu AR**
   - Botão "AR DICE" adicionado no menu hambúrguer (topo direito)
   - Ícone: ARKit symbol

2. **Tela AR (ARDiceView.swift)**
   - Fullscreen com câmera ativa
   - Detecção automática de superfícies horizontais
   - Dado D20 fixo na parte de baixo da tela
   - Arraste o dado pra cima e solte para jogar!

3. **Física Realista (ARDiceCoordinator.swift)**
   - RealityKit physics engine
   - Colisão e rotação realistas
   - Força do arremesso baseada na velocidade do gesto
   - Torque aleatório para rotação natural

4. **Feedback Visual**
   - Indicador de superfície detectada (plano semi-transparente)
   - Animação de pulso no dado quando pronto para jogar
   - Resultado grande e dourado quando o dado para
   - Dado desaparece automaticamente após 4 segundos

---

## 🎮 Como usar:

1. **Abra o app** → Tela principal
2. **Clique no menu** (≡) no canto superior direito
3. **Clique em "AR DICE"**
4. **Autorize o acesso à câmera** (primeira vez)
5. **Aponte a câmera para o chão/mesa**
6. **Aguarde** "Superfície detectada" (o dado na parte de baixo vai pulsar)
7. **Arraste o dado de baixo pra cima** e solte!
8. **Assista o dado rolar** com física realista
9. **Veja o resultado** aparecer na tela

---

## 🔧 Detalhes Técnicos:

### **ARDiceView.swift**
- Interface SwiftUI com ARViewContainer
- Drag gesture customizado
- Animações e transições suaves
- Feedback háptico no arremesso

### **ARDiceCoordinator.swift**
- ARSessionDelegate para plane detection
- Physics engine com friction e restitution
- Algoritmo de detecção do número (simplificado)
- Timer para detectar quando o dado para

### **Modelo 3D**
- Arquivo: `D20.usdz`
- Localização: `Resources/Models/`
- Escala: 5cm (0.05 units)
- Física: Dynamic body com collision shape

---

## ⚠️ Limitações atuais:

1. **Detecção do número**: Algoritmo simplificado que mapeia a rotação para 1-20
   - Em produção, você deveria mapear cada face específica do modelo D20
   - Requer análise da geometria do modelo ou ray casting

2. **Performance**: Testado em dispositivos com A12 Bionic ou superior
   - Pode ter lag em devices antigos

3. **Lighting**: Usa ambient lighting automático
   - Em ambientes muito escuros pode não detectar superfícies bem

---

## 🚀 Melhorias futuras sugeridas:

1. ✨ **Detecção precisa de faces**
   - Ray casting do centro do dado pra cima
   - Leitura de texture/material da face superior
   - Mapeamento 3D de cada uma das 20 faces

2. 🎨 **Customização visual**
   - Aplicar cores do tema atual no dado AR
   - Múltiplos tipos de dados (D4, D6, D8, D10, D12, D20)
   - Texturas personalizadas

3. 🎭 **Multiplayer**
   - ARKit collaborative sessions
   - Vários dados na mesma superfície
   - Sync via Firebase/CloudKit

4. 📊 **Histórico de rolagens AR**
   - Salvar resultados de dados AR
   - Estatísticas separadas

5. 🎯 **Tutoria interativo**
   - Primeira vez mostra como usar
   - Dicas durante a experiência

---

## 📱 Requisitos:

- **iOS**: 15.0+
- **Dispositivo**: iPhone/iPad com suporte a ARKit
- **Processador**: A12 Bionic ou superior (recomendado)
- **Permissões**: Câmera (autorização obrigatória)

---

## 🐛 Debug:

Se o dado não aparecer:
1. Verifique se `D20.usdz` está no target do app
2. Veja os logs no console: "❌ Erro ao carregar D20.usdz"
3. Confirme que a superfície foi detectada (plano branco aparece)
4. Teste em ambiente bem iluminado

---

**Feito com ❤️ usando RealityKit + ARKit**

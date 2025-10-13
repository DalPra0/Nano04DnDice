# 🔍 DEBUG GUIDE - AR Dice não aparece

## ✅ Checklist para resolver:

### 1. **Verificar se D20.usdz está no target**
   - Abra o Xcode
   - Clique em `D20.usdz` no navegador de arquivos
   - No painel direito, veja "Target Membership"
   - ✅ Marque "Nano04DnDice"

### 2. **Verificar logs no Console**
   O código agora imprime MUITOS logs. Quando você jogar o dado, veja:
   
   ```
   ✅ D20 carregado com nome 'D20'  // OU
   ✅ D20 carregado via Bundle URL   // OU
   🎲 Usando dado FALLBACK (esfera dourada)  // Se falhar
   
   📍 Posição do dado: [x, y, z]
   💫 Força aplicada: [x, y, z]
   🌀 Torque aplicado: [x, y, z]
   ✅ Dado adicionado à cena!
   ```

### 3. **Se aparecer "📦 Arquivos .usdz encontrados"**
   Veja o nome exato do arquivo listado. Pode ser que tenha espaço ou caractere especial.

### 4. **Dado FALLBACK (esfera dourada)**
   Se o modelo D20 não carregar, uma **esfera dourada metálica** vai aparecer como fallback.
   - Se isso funcionar → problema é no arquivo D20.usdz
   - Se nem isso funcionar → problema é na detecção de superfície

---

## 🎯 Teste passo a passo:

1. **Build no device** (não simulador!)
2. **Abra o Console** no Xcode (View → Debug Area → Activate Console)
3. **Clique em AR DICE** no menu
4. **Autorize câmera**
5. **Aponte para o chão/mesa**
6. **ESPERE** até aparecer "Superfície detectada"
7. **Arraste o dado de baixo pra cima** (rápido!)
8. **OLHE OS LOGS** no console

---

## 🐛 Possíveis problemas:

### Problema 1: "❌ Erro ao carregar D20.usdz de TODAS as formas"
**Solução:**
- Deletar D20.usdz do projeto
- Re-adicionar via "Add Files to..."
- ✅ MARCAR "Copy items if needed"
- ✅ MARCAR "Add to targets: Nano04DnDice"

### Problema 2: Dado carrega mas não aparece
**Causas:**
- Escala muito pequena → Tente mudar `dice.scale = [0.1, 0.1, 0.1]` (linha ~120)
- Posição fora da câmera → Tente `dice.position = [0, 0.5, -0.3]`
- Material transparente no modelo

### Problema 3: Superfície não detectada
**Causas:**
- Ambiente muito escuro
- Superfície não plana (tapete felpudo, etc)
- Câmera muito perto ou muito longe
**Solução:** Aponte para uma mesa lisa, bem iluminada, a ~1 metro

---

## 📊 O que esperar:

✅ **Funcionando:**
- Dado D20 detalhado aparece e rola OU
- Esfera dourada aparece e rola

❌ **Não funcionando:**
- Nada aparece
- App trava
- Console mostra erros

---

**Rode agora e me manda os logs do Console! 📱**

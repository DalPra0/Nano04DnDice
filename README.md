# 🎲 DnDice

> **Roll dice like you've never rolled before.**  
> Customize everything. Roll in AR. Play your way.

<div align="center">

<!-- 🖼️ COLOQUE hero.png AQUI -->
<img src="./Screenshots/hero.png" alt="DnDice" width="100%">

**iOS 15.0+** • **SwiftUI** • **RealityKit** • **Three.js**

[Features](#-features) · [Screenshots](#-screenshots) · [Installation](#-installation) · [Roadmap](#-roadmap)

</div>

---

## 💎 The Ultimate Dice Roller

DnDice is **not** your average dice rolling app. It's a complete RPG companion built from the ground up with **brutal customization**, **3D physics**, and **augmented reality** support.

Whether you're rolling for initiative in D&D, making skill checks in Pathfinder, or testing fate in Call of Cthulhu—**DnDice adapts to your game**.

### Why DnDice?

- 🎲 **Physical D20 in 3D** powered by Three.js
- 🌟 **Throw dice on your table** with AR
- 🎨 **7 stunning themes** + infinite custom options
- ⚡ **Portrait & Landscape** modes
- 🔮 **Roll modes**: Normal, Blessed (advantage), Cursed (disadvantage)
- 🤝 **Shake to roll** for that authentic feel
- 🎵 **Audio & haptics** that bring rolls to life

---

## ⚡ Features

### 🎲 Complete Dice Arsenal

Roll **any dice** you need:
- Standard set: **D4, D6, D8, D10, D12, D20**
- Custom dice: **2 to 100 sides**
- Multiple dice: Roll **up to 20 at once**
- Roll modes: **Normal** • **Blessed** (advantage) • **Cursed** (disadvantage)
- Modifiers: Add **proficiency bonus** (-10 to +10)

<!-- 🖼️ COLOQUE dice-roll.gif AQUI (OPCIONAL) -->
<div align="center">
<img src="./Screenshots/dice-roll.gif" alt="D20 Rolling" width="500">
</div>

---

### 🎨 Infinite Customization

**7 Preset Themes:**
- 🏰 Classic D&D (golden elegance)
- 🌲 Medieval (wooden warmth)
- 🌆 Cyberpunk (neon chaos)
- 🌑 Horror (cosmic dread)
- ⚡ Norse (viking power)
- ✨ Arcane (mystical glow)
- ☀️ Light Mode (for the brave)

**Customize Everything:**
- Colors: dice face, border, numbers, background, accents
- Textures: standard, metallic, wooden, stone, crystal
- Fonts: 11 options including PlayfairDisplay, Ubuntu, Bebas Neue
- Effects: glow intensity, shadows, particles
- Smart contrast system that auto-adapts text colors

---

### 📱 Adaptive Interface

**Portrait Mode:**  
Large dice view with all controls at your fingertips. Perfect for tactical rolling.

**Landscape Mode:**  
Quick-roll interface. Tap the dice or buttons. Fast gameplay.

**Shake Detection:**  
Shake your device to roll. Works in both modes.

---

### 🌟 Augmented Reality

Throw a **physical D20** onto your **real table**.

- Pokémon GO-style drag interface
- Realistic physics (RealityKit)
- Collision detection
- Automatic surface scanning

**How it works:**
1. Point camera at a flat surface
2. Wait for detection
3. Drag the D20 upward
4. Release to throw
5. Watch it roll with real physics

<!-- 🖼️ COLOQUE ar-mode.png AQUI -->
<div align="center">
<img src="./Screenshots/ar-mode.png" alt="AR Mode" width="700">
</div>

---

### 🎯 Roll Modes

**Blessed Mode (Advantage):**  
Roll 2 dice, keep the highest. Green glow. Fortune smiles upon you.

**Cursed Mode (Disadvantage):**  
Roll 2 dice, keep the lowest. Red shadow. Fate turns against you.

Both modes show **both results**, striking through the discarded roll.

---

### 🎲 Multiple Dice

Roll **up to 20 dice simultaneously**.

**Instant stats:**
- **Total** (displayed big)
- Average
- Highest roll
- Lowest roll

**Quick presets:** 2D6, 3D6, 4D6, 8D6, 2D8, 3D8, 2D10, 2D20

---

## 📸 Screenshots

<table>
<tr>
<td width="40%">

### Portrait Mode
<!-- 🖼️ COLOQUE portrait.png AQUI -->
<img src="./Screenshots/portrait.png" alt="Portrait">

Large dice display with intuitive controls

</td>
<td width="60%">

### Landscape Mode
<!-- 🖼️ COLOQUE landscape.png AQUI -->
<img src="./Screenshots/landscape.png" alt="Landscape">

Quick-roll interface for fast gameplay

</td>
</tr>
</table>

<table>
<tr>
<td width="50%">

### Themes
<!-- 🖼️ COLOQUE themes.png AQUI -->
<img src="./Screenshots/themes.png" alt="Themes">

7 presets + unlimited custom themes

</td>
<td width="50%">

### Customization
<!-- 🖼️ COLOQUE customization.png AQUI -->
<img src="./Screenshots/customization.png" alt="Customization">

Control every visual detail

</td>
</tr>
</table>

<table>
<tr>
<td width="50%">

### Multiple Dice
<!-- 🖼️ COLOQUE multiple-dice.png AQUI -->
<img src="./Screenshots/multiple-dice.png" alt="Multiple Dice">

Roll many, see stats instantly

</td>
<td width="50%">

### Roll Modes
<!-- 🖼️ COLOQUE roll-modes.png AQUI -->
<img src="./Screenshots/roll-modes.png" alt="Roll Modes">

Advantage & disadvantage system

</td>
</tr>
</table>

---

## 🛠️ Tech Stack

**Frontend:**
- SwiftUI (declarative UI)
- MVVM architecture
- Combine (reactive programming)

**3D & Graphics:**
- **Three.js (r128)** for 3D dice physics
- WebKit integration
- Custom geometries for each die type

**Augmented Reality:**
- **RealityKit** (rendering)
- **ARKit** (plane detection)
- Physics engine (collision, friction, restitution)

**Audio:**
- AVFoundation (playback)
- CoreHaptics (feedback)

**Persistence:**
- UserDefaults (theme storage)
- Core Data ready (future features)

**Design:**
- 11 custom fonts
- Automatic contrast calculation (ITU-R BT.709)
- 12 modular SwiftUI components

---

## 📦 Installation

### Requirements
- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+
- ARKit compatible device (for AR features)

### Setup

```bash
# Clone
git clone https://github.com/yourusername/DnDice.git
cd DnDice

# Open in Xcode
open Nano04DnDice.xcodeproj

# Add assets (if needed)
# - Fonts → Resources/Fonts/
# - Audio → Resources/Audio/
# - D20.usdz → Resources/Models/

# Build & Run
# Press ⌘ + R
```

### Project Structure

```
Nano04DnDice/
├── App/                   # Entry point
├── Views/                 # 13+ SwiftUI views
│   ├── Components/        # 12 reusable components
│   ├── DiceRollerView.swift
│   ├── DiceRollerLandscapeView.swift
│   ├── ThemesListView.swift
│   ├── ThemeCustomizerView.swift
│   └── ARDiceView.swift
├── ViewModels/            # Business logic
├── Models/                # Data structures
├── Managers/              # Audio, Theme, AR, Shake
├── Extensions/            # Color utilities
└── Resources/             # Assets
```

---

## 🗺️ Roadmap

### ✅ Phase 1-3: Shipped

- [x] Standard dice (D4-D20)
- [x] Custom dice (2-100 sides)
- [x] Multiple dice rolling
- [x] 7 preset themes
- [x] Full theme customization
- [x] Portrait & landscape modes
- [x] Shake detection
- [x] AR mode with RealityKit
- [x] Roll modes (Blessed/Cursed)
- [x] Proficiency bonus
- [x] Audio & haptic feedback
- [x] Smart contrast system

### 🚧 Phase 4: In Progress

- [ ] Session tracking
- [ ] Character sheet integration
- [ ] Initiative tracker
- [ ] Roll history with context
- [ ] Modifier calculator
- [ ] Quick notes

### 🔮 Future

- [ ] iCloud sync
- [ ] Multiplayer support
- [ ] Widget support
- [ ] Apple Watch companion
- [ ] Siri shortcuts
- [ ] Dice bag presets
- [ ] Campaign manager
- [ ] Statistics export
- [ ] Community themes

---

## 🏗️ Architecture

DnDice follows **MVVM** pattern:

```
View (SwiftUI)
  ↓ observes
ViewModel (@Published)
  ↓ updates
Model (Codable structs)
```

**Key components:**
- `DiceRollerViewModel` - State management
- `ThemeManager` - Theme persistence
- `AudioManager` - Sound & haptics
- `ARDiceCoordinator` - AR session & physics

For details, see [ARCHITECTURE.md](ARCHITECTURE.md)

---

## 🎨 Design Philosophy

DnDice embraces **dark elegance**:

- **PlayfairDisplay** serif font for sophistication
- **Golden accents** (#FFD700) for premium feel
- **Deep blacks** for immersion
- **Smooth animations** for polish
- **Smart contrast** for accessibility

The UI adapts to your theme. Text automatically adjusts for readability based on background luminance.

---

## 🤝 Contributing

Contributions welcome!

```bash
# Fork & clone
git checkout -b feature/YourFeature
git commit -m 'Add YourFeature'
git push origin feature/YourFeature
# Open PR
```

**Guidelines:**
- Follow MVVM
- Use SwiftUI best practices
- Comment in Portuguese
- Test on multiple devices
- Keep components modular

---

## 📝 License

MIT License - see [LICENSE](LICENSE)

Free to use, modify, distribute. Just include the license.

---

## 🙏 Credits

- **Three.js** - 3D engine
- **Apple** - RealityKit & ARKit
- **Google Fonts** - Typography
- **RPG Community** - Inspiration

---

## 📬 Contact

**Lucas Dal Pra Brascher**

- GitHub: [@DalPra0](https://github.com/DalPra0)
- Email: your.email@example.com

Questions? Issues? Open an issue or reach out!

---

<div align="center">

### ⭐ Star this repo if you love rolling dice! ⭐

**Made with ❤️ for the tabletop RPG community**

*"May your rolls be high and your crits be plentiful"*

</div>

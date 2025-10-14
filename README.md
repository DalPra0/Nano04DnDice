<div align="center">

<!-- 🖼️ COLOQUE A IMAGEM hero.png AQUI -->
<img src="./Screenshots/hero.png" alt="DnDice Hero" width="100%">

# 🎲 DnDice

### The Ultimate Customizable Dice Roller for RPG Players

[![Platform](https://img.shields.io/badge/Platform-iOS%2015.0%2B-blue.svg?style=flat)](https://www.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg?style=flat)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-4.0-blue.svg?style=flat)](https://developer.apple.com/xcode/swiftui/)
[![RealityKit](https://img.shields.io/badge/RealityKit-AR-green.svg?style=flat)](https://developer.apple.com/augmented-reality/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat)](LICENSE)

**Roll dice like never before. Customize everything. Play in AR.**

[Features](#-features) • [Screenshots](#-screenshots) • [Tech Stack](#-tech-stack) • [Installation](#-installation) • [Roadmap](#-roadmap)

</div>

---

## 🎯 About

**DnDice** is a premium dice rolling app designed for tabletop RPG players who want complete control over their gaming experience. Built with SwiftUI and powered by Three.js for stunning 3D dice physics, DnDice combines beautiful design with powerful customization.

Whether you're playing D&D, Pathfinder, Call of Cthulhu, or any other RPG system, DnDice adapts to your game style with **unlimited customization** and **immersive AR support**.

<!-- 🎬 COLOQUE O GIF dice-roll.gif AQUI (OPCIONAL) -->
<div align="center">
<img src="./Screenshots/dice-roll.gif" alt="Dice Rolling Demo" width="600">
</div>

---

## ✨ Features

### 🎲 **Complete Dice Collection**
- **Standard Dice**: D4, D6, D8, D10, D12, D20
- **Custom Dice**: Create any dice from 2 to 100 sides
- **Multiple Dice**: Roll up to 20 dice simultaneously with statistics
- **Roll Modes**: Normal, Blessed (advantage), Cursed (disadvantage)
- **Proficiency Bonus**: Add modifiers from -10 to +10

### 🎨 **Unlimited Customization**
- **7 Preset Themes**: Classic D&D, Medieval, Cyberpunk, Horror, Norse, Arcane, Light Mode
- **Custom Themes**: Change every color, texture, font, and effect
- **Smart Contrast**: Text automatically adapts to background luminance
- **11 Fonts**: From elegant PlayfairDisplay to modern Ubuntu
- **5 Textures**: Standard, Metallic, Wooden, Stone, Crystal

### 📱 **Adaptive Interface**
- **Portrait Mode**: Large dice view with intuitive controls
- **Landscape Mode**: Quick-roll interface for fast gameplay
- **Shake to Roll**: Shake your device to roll dice
- **Responsive Design**: Perfect on iPhone, iPad, and Mac

### 🌟 **Augmented Reality**
- **Pokémon GO-style AR**: Throw dice onto real surfaces
- **Realistic Physics**: Powered by RealityKit
- **Surface Detection**: Automatic plane detection
- **Immersive Experience**: Watch your D20 roll in the real world

### 🎵 **Immersive Audio**
- **Sound Effects**: Dice roll, critical success, fumble sounds
- **Haptic Feedback**: Feel every roll
- **Volume Control**: Adjustable master volume

---

## 📸 Screenshots

### Portrait Mode
<div align="center">

<!-- 🖼️ COLOQUE A IMAGEM portrait.png AQUI -->
<img src="./Screenshots/portrait.png" alt="Portrait Mode" width="300">

*Large dice display with all controls at your fingertips*

</div>

### Landscape Mode
<div align="center">

<!-- 🖼️ COLOQUE A IMAGEM landscape.png AQUI -->
<img src="./Screenshots/landscape.png" alt="Landscape Mode" width="600">

*Quick-roll interface for fast-paced gaming*

</div>

### Themes Gallery
<div align="center">

<!-- 🖼️ COLOQUE A IMAGEM themes.png AQUI -->
<img src="./Screenshots/themes.png" alt="Themes" width="300">

*Choose from 7 beautiful preset themes or create your own*

</div>

### Full Customization
<div align="center">

<!-- 🖼️ COLOQUE A IMAGEM customization.png AQUI -->
<img src="./Screenshots/customization.png" alt="Customization" width="300">

*Customize every aspect of your dice and interface*

</div>

### Augmented Reality
<div align="center">

<!-- 🖼️ COLOQUE A IMAGEM ar-mode.png AQUI -->
<img src="./Screenshots/ar-mode.png" alt="AR Mode" width="600">

*Throw dice onto real surfaces with realistic physics*

</div>

### Multiple Dice & Roll Modes
<div align="center">

<!-- 🖼️ COLOQUE AS IMAGENS multiple-dice.png E roll-modes.png AQUI LADO A LADO -->
<img src="./Screenshots/multiple-dice.png" alt="Multiple Dice" width="300">
<img src="./Screenshots/roll-modes.png" alt="Roll Modes" width="300">

*Roll multiple dice at once • Advantage/Disadvantage system*

</div>

---

## 🛠️ Tech Stack

### **Frontend**
- **SwiftUI** - Modern declarative UI framework
- **MVVM Architecture** - Clean separation of concerns
- **Combine** - Reactive programming

### **3D & Graphics**
- **Three.js (r128)** - WebView-based 3D rendering
- **WebKit** - Native web integration
- **Custom Geometries** - D4, D6, D8, D10, D12, D20

### **Augmented Reality**
- **RealityKit** - AR rendering engine
- **ARKit** - Plane detection & tracking
- **Physics Engine** - Collision, friction, restitution

### **Audio & Haptics**
- **AVFoundation** - Audio playback
- **CoreHaptics** - Haptic feedback

### **Persistence**
- **UserDefaults** - Theme storage (JSON)
- **Core Data** - Ready for future features

### **Design System**
- **Custom Fonts** - 11 fonts including PlayfairDisplay
- **Color+Contrast** - Automatic luminance calculation (ITU-R BT.709)
- **Modular Components** - 12+ reusable SwiftUI views

---

## 📦 Installation

### **Requirements**
- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+
- Device with ARKit support (for AR features)

### **Setup**

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/DnDice.git
cd DnDice
```

2. **Open in Xcode**
```bash
open Nano04DnDice.xcodeproj
```

3. **Add required assets** (if not included)
   - Place custom fonts in `Resources/Fonts/`
   - Place audio files in `Resources/Audio/`
   - Place D20.usdz in `Resources/Models/`

4. **Build and Run**
   - Select your target device
   - Press `Cmd + R`

### **Project Structure**
```
Nano04DnDice/
├── App/                    # App entry point
├── Views/                  # SwiftUI views
│   ├── Components/         # Reusable components (12)
│   ├── DiceRollerView.swift
│   ├── DiceRollerLandscapeView.swift
│   ├── ThemesListView.swift
│   ├── ThemeCustomizerView.swift
│   └── ARDiceView.swift
├── ViewModels/             # Business logic
├── Models/                 # Data models
├── Managers/               # Services (Audio, Theme, AR)
├── Extensions/             # Swift extensions
└── Resources/              # Assets (fonts, audio, 3D models)
```

---

## 🗺️ Roadmap

### **✅ Completed (Phase 1-3)**
- [x] 6 standard dice types (D4-D20)
- [x] Custom dice (2-100 sides)
- [x] Multiple dice rolling
- [x] 7 preset themes
- [x] Full theme customization
- [x] Portrait/Landscape modes
- [x] Shake detection
- [x] AR mode with RealityKit
- [x] Roll modes (Blessed/Cursed)
- [x] Proficiency bonus
- [x] Audio & haptic feedback
- [x] Smart contrast system

### **🚧 In Progress (Phase 4)**
- [ ] Session tracking
- [ ] Character sheet integration
- [ ] Initiative tracker
- [ ] Roll history with context
- [ ] Modifier calculator
- [ ] Quick notes

### **🔮 Future Ideas**
- [ ] iCloud sync
- [ ] Multiplayer support
- [ ] Widget support
- [ ] Apple Watch companion
- [ ] Siri shortcuts
- [ ] Dice bag presets
- [ ] Campaign manager
- [ ] Export roll statistics
- [ ] Community themes marketplace

---

## 🏗️ Architecture

DnDice follows the **MVVM (Model-View-ViewModel)** pattern for clean separation of concerns:

```
┌─────────────┐
│    View     │ ← SwiftUI Views (12+ components)
└──────┬──────┘
       │ observes
       ▼
┌─────────────┐
│  ViewModel  │ ← Business Logic (@Published properties)
└──────┬──────┘
       │ updates
       ▼
┌─────────────┐
│    Model    │ ← Data Models (Codable structs)
└─────────────┘
```

**Key Components:**
- **DiceRollerViewModel**: Main state management
- **ThemeManager**: Theme persistence & application
- **AudioManager**: Sound & haptic feedback
- **ARDiceCoordinator**: AR session & physics

For more details, see [ARCHITECTURE.md](ARCHITECTURE.md)

---

## 🎨 Design Philosophy

DnDice embraces a **dark, elegant aesthetic** inspired by classic tabletop RPGs:

- **PlayfairDisplay** - Serif font for elegance
- **Golden Accents** (#FFD700) - Premium feel
- **Deep Blacks** - Immersive dark mode
- **Smooth Animations** - Polished interactions
- **Accessible Contrast** - Automatic text adaptation

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/AmazingFeature`)
3. **Commit** your changes (`git commit -m 'Add AmazingFeature'`)
4. **Push** to the branch (`git push origin feature/AmazingFeature`)
5. **Open** a Pull Request

### **Development Guidelines**
- Follow MVVM architecture
- Use SwiftUI best practices
- Comment in Portuguese for consistency
- Test on multiple devices
- Keep components modular

---

## 📝 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Three.js** - 3D rendering engine
- **RealityKit & ARKit** - Apple's AR frameworks
- **PlayfairDisplay** - Google Fonts
- **RPG Community** - For inspiration and feedback

---

## 📬 Contact

**Lucas Dal Pra Brascher**

- GitHub: [@DalPra0](https://github.com/DalPra0)
- Email: your.email@example.com

---

<div align="center">

### ⭐ Star this repo if you find it useful!

**Made with ❤️ for the RPG community**

[⬆ Back to top](#-dndice)

</div>

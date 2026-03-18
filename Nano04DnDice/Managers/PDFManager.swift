
import SwiftUI
import PDFKit

/// Gerencia a geração de PDFs profissionais para as fichas de personagens
@MainActor
final class PDFManager {
    static let shared = PDFManager()
    
    private init() {}
    
    /// Gera um PDF e retorna a URL do arquivo temporário
    func generateCharacterPDF(character: PlayerCharacter) -> URL? {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 595.2, height: 841.8)) // A4 Size
        
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(character.name)_Sheet.pdf")
        
        do {
            try pdfRenderer.writePDF(to: url) { context in
                context.beginPage()
                
                // 1. Header (Name, Class, Level)
                drawHeader(character: character)
                
                // 2. Attributes (STR, DEX, etc)
                drawAttributes(character: character)
                
                // 3. Combat Stats (AC, HP, Speed)
                drawCombatStats(character: character)
                
                // 4. Skills & Proficiencies
                drawSkills(character: character)
                
                // 5. Equipment & Notes
                drawNotes(character: character)
                
                // Footer
                drawFooter()
            }
            return url
        } catch {
            print("❌ Error generating PDF: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Drawing Helpers
    
    private func drawHeader(character: PlayerCharacter) {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "PlayfairDisplay-Bold", size: 28) ?? UIFont.boldSystemFont(ofSize: 28),
            .foregroundColor: UIColor.black
        ]
        
        character.name.draw(at: CGPoint(x: 50, y: 50), withAttributes: titleAttributes)
        
        let subTitle = "\(character.race) \(character.characterClass) - Level \(character.level)"
        let subTitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "PlayfairDisplay-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.darkGray
        ]
        subTitle.draw(at: CGPoint(x: 50, y: 85), withAttributes: subTitleAttributes)
        
        // Horizontal line
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 50, y: 110))
        path.addLine(to: CGPoint(x: 545, y: 110))
        path.lineWidth = 2
        UIColor.black.setStroke()
        path.stroke()
    }
    
    private func drawAttributes(character: PlayerCharacter) {
        let attributes = [
            ("STR", character.strength),
            ("DEX", character.dexterity),
            ("CON", character.constitution),
            ("INT", character.intelligence),
            ("WIS", character.wisdom),
            ("CHA", character.charisma)
        ]
        
        var currentX = 50
        for (name, value) in attributes {
            let mod = (value - 10) / 2
            let modStr = mod >= 0 ? "+\(mod)" : "\(mod)"
            
            // Box
            let rect = CGRect(x: currentX, y: 130, width: 75, height: 60)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: 5)
            UIColor.systemGray6.setFill()
            path.fill()
            UIColor.black.setStroke()
            path.lineWidth = 1
            path.stroke()
            
            // Text
            name.draw(at: CGPoint(x: currentX + 25, y: 135), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 10)])
            modStr.draw(at: CGPoint(x: currentX + 22, y: 150), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 22)])
            "(\(value))".draw(at: CGPoint(x: currentX + 30, y: 175), withAttributes: [.font: UIFont.systemFont(ofSize: 8)])
            
            currentX += 82
        }
    }
    
    private func drawCombatStats(character: PlayerCharacter) {
        let stats = [
            ("Armor Class", "\(character.armorClass)"),
            ("Hit Points", "\(character.hitPoints)/\(character.maxHitPoints)"),
            ("Initiative", "\(character.initiative >= 0 ? "+" : "")\(character.initiative)"),
            ("Speed", "\(character.speed)ft")
        ]
        
        var currentY = 210
        for (label, value) in stats {
            label.draw(at: CGPoint(x: 50, y: currentY), withAttributes: [.font: UIFont.systemFont(ofSize: 12)])
            value.draw(at: CGPoint(x: 150, y: currentY), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 12)])
            currentY += 20
        }
    }
    
    private func drawSkills(character: PlayerCharacter) {
        "SKILLS & PROFICIENCIES".draw(at: CGPoint(x: 300, y: 210), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 12)])
        
        let skills = character.proficientSkillsStrings.joined(separator: ", ")
        let rect = CGRect(x: 300, y: 230, width: 245, height: 100)
        skills.draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 10)])
    }
    
    private func drawNotes(character: PlayerCharacter) {
        "EQUIPMENT & BACKSTORY".draw(at: CGPoint(x: 50, y: 350), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        
        let notes = "EQUIPMENT:\n\(character.equippedWeapon), \(character.equippedArmor)\n\nBACKSTORY:\n\(character.backstory)\n\nNOTES:\n\(character.notes)"
        let rect = CGRect(x: 50, y: 375, width: 495, height: 400)
        notes.draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 11)])
    }
    
    private func drawFooter() {
        let footer = "Generated by Dice and Dragons App - Pro Version"
        footer.draw(at: CGPoint(x: 200, y: 810), withAttributes: [
            .font: UIFont.italicSystemFont(ofSize: 8),
            .foregroundColor: UIColor.lightGray
        ])
    }
}

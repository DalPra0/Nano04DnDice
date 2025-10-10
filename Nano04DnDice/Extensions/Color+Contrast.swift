//
//  Color+Contrast.swift
//  Nano04DnDice
//
//  Extension para calcular contraste e adaptar cores de texto
//

import SwiftUI

extension Color {
    /// Calcula a luminância relativa da cor (0.0 = escuro, 1.0 = claro)
    var luminance: Double {
        let components = UIColor(self).cgColor.components ?? [0, 0, 0]
        
        let r = components.count > 0 ? components[0] : 0
        let g = components.count > 1 ? components[1] : 0
        let b = components.count > 2 ? components[2] : 0
        
        // Fórmula de luminância relativa (ITU-R BT.709)
        let rL = r <= 0.03928 ? r / 12.92 : pow((r + 0.055) / 1.055, 2.4)
        let gL = g <= 0.03928 ? g / 12.92 : pow((g + 0.055) / 1.055, 2.4)
        let bL = b <= 0.03928 ? b / 12.92 : pow((b + 0.055) / 1.055, 2.4)
        
        return 0.2126 * rL + 0.7152 * gL + 0.0722 * bL
    }
    
    /// Retorna true se a cor é clara (luminância > 0.5)
    var isLight: Bool {
        luminance > 0.5
    }
    
    /// Retorna a cor de texto ideal para contraste (preto para fundos claros, branco para fundos escuros)
    var contrastText: Color {
        isLight ? .black : .white
    }
    
    /// Retorna a cor de texto com opacidade para contraste
    func contrastText(opacity: Double) -> Color {
        contrastText.opacity(opacity)
    }
    
    /// Retorna uma cor secundária de texto (mais suave) com contraste
    var contrastTextSecondary: Color {
        isLight ? Color.black.opacity(0.7) : Color.white.opacity(0.7)
    }
    
    /// Retorna uma cor terciária de texto (ainda mais suave) com contraste
    var contrastTextTertiary: Color {
        isLight ? Color.black.opacity(0.5) : Color.white.opacity(0.5)
    }
}

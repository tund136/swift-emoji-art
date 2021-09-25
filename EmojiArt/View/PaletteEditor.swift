//
//  PaletteEditor.swift
//  EmojiArt
//
//  Created by Danh Tu on 24/09/2021.
//

import SwiftUI

struct PaletteEditor: View {
    // A Binding cannot be private
    // By definition, other Views have to be able to set this, so do not make these private
    @Binding var palette: Palette
    var body: some View {
        Form {
            TextField("Name", text: $palette.name)
        }
        .frame(minWidth: 300, minHeight: 350)
    }
}

struct PaletteEditor_Previews: PreviewProvider {
    static var previews: some View {
        PaletteEditor(palette: .constant(PaletteStore(named: "Preview").palette(at: 1)))
            .previewLayout(.fixed(width: 300, height: 350))
    }
}

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

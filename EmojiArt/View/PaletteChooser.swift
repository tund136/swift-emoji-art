//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by Danh Tu on 24/09/2021.
//

import SwiftUI

struct PaletteChooser: View {
    var emojiFontSize: CGFloat = 40
    var emojiFont: Font { .system(size: emojiFontSize) }
    
    @EnvironmentObject var store: PaletteStore
    
    @State private var chosenPaletteIndex = 0
    
    var body: some View {
        let palette = store.palette(at: chosenPaletteIndex)
        
        HStack {
            paletteControlButton
            body(for: palette)
        }
        
    }
    
    var paletteControlButton: some View {
        Button {
            chosenPaletteIndex = (chosenPaletteIndex + 1) % store.palettes.count
        } label: {
            Image(systemName: "paintpalette")
        }
        .font(emojiFont)
    }
    
    func body(for palette: Palette) -> some View {
        HStack {
            Text(palette.name)
            ScrollingEmojisView(emojis: palette.emojis)
                .font(emojiFont)
        }
    }
}

struct ScrollingEmojisView: View {
    let emojis: String
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis.map { String($0) }, id: \.self) { emoji in
                    Text(emoji)
                        .onDrag {
                            NSItemProvider(object: emoji as NSString)
                        }
                }
            }
        }
    }
}


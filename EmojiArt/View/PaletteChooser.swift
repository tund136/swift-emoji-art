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
    
    var body: some View {
        ScrollingEmojisView(emojis: testEmojis)
            .font(emojiFont)
    }
    
    let testEmojis = "🐼🚣☘️⛷✈️🥋🐹🦋🛵🚐🚜🚑🏎🎱🪀🥅🪃🛷🇦🇹📞🎛📠💿🖲🖤🍈🍌🍎🍅🥭🍑🫒🥔🌽🧅"
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


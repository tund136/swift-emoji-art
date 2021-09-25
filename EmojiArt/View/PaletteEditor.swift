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
            nameSection
            addEmojisSection
            removeEmojiSection
        }
        .frame(minWidth: 300, minHeight: 350)
    }
    
    var nameSection: some View {
        Section(header: Text("Name")) {
            TextField("Name", text: $palette.name)
        }
    }
    
    @State private var emojisToAdd = ""
    
    var addEmojisSection: some View {
        Section(header: Text("Add Emojis")) {
            TextField("", text: $emojisToAdd)
                .onChange(of: emojisToAdd) { emojis in
                    addEmojis(emojis)
                }
        }
    }
    
    func addEmojis(_ emojis: String) {
        withAnimation {
            palette.emojis = (emojis + palette.emojis)
                .filter { $0.isEmoji }
        }
    }
    
    var removeEmojiSection: some View {
        Section(header: Text("Remove Emoji")) {
            let emojis = palette.emojis.map { String($0)}
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                        .onTapGesture {
                            withAnimation {
                                palette.emojis.removeAll(where: { String($0) == emoji})
                            }
                        }
                }
            }
        }
    }
}

struct PaletteEditor_Previews: PreviewProvider {
    static var previews: some View {
        PaletteEditor(palette: .constant(PaletteStore(named: "Preview").palette(at: 1)))
            .previewLayout(.fixed(width: 300, height: 350))
    }
}

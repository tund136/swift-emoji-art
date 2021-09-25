//
//  PaletteManager.swift
//  EmojiArt
//
//  Created by Danh Tu on 25/09/2021.
//

import SwiftUI

struct PaletteManager: View {
    @EnvironmentObject var store: PaletteStore
    @Environment(\.colorScheme) var colorScheme
    
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        // A NavigationView and a NavigationLink go together
        NavigationView {
            List {
                ForEach(store.palettes) { palette in
                    NavigationLink(destination: PaletteEditor(palette: $store.palettes[palette])) {
                        VStack(alignment: .leading) {
                            Text(palette.name)
                                .font(editMode == .active ? .largeTitle : .caption)
                            Text(palette.emojis)
                        }
                    }
                }
            }
            .navigationTitle("Manage Palettes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                EditButton()
            }
            .environment(\.editMode, $editMode)
        }
    }
}

struct PaletteManager_Previews: PreviewProvider {
    static var previews: some View {
        PaletteManager()
            .environmentObject(PaletteStore(named: "Preview"))
    }
}

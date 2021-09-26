//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Danh Tu on 22/09/2021.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    @StateObject var document = EmojiArtDocument()
    @StateObject var paletteStore = PaletteStore(named: "Default")
    
    // Which is some Scene, not some View
    // A Scene is just a high-level container
    // that contains the top-level View of your application
    
    // On the iPhone, only have on top-level Scene
    // In iPad, not even realize what's going on there with Scenes.
    var body: some Scene {
        DocumentGroup(newDocument: { EmojiArtDocument() }) { config in
            EmojiArtDocumentView(document: config.document)
                .environmentObject(paletteStore)
        }
    }
}

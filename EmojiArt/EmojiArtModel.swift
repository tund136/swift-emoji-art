//
//  EmojiArtModel.swift
//  EmojiArt
//
//  Created by Danh Tu on 22/09/2021.
//

import Foundation

struct EmojiArtModel {
    var background = Background.blank
    var emojis = [Emoji]()
    
    struct Emoji: Identifiable {
        let id: Int
        let text: String
        var x: Int
        var y: Int
        var size: Int
        
        // fileprivate means anyone in this file can use this, but no one else
        fileprivate init(id: Int, text: String, x: Int, y: Int, size: Int) {
            self.id = id
            self.text = text
            self.x = x
            self.y = y
            self.size = size
        }
    }
    
    init() { 
        
    }
    
    private var uniqueEmojiId = 0
    mutating func addEmoji(_ text: String, at location: (x: Int, y: Int), size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(id: uniqueEmojiId, text: text, x: location.x, y: location.y, size: size))
    }
}

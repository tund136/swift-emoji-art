//
//  PaletteStore.swift
//  EmojiArt
//
//  Created by Danh Tu on 24/09/2021.
//

import SwiftUI

struct Palette: Identifiable {
    var id: Int
    var name: String
    var emojis: String
    
    fileprivate init(id: Int, name: String, emojis: String) {
        self.id = id
        self.name = name
        self.emojis = emojis
    }
}

class PaletteStore: ObservableObject {
    let name: String
    
    @Published var palettes = [Palette]() {
        didSet {
            storeInUserDefaults()
        }
    }
    
    private var userDefaultsKey: String {
        "PaletteStore: " + name
    }
    
    private func storeInUserDefaults() {
        UserDefaults.standard.set(palettes.map { [String($0.id), $0.name, $0.emojis] }, forKey: userDefaultsKey)
    }
    
    private func restoreFromUserDefaults() {
        if let palettesAsPropertyList = UserDefaults.standard.array(forKey: userDefaultsKey) as? [[String]] {
            for paletteAsArray in palettesAsPropertyList {
                if paletteAsArray.count == 3, let id = Int(paletteAsArray[0]), !palettes.contains(where: { $0.id == id }) {
                    let palette = Palette(id: id, name: paletteAsArray[1], emojis: paletteAsArray[2])
                    palettes.append(palette)
                }
            }
        }
    }
    
    init(named name: String) {
        self.name = name
        restoreFromUserDefaults()
        if palettes.isEmpty {
            print("Using built-in palettes")
            insertPalette(named: "Vehicles", emojis: "🚗🚙🚕🚌🚎🏎🚓🚑🚒🚐🛻🚚🚛🚜🛴🚲🛵🏍🛺🚍🚘🚖🚔✈️🚢🚤🛥")
            insertPalette(named: "Sports", emojis: "⚽️🏀🏈⚾️🥎🎾🏐🏉🥏🎱🪀🏸🏒🏑🥍🏏🪃🥅⛳️🪁🏹🎣🤿🥊🥋🛹🛼🛷⛸🥌🎿⛷🏂🪂")
            insertPalette(named: "Animals", emojis: "🐶🐱🐭🐹🐰🦊🐻🐼🐻‍❄️🐨🐯🦁🐮🐷🐽🐵🙈🙉🙊🐒🐔🐧🐦🐤🐣🐥🦆🦅🦉🦇🐺🐗🐴🦄🐝")
        } else {
            print("Successfully loaded palettes from UserDefaults: \(palettes)")
        }
    }
    
    // MARK: -Intent(s)
    
    func palette(at index: Int) -> Palette {
        let safeIndex = min(max(index, 0), palettes.count - 1)
        return palettes[safeIndex]
    }
    
    @discardableResult // Ignore return values
    func removePalette(at index: Int) -> Int {
        if palettes.count > 1, palettes.indices.contains(index) {
            palettes.remove(at: index)
        }
        
        return index % palettes.count
    }
    
    func insertPalette(named name: String, emojis: String? = nil, at index: Int = 0) {
        let unique = (palettes.max(by: { $0.id < $1.id })?.id ?? 0) + 1
        let palette = Palette(id: unique, name: name, emojis: emojis ?? "")
        let safeIndex = min(max(index, 0), palettes.count)
        palettes.insert(palette, at: safeIndex)
    }
}

//
//  PaletteStore.swift
//  EmojiArt
//
//  Created by Danh Tu on 24/09/2021.
//

import SwiftUI

struct Palette: Identifiable, Codable, Hashable {
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
        //        UserDefaults.standard.set(palettes.map { [String($0.id), $0.name, $0.emojis] }, forKey: userDefaultsKey)
        UserDefaults.standard.set(try? JSONEncoder().encode(palettes), forKey: userDefaultsKey)
    }
    
    private func restoreFromUserDefaults() {
        //        if let palettesAsPropertyList = UserDefaults.standard.array(forKey: userDefaultsKey) as? [[String]] {
        //            for paletteAsArray in palettesAsPropertyList {
        //                if paletteAsArray.count == 3, let id = Int(paletteAsArray[0]), !palettes.contains(where: { $0.id == id }) {
        //                    let palette = Palette(id: id, name: paletteAsArray[1], emojis: paletteAsArray[2])
        //                    palettes.append(palette)
        //                }
        //            }
        //        }
        if let jsonData = UserDefaults.standard.data(forKey: userDefaultsKey),let decodePalettes = try? JSONDecoder().decode(Array<Palette>.self, from: jsonData) {
            palettes = decodePalettes
        }
    }
    
    init(named name: String) {
        self.name = name
        restoreFromUserDefaults()
        if palettes.isEmpty {
            print("Using built-in palettes")
            insertPalette(named: "Vehicles", emojis: "πππππππππππ»ππππ΄π²π΅ππΊππππβοΈπ’π€π₯")
            insertPalette(named: "Sports", emojis: "β½οΈππβΎοΈπ₯πΎπππ₯π±πͺπΈπππ₯ππͺπ₯β³οΈπͺπΉπ£π€Ώπ₯π₯πΉπΌπ·βΈπ₯πΏβ·ππͺ")
            insertPalette(named: "Animals", emojis: "πΆπ±π­πΉπ°π¦π»πΌπ»ββοΈπ¨π―π¦π?π·π½π΅ππππππ§π¦π€π£π₯π¦π¦π¦π¦πΊππ΄π¦π")
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

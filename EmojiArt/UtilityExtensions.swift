//
//  UtilityExtensions.swift
//  EmojiArt
//
//  Created by Danh Tu on 22/09/2021.
//

import SwiftUI

// In a Collection of Identifiables
// We often might want to find the element that has the same id
// as an Identifiable we already have in hand
// We name this index(matching:) instead of firstIndex(matching:)
// because we assume that someone creating a Collection of Identifiable
// is usually going to have only one of each Identifiable thing in there
// (though there's nothing to restrict them from doing so; it's just a naming choice)

extension Collection where Element: Identifiable {
    func index(matching element: Element) -> Self.Index? {
        firstIndex(where: { $0.id == element.id})
    }
}

//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Danh Tu on 22/09/2021.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    // private(set) should be good enough here.
    // People can access the emojis and look at the background
    @Published private(set) var emojiArt: EmojiArtModel {
        didSet {
            if emojiArt.background != oldValue.background {
                fetchBackgroundImageDataIfNecessary()
            }
        }
    }
    
    private func save(to url: URL) {
        let thisFunction = "\(String(describing: self)).\(#function)"
        do {
            let data: Data = try emojiArt.json()
            print("\(thisFunction) json = \(String(data: data, encoding: .utf8) ?? "nil")")
            try data.write(to: url)
            print("\(thisFunction) success!")
        } catch let encodingError where encodingError is EncodingError {
            print("\(thisFunction) couldn't encode EmojiArt as JSON because \(encodingError.localizedDescription)")
        } catch {
            print("\(thisFunction) error = \(error)")
        }
    }
    
    init() {
        emojiArt = EmojiArtModel()
        //        emojiArt.addEmoji("🍅", at: (-200, -100), size: 80)
        //        emojiArt.addEmoji("🥰", at: (50, 100), size: 40)
    }
    
    var emojis: [EmojiArtModel.Emoji] { emojiArt.emojis }
    var background: EmojiArtModel.Background { emojiArt.background }
    
    @Published var backgroundImage: UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    
    enum BackgroundImageFetchStatus {
        case idle
        case fetching
    }
    
    private func fetchBackgroundImageDataIfNecessary() {
        backgroundImage = nil
        switch emojiArt.background {
        case .url(let url):
            // fetch the url
            backgroundImageFetchStatus = .fetching
            // This took a very long time
            // Something that for it to download
            // and meanwhile, our app was completely forzen. We couldn't try another one. We can't do anything.
            // The reason it was stuck is because this Data(contentOf:)
            
            // How are we going to make this thing multithreaded?
            // Use the quality of service: userInitiated because the user did initiate this download.
            DispatchQueue.global(qos: .userInitiated).async {
                let imageData = try? Data(contentsOf: url) // There is a way to ignore the error
                
                DispatchQueue.main.async { [weak self] in
                    if self?.emojiArt.background == EmojiArtModel.Background.url(url) {
                        self?.backgroundImageFetchStatus = .idle
                        if imageData != nil {
                            // A purple error
                            // This is changing the UI
                            // And we never change the UI from a background thread.
                            // This can only happen on the main thread.
                            // This is a super important thing to understand.
                            self?.backgroundImage = UIImage(data: imageData!) // Which we can force unwrap because I just checked to make sure it's not nil right there.
                            // What about this self?
                            // The reason for this is this is a closure
                            // and it's a closure that's going to be put in memory
                            // and held onto until this thing finishes running
                        }
                    }
                }
            }
            
        case .imageData(let data):
            backgroundImage = UIImage(data: data)
        case .blank:
            break
        }
    }
    
    // MARK: - Intent(s)
    
    func setBackground(_ background: EmojiArtModel.Background) {
        emojiArt.background = background
        print("background set to \(background)")
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat) {
        emojiArt.addEmoji(emoji, at: location, size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
        }
    }
}

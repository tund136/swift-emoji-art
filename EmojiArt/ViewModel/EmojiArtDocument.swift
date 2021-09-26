//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Danh Tu on 22/09/2021.
//

import SwiftUI
import Combine
import UniformTypeIdentifiers

extension UTType {
    static let emojiart = UTType(exportedAs: "com.tund.EmojiArt")
}

// ReferenceFileDocument
// It inherits the ObservableObject protocol.
class EmojiArtDocument: ReferenceFileDocument {
    
    static var readableContentTypes = [UTType.emojiart]
    static var writableContentTypes = [UTType.emojiart]
    
    required init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            emojiArt = try EmojiArtModel(json: data)
            fetchBackgroundImageDataIfNecessary()
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    func snapshot(contentType: UTType) throws -> Data {
        try emojiArt.json()
    }
    
    func fileWrapper(snapshot: Data, configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: snapshot)
    }
    
    // private(set) should be good enough here.
    // People can access the emojis and look at the background
    @Published private(set) var emojiArt: EmojiArtModel {
        didSet {
            if emojiArt.background != oldValue.background {
                fetchBackgroundImageDataIfNecessary()
            }
        }
    }
    
    init() {
        emojiArt = EmojiArtModel()
    }
    
    var emojis: [EmojiArtModel.Emoji] { emojiArt.emojis }
    var background: EmojiArtModel.Background { emojiArt.background }
    
    @Published var backgroundImage: UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    
    enum BackgroundImageFetchStatus: Equatable {
        case idle
        case fetching
        case failed(URL)
    }
    
    private var backgroundImageFetchCancellable: AnyCancellable?
    
    private func fetchBackgroundImageDataIfNecessary() {
        backgroundImage = nil
        switch emojiArt.background {
        case .url(let url):
            // fetch the url
            backgroundImageFetchStatus = .fetching
            backgroundImageFetchCancellable?.cancel()
            let session = URLSession.shared
            let publisher = session.dataTaskPublisher(for: url)
                .map { (data, urlResponse) in UIImage(data: data) }
                .replaceError(with: nil)
                .receive(on: DispatchQueue.main)
            
            backgroundImageFetchCancellable = publisher
            //                .assign(to: \EmojiArtDocument.backgroundImage, on: self)
                .sink { [weak self] image in
                    self?.backgroundImage = image
                    self?.backgroundImageFetchStatus = (image != nil) ? .idle : .failed(url)
                }
            
            // This took a very long time
            // Something that for it to download
            // and meanwhile, our app was completely forzen. We couldn't try another one. We can't do anything.
            // The reason it was stuck is because this Data(contentOf:)
            
            // How are we going to make this thing multithreaded?
            // Use the quality of service: userInitiated because the user did initiate this download.
            
            //            DispatchQueue.global(qos: .userInitiated).async {
            //                let imageData = try? Data(contentsOf: url) // There is a way to ignore the error
            //
            //                DispatchQueue.main.async { [weak self] in
            //                    if self?.emojiArt.background == EmojiArtModel.Background.url(url) {
            //                        self?.backgroundImageFetchStatus = .idle
            //                        if imageData != nil {
            //                            // A purple error
            //                            // This is changing the UI
            //                            // And we never change the UI from a background thread.
            //                            // This can only happen on the main thread.
            //                            // This is a super important thing to understand.
            //                            self?.backgroundImage = UIImage(data: imageData!) // Which we can force unwrap because I just checked to make sure it's not nil right there.
            //                            // What about this self?
            //                            // The reason for this is this is a closure
            //                            // and it's a closure that's going to be put in memory
            //                            // and held onto until this thing finishes running
            //                        }
            //                        if self?.backgroundImage == nil {
            //                            self?.backgroundImageFetchStatus = .failed(url)
            //                        }
            //                    }
            //                }
            //            }
            
        case .imageData(let data):
            backgroundImage = UIImage(data: data)
        case .blank:
            break
        }
    }
    
    // MARK: - Intent(s)
    
    func setBackground(_ background: EmojiArtModel.Background, undoManager: UndoManager?) {
        undoablyPerform(operation: "Set Background", with: undoManager) {
            emojiArt.background = background
            print("background set to \(background)")
        }
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat, undoManager: UndoManager?) {
        undoablyPerform(operation: "Add \(emoji)", with: undoManager) {
            emojiArt.addEmoji(emoji, at: location, size: Int(size))
        }
    }
    
    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize, undoManager: UndoManager?) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            undoablyPerform(operation: "Move", with: undoManager) {
                emojiArt.emojis[index].x += Int(offset.width)
                emojiArt.emojis[index].y += Int(offset.height)
            }
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat, undoManager: UndoManager?) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            undoablyPerform(operation: "Scale", with: undoManager) {
                emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
            }
        }
    }
    
    // MARK: - Undo
    private func undoablyPerform(operation: String, with undoManager: UndoManager? = nil, doit: () -> Void) {
        let oldEmojiArt = emojiArt
        doit()
        undoManager?.registerUndo(withTarget: self) { myself in
            myself.undoablyPerform(operation: operation, with: undoManager) {
                myself.emojiArt =  oldEmojiArt
            }
        }
        undoManager?.setActionName(operation)
    }
}

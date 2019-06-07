//
//  ModeratorManager.swift
//  Infinite
//
//  Created by Kenneth Cluff on 6/5/19.
//  Copyright © 2019 Kenneth Cluff. All rights reserved.
//

import UIKit

typealias LoadCompletionHandler = (Error?, [Moderator]?) -> Void

enum LoadError: Error {
    case badURL
    case initialSerializeFailure
    case deserializeFailure
}

enum AppState {
    case startingUp
    case loadFinished
    case loadingImage
}

let photosDoneNotificationName = Notification.Name("didGetPhotos")

protocol PhotoSearchHandler {
    func handleFoundImage(_ image: UIImage, at recordIndex: Int)
    func finished()
}

protocol UIOutlet {
    func updateUI(with state: AppState)
}

class ModeratorManager {
    static let shared = ModeratorManager()
    
    private let queue = OperationQueue()
    private var uiDelegate: UIOutlet?
    private var moderatorList = [Moderator]()
    
    func start(with delegate: UIOutlet?) {
        uiDelegate = delegate
        queue.maxConcurrentOperationCount = 5
        
        uiDelegate?.updateUI(with: .startingUp)
        ModeratorManager.loadFromFile { (error, results) in
            if let error = error {
                print("There was an error loading moderators: \(error.localizedDescription)")
            } else if let moderators = results {
                moderatorList = moderators
            }
            uiDelegate?.updateUI(with: .loadFinished)
        }
    }
    
    func getNumberOfModerators() -> Int {
        return moderatorList.count
    }
    
    func getModeratorAt(index: Int) -> Moderator? {
        guard index >= 0,
            index < moderatorList.count else { return nil }
        return moderatorList[index]
    }
    
    func getModerator(with id: Int) -> Moderator? {
        guard let foundModerator = moderatorList.first(where: { $0.userID == id }) else { return nil }
        return foundModerator
    }
    
    private static func loadFromFile(with handler: LoadCompletionHandler) {
        guard let testFileURL = Bundle.main.url(forResource: "TestFile", withExtension: nil) else {
            handler( LoadError.badURL, [])
            return }
        let decoder = JSONDecoder()
        
        do {
            let testString = try String(contentsOf: testFileURL)
            guard let jsonData = testString.data(using: .utf8),
                let json = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) as? [String: Any] else {
                    handler(LoadError.initialSerializeFailure, [])
                    return }
            guard let arrayOfModerators = json["items"] as? [[String: Any]],
                let moderatorData = try? JSONSerialization.data(withJSONObject: arrayOfModerators, options: []) else {
                    handler(LoadError.deserializeFailure, [])
                    return }
            
            let moderators = try decoder.decode([Moderator].self, from: moderatorData)
            
            moderators.forEach({
                let newPhotoOP = PhotoLookupOperation($0.profileImageLink, with: $0.userID, and: ModeratorManager.shared)
                ModeratorManager.shared.queue.addOperation(newPhotoOP)
            })
            
            let finishOp = PhotoLookupOperationFinished(with: ModeratorManager.shared)
            ModeratorManager.shared.queue.addOperation(finishOp)
            
            handler(nil, moderators)
        } catch {
            handler(error, [])
        }
    }
}

extension ModeratorManager: PhotoSearchHandler {
    func handleFoundImage(_ image: UIImage, at recordIndex: Int) {
        guard let index = moderatorList.firstIndex(where: { $0.userID == recordIndex }) else { return }
        var updatedModerator = moderatorList[index]
        updatedModerator.userImage = image
        moderatorList[index] = updatedModerator
    }
    
    func finished() {
        NotificationCenter.default.post(name: photosDoneNotificationName, object: nil)
    }
}

class PhotoLookupOperationFinished: Operation {
    let delegate: PhotoSearchHandler?
    
    init(with aDelegate: PhotoSearchHandler?) {
        delegate = aDelegate
    }
    
    override func main() {
        delegate?.finished()
    }
}

class PhotoLookupOperation: Operation {
    let userID: Int
    let photoURL: String
    let photoDelegate: PhotoSearchHandler?
    
    init(_ photoURLString: String, with moderatorUserID: Int, and delegate: PhotoSearchHandler?) {
        userID = moderatorUserID
        photoURL = photoURLString
        photoDelegate = delegate
    }
    
    override func main() {
        guard let url = URL(string: photoURL),
            let imageData = try? Data(contentsOf: url),
            let newImage = UIImage(data: imageData) else { return }
        
        photoDelegate?.handleFoundImage(newImage, at: userID)
    }
}

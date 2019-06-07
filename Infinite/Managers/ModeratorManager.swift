//
//  ModeratorManager.swift
//  Infinite
//
//  Created by Kenneth Cluff on 6/5/19.
//  Copyright © 2019 Kenneth Cluff. All rights reserved.
//

import UIKit

class ModeratorManager {
    static let shared = ModeratorManager()
    
    private let queue = OperationQueue()
    private var uiDelegate: UIOutlet?
    private var moderatorList = [Moderator]()
    
    func start(with delegate: UIOutlet?) {
        uiDelegate = delegate
        queue.maxConcurrentOperationCount = 5
        
        uiDelegate?.updateUI(with: .startingUp)
        loadFromFile { (error, results) in
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
}

fileprivate extension ModeratorManager {
    func loadFromFile(with handler: LoadCompletionHandler) {
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
                let newPhotoOP = PhotoLookupOperation($0.profileImageLink, with: $0.userID, and: self)
                queue.addOperation(newPhotoOP)
            })
            
            let finishOp = PhotoLookupOperationFinished(with: self)
            queue.addOperation(finishOp)
            
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

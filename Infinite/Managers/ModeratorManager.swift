//
//  ModeratorManager.swift
//  Infinite
//
//  Created by Kenneth Cluff on 6/5/19.
//  Copyright © 2019 Kenneth Cluff. All rights reserved.
//

import Foundation

typealias LoadCompletionHandler = (Error?, [Moderator]?) -> Void

enum LoadError: Error {
    case badURL
    case initialSerializeFailure
    case deserializeFailure
}

class ModeratorManager {
    static let shared = ModeratorManager()
    
    private var moderatorList = [Moderator]()
    
    init() {
        ModeratorManager.loadFromFile { (error, results) in
            if let error = error {
                print("There was an error loading moderators: \(error.localizedDescription)")
            } else if let moderators = results {
                moderatorList = moderators
            }
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
            handler(nil, moderators)
        } catch {
            handler(error, [])
        }
    }
}

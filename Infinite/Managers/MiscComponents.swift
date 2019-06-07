//
//  MiscComponents.swift
//  Infinite
//
//  Created by Kenneth Cluff on 6/7/19.
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

enum NewFrameRelativeLocation {
    case above
    case below
    case same
}


let photosDoneNotificationName = Notification.Name("didGetPhotos")

protocol PhotoSearchHandler {
    func handleFoundImage(_ image: UIImage, at recordIndex: Int)
    func finished()
}

protocol UIOutlet {
    func updateUI(with state: AppState)
}

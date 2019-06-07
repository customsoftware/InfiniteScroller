//
//  Operations.swift
//  Infinite
//
//  Created by Kenneth Cluff on 6/7/19.
//  Copyright © 2019 Kenneth Cluff. All rights reserved.
//

import UIKit

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

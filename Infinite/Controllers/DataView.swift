//
//  DataView.swift
//  Infinite
//
//  Created by Kenneth Cluff on 6/6/19.
//  Copyright © 2019 Kenneth Cluff. All rights reserved.
//

import UIKit

protocol ShowLink: UIViewController {
    func display(link: URL)
}

class DataView: UIView {
    
    @IBOutlet weak var indexer: UILabel!
    @IBOutlet weak var moderatorName: UILabel!
    @IBOutlet weak var moderatorImage: UIImageView!
    
    @IBAction func goToBlog(_ sender: UIButton) {
        guard let ownerLink = owningModerator?.link,
            let ownerURL = URL(string: ownerLink) else { return }
        
        delegate?.display(link: ownerURL)
    }
    
    weak var delegate: ShowLink?
    
    var owningModerator: Moderator? {
        didSet {
            guard let owner = owningModerator else { return }
            moderatorName.text = owner.displayName
        }
    }
}

//
//  ViewController.swift
//  Infinite
//
//  Created by Kenneth Cluff on 6/5/19.
//  Copyright © 2019 Kenneth Cluff. All rights reserved.
//
// This will scroll vertically, but the principle is the same as horizontal... we just do delta-y instead of delta-x

import UIKit

class ViewController: UIViewController {

    private let webSegue = "pushToLink"
    
    @IBOutlet private weak var scroller: InfiniteScroller!
    
    override func loadView() {
        super.loadView()
        ModeratorManager.shared.start(with: self)
        scroller.passThroughDelegate = self
        scroller.configureView(in: view)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scroller.contentOffset = CGPoint(x: 0, y: scroller.contentSize.height/2)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateNotification), name: photosDoneNotificationName, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueID = segue.identifier else { return }
        if segueID == webSegue {
            let destinationVC = segue.destination as! WebViewController
            destinationVC.webURL = sender as? URL
        }
    }
    
    @objc func handleUpdateNotification() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.scroller.refreshArt()
        }
    }
}

extension ViewController: UIOutlet {
    func updateUI(with state: AppState) {
        DispatchQueue.main.async {
            switch state {
            case .loadFinished:()
            case .startingUp, .loadingImage:
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
        }
    }
}

extension ViewController: ShowLink {
    func display(link: URL) {
        self.performSegue(withIdentifier: self.webSegue, sender: link)
    }
}

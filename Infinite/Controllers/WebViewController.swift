//
//  WebViewController.swift
//  Infinite
//
//  Created by Kenneth Cluff on 6/6/19.
//  Copyright © 2019 Kenneth Cluff. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    var webURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.browseLink()
    }
    
    private func browseLink() {
        guard let link = webURL  else { return }
        
        let request = URLRequest(url: link)
        webView.load(request)
    }
}

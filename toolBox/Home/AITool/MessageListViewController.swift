//
//  MessageListViewController.swift
//  toolBox
//
//  Created by wang on 2025/3/26.
//  Copyright © 2025 ToolBox. All rights reserved.
//

import UIKit

class MessageListViewController: UIViewController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "MessageListViewController", bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backAction(_ sender: Any) {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        }
    }


}

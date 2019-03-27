//
//  ViewController.swift
//  MediumMenu-Sample
//
//  Created by pixyzehn on 2/8/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let item = UIBarButtonItem(
            image: UIImage(named: "medium_icon"),
            style: .plain, target: navigationController,
            action: #selector(NavigationController.showMenu)
        )
        item.imageInsets = UIEdgeInsets.init(top: -10, left: 0, bottom: 0, right: 0)
        item.tintColor = UIColor.black
        navigationItem.leftBarButtonItem = item
    } 
}

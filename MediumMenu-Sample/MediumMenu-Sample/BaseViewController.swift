//
//  ViewController.swift
//  MediumMenu-Sample
//
//  Created by pixyzehn on 2/8/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let icon = UIBarButtonItem(image: UIImage(named: "medium_icon"), style: .Plain, target: navigationController, action: #selector(NavigationController.showMenu))
        icon.imageInsets = UIEdgeInsetsMake(-10, 0, 0, 0)
        icon.tintColor = UIColor.blackColor()
        navigationItem.leftBarButtonItem = icon
    } 
}

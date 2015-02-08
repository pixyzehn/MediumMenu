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
        
        var icon: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "medium_icon"), style: UIBarButtonItemStyle.Plain, target: navigationController, action: "showMenu")
        icon.imageInsets = UIEdgeInsetsMake(-10, 0, 0, 0)
        icon.tintColor = UIColor.blackColor()
        navigationItem.leftBarButtonItem = icon
    }
}


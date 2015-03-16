//
//  MediumMenuItem.swift
//  MediumMenu-Sample
//
//  Created by pixyzehn on 3/16/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

import UIKit

class MediumMenuItem: NSObject {
    var title: String?
    var completion: completionHandler?
    private var menuButton: UIButton?
    
    override init() {
        super.init()
    }
    
    convenience init(menuItemWithTitle title: String, withCompletionHandler completion: completionHandler) {
        self.init()
        self.title = title
        self.completion = completion
    }
}


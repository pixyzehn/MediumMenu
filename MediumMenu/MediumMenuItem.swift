//
//  MediumMenuItem.swift
//  MediumMenu-Sample
//
//  Created by pixyzehn on 3/16/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

import UIKit

open class MediumMenuItem {
    open var title: String?
    open var image: UIImage?
    open var completion: (() -> Void)?

    init() {}
    
    public convenience init(title: String, image:UIImage? = nil, completion: (() -> Void)? = nil) {
        self.init()
        self.title = title
        self.image = image
        self.completion = completion
    }
}

//
//  MediumMenuItem.swift
//  MediumMenu-Sample
//
//  Created by pixyzehn on 3/16/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

import UIKit

public class MediumMenuItem: NSObject {
    public var title: String?
    public var completion: completionHandler?

    override private init() {
        super.init()
    }
    
    public convenience init(title: String, completion: completionHandler) {
        self.init()
        self.title = title
        self.completion = completion
    }
}

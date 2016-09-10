//
//  MediumMenuItem.swift
//  MediumMenu-Sample
//
//  Created by pixyzehn on 3/16/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

import UIKit

public class MediumMenuItem {
    public var title: String?
    public var image: UIImage?
    public var completion: CompletionHandler?

    init() {}
    
    public convenience init(title: String, image:UIImage? = nil, completion: CompletionHandler? = nil) {
        self.init()
        self.title = title
        self.image = image
        self.completion = completion
    }
}

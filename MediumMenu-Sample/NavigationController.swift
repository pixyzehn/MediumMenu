//
//  NavigationController.swift
//  MediumMenu
//
//  Created by pixyzehn on 2/3/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

import UIKit
import MediumMenu

class NavigationController: UINavigationController {
   
    var menu: MediumMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = .lightContent

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController = storyboard.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        setViewControllers([homeViewController], animated: false)

        let item1 = MediumMenuItem(title: "Home") {
            let homeViewController = storyboard.instantiateViewController(withIdentifier: "Home") as! HomeViewController
            self.setViewControllers([homeViewController], animated: false)
        }
        
        let item2 = MediumMenuItem(title: "Top stories") {
            let topStoriesViewController = storyboard.instantiateViewController(withIdentifier: "Top") as! TopStoriesViewController
            self.setViewControllers([topStoriesViewController], animated: false)
        }
        
        let item3 = MediumMenuItem(title: "Bookmarks") {
            let bookMarksViewController = storyboard.instantiateViewController(withIdentifier: "Bookmarks") as! BookmarksViewController
            self.setViewControllers([bookMarksViewController], animated: false)
        }

        let item4 = MediumMenuItem(title: "Help") {
            let helpViewController = storyboard.instantiateViewController(withIdentifier: "Help") as! HelpViewController
            self.setViewControllers([helpViewController], animated: false)
        }
        
        let item5 = MediumMenuItem(title: "Sign out") {
            let signoutViewController = storyboard.instantiateViewController(withIdentifier: "Signout") as! SignoutViewController
            self.setViewControllers([signoutViewController], animated: false)
        }

        menu = MediumMenu(items: [item1, item2, item3, item4, item5], forViewController: self)
    }
    
    func showMenu() {
        menu?.show()
    }
}

extension UINavigationBar {
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width, height: 60)
    }
}

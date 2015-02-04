//
//  NavigationController.swift
//  MediumMenu
//
//  Created by pixyzehn on 2/3/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
   
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var menu: MediumMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController: HomeViewController = storyboard.instantiateViewControllerWithIdentifier("Home") as HomeViewController
        self.setViewControllers([homeViewController], animated: false)

        let item1: MediumMenuItem = MediumMenuItem(menuItemWithTitle: "Home", withCompletionHandler: {(finished: Bool) -> () in
            let homeViewController: HomeViewController = storyboard.instantiateViewControllerWithIdentifier("Home") as HomeViewController
            self.setViewControllers([homeViewController], animated: false)
        } )
        
        let item2: MediumMenuItem = MediumMenuItem(menuItemWithTitle: "Top stories", withCompletionHandler: {(finished: Bool) -> () in
            let topStoriesViewController: TopStoriesViewController = storyboard.instantiateViewControllerWithIdentifier("Top") as TopStoriesViewController
            self.setViewControllers([topStoriesViewController], animated: false)
        })
        
        let item3: MediumMenuItem = MediumMenuItem(menuItemWithTitle: "Bookmark", withCompletionHandler: {(finished: Bool) -> () in
            let bookMarksViewController: BookmarksViewController = storyboard.instantiateViewControllerWithIdentifier("Bookmark") as BookmarksViewController
            self.setViewControllers([bookMarksViewController], animated: false)
        })

        let item4: MediumMenuItem = MediumMenuItem(menuItemWithTitle: "Help", withCompletionHandler: {(finished: Bool) -> () in
            let helpViewController: HelpViewController = storyboard.instantiateViewControllerWithIdentifier("Help") as HelpViewController
            self.setViewControllers([helpViewController], animated: false)
        })
        
        let item5: MediumMenuItem = MediumMenuItem(menuItemWithTitle: "Sign out", withCompletionHandler: {(finished: Bool) -> () in
            let signoutViewController: SignoutViewController = storyboard.instantiateViewControllerWithIdentifier("Signout") as SignoutViewController
            self.setViewControllers([signoutViewController], animated: false)
        })
        
        menu = MediumMenu(Items: [item1, item2, item3, item4, item5], andTextAllignment: Allignment.Left, forViewController: self)
    }
    
    func showMenu() {
        menu?.showMenu()
    }
}
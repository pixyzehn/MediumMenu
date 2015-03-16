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
    
    var showMediumMenu:() -> () = {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController: HomeViewController = storyboard.instantiateViewControllerWithIdentifier("Home") as HomeViewController
        setViewControllers([homeViewController], animated: false)

        let item1: MediumMenuItem = MediumMenuItem(menuItemWithTitle: "Home", withCompletionHandler: {(finished: Bool) -> () in
            let homeViewController: HomeViewController = storyboard.instantiateViewControllerWithIdentifier("Home") as HomeViewController
            self.setViewControllers([homeViewController], animated: false)
        } )
        
        let item2: MediumMenuItem = MediumMenuItem(menuItemWithTitle: "Top stories", withCompletionHandler: {(finished: Bool) -> () in
            let topStoriesViewController: TopStoriesViewController = storyboard.instantiateViewControllerWithIdentifier("Top") as TopStoriesViewController
            self.setViewControllers([topStoriesViewController], animated: false)
        })
        
        let item3: MediumMenuItem = MediumMenuItem(menuItemWithTitle: "Bookmarks", withCompletionHandler: {(finished: Bool) -> () in
            let bookMarksViewController: BookmarksViewController = storyboard.instantiateViewControllerWithIdentifier("Bookmarks") as BookmarksViewController
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

        let menu = MediumMenu(Items: [item1, item2, item3, item4, item5], andTextAlignment: .Left, forViewController: self)
        showMediumMenu = {
            menu.showMenu()
        }
    }
    
    func showMenu() {
        showMediumMenu()
    }
}

extension UINavigationBar {
    public override func sizeThatFits(size: CGSize) -> CGSize {
        var newsize: CGSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, 60)
        return newsize
    }
}

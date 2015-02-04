//
//  MediumMenu.swift
//  MediumMenu
//
//  Created by pixyzehn on 2/2/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

import UIKit

let CELLIDENTIFIER                      = "menubutton"
let MENU_BOUNCE_OFFSET: CGFloat         = 10
let PANGESTUREENABLE                    = 1// 1 is enable
let VELOCITY_TRESHOLD: CGFloat          = 1000
let AUTOCLOSE_VELOCITY: CGFloat         = 1200
let MENU_ITEM_DEFAULT_FONTNAME          = "HelveticaNeue-Light"
let MENU_ITEM_DEFAULT_FONTSIZE: CGFloat = 25
let STARTINDEX                          = 1

enum State {
    case Shown
    case Closed
    case Displaying
}

enum Allignment {
    case Left
    case Right
    case Center
}

typealias completionHandler = Bool -> ()

/**
*  MediumMenuItem
*/

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

/**
*  MediumMenu
*/

class MediumMenu: UIView, UITableViewDataSource, UITableViewDelegate {
    let CRITERION = UIScreen.mainScreen().bounds.size.height / 2
    var currentMenuState: State?
    var highLighedIndex: Int?
    
    var _height: CGFloat?
    var height: CGFloat? {
        get {
            return _height
        }
        set {
            if _height != newValue {
                var menuFrame: CGRect = self.frame
                menuFrame.size.height = newValue!
                self.menuContentTable?.frame = menuFrame
                _height = newValue
            }
        }
    }
    var textColor: UIColor?
    var highLightTextColor: UIColor?
    var titleFont: UIFont?
    var titleAllignment: Allignment?
    
    var _backgroundColor: UIColor?
    override var backgroundColor: UIColor? {
        get {
            return _backgroundColor
        }
        set {
            if _backgroundColor != newValue {
                _backgroundColor = newValue
                self.menuContentTable?.backgroundColor = newValue
            }
        }
    }
    
    private var menuItems: [MediumMenuItem] = [MediumMenuItem]()
    
    private var _menuContentTable: UITableView?
    private var menuContentTable: UITableView? {
        get {
            return _menuContentTable
        }
        set {
            if _menuContentTable != newValue {
                newValue?.delegate = self
                newValue?.dataSource = self
                newValue?.showsVerticalScrollIndicator = false
                newValue?.separatorColor = UIColor.clearColor()
                newValue?.backgroundColor = UIColor.whiteColor()
                newValue?.allowsMultipleSelection = false
                _menuContentTable = newValue
                self.addSubview(_menuContentTable!)
            }
        }
    }
    
    private var _contentController: UIViewController?
    private var contentController: UIViewController? {
        get {
            return _contentController
        }
        set {
            if _contentController != newValue {
                if  newValue?.navigationController != nil {
                    _contentController = newValue?.navigationController
                } else {
                    _contentController = newValue
                }
                if PANGESTUREENABLE == 1 {
                    let pan: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "didPan:")
                    _contentController?.view.addGestureRecognizer(pan)
                }
                self.setShadowProperties()
                _contentController?.view.autoresizingMask = UIViewAutoresizing.None
                var menuController: UIViewController = UIViewController()
                menuController.view = self
                UIApplication.sharedApplication().delegate?.window??.rootViewController = menuController
                UIApplication.sharedApplication().delegate?.window??.addSubview(_contentController!.view!)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.highLighedIndex = STARTINDEX
        self.currentMenuState = State.Closed
        self.titleFont = UIFont(name: MENU_ITEM_DEFAULT_FONTNAME, size: MENU_ITEM_DEFAULT_FONTSIZE)
        self.height = 400
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
    }
    
    // Initializers

    convenience init(Items menuItems: [MediumMenuItem], andTextAllignment titleAllignment: Allignment, forViewController viewController: UIViewController) {
        
        self.init(Items: menuItems, textColor: UIColor.lightGrayColor(), hightLightTextColor: UIColor.whiteColor(), backGroundColor: UIColor.blackColor(), andTextAllignment: titleAllignment, forViewController: viewController)
    }
    
    convenience init(Items menuItems: [MediumMenuItem], textColor: UIColor, hightLightTextColor: UIColor, backGroundColor: UIColor, andTextAllignment titleAllignment: Allignment, forViewController viewController: UIViewController) {
        self.init()
        self.frame = CGRectMake(0, 0, CGRectGetWidth(UIScreen.mainScreen().bounds), self.height!)
        self.menuContentTable = UITableView(frame: self.frame)
        self.menuItems = menuItems
        self.titleAllignment = titleAllignment
        self.textColor = textColor
        self.highLightTextColor = hightLightTextColor
        self.backgroundColor = backGroundColor
        self.contentController = viewController
    }
    
    func setShadowProperties() {
        _contentController?.view.layer.shadowOffset = CGSizeMake(0, 1)
        _contentController?.view.layer.shadowRadius = 4.0
        _contentController?.view.layer.shadowColor = UIColor.lightGrayColor().CGColor
        _contentController?.view.layer.shadowOpacity = 0.4
        _contentController?.view.layer.shadowPath = UIBezierPath(rect: _contentController!.view.bounds).CGPath
    }
    
    // Menu interactions
    
    func showMenu() {
        if currentMenuState == State.Shown || currentMenuState == State.Displaying {
            self.animateMenuClosingWithCompletion(nil)
        } else {
            currentMenuState = State.Displaying
            self.animateMenuOpening()
        }
    }
    
    func dismissMenu() {
        if currentMenuState == State.Shown || currentMenuState == State.Displaying {
            let frame = contentController?.view.frame
            contentController?.view.frame = CGRectOffset(frame!, 0, -CGFloat(height!) + MENU_BOUNCE_OFFSET)
            currentMenuState = State.Closed
        }
    }
    
    func didPan(pan: UIPanGestureRecognizer) {
        var viewCenter: CGPoint = pan.view!.center
        if pan.state == UIGestureRecognizerState.Began || pan.state == UIGestureRecognizerState.Changed {
            let translation: CGPoint = pan.translationInView(pan.view!.superview!)
            if viewCenter.y >= CRITERION && viewCenter.y <= (CRITERION + height!) - MENU_BOUNCE_OFFSET {
                currentMenuState = State.Displaying
                viewCenter.y = abs(viewCenter.y + translation.y)
                if viewCenter.y >= CRITERION && viewCenter.y <= (CRITERION + height!) - MENU_BOUNCE_OFFSET {
                    contentController?.view.center = viewCenter
                }
                pan.setTranslation(CGPointZero, inView: contentController?.view)
            }
        } else if pan.state == UIGestureRecognizerState.Ended {
            let velocity: CGPoint = pan.velocityInView(contentController?.view.superview)
            if velocity.y > VELOCITY_TRESHOLD {
                self.openMenuFromCenterWithVelocity(velocity.y)
            } else if velocity.y < -VELOCITY_TRESHOLD {
                self.closeMenuFromCenterWithVelocity(abs(velocity.y))
            } else if velocity.y < CRITERION + (height! / 2) {
                self.closeMenuFromCenterWithVelocity(AUTOCLOSE_VELOCITY)
            } else if velocity.y <= CRITERION + height! - MENU_BOUNCE_OFFSET {
                self.openMenuFromCenterWithVelocity(AUTOCLOSE_VELOCITY)
            }
        }
    }
    
    // Animation and menu operations
    
    func animateMenuOpening() {
        if self.currentMenuState != State.Shown {
            UIView.animateWithDuration(0.2, animations: {[unowned self]() -> Void in
                //Pushing the content controller down
                let x = self.contentController!.view.center.x
                self.contentController?.view.center = CGPointMake(x, self.CRITERION + self.height!)
            }, completion: {[unowned self](finished: Bool) -> Void in
                UIView.animateWithDuration(0.2, animations: {[unowned self]() -> Void in
                    let x = self.contentController!.view.center.x
                    self.contentController?.view.center = CGPointMake(x, self.CRITERION + self.height! - MENU_BOUNCE_OFFSET)
                }, completion: {(finished: Bool) -> Void in
                    self.currentMenuState = State.Shown
                })
            })
        }
    }
    
    func animateMenuClosingWithCompletion(completion: completionHandler?) {
        UIView.animateWithDuration(0.2, animations: {[unowned self]() -> Void in
            //Pushing the content controller down
            let center = self.contentController!.view.center
            self.contentController?.view.center = CGPointMake(center.x, center.y + MENU_BOUNCE_OFFSET)
        }, completion: {[unowned self](finished: Bool) -> Void in
                UIView.animateWithDuration(0.2, animations: {[unowned self]() -> Void in
                    //Pushing the content controller down
                    let center = self.contentController!.view.center
                    self.contentController?.view.center = CGPointMake(center.x, self.CRITERION)
                }, completion: {(finished: Bool) -> Void in
                        if finished {
                            self.currentMenuState = State.Closed
                            if completion != nil {
                                completion!(finished)
                            }
                        }
                })
        })
    }
    
    func openMenuFromCenterWithVelocity(velocity: CGFloat) {
        let viewCenterY: CGFloat = CRITERION + height! - MENU_BOUNCE_OFFSET
        self.currentMenuState = State.Displaying
        let duration: NSTimeInterval = Double((viewCenterY - self.contentController!.view.center.y) / velocity)
        UIView.animateWithDuration(duration, animations: {[unowned self]() -> Void in
            //Pushing the content controller down
            let center = self.contentController!.view.center
            self.contentController?.view.center = CGPointMake(center.x, viewCenterY)
        }, completion: {[unowned self](finished: Bool) -> Void in
            self.currentMenuState = State.Shown
        })
    }
    
    func closeMenuFromCenterWithVelocity(velocity: CGFloat) {
        let viewCenterY: CGFloat = CRITERION
        self.currentMenuState = State.Displaying
        let duration: NSTimeInterval = Double((self.contentController!.view.center.y - viewCenterY) / velocity)
        UIView.animateWithDuration(duration, animations: {[unowned self]() -> Void in
            //Pushing the content controller down
            let center = self.contentController!.view.center
            self.contentController?.view.center = CGPointMake(center.x, self.CRITERION)
            }, completion: {[unowned self](finished: Bool) -> Void in
                self.currentMenuState = State.Shown
        })
    }
    
    // UITableViewDelegates

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuItems.count + 2 * STARTINDEX
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var menuCell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(CELLIDENTIFIER) as? UITableViewCell
        var mediumMenuItem: MediumMenuItem?
        
        if menuCell == nil {
            menuCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: CELLIDENTIFIER)
            self.setMenuTitleAlligmentForCell(menuCell!)
            menuCell?.backgroundColor = UIColor.clearColor()
            menuCell?.selectionStyle = UITableViewCellSelectionStyle.None
            menuCell?.textLabel?.textColor = textColor
            menuCell?.textLabel?.font = titleFont
        }
        
        if indexPath.row >= STARTINDEX && indexPath.row <= (self.menuItems.count - 1 + STARTINDEX) {
            mediumMenuItem = self.menuItems[indexPath.row - STARTINDEX]
            menuCell?.textLabel?.text = mediumMenuItem?.title
        }
        
        return menuCell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < STARTINDEX || indexPath.row > self.menuItems.count - 1 + STARTINDEX {
            return
        }
        
        self.highLighedIndex = indexPath.row
        self.menuContentTable?.reloadData()
        let selectedItem: MediumMenuItem = menuItems[indexPath.row - STARTINDEX]
        self.animateMenuClosingWithCompletion(selectedItem.completion)
    }
    
    func setMenuTitleAlligmentForCell(cell: UITableViewCell) {
        if let tAlignment = titleAllignment {
            switch tAlignment {
            case Allignment.Left:
                cell.textLabel?.textAlignment = NSTextAlignment.Left
            case Allignment.Center:
                cell.textLabel?.textAlignment = NSTextAlignment.Center
            case Allignment.Right:
                cell.textLabel?.textAlignment = NSTextAlignment.Right
            default:
                break
            }
        }
    }
}

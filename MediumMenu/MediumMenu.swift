//
//  MediumMenu.swift
//  MediumMenu
//
//  Created by pixyzehn on 2/2/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

import UIKit

let CELL_IDENTIFIER                     = "menucell"
let MENU_BOUNCE_OFFSET: CGFloat         = 0
let PAN_GESTURE_ENABLE                  = 1 // Enable pan gesture (Default is 1)
let VELOCITY_TRESHOLD: CGFloat          = 1000
let AUTOCLOSE_VELOCITY: CGFloat         = 1200
let MENU_ITEM_DEFAULT_FONTNAME          = "HelveticaNeue-Light"
let MENU_ITEM_DEFAULT_FONTSIZE: CGFloat = 28
let STARTINDEX                          = 1
let MENU_HEIGHT: CGFloat                = 466
let MEDIUM_WHITE_COLOR                  = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1)
let MEDIUM_BLACK_COLOR                  = UIColor(red:0.05, green:0.05, blue:0.05, alpha:1)
let MEDIUM_GLAY_COLOR                   = UIColor(red:0.57, green:0.57, blue:0.57, alpha:1)

enum State {
    case Shown
    case Closed
    case Displaying
}

enum Alignment {
    case Left
    case Right
    case Center
}

typealias completionHandler = Bool -> ()

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
                var menuFrame: CGRect = frame
                menuFrame.size.height = newValue!
                menuContentTable?.frame = menuFrame
                _height = newValue
            }
        }
    }
    var textColor: UIColor?
    var highLightTextColor: UIColor?
    var titleFont: UIFont?
    var titleAlignment: Alignment?
    
    var _backgroundColor: UIColor?
    override var backgroundColor: UIColor? {
        get {
            return _backgroundColor
        }
        set {
            if _backgroundColor != newValue {
                _backgroundColor = newValue
                menuContentTable?.backgroundColor = newValue
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
                newValue?.allowsMultipleSelection = false
                _menuContentTable = newValue
                addSubview(_menuContentTable!)
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
                if PAN_GESTURE_ENABLE == 1 {
                    let pan: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "didPan:")
                    _contentController?.view.addGestureRecognizer(pan)
                }
                setShadowProperties()
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
        self.height = MENU_HEIGHT
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
    }
    
    // Initializers

    convenience init(Items menuItems: [MediumMenuItem],
     andTextAlignment titleAlignment: Alignment,
    forViewController viewController: UIViewController) {
        self.init(Items: menuItems,
              textColor: MEDIUM_GLAY_COLOR,
    hightLightTextColor: MEDIUM_WHITE_COLOR,
        backGroundColor: MEDIUM_BLACK_COLOR,
       andTextAlignment: titleAlignment,
      forViewController: viewController)
    }
    
    convenience init(Items menuItems: [MediumMenuItem],
                           textColor: UIColor,
                 hightLightTextColor: UIColor,
                     backGroundColor: UIColor,
     andTextAlignment titleAlignment: Alignment,
    forViewController viewController: UIViewController) {
        self.init()
        self.frame = CGRectMake(0, 0, CGRectGetWidth(UIScreen.mainScreen().bounds), self.height!)
        self.menuContentTable = UITableView(frame: self.frame)
        self.menuItems = menuItems
        self.titleAlignment = titleAlignment
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
    
    // Status Bar
    
    func showStatusBar() {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
    }
    
    func dismissStatusBar() {
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
    }
    
    // Menu interactions
    
    func showMenu() {
        if currentMenuState == State.Shown || currentMenuState == State.Displaying {
            animateMenuClosingWithCompletion(nil)
        } else {
            currentMenuState = State.Displaying
            animateMenuOpening()
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
                openMenuFromCenterWithVelocity(velocity.y)
                return
            } else if velocity.y < -VELOCITY_TRESHOLD {
                closeMenuFromCenterWithVelocity(abs(velocity.y))
                return
            }
            if viewCenter.y <= contentController?.view.frame.size.height {
                animateMenuClosingWithCompletion(nil)
            } else {
                animateMenuOpening()
            }
        }
    }
    
    // Animation and menu operations
    
    func animateMenuOpening() {
        showStatusBar()
        if currentMenuState != State.Shown {
            UIView.animateWithDuration(0.2, animations: {[unowned self]() -> Void in
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
        dismissStatusBar()
        UIView.animateWithDuration(0.2, animations: {[unowned self]() -> Void in
            let center = self.contentController!.view.center
            self.contentController?.view.center = CGPointMake(center.x, center.y + MENU_BOUNCE_OFFSET)
        }, completion: {[unowned self](finished: Bool) -> Void in
                UIView.animateWithDuration(0.2, animations: {[unowned self]() -> Void in
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
        showStatusBar()
        let viewCenterY: CGFloat = CRITERION + height! - MENU_BOUNCE_OFFSET
        currentMenuState = State.Displaying
        let duration: NSTimeInterval = Double((viewCenterY - contentController!.view.center.y) / velocity)
        UIView.animateWithDuration(duration, animations: {[unowned self]() -> Void in
            let center = self.contentController!.view.center
            self.contentController?.view.center = CGPointMake(center.x, viewCenterY)
        }, completion: {[unowned self](finished: Bool) -> Void in
            self.currentMenuState = State.Shown
        })
    }
    
    func closeMenuFromCenterWithVelocity(velocity: CGFloat) {
        dismissStatusBar()
        let viewCenterY: CGFloat = CRITERION
        currentMenuState = State.Displaying
        let duration: NSTimeInterval = Double((contentController!.view.center.y - viewCenterY) / velocity)
        UIView.animateWithDuration(duration, animations: {[unowned self]() -> Void in
            let center = self.contentController!.view.center
            self.contentController?.view.center = CGPointMake(center.x, self.CRITERION)
            }, completion: {[unowned self](finished: Bool) -> Void in
                self.currentMenuState = State.Closed
        })
    }
    
    // UITableViewDelegates

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count + 2 * STARTINDEX
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var menuCell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER) as? UITableViewCell
        var mediumMenuItem: MediumMenuItem?
        
        if menuCell == nil {
            menuCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: CELL_IDENTIFIER)
            setMenuTitleAlligmentForCell(menuCell!)
            menuCell?.backgroundColor = UIColor.clearColor()
            menuCell?.selectionStyle = UITableViewCellSelectionStyle.None
            menuCell?.textLabel?.textColor = textColor
            menuCell?.textLabel?.font = titleFont
        }
        
        if indexPath.row >= STARTINDEX && indexPath.row <= (menuItems.count - 1 + STARTINDEX) {
            mediumMenuItem = menuItems[indexPath.row - STARTINDEX]
            menuCell?.textLabel?.text = mediumMenuItem?.title
        }
        
        return menuCell!
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if highLighedIndex == indexPath.row {
            cell.textLabel?.textColor = highLightTextColor
            cell.textLabel?.font = titleFont?.fontWithSize(titleFont!.pointSize)
        } else {
            cell.textLabel?.textColor = textColor
            cell.textLabel?.font = titleFont?.fontWithSize(titleFont!.pointSize)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < STARTINDEX || indexPath.row > menuItems.count - 1 + STARTINDEX {
            return
        }
        dismissStatusBar()
        highLighedIndex = indexPath.row
        menuContentTable?.reloadData()
        let selectedItem: MediumMenuItem = menuItems[indexPath.row - STARTINDEX]
        animateMenuClosingWithCompletion(selectedItem.completion)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view: UIView = UIView(frame: CGRectMake(0, 0, frame.width, 30))
        view.backgroundColor = UIColor.clearColor()
        return view
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 57
    }
    
    func setMenuTitleAlligmentForCell(cell: UITableViewCell) {
        if let tAlignment = titleAlignment {
            switch tAlignment {
            case Alignment.Left:
                cell.textLabel?.textAlignment = NSTextAlignment.Left
            case Alignment.Center:
                cell.textLabel?.textAlignment = NSTextAlignment.Center
            case Alignment.Right:
                cell.textLabel?.textAlignment = NSTextAlignment.Right
            default:
                break
            }
        }
    }
}

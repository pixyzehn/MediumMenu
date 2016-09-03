//
//  MediumMenu.swift
//  MediumMenu
//
//  Created by pixyzehn on 2/2/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

import UIKit

public typealias CompletionHandler = (() -> Void)

public class MediumMenu: UIView {

    public enum State {
        case Shown
        case Closed
        case Displaying
    }
    
    public enum Alignment {
        case Left
        case Center
        case Right
    }

    private struct Color {
        static let mediumWhiteColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1)
        static let mediumBlackColor = UIColor(red:0.05, green:0.05, blue:0.05, alpha:1)
        static let mediumGlayColor  = UIColor(red:0.57, green:0.57, blue:0.57, alpha:1)
    }

    private let startIndex = 1
    private let cellIdentifier = "cell"
    private var currentState: State = .Closed
    private var contentController: UIViewController?
    public var menuContentTableView: UITableView?

    public var panGestureEnable: Bool = true
    public var titleAlignment: Alignment = .Left
    public var textColor: UIColor?
    public var highlightTextColor: UIColor?
    public var menuBackgroundColor: UIColor?
    public var titleFont: UIFont?
    public var bounceOffset: CGFloat = 0
    public var velocityTreshold: CGFloat = 0
    public var highlighedIndex: Int?
    public var autoUpdateHighlightedIndex: Bool = true
    public var heightForRowAtIndexPath: CGFloat = 57
    public var heightForHeaderInSection: CGFloat = 30
    public var enabled: Bool = true
    public var animationDuration: NSTimeInterval = 0.2

    public var items: [MediumMenuItem] = []

    public var height: CGFloat = 0 {
        didSet {
            frame.size.height = height
            menuContentTableView?.frame = frame
        }
    }

    private var screenBounds: CGRect {
        return UIScreen.mainScreen().bounds
    }

    private var screenHeight: CGFloat {
        return screenBounds.height
    }

    private var screenWidth: CGFloat {
        return screenBounds.width
    }

    override public var backgroundColor: UIColor? {
        didSet {
            menuContentTableView?.backgroundColor = backgroundColor
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.titleFont           = UIFont(name: "HelveticaNeue-Light", size: 28)
        self.titleAlignment      = .Left
        self.height              = 400 // updated to good-fit height for iPhone 4s
        self.textColor           = Color.mediumWhiteColor
        self.highlightTextColor  = Color.mediumGlayColor
        self.menuBackgroundColor = Color.mediumBlackColor
        self.bounceOffset        = 0
        self.velocityTreshold    = 1000
        self.panGestureEnable    = true
        self.highlighedIndex     = 1
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public init(items: [MediumMenuItem], forViewController: UIViewController) {
        self.init()
        self.items = items
        height = screenHeight - 80 // auto-calculate initial height based on screen size
        frame = CGRect(x: 0, y: 0, width: screenWidth, height: height)
        contentController = forViewController
        menuContentTableView = UITableView(frame: frame)
        menuContentTableView?.delegate = self
        menuContentTableView?.dataSource = self
        menuContentTableView?.showsVerticalScrollIndicator = false
        menuContentTableView?.separatorColor = UIColor.clearColor()
        menuContentTableView?.backgroundColor = menuBackgroundColor
        addSubview(menuContentTableView!)
        
        if panGestureEnable {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(MediumMenu.didPan(_:)))
            contentController?.view.addGestureRecognizer(pan)
        }

        let menuController = UIViewController()
        menuController.view = self
        
        UIApplication.sharedApplication().delegate?.window??.rootViewController = contentController
        UIApplication.sharedApplication().delegate?.window??.insertSubview(menuController.view, atIndex: 0)
    }
    
    public override func layoutSubviews() {
        frame = CGRect(x: 0, y: 0, width: screenWidth, height: height);
        contentController?.view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight);
        menuContentTableView = UITableView(frame: frame)
    }

    // MARK:Menu Interactions
    
    public func show() {
        if !enabled { return }
        
        if currentState == .Shown || currentState == .Displaying {
            closeWithCompletion(animated: true, completion: nil)
        } else {
            currentState = .Displaying
            openWithCompletion(animated: true, completion: nil)
        }
    }
    
    public func didPan(pan: UIPanGestureRecognizer) {
        if !enabled { return }
        if !panGestureEnable { return }

        if var viewCenter = pan.view?.center {
            if pan.state == .Began || pan.state == .Changed {
                
                let translation = pan.translationInView(pan.view!.superview!)

                if viewCenter.y >= screenHeight / 2
                    && viewCenter.y <= (screenHeight / 2 + height) - bounceOffset {
                            
                    currentState = .Displaying
                    viewCenter.y = abs(viewCenter.y + translation.y)
                    if viewCenter.y >= screenHeight / 2
                        && viewCenter.y <= (screenHeight / 2 + height) - bounceOffset {

                        contentController?.view.center = viewCenter
                    }
                    pan.setTranslation(CGPointZero, inView: contentController?.view)
                }
                
            } else if pan.state == .Ended {

                let velocity = pan.velocityInView(contentController?.view.superview)

                if velocity.y > velocityTreshold {
                    openMenuFromCenterWithVelocity(velocity.y)
                    return
                } else if velocity.y < -velocityTreshold {
                    closeMenuFromCenterWithVelocity(abs(velocity.y))
                    return
                }

                if viewCenter.y > contentController?.view.frame.size.height {
                    openWithCompletion(animated: true, completion: nil)
                } else {
                    closeWithCompletion(animated: true, completion: nil)
                }
            }
        }
    }

    // MARK:Animation and menu operations

    public func openWithCompletion(animated animated:Bool, completion: CompletionHandler?) {
        if currentState == .Shown { return }

        guard let x = contentController?.view.center.x else { return }

        if animated {
            UIView.animateWithDuration(animationDuration, animations: {
                self.contentController?.view.center = CGPoint(x: x, y: self.screenHeight / 2 + self.height)
            }, completion: { _ in
                UIView.animateWithDuration(self.animationDuration, animations: {
                    self.contentController?.view.center = CGPoint(x: x, y: self.screenHeight / 2 + self.height - self.bounceOffset)
                }, completion: { _ in
                    self.currentState = .Shown
                    completion?()
                })
            })
        } else {
            self.contentController?.view.center = CGPoint(x: x, y: screenHeight / 2 + self.height)
            self.currentState = .Shown
            completion?()
        }
    }
    
    public func closeWithCompletion(animated animated:Bool, completion: CompletionHandler?) {
        guard let center = contentController?.view.center else { return }

        if animated {
            UIView.animateWithDuration(animationDuration, animations: {
                self.contentController?.view.center = CGPoint(x: center.x, y: center.y + self.bounceOffset)
            }, completion: { _ in
                UIView.animateWithDuration(self.animationDuration, animations: {
                    self.contentController?.view.center = CGPoint(x: center.x, y: self.screenHeight / 2)
                }, completion: { _ in
                    self.currentState = .Closed
                    completion?()
                })
            })
        } else {
            contentController?.view.center = CGPoint(x: center.x, y: screenHeight / 2)
            currentState = .Closed
            completion?()
        }
    }

    public func openMenuFromCenterWithVelocity(velocity: CGFloat) {
        let viewCenterY = screenHeight / 2 + height - bounceOffset
        currentState = .Displaying

        let duration = Double((viewCenterY - contentController!.view.center.y) / velocity)
        UIView.animateWithDuration(duration, animations: {
            if let center = self.contentController?.view.center {
                self.contentController?.view.center = CGPoint(x: center.x, y: viewCenterY)
            }
        }, completion: { _ in
            self.currentState = .Shown
        })
    }

    public func closeMenuFromCenterWithVelocity(velocity: CGFloat) {
        let viewCenterY = screenHeight / 2
        currentState = .Displaying

        let duration = Double((contentController!.view.center.y - viewCenterY) / velocity)
        UIView.animateWithDuration(duration, animations: {
            if let center = self.contentController?.view.center {
                self.contentController?.view.center = CGPoint(x: center.x, y: self.screenHeight / 2)
            }
        }, completion: { _ in
            self.currentState = .Closed
        })
    }
    
    // MARK:Custom Function
    
    public func setHighLighedRow(row: Int) {
        highlighedIndex = row
    }
    
    public func setHighLighedRowAtIndexPath(indexPath: NSIndexPath) {
        highlighedIndex = indexPath.row
    }
    
    private func setMenuTitleAlligmentForCell(cell: UITableViewCell) {
        switch titleAlignment {
        case .Left:
            cell.textLabel?.textAlignment = .Left
        case .Center:
            cell.textLabel?.textAlignment = .Center
        case .Right:
            cell.textLabel?.textAlignment = .Right
        }
    }
}

extension MediumMenu: UITableViewDataSource, UITableViewDelegate {
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count + 2 * startIndex
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
        
        setMenuTitleAlligmentForCell(cell)
        cell.backgroundColor = UIColor.clearColor()
        cell.selectionStyle = .None
        cell.textLabel?.textColor = highlighedIndex == indexPath.row ? highlightTextColor : textColor
        cell.textLabel?.font = titleFont
        
        let mediumMenuItem: MediumMenuItem?
        if indexPath.row >= startIndex && indexPath.row <= (items.count - 1 + startIndex) {
            mediumMenuItem = items[indexPath.row - startIndex]
            cell.textLabel?.text = mediumMenuItem?.title
        }
        
        return cell
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < startIndex || indexPath.row > items.count - 1 + startIndex {
            return
        }
        if autoUpdateHighlightedIndex {
            highlighedIndex = indexPath.row
        }
        tableView.reloadData()
        
        let selectedItem = items[indexPath.row - startIndex]
        closeWithCompletion(animated: true, completion: selectedItem.completion)
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 30))
        view.backgroundColor = UIColor.clearColor()
        return view
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return heightForHeaderInSection
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return heightForRowAtIndexPath
    }
}

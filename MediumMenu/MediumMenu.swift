//
//  MediumMenu.swift
//  MediumMenu
//
//  Created by pixyzehn on 2/2/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

import UIKit

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

public typealias CompletionHandler = (() -> Void)

open class MediumMenu: UIView {
    public enum State {
        case shown
        case closed
        case displaying
    }
    
    public enum Alignment {
        case left
        case center
        case right
    }

    fileprivate struct DefaultColor {
        static let mediumWhiteColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1)
        static let mediumBlackColor = UIColor(red:0.05, green:0.05, blue:0.05, alpha:1)
        static let mediumGlayColor = UIColor(red:0.57, green:0.57, blue:0.57, alpha:1)
    }

    // Internal settings
    fileprivate let startIndex = 1
    fileprivate let cellIdentifier = "MediumMenucell"
    fileprivate var currentState: State = .closed
    fileprivate var contentController: UIViewController?
    fileprivate var screenBounds: CGRect {
        return UIScreen.main.bounds
    }
    fileprivate var screenHeight: CGFloat {
        return screenBounds.height
    }
    fileprivate var screenWidth: CGFloat {
        return screenBounds.width
    }

    // External settings
    open var panGestureEnable: Bool = true
    open var titleAlignment: Alignment = .left
    open var textColor: UIColor?
    open var highlightTextColor: UIColor?
    open var menuBackgroundColor: UIColor?
    open var titleFont: UIFont?
    open var bounceOffset: CGFloat = 0
    open var velocityTreshold: CGFloat = 0
    open var highlighedIndex: Int?
    open var autoUpdateHighlightedIndex: Bool = true
    open var heightForRowAtIndexPath: CGFloat = 57
    open var heightForHeaderInSection: CGFloat = 30
    open var enabled: Bool = true
    open var animationDuration: TimeInterval = 0.2
    open var items: [MediumMenuItem] = []
    open var menuContentTableView: UITableView?
    open var height: CGFloat = 0 {
        didSet {
            frame.size.height = height
            menuContentTableView?.frame = frame
        }
    }

    override open var backgroundColor: UIColor? {
        didSet {
            menuContentTableView?.backgroundColor = backgroundColor
        }
    }
    
    // MARK: Initializers

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.titleFont = UIFont(name: "HelveticaNeue-Light", size: 28)
        self.titleAlignment = .left
        self.height = 400 // updated to good-fit height for iPhone 4s
        self.textColor = DefaultColor.mediumWhiteColor
        self.highlightTextColor = DefaultColor.mediumGlayColor
        self.menuBackgroundColor = DefaultColor.mediumBlackColor
        self.bounceOffset = 0
        self.velocityTreshold = 1000
        self.panGestureEnable = true
        self.highlighedIndex = 1
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
        menuContentTableView?.separatorColor = UIColor.clear
        menuContentTableView?.backgroundColor = menuBackgroundColor
        addSubview(menuContentTableView!)
        
        if panGestureEnable {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(MediumMenu.didPan(_:)))
            contentController?.view.addGestureRecognizer(pan)
        }

        let menuController = UIViewController()
        menuController.view = self
        
        UIApplication.shared.delegate?.window??.rootViewController = contentController
        UIApplication.shared.delegate?.window??.insertSubview(menuController.view, at: 0)
    }
    
    open override func layoutSubviews() {
        frame = CGRect(x: 0, y: 0, width: screenWidth, height: height);
        contentController?.view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight);
        menuContentTableView = UITableView(frame: frame)
    }
    
    // MARK: Custom Functions
    
    open func setHighLighedRow(_ row: Int) {
        highlighedIndex = row
    }
    
    open func setHighLighedRowAtIndexPath(_ indexPath: IndexPath) {
        highlighedIndex = (indexPath as NSIndexPath).row
    }

    // MARK: Menu Interactions

    open func show() {
        if !enabled { return }
        if currentState == .shown || currentState == .displaying {
            close()
        } else {
            currentState = .displaying
            open()
        }
    }
    
    open func didPan(_ pan: UIPanGestureRecognizer) {
        if !enabled { return }
        if !panGestureEnable { return }
        guard let panView = pan.view,
            let parentPanView = panView.superview,
            var viewCenter = pan.view?.center else { return }

        if pan.state == .began || pan.state == .changed {
            let translation = pan.translation(in: parentPanView)
            if viewCenter.y >= screenHeight / 2
                    && viewCenter.y <= (screenHeight / 2 + height) - bounceOffset {
                currentState = .displaying
                viewCenter.y = abs(viewCenter.y + translation.y)
                if viewCenter.y >= screenHeight / 2
                        && viewCenter.y <= (screenHeight / 2 + height) - bounceOffset {
                    contentController?.view.center = viewCenter
                }
                pan.setTranslation(CGPoint.zero, in: contentController?.view)
            }
        } else if pan.state == .ended {
            let velocity = pan.velocity(in: contentController?.view.superview)
            if velocity.y > velocityTreshold {
                openMenuFromCenter(velocity.y)
                return
            } else if velocity.y < -velocityTreshold {
                closeMenuFromCenter(abs(velocity.y))
                return
            }
            if viewCenter.y > contentController?.view.frame.size.height {
                open()
            } else {
                close()
            }
        }
    }

    // MARK: Private method
    // Animation and menu operations

    fileprivate func open(animated: Bool = true, completion: CompletionHandler? = nil) {
        if currentState == .shown { return }
        guard let x = contentController?.view.center.x else { return }
        if animated {
            UIView.animate(withDuration: animationDuration, animations: {
                self.contentController?.view.center = CGPoint(x: x, y: self.screenHeight / 2 + self.height)
            }, completion: { _ in
                UIView.animate(withDuration: self.animationDuration, animations: {
                    self.contentController?.view.center = CGPoint(x: x, y: self.screenHeight / 2 + self.height - self.bounceOffset)
                }, completion: { _ in
                    self.currentState = .shown
                    completion?()
                })
            })
        } else {
            contentController?.view.center = CGPoint(x: x, y: screenHeight / 2 + height)
            currentState = .shown
            completion?()
        }
    }
    
    fileprivate func close(animated: Bool = true, completion: CompletionHandler? = nil) {
        guard let center = contentController?.view.center else { return }
        if animated {
            UIView.animate(withDuration: animationDuration, animations: {
                self.contentController?.view.center = CGPoint(x: center.x, y: center.y + self.bounceOffset)
            }, completion: { _ in
                UIView.animate(withDuration: self.animationDuration, animations: {
                    self.contentController?.view.center = CGPoint(x: center.x, y: self.screenHeight / 2)
                }, completion: { _ in
                    self.currentState = .closed
                    completion?()
                })
            })
        } else {
            contentController?.view.center = CGPoint(x: center.x, y: screenHeight / 2)
            currentState = .closed
            completion?()
        }
    }

    fileprivate func openMenuFromCenter(_ velocity: CGFloat) {
        let viewCenterY = screenHeight / 2 + height - bounceOffset
        currentState = .displaying
        let duration = Double((viewCenterY - contentController!.view.center.y) / velocity)
        UIView.animate(withDuration: duration, animations: {
            if let center = self.contentController?.view.center {
                self.contentController?.view.center = CGPoint(x: center.x, y: viewCenterY)
            }
        }, completion: { _ in
            self.currentState = .shown
        })
    }

    fileprivate func closeMenuFromCenter(_ velocity: CGFloat) {
        let viewCenterY = screenHeight / 2
        currentState = .displaying
        let duration = Double((contentController!.view.center.y - viewCenterY) / velocity)
        UIView.animate(withDuration: duration, animations: {
            if let center = self.contentController?.view.center {
                self.contentController?.view.center = CGPoint(x: center.x, y: self.screenHeight / 2)
            }
        }, completion: { _ in
            self.currentState = .closed
        })
    }
}

extension MediumMenu: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count + 2 * startIndex
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        setMenuTitleAlligmentForCell(cell)
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        cell.textLabel?.textColor = highlighedIndex == (indexPath as NSIndexPath).row ? highlightTextColor : textColor
        cell.textLabel?.font = titleFont
        let mediumMenuItem: MediumMenuItem?
        if (indexPath as NSIndexPath).row >= startIndex && (indexPath as NSIndexPath).row <= (items.count - 1 + startIndex) {
            mediumMenuItem = items[(indexPath as NSIndexPath).row - startIndex]
            cell.textLabel?.text = mediumMenuItem?.title
            cell.imageView?.image = mediumMenuItem?.image
        }
        return cell
    }
    
    // MARK: Private method
    
    fileprivate func setMenuTitleAlligmentForCell(_ cell: UITableViewCell) {
        switch titleAlignment {
        case .left:
            cell.textLabel?.textAlignment = .left
        case .center:
            cell.textLabel?.textAlignment = .center
        case .right:
            cell.textLabel?.textAlignment = .right
        }
    }
}

extension MediumMenu: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row < startIndex || (indexPath as NSIndexPath).row > items.count - 1 + startIndex { return }
        if autoUpdateHighlightedIndex {
            highlighedIndex = (indexPath as NSIndexPath).row
        }
        tableView.reloadData()
        let selectedItem = items[(indexPath as NSIndexPath).row - startIndex]
        close(completion: selectedItem.completion)
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 30))
        view.backgroundColor = UIColor.clear
        return view
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return heightForHeaderInSection
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRowAtIndexPath
    }
}

//
//  MediumMenu.swift
//  MediumMenu
//
//  Created by pixyzehn on 2/2/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

import UIKit

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

    // MARK: Internal settings

    fileprivate let startIndex = 1
    fileprivate var currentState: State = .closed
    fileprivate var contentController: UIViewController?
    fileprivate var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    fileprivate var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }

    // MARK: External settings

    open var panGestureEnable = true
    open var titleAlignment: Alignment = .left
    open var textColor = DefaultColor.mediumWhiteColor
    open var highlightTextColor = DefaultColor.mediumGlayColor
    open var menuBackgroundColor = DefaultColor.mediumBlackColor
    open var titleFont = UIFont(name: "HelveticaNeue-Light", size: 28)
    open var bounceOffset: CGFloat = 0
    open var velocityThreshold: CGFloat = 1000
    open var highlighedIndex: Int = 1
    open var autoUpdateHighlightedIndex: Bool = true
    open var heightForRowAtIndexPath: CGFloat = 57
    open var heightForHeaderInSection: CGFloat = 30
    open var enabled: Bool = true
    open var animationDuration: TimeInterval = 0.2
    open var items: [MediumMenuItem] = []
    open var menuContentTableView: UITableView?
    open var height: CGFloat = 400 { // Updated to good-fit height for iPhone 4s.
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
            let pan = UIPanGestureRecognizer(target: self, action: #selector(MediumMenu.panned(on:)))
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
    
    open func setHighLighed(at row: Int) {
        highlighedIndex = row
    }
    
    open func setHighLighedRow(at indexPath: IndexPath) {
        highlighedIndex = indexPath.row
    }

    // MARK: Menu Interactions

    open func show() {
        if !enabled { return }
        switch currentState {
        case .shown, .displaying:
            close()
        case .closed:
            open()
        }
    }
    
    open func panned(on pan: UIPanGestureRecognizer) {
        if !enabled || !panGestureEnable { return }

        guard
            let panView = pan.view,
            let parentPanView = panView.superview,
            var viewCenter = pan.view?.center,
            let contentController = contentController
        else { return }

        if pan.state == .began || pan.state == .changed {
            let translation = pan.translation(in: parentPanView)
            if viewCenter.y >= screenHeight / 2
                    && viewCenter.y <= (screenHeight / 2 + height) - bounceOffset {
                currentState = .displaying
                viewCenter.y = abs(viewCenter.y + translation.y)
                if viewCenter.y >= screenHeight / 2
                        && viewCenter.y <= (screenHeight / 2 + height) - bounceOffset {
                    contentController.view.center = viewCenter
                }
                pan.setTranslation(CGPoint.zero, in: contentController.view)
            }
        } else if pan.state == .ended {
            let velocity = pan.velocity(in: contentController.view.superview)
            if velocity.y > velocityThreshold {
                openMenuFromCenter(with: velocity.y)
                return
            } else if velocity.y < -velocityThreshold {
                closeMenuFromCenter(with: abs(velocity.y))
                return
            }
            if viewCenter.y > contentController.view.frame.size.height {
                open()
            } else {
                close()
            }
        }
    }

    // MARK: Private method
    // Animation and menu operations

    fileprivate func open(animated: Bool = true, completion: (() -> Void)? = nil) {
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
    
    fileprivate func close(animated: Bool = true, completion: (() -> Void)? = nil) {
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

    fileprivate func openMenuFromCenter(with velocity: CGFloat) {
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

    fileprivate func closeMenuFromCenter(with velocity: CGFloat) {
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
        let cellIdentifier = "MediumMenucell"
        let cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        setMenuTitleAlligment(for: cell)
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        cell.textLabel?.textColor = highlighedIndex == indexPath.row ? highlightTextColor : textColor
        cell.textLabel?.font = titleFont
        let mediumMenuItem: MediumMenuItem?
        if indexPath.row >= startIndex && indexPath.row <= (items.count - 1 + startIndex) {
            mediumMenuItem = items[indexPath.row - startIndex]
            cell.textLabel?.text = mediumMenuItem?.title
            cell.imageView?.image = mediumMenuItem?.image
        }
        return cell
    }
    
    // MARK: Private method
    
    fileprivate func setMenuTitleAlligment(for cell: UITableViewCell) {
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
        if indexPath.row < startIndex || indexPath.row > items.count - 1 + startIndex { return }
        if autoUpdateHighlightedIndex {
            highlighedIndex = indexPath.row
        }
        tableView.reloadData()
        let selectedItem = items[indexPath.row - startIndex]
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

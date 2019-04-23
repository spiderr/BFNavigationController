//
//  BFNavigationController.swift
//
//  Created by Heiko Dreyer on 04/26/12.
//  Copyright (c) 2012 boxedfolder.com. All rights reserved.
//  Swift Port by https://github.com/spiderr
//

import Cocoa

private let kPushPopAnimationDuration: CGFloat = 0.2

@objc protocol BFNavigationControllerDelegate: NSObjectProtocol {
    ///---------------------------------------------------------------------------------------
    /// @name Customizing Behavior
    ///---------------------------------------------------------------------------------------
    /**
     *  Sent to the receiver just after the navigation controller displays a view controller’s view and navigation item properties.
     */
    @objc optional func navigationController(_ navigationController: BFNavigationController, didShow viewController: NSViewController, animated: Bool)
    /**
     *  Sent to the receiver just before the navigation controller displays a view controller’s view and navigation item properties.
     */
    @objc optional func navigationController(_ navigationController: BFNavigationController, willShow viewController: NSViewController, animated: Bool)
}

class BFNavigationController: NSViewController {
    private var _viewControllers: [BFNavigationController] = []

    ///---------------------------------------------------------------------------------------
    /// @name Creating Navigation Controllers
    ///---------------------------------------------------------------------------------------

    /**
     *  Initializes and returns a newly created navigation controller.
     */
    init(frame aFrame: NSRect, rootViewController: NSViewController?) {
        super.init(nibName: nil, bundle: nil)
        // Create view
        self.view = NSView(frame: aFrame)
        self.view.autoresizingMask = [.minXMargin, .maxXMargin, .minYMargin, .maxYMargin, .width, .height]

        if let viewController = rootViewController {
            self.viewControllers.append(viewController)

            viewController.navigationController = self
            
            viewController.view.autoresizingMask = view.autoresizingMask
            viewController.view.frame = view.bounds
            view.addSubview(viewController.view)
            
            // Initial controller will appear on startup
            // New controller will appear
            if let bfController = viewController as? BFViewController {
                bfController.viewWillAppear?(false)
            }
        }
    }

    ///---------------------------------------------------------------------------------------
    /// @name Accessing Items on the Navigation Stack
    ///---------------------------------------------------------------------------------------

    /**
     *  The view controller at the top of the navigation stack. (read-only)
     */

    var topViewController: NSViewController? {
        return viewControllers.last
    }
    /**
     *  The view controller associated with the currently visible view in the navigation interface. (read-only)
     */

    var visibleViewController: NSViewController? {
        return viewControllers.last
    }
    /**
     *  The view controllers currently on the navigation stack.
     */

    var viewControllers: [NSViewController] {
        get {
            return _viewControllers
        }
        set(viewControllers) {
            _setViewControllers(viewControllers, animated: false)
        }
    }

    /**
     *  Replaces the view controllers currently managed by the navigation controller with the specified items.
     */
    func setViewControllers(_ viewControllers: [NSViewController], animated: Bool) {
        _setViewControllers(viewControllers, animated: animated)
    }

    ///---------------------------------------------------------------------------------------
    /// @name Pushing and Popping Stack Items
    ///---------------------------------------------------------------------------------------

    /**
     *  Pushes a view controller onto the receiver’s stack and updates the display.
     */
    func pushViewController(_ viewController: BFNavigationController, animated: Bool) {
        let visibleController: NSViewController? = visibleViewController
        viewControllers.append(viewController)

        viewController.navigationController = self

        // Navigate
        _navigate(from: visibleController, to: viewControllers.last, animated: animated, push: true)
    }

    /**
     *  Pops the top view controller from the navigation stack and updates the display.
     */
    func popViewController(animated: Bool) -> NSViewController? {
        // Don't pop last controller
        if viewControllers.count == 1 {
            return nil
        }

        let viewController = viewControllers.last
        viewControllers.removeLast()

        // Navigate
        _navigate(from: viewController, to: viewControllers.last, animated: animated, push: false)

        viewController?.navigationController = nil

        // Return popping controller
        return viewController
    }

    /**
     *  Pops all the view controllers on the stack except the root view controller and updates the display.
     */
    func popToRootViewController(animated: Bool) -> [NSViewController]? {
        // Don't pop last controller
        if viewControllers.count == 1 {
            return []
        }

        let dispControllers = viewControllers
        
        if let rootController = viewControllers.first {
            viewControllers.removeAll(where: { element in element == rootController })

            viewControllers = [rootController]

            // Navigate
            _navigate(from: dispControllers.last, to: rootController, animated: animated, push: false)

            for aViewController in dispControllers {
                aViewController.navigationController = nil
            }
        }

        // Return popping controller stack
        return ((dispControllers as NSArray).reverseObjectEnumerator()).allObjects as? [NSViewController]
    }

    /**
     *  Pops view controllers until the specified view controller is at the top of the navigation stack.
     */
    func popToViewController(_ viewController: NSViewController, animated: Bool) -> [NSViewController]? {
        let visibleController: NSViewController? = visibleViewController

        // Don't pop last controller
        if !viewControllers.contains(viewController) || visibleController == viewController {
            return []
        }

        let index: Int = (viewControllers as NSArray).index(of: viewController)
        let length: Int = viewControllers.count - (index + 1)
        let range = NSRange(location: index + 1, length: length)
        let dispControllers = (viewControllers as NSArray).subarray(with: range)
//        viewControllers = viewControllers.filter({ !dispControllers.contains($0 as? NSViewController) })

        // Navigate
        _navigate(from: visibleController, to: viewController, animated: animated, push: false)

        for aViewController in dispControllers as? [NSViewController] ?? [] {
            aViewController.navigationController = nil
        }

        // Return popping controller stack
        return ((dispControllers as NSArray).reverseObjectEnumerator()).allObjects as? [NSViewController]
    }

    ///---------------------------------------------------------------------------------------
    /// @name Accessing the Delegate
    ///---------------------------------------------------------------------------------------

    /**
     *  The reciever's delegate or nil.
     */
    weak var delegate: BFNavigationControllerDelegate?

    private func _setViewControllers(_ controllers: [Any]?, animated: Bool) {
        let visibleController: NSViewController? = visibleViewController
        let newTopmostController = controllers?.last as? NSViewController

        // Decide if pop or push - If visible controller already in new stack, but is not topmost, use pop otherwise push
        var push: Bool = false
        if let newTopmostController = newTopmostController {
            push = !(viewControllers.contains(newTopmostController) && (viewControllers as NSArray).index(of: newTopmostController) < viewControllers.count - 1)
        }

        if let controllers = controllers as? [NSViewController] {
            viewControllers = controllers
        }

        for viewController in viewControllers {
            viewController.navigationController = self
        }

        // Navigate
        _navigate(from: visibleController, to: newTopmostController, animated: animated, push: push)
    }

    private func _navigate(from lastController: NSViewController?, to newController: NSViewController?, animated: Bool, push: Bool) {
        newController?.view.autoresizingMask = view.autoresizingMask

        // Call delegate
        if delegate != nil && delegate?.responds(to: #selector(BFNavigationControllerDelegate.navigationController(_:willShow:animated:))) ?? false {
            if let newController = newController {
                delegate?.navigationController?(self, willShow: newController, animated: animated)
            }
        }

        // New controller will appear
        if let bfController = newController as? BFViewController {
            bfController.viewWillAppear?(animated)
        }

        // Last controller will disappear
        if let bfController = lastController as? BFViewController {
            bfController.viewWillAppear?(animated)
        }

        var newControllerStartFrame: NSRect = view.bounds
        var lastControllerEndFrame: NSRect = view.bounds

        // Completion inline Block
        let navigationCompleted: ((Bool) -> Void)? = { animated in
                // Call delegate
                if let bfDelegate = self.delegate, let newController = newController {
                    bfDelegate.navigationController?(self, didShow: newController, animated: animated)
                }

                // New controller did appear
                if let bfController = newController as? BFViewController {
                    bfController.viewDidAppear?(animated)
                }

                // Last controller did disappear
                if let bfController = lastController as? BFViewController {
                    bfController.viewDidDisappear?(animated)
                }
            }

        if animated {
            newControllerStartFrame.origin.x = push ? newControllerStartFrame.size.width : -newControllerStartFrame.size.width
            lastControllerEndFrame.origin.x = push ? -lastControllerEndFrame.size.width : lastControllerEndFrame.size.width

            // Assign start frame
            newController?.view.frame = newControllerStartFrame

            // Remove last controller from superview
            lastController?.view.removeFromSuperview()

            // We use NSImageViews to cache animating views. Of course we could animate using Core Animation layers - Do it if you like that.
            let lastControllerImageView = NSImageView(frame: view.bounds)
            let newControllerImageView = NSImageView(frame: newControllerStartFrame)

            lastControllerImageView.image = lastController?.view.flattenWithSubviews()
            newControllerImageView.image = newController?.view.flattenWithSubviews()

            view.addSubview(lastControllerImageView)
            view.addSubview(newControllerImageView)

            // Animation 'block' - Using default timing function
            NSAnimationContext.beginGrouping()
            NSAnimationContext.current.duration = TimeInterval(kPushPopAnimationDuration)
//            lastControllerImageView.animator().setFrame(lastControllerEndFrame)
//            newControllerImageView.animator().setFrame(view.bounds)
            NSAnimationContext.endGrouping()

            // Could have just called setCompletionHandler: on animation context if it was Lion only.
            let popTime = DispatchTime.now() + Double(Double(kPushPopAnimationDuration) * Double(NSEC_PER_SEC))
//            let deadline: DispatchTime = popTime / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: popTime, execute: {
                lastControllerImageView.removeFromSuperview()
                if let view = newController?.view {
                    self.view.replaceSubview(newControllerImageView, with: view)
                }
                newController?.view.frame = self.view.bounds
                navigationCompleted?(animated)
            })
        } else {
            newController?.view.frame = newControllerStartFrame
            if let view = newController?.view {
                view.addSubview(view)
            }
            lastController?.view.removeFromSuperview()
            navigationCompleted?(animated)
        }
    }

    // MARK: - Init Methods
    convenience override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        self.init(frame: NSRect.zero, rootViewController: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

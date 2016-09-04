// CoachMarksController.swift
//
// Copyright (c) 2015, 2016 Frédéric Maquin <fred@ephread.com>,
//                          Daniel Basedow <daniel.basedow@gmail.com>,
//                          Esteban Soto <esteban.soto.dev@gmail.com>,
//                          Ogan Topkaya <>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

// swiftlint:disable type_body_length

// TODO: Refactor the Mega Controller!
/// Handles a set of coach marks, and display them successively.
open class CoachMarksController: UIViewController {
    //MARK: - Public properties -
    /// `true` if coach marks are curently being displayed, `false` otherwise.
    open var started: Bool {
        return currentIndex != -1
    }

    /// Sometimes, the chain of coach mark display can be paused
    /// to let animations be performed. `true` to pause the execution,
    /// `false` otherwise.
    fileprivate(set) open var paused = false

    /// An object implementing the data source protocol and supplying the coach marks to display.
    open weak var dataSource: CoachMarksControllerDataSource? {
        didSet {
            self.coachMarkDisplayManager.dataSource = self.dataSource
        }
    }

    @available(*, deprecated: 0.4, message: "use dataSource instead")
    open weak var datasource: CoachMarksControllerDataSource? {
        set(datasource) {
            print("The `datasource` accessor is deprecated and will be removed" +
                  "in further versions. Please use `dataSource` instead.")
            self.dataSource = datasource
        }

        get {
            print("The `datasource` accessor is deprecated and will be removed" +
                  "in further versions. Please use `dataSource` instead.")
            return self.dataSource
        }
    }

    /// An object implementing the delegate data source protocol,
    /// which methods will be called at various points.
    open weak var delegate: CoachMarksControllerDelegate?

    /// Overlay fade animation duration
    open var overlayFadeAnimationDuration = Constants.overlayFadeAnimationDuration

    /// Background color of the overlay.
    open var overlayBackgroundColor: UIColor {
        get {
            return self.overlayView.overlayColor
        }

        set {
            self.overlayView.overlayColor = newValue
        }
    }

    /// Blur effect style for the overlay view. Keeping this property
    /// `nil` will disable the effect. This property
    /// is mutually exclusive with `overlayBackgroundColor`.
    open var overlayBlurEffectStyle: UIBlurEffectStyle? {
        get {
            return self.overlayView.blurEffectStyle
        }

        set {
            self.overlayView.blurEffectStyle = newValue
        }
    }

    /// `true` to let the overlay catch tap event and forward them to the
    /// CoachMarkController, `false` otherwise.
    ///
    /// After receiving a tap event, the controller will show the next coach mark.
    ///
    /// You can disable the tap on a case-by-case basis, see CoachMark.disableOverlayTap
    open var allowOverlayTap: Bool {
        get {
            return self.overlayView.allowOverlayTap
        }

        set {
            self.overlayView.allowOverlayTap = newValue
        }
    }

    // swiftlint:disable force_cast
    /// The view holding the "Skip" control
    open var skipView: CoachMarkSkipView? {
        // Again, we test the protocol/UIView combination
        // at runtime.

        get {
            return self.skipViewAsView as! CoachMarkSkipView?
        }

        set {
            guard let validSkipView = newValue else {
                self.skipViewAsView = nil
                return
            }

            if !(validSkipView is UIView) {
                fatalError("skipView must conform to CoachMarkBodyView but also be a UIView.")
            }

            self.skipViewAsView = validSkipView as? UIView

            self.skipViewDisplayManager = SkipViewDisplayManager(
                skipView: skipViewAsView!,
                instructionsTopView: self.instructionsTopView
            )
        }
    }
    // swiftlint:enable force_cast

    //MARK: - Private properties -
    fileprivate lazy var coachMarkDisplayManager: CoachMarkDisplayManager! = {
        return CoachMarkDisplayManager(coachMarksController: self,
                                       overlayView: self.overlayView,
                                       instructionsTopView: self.instructionsTopView)
    }()

    fileprivate var skipViewDisplayManager: SkipViewDisplayManager?

    /// The total number of coach marks, supplied by the `datasource`.
    fileprivate var numberOfCoachMarks = 0

    /// The index (in `coachMarks`) of the coach mark being currently displayed.
    fileprivate var currentIndex = -1

    /// Reference to the currently displayed coach mark, supplied by the `datasource`.
    fileprivate var currentCoachMark: CoachMark?

    /// Reference to the currently displayed coach mark, supplied by the `datasource`.
    fileprivate var currentCoachMarkView: CoachMarkView?

    /// The overlay view dim the background, handle the cutout path
    /// showing the point of interest and also show up the coach marks themselve.
    fileprivate lazy var overlayView: OverlayView = {
        var overlayView = OverlayView()
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.delegate = self

        return overlayView
    }()

    /// This view will be added to the current `UIWindow` and cover everything.
    /// The overlay and the coachmarks will all be subviews of this property.
    fileprivate var instructionsTopView = InstructionsTopView()

    /// The view holding the "Skip" control.
    fileprivate var skipViewAsView: UIView?

    /// Constraints defining the SKipView position.
    fileprivate var skipViewConstraints: [NSLayoutConstraint] = []

    //MARK: Flow control
    /// Since changing size calls asynchronous completion blocks,
    /// we might end up firing multiple times the methods adding coach
    /// marks to the view. To prevent that from happening we use the guard
    /// property.
    ///
    /// Everything is normally happening on the main thread, atomicity should
    /// not be a problem. Plus, a size change is a very long process compared to
    /// subview addition.
    ///
    /// This property will be checked multiple time during the process of
    /// showing coach marks and can abort the normal flow. This, it's also
    /// used to prevent the normal flow when calling `stop(imediately:)`.
    ///
    /// `true` when the controller is performing a size change, `false` otherwise.
    fileprivate var disableFlow = false

    /// This property is much like `disableFlow`, except it's used only to
    /// prevent a coach mark from being shown multiple times (in case the user
    /// is tapping too fast.
    ///
    /// `true` if a new coach mark can be shown, `false` otherwise.
    fileprivate var canShowCoachMark = true

    /// `true` when a size change is ongoing, false otherwise.
    fileprivate var onGoingSizeChange = false

    //MARK: - View lifecycle -
    open override func loadView() {
        let view = DummyView(frame: UIScreen.main.bounds)

        self.view = view
    }

    // Called after the view was loaded.
    override open func viewDidLoad() {
        super.viewDidLoad()

        self.view.translatesAutoresizingMaskIntoConstraints = false

        self.addOverlayView()

        self.registerForStatusBarFrameChanges()
    }

    deinit {
        self.unregisterFromStatusBarFrameChanges()
    }

    //MARK: - Overrides -
    override open func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        if onGoingSizeChange { return }
        onGoingSizeChange = true

        self.overlayView.updateCutoutPath(nil)
        self.prepareForSizeTransition()

        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: nil, completion: {
            (context: UIViewControllerTransitionCoordinatorContext) -> Void in
            self.onGoingSizeChange = false
            self.restoreAfterSizeTransitionDidComplete()
        })
    }

    //MARK: - Public handlers -
    /// Will be called when the user perform an action requiring the display of the next coach mark.
    ///
    /// - Parameter sender: the object sending the message
    open func performShowNextCoachMark(_ sender: AnyObject?) {
        self.showNextCoachMark()
    }

    /// Will be called when the user choose to skip the coach mark tour.
    ///
    /// - Parameter sender: the object sending the message
    open func skipCoachMarksTour(_ sender: AnyObject?) {
        self.stopFlow(userDidSkip: true)
    }

    //MARK: - Public Helpers -
    /// Returns a new coach mark with a cutout path set to be
    /// around the provided UIView. The cutout path will be slightly
    /// larger than the view and have rounded corners, however you can
    /// bypass the default creator by providing a block.
    ///
    /// The point of interest (defining where the arrow will sit, horizontally)
    /// will be set at the center of the cutout path.
    ///
    /// - Parameter view: the view around which create the cutoutPath
    /// - Parameter bezierPathBlock: a block customizing the cutoutPath
    open func coachMarkForView(
        _ view: UIView? = nil,
        bezierPathBlock: ((_ frame: CGRect) -> UIBezierPath)? = nil
    ) -> CoachMark {
        return self.coachMarkForView(view, pointOfInterest: nil, bezierPathBlock: bezierPathBlock)
    }

    /// Returns a new coach mark with a cutout path set to be
    /// around the provided UIView. The cutout path will be slightly
    /// larger than the view and have rounded corners, however you can
    /// bypass the default creator by providing a block.
    ///
    /// The point of interest (defining where the arrow will sit, horizontally)
    /// will be the one provided.
    ///
    /// - Parameter view: the view around which create the cutoutPath
    /// - Parameter pointOfInterest: the point of interest toward which the arrow should point
    /// - Parameter bezierPathBlock: a block customizing the cutoutPath
    open func coachMarkForView(
        _ view: UIView? = nil,
        pointOfInterest: CGPoint?,
        bezierPathBlock: ((_ frame: CGRect) -> UIBezierPath)? = nil
    ) -> CoachMark {
        var coachMark = CoachMark()

        guard let view = view else {
            return coachMark
        }

        self.updateCoachMark(&coachMark, forView: view,
                             pointOfInterest: pointOfInterest,
                             bezierPathBlock: bezierPathBlock)

        return coachMark
    }

    /// Updates the currently stored coach mark with a cutout path set to be
    /// around the provided UIView. The cutout path will be slightly
    /// larger than the view and have rounded corners, however you can
    /// bypass the default creator by providing a block.
    ///
    /// The point of interest (defining where the arrow will sit, horizontally)
    /// will be the one provided.
    ///
    /// This method is expected to be used in the delegate, after pausing the display.
    /// Otherwise, there might not be such a thing as a "current coach mark".
    ///
    /// - Parameter view: the view around which create the cutoutPath
    /// - Parameter pointOfInterest: the point of interest toward which the arrow
    ///                              should point
    /// - Parameter bezierPathBlock: a block customizing the cutoutPath
    open func updateCurrentCoachMarkForView(
        _ view: UIView? = nil,
        pointOfInterest: CGPoint? = nil,
        bezierPathBlock: ((_ frame: CGRect) -> UIBezierPath)? = nil
    ) {
        if !self.paused || self.currentCoachMark == nil {
            print("updateCurrentCoachMarkForView: Something is wrong, did you" +
                  "called updateCurrentCoachMarkForView without pausing" +
                  "the controller first?")
            return
        }

        self.updateCoachMark(&self.currentCoachMark!, forView: view,
                             pointOfInterest: pointOfInterest,
                             bezierPathBlock: bezierPathBlock)
    }

    /// Updates the given coach mark with a cutout path set to be
    /// around the provided UIView. The cutout path will be slightly
    /// larger than the view and have rounded corners, however you can
    /// bypass the default creator by providing a block.
    ///
    /// The point of interest (defining where the arrow will sit, horizontally)
    /// will be the one provided.
    ///
    /// - Parameter coachMark: the CoachMark to update
    /// - Parameter forView: the view around which create the cutoutPath
    /// - Parameter pointOfInterest: the point of interest toward which the arrow should point
    /// - Parameter bezierPathBlock: a block customizing the cutoutPath
    open func updateCoachMark(
        _ coachMark: inout CoachMark,
        forView view: UIView? = nil,
        pointOfInterest: CGPoint?,
        bezierPathBlock: ((_ frame: CGRect) -> UIBezierPath)? = nil
    ) {

        guard let view = view else {
            return
        }

        let convertedFrame =
            self.instructionsTopView.convert(view.frame, from:view.superview)

        var bezierPath: UIBezierPath

        if let bezierPathBlock = bezierPathBlock {
            bezierPath = bezierPathBlock(convertedFrame)
        } else {
            bezierPath = UIBezierPath(
                roundedRect: convertedFrame.insetBy(dx: -4, dy: -4),
                byRoundingCorners: .allCorners,
                cornerRadii: CGSize(width: 4, height: 4)
            )
        }

        coachMark.cutoutPath = bezierPath

        if let pointOfInterest = pointOfInterest {
            let convertedPoint =
                self.instructionsTopView.convert(pointOfInterest, from:view.superview)

            coachMark.pointOfInterest = convertedPoint
        }
    }

    /// Provides default coach views.
    ///
    /// - Parameter withArrow: `true` to return an instance of `CoachMarkArrowDefaultView`
    ///                        as well, `false` otherwise.
    /// - Parameter withNextText: `true` to show the ‘next’ pseudo-button,
    ///                           `false` otherwise.
    /// - Parameter arrowOrientation: orientation of the arrow (either .Top or .Bottom)
    ///
    /// - Returns: new instances of the default coach views.
    open func defaultCoachViewsWithArrow(
        _ withArrow: Bool = true,
        withNextText: Bool = true,
        arrowOrientation: CoachMarkArrowOrientation? = .top
    ) -> (bodyView: CoachMarkBodyDefaultView, arrowView: CoachMarkArrowDefaultView?) {

        var coachMarkBodyView: CoachMarkBodyDefaultView

        if withNextText {
            coachMarkBodyView = CoachMarkBodyDefaultView()
        } else {
            coachMarkBodyView = CoachMarkBodyDefaultView(hintText: "", nextText: nil)
        }

        var coachMarkArrowView: CoachMarkArrowDefaultView? = nil

        if withArrow {
            var arrowOrientation = arrowOrientation

            if arrowOrientation == nil {
                arrowOrientation = .top
            }

            coachMarkArrowView = CoachMarkArrowDefaultView(orientation: arrowOrientation!)
        }

        return (bodyView: coachMarkBodyView, arrowView: coachMarkArrowView)
    }

    /// Provides default coach views, can have a next label or just the message.
    ///
    /// - Parameter withArrow: `true` to return an instance of
    ///                        `CoachMarkArrowDefaultView` as well, `false` otherwise.
    /// - Parameter arrowOrientation: orientation of the arrow (either .Top or .Bottom)
    /// - Parameter hintText: message to show in the CoachMark
    /// - Parameter nextText: text for the next label, if nil the CoachMark
    ///                       view will only show the hint text
    ///
    /// - Returns: new instances of the default coach views.
    open func defaultCoachViewsWithArrow(
        _ withArrow: Bool = true,
        arrowOrientation: CoachMarkArrowOrientation? = .top,
        hintText: String,
        nextText: String?
    ) -> (bodyView: CoachMarkBodyDefaultView, arrowView: CoachMarkArrowDefaultView?) {

        let coachMarkBodyView = CoachMarkBodyDefaultView(hintText: hintText, nextText: nextText)

        var coachMarkArrowView: CoachMarkArrowDefaultView? = nil

        if withArrow {
            var arrowOrientation = arrowOrientation

            if arrowOrientation == nil {
                arrowOrientation = .top
            }

            coachMarkArrowView = CoachMarkArrowDefaultView(orientation: arrowOrientation!)
        }

        return (bodyView: coachMarkBodyView, arrowView: coachMarkArrowView)
    }

    //MARK: - Public methods -
    /// Start displaying the coach marks.
    ///
    /// - Parameter parentViewController: View Controller to which attach self.
    open func startOn(_ parentViewController: UIViewController) {
        guard let dataSource = self.dataSource else {
            print("startOn: Snap! You didn't setup any datasource, the" +
                  "coach mark manager won't do anything.")
            return
        }

        // If coach marks are currently being displayed, calling `start()` doesn't do anything.
        if self.started { return }

        self.attachToViewController(parentViewController)

        // We make sure we are in a idle state and get the number of coach marks to display
        // from the datasource.
        self.currentIndex = -1
        self.numberOfCoachMarks = dataSource.numberOfCoachMarksForCoachMarksController(self)

        if self.numberOfCoachMarks == 0 {
            self.detachFromViewController()
            return
        }

        self.overlayView.prepareForFade()

        if let skipViewDisplayManager = self.skipViewDisplayManager {
            self.skipView?.skipControl?.addTarget(self,
                action: #selector(CoachMarksController.skipCoachMarksTour(_:)),
                for: .touchUpInside
            )

            skipViewDisplayManager.addSkipView()
            updateSkipViewConstraints()
        }

        UIView.animate(withDuration: self.overlayFadeAnimationDuration, animations: { () -> Void in
            self.overlayView.alpha = 1.0
            self.skipViewAsView?.alpha = 1.0
        }, completion: { (finished: Bool) -> Void in
            // The view was previously hidden, to prevent it from catching the user input.
            // Now, we want exactly the opposite. We want the overlay view to prevent events
            // from reaching down.
            self.view.isUserInteractionEnabled = true

            self.showNextCoachMark()
        })
    }

    open func stop(immediately: Bool = false) {
        if immediately {
            self.overlayView.layer.removeAllAnimations()
            self.skipViewAsView?.layer.removeAllAnimations()
            self.currentCoachMarkView?.layer.removeAllAnimations()

            self.overlayView.removeFromSuperview()
            self.skipViewAsView?.removeFromSuperview()
            self.currentCoachMarkView?.removeFromSuperview()

            self.skipViewAsView = nil
            self.currentCoachMarkView = nil

            self.disableFlow = true

            self.stopFlow(withAnimation: false, userDidSkip: false, shouldCallDelegate: false)
        } else {
            self.stopFlow()
        }
    }

    /// Stop displaying the coach marks and perform some cleanup.
    ///
    /// - Parameter withAnimation: `true` to fade the coach marks / overlay visibility
    ///                            `false` otherwise.
    /// - Parameter userDidSkip: `true` when the user canceled the flow, `false` otherwise.
    /// - Parameter shouldCallDelegate: `true` to notify the delegate that the flow
    ///                                 was stop.
    internal func stopFlow(
        withAnimation animate: Bool = true,
        userDidSkip skipped: Bool = false,
        shouldCallDelegate: Bool = true
    ) {
        let animationDuration: TimeInterval

        if animate {
            animationDuration = self.overlayFadeAnimationDuration
        } else {
            animationDuration = 0.0
        }

        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            self.overlayView.alpha = 0.0
            self.skipViewAsView?.alpha = 0.0
            self.currentCoachMarkView?.alpha = 0.0
        }, completion: {(finished: Bool) -> Void in
            self.skipView?.skipControl?.removeTarget(self,
                action: #selector(CoachMarksController.skipCoachMarksTour(_:)),
                for: .touchUpInside
            )

            self.reset()
            self.detachFromViewController()

            if shouldCallDelegate {
                // Calling the delegate, maybe the user wants to do something?
                self.delegate?.didFinishShowingFromCoachMarksController(self)
                self.delegate?.coachMarksController(self, didFinishShowingAndWasSkipped: skipped)
            }

        })
    }

    /// Pause the display.
    /// This method is expected to be used by the delegate to
    /// top the display, perform animation and resume display with `play()`
    open func pause() {
        self.paused = true
    }

    /// Resume the display.
    /// If the display wasn't paused earlier, this method won't do anything.
    open func resume() {
        if self.started && self.paused {
            self.paused = false
            self.createAndShowCoachMark(shouldCallDelegate: false)
        }
    }

    //MARK: - Private methods -
    /// Return the controller into an idle state.
    fileprivate func reset() {
        self.numberOfCoachMarks = 0
        self.currentIndex = -1

        self.currentCoachMark = nil
        self.currentCoachMarkView = nil
    }

    /// Show the next specified Coach Mark.
    ///
    /// - Parameter numberOfCoachMarksToSkip: the number of coach marks
    ///                                       to skip.
    open func showNext(numberOfCoachMarksToSkip numberToSkip: Int = 0) {
        if !self.started || !canShowCoachMark { return }

        if numberToSkip < 0 {
            print("showNext: The specified number of coach marks to skip" +
                  "was negative, nothing to do.")
            return
        }

        if numberToSkip != -1 {
            self.currentIndex += numberToSkip
        }

        self.showNextCoachMark(hidePrevious: true)
    }

    /// Will attach the controller as a child of the given view controller. This will
    /// allow the coach mark controller to respond to size changes, though
    /// `instructionsTopView` will be a subview of `UIWindow`.
    ///
    /// - Parameter parentViewController: the controller of which become a child
    fileprivate func attachToViewController(_ parentViewController: UIViewController) {
        guard let window = parentViewController.view?.window else {
            print("attachToViewController: Instructions could not be properly" +
                  "attached to the window, did you call `startOn` inside" +
                  "`viewDidLoad` instead of `ViewDidAppear`?")

            return
        }

        parentViewController.addChildViewController(self)
        parentViewController.view.addSubview(self.view)

        self.instructionsTopView.translatesAutoresizingMaskIntoConstraints = false

        window.addSubview(self.instructionsTopView)

        window.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[instructionsTopView]|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["instructionsTopView": self.instructionsTopView]
        ))

        window.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[instructionsTopView]|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["instructionsTopView": self.instructionsTopView]
        ))

        // If we're in the background we'll manually lay out the view.
        //
        // `instructionsTopView` is not laid out automatically in the
        // background, likely because it's added to the window.
        #if !INSTRUCTIONS_APP_EXTENSIONS
            if UIApplication.shared.applicationState == .background {
                window.layoutIfNeeded()
            }
        #else
            window.layoutIfNeeded()
        #endif

        self.instructionsTopView.backgroundColor = UIColor.clear

        self.didMove(toParentViewController: parentViewController)
    }

    /// Detach the controller from its parent view controller.
    fileprivate func detachFromViewController() {
        self.instructionsTopView.removeFromSuperview()

        self.willMove(toParentViewController: nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }

    /// Show the next coach mark and hide the current one.
    ///
    /// - Parameter hidePrevious: `true` to hide the previously shown coach mark,
    ///                           `false` otherwise.
    fileprivate func showNextCoachMark(hidePrevious: Bool = true) {
        if disableFlow || paused || !canShowCoachMark { return }
        self.instructionsTopView.isUserInteractionEnabled = false
        self.canShowCoachMark = false

        self.currentIndex += 1

        // if `currentIndex` is above 0, that means a previous coach mark
        // is displayed. We call the delegate to notify that the current coach
        // mark will disappear, and only then, we hide the coach mark.
        if self.currentIndex > 0 {
            if let currentCoachMark = self.currentCoachMark {
                self.delegate?.coachMarksController(self,
                    coachMarkWillDisappear: currentCoachMark,
                    forIndex: self.currentIndex - 1
                )
            }

            if hidePrevious {
                guard let currentCoachMark = self.currentCoachMark else {
                    return
                }

                self.coachMarkDisplayManager.hideCoachMarkView(
                    currentCoachMarkView,
                    animationDuration: currentCoachMark.animationDuration,
                    completion: {
                        self.removeTargetFromCurrentCoachView()

                        if self.currentIndex < self.numberOfCoachMarks {
                            self.createAndShowCoachMark()
                        } else {
                            self.stopFlow()
                        }
                    }
                )
            } else {
                if self.currentIndex < self.numberOfCoachMarks {
                    self.createAndShowCoachMark()
                } else {
                    self.stopFlow()
                }
            }
        } else {
            self.createAndShowCoachMark()
        }
    }

    /// Add the overlay view which will blur/dim the background.
    fileprivate func addOverlayView() {
        self.instructionsTopView.addSubview(self.overlayView)

        self.instructionsTopView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[overlayView]|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["overlayView": self.overlayView]
            )
        )

        self.instructionsTopView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[overlayView]|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["overlayView": self.overlayView]
            )
        )

        self.overlayView.alpha = 0.0
    }

    /// Ask the datasource, create the coach mark and display it. Also
    /// notifies the delegate. When this method is called during a size change,
    /// the delegate is not notified.
    ///
    /// - Parameter shouldCallDelegate: `true` to call delegate methods, `false` otherwise.
    /// - Parameter noAnimation: `true` to show the coachmark without fade, `false` otherwise.
    fileprivate func createAndShowCoachMark(
        shouldCallDelegate: Bool = true,
        noAnimation: Bool = false
    ) {
        if disableFlow { return }

        if instructionsTopView.bounds.isEmpty {
            print("The overlay view added to the window has empty bounds, Instructions will stop.")
            self.stopFlow()
            return
        }

        if let delegate = self.delegate {
            let shouldLoad = delegate.coachMarksController(
                self, coachMarkWillLoadForIndex: self.currentIndex
            )

            if !shouldLoad {
                self.canShowCoachMark = true
                showNextCoachMark(hidePrevious: false)
                return
            }
        }

        // Retrieves the current coach mark structure from the datasource.
        // It can't be nil, that's why we'll force unwrap it everywhere.
        self.currentCoachMark = self.dataSource!.coachMarksController(
            self, coachMarksForIndex: self.currentIndex
        )

        // The coach mark will soon show, we notify the delegate, so it
        // can perform some things and, if required, update the coach mark structure.
        if shouldCallDelegate {
            self.delegate?.coachMarksController(self,
                coachMarkWillShow: &self.currentCoachMark!,
                forIndex: self.currentIndex
            )
        }

        // The delegate might have paused the flow, he check whether or not it's
        // the case.
        if !self.paused {
            currentCoachMark!.computeMetadataForFrame(self.instructionsTopView.frame)

            currentCoachMarkView = coachMarkDisplayManager.createCoachMarkViewFromCoachMark(
                currentCoachMark!, withIndex: self.currentIndex
            )

            addTargetToCurrentCoachView()

            coachMarkDisplayManager.displayCoachMarkView(
                self.currentCoachMarkView!,
                coachMark: self.currentCoachMark!,
                noAnimation: noAnimation,
                completion: {
                    self.instructionsTopView.isUserInteractionEnabled = true
                    self.canShowCoachMark = true
                }
            )
        }
    }

    /// Add touch up target to the current coach mark view.
    fileprivate func addTargetToCurrentCoachView() {
        self.currentCoachMarkView?.nextControl?.addTarget(self,
            action: #selector(CoachMarksController.performShowNextCoachMark(_:)),
            for: .touchUpInside
        )
    }

    /// Remove touch up target from the current coach mark view.
    fileprivate func removeTargetFromCurrentCoachView() {
        self.currentCoachMarkView?.nextControl?.removeTarget(self,
            action: #selector(CoachMarksController.performShowNextCoachMark(_:)),
            for: .touchUpInside
        )
    }

    /// Will remove currently displayed coach mark.
    fileprivate func prepareForSizeTransition() {
        self.disableFlow = true
        self.currentCoachMarkView?.layer.removeAllAnimations()
        self.removeTargetFromCurrentCoachView()
        self.skipViewDisplayManager?.hideSkipView()

        self.coachMarkDisplayManager.hideCoachMarkView(
            self.currentCoachMarkView,
            animationDuration: 0
        )

        self.currentCoachMarkView = nil
    }

    /// Will re-add the current coach mark
    fileprivate func restoreAfterSizeTransitionDidComplete() {
        self.disableFlow = false
        self.overlayView.alpha = 1.0
        self.updateSkipViewConstraints()
        self.skipViewAsView?.alpha = 1.0
        self.createAndShowCoachMark(shouldCallDelegate: false, noAnimation: true)
    }

    /// Same as `prepareForSizeTransition`, but for status bar changes.
    func prepareForStatusBarChange() {
        if !onGoingSizeChange {
            prepareForSizeTransition()
        }
    }

    /// Same as `restoreAfterSizeTransitionDidComplete`, but for status bar changes.
    func restoreAfterStatusBarChangeDidComplete() {
        if !onGoingSizeChange {
            prepareForSizeTransition()
            restoreAfterSizeTransitionDidComplete()
        }
    }

    /// Update the constraints defining the position of the "Skip" view.
    fileprivate func updateSkipViewConstraints() {
        guard let skipView = self.skipViewAsView,
                  let skipViewDisplayManager = self.skipViewDisplayManager else {
            return
        }

        let layoutConstraints = self.dataSource?.coachMarksController(self,
            constraintsForSkipView: skipView,
            inParentView: self.instructionsTopView
        )

        skipViewDisplayManager.updateSkipViewConstraintsWithConstraints(layoutConstraints)
    }

    fileprivate func registerForStatusBarFrameChanges() {
        let notificationCenter = NotificationCenter.default

        notificationCenter.addObserver(self,
            selector: #selector(prepareForStatusBarChange),
            name: NSNotification.Name.UIApplicationWillChangeStatusBarFrame,
            object: nil
        )

        notificationCenter.addObserver(self,
            selector: #selector(restoreAfterStatusBarChangeDidComplete),
            name: NSNotification.Name.UIApplicationDidChangeStatusBarFrame,
            object: nil
        )
    }

    fileprivate func unregisterFromStatusBarFrameChanges() {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: - Protocol Conformance | OverlayViewDelegate -
extension CoachMarksController: OverlayViewDelegate {
    func didReceivedSingleTap() {
        if self.paused { return }

        self.showNextCoachMark()
    }
}

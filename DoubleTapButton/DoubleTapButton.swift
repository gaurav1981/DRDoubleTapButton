//
//  DoubleTapButton.swift
//  DoubleTapButton
//
//  Created by Diego Rueda on 17/07/15.
//  Copyright (c) 2015 Diego Rueda. All rights reserved.
//

import UIKit

@IBDesignable
public class DoubleTapButton: UIView {
    
/// MARK: Elements
    
    lazy var primaryButton: UIButton = {
        let button = UIButton()
        
        button.setTitle(self.primaryText, forState: .Normal)
        button.backgroundColor = self.primaryBgColor
        
        return button
    }()
    
    lazy var confirmButton: UIButton = {
        let button = UIButton()
        
        button.setTitle(self.confirmText, forState: .Normal)
        button.backgroundColor = self.confirmBgColor
        
        return button
    }()
    
    lazy var label: UILabel = {
        let tempLabel = UILabel()
        
        tempLabel.text = self.successText
        tempLabel.textColor = self.successTxtColor
        tempLabel.textAlignment = .Center
        tempLabel.backgroundColor = self.successBgColor
        
        return tempLabel
    }()
    
/// MARK: Frame properties
    
    /** Corner Radius of the frame
        Default to empty (no radius) */
    @IBInspectable var borderRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    /** Border Width of the frame
        Default to empty (no border) */
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    /** Border Color of the frame
        Default to empty (no color) */
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(CGColor: layer.borderColor)
        }
        set {
            layer.borderColor = newValue?.CGColor
        }
    }
    
/// MARK: Common Buttons properties
    
    /// To move the button horizontally outside the frame
    lazy var horizontalSlide: CGFloat = {
        return -self.boundsWidth / 2
    }()

    /// To move the button vertically outside the frame
    lazy var verticalSlide: CGFloat = {
        return -self.boundsHeight / 2
    }()
    
    /// To return button to its original position after slide it
    var originalCenter: CGPoint!
    
    /// Duration of the button slide animation
    var animationDuration: NSTimeInterval = 0.5
    
    /** Controls the sliding direction for the buttons. 
        If true, buttons slide horizontal
        If false, buttons slides vertical 
        Default: slides horizontally */
    @IBInspectable var slidesHorizontally: Bool = true
    
/// MARK: Primary Button properties
    
    /** Controls if the primary button reacts to a single tap or to pan gesture
        Default: false - only reacts to pan gesture */
    @IBInspectable var reactsToTap: Bool = false
    
    /** Text for the primary button 
        Be sure that it fits the button 
        Default to "DO SOMETHING" */
    @IBInspectable var primaryText: String = "DO SOMETHING" {
        didSet {
            primaryButton.setTitle(primaryText, forState: .Normal)
        }
    }
    
    /** Text color for the primary button 
        Be sure that it's different than primaryBgColor to make it readable
        Default to blue */
    @IBInspectable var primaryTxtColor: UIColor? = UIColor.blueColor() {
        didSet {
            primaryButton.setTitleColor(primaryTxtColor, forState: .Normal)
        }
    }
    
    /** Background color for the primary button
        Be sure that it's different than primaryTxtColor to make it readable
        Default to white */
    @IBInspectable var primaryBgColor: UIColor? = UIColor.whiteColor() {
        didSet {
            primaryButton.backgroundColor = primaryBgColor
        }
    }
    
    /** Name of the background image of the primary button
        Only implemented for primaryButton (adds an image that gives feedback to user that is draggable)
        If empty, no image is applied
        Default to empty */
    @IBInspectable var bgImageName: String = "" {
        didSet {
            let bgImage = UIImage(named: bgImageName)
            primaryButton.setBackgroundImage(bgImage, forState: .Normal)
        }
    }
    
/// MARK: Confirm Button properties
    
    /** Text for the confirm button
        Be sure that it fits the button
        Default to "CONFIRM" */
    @IBInspectable var confirmText: String = "CONFIRM" {
        didSet {
            confirmButton.setTitle(confirmText, forState: .Normal)
        }
    }
    
    /** Text color for the confirm button
        Be sure that it's different than confirmBgColor to make it readable */
    @IBInspectable var confirmTxtColor: UIColor = UIColor.whiteColor() {
        didSet {
            confirmButton.setTitleColor(confirmTxtColor, forState: .Normal)
        }
    }

    /// Background color for the confirm button. Be sure that it's different than confirmTxtColor to make it readable
    @IBInspectable var confirmBgColor: UIColor = UIColor.whiteColor() {
        didSet {
            confirmButton.backgroundColor = confirmBgColor
        }
    }
    
/// MARK: Function to call in confirm button

    /** Function that calls the confirm button
        You must define it in code (IBInspectable doesn't accept function type)
        It must be a reference to a function wich returns a boolean, but you can change the implementation
        
        @remark Just be sure to change it also in **confirmTap()** when it is used. Default to (() -> true)
        
        Functions can be assigned in the ViewController in this way:
        
        @code
            func redButtonPushed() -> Bool {
            /// Do something and then return boolean
            return false
            }
        @endcode
    */
    var functionToCall: () -> Bool = { return false }
    
/// MARK: Label properties

    /** Text for label when confirm button returns a success message
        Defatul to "SUCCESS" */
    @IBInspectable var successText: String = "SUCCESS" {
        didSet {
            label.text = successText
        }
    }
    
    /** Text color for label when confirm button returns a success message
        Default to green */
    @IBInspectable var successTxtColor: UIColor? = UIColor.greenColor()
    
    /** Background color for label when confirm button returns a success message
        Default to white */
    @IBInspectable var successBgColor: UIColor? = UIColor.whiteColor()
    
    /** Text for label when confirm button returns an error message
        Default to "ERROR" */
    @IBInspectable var errorText: String = "ERROR" {
        didSet {
            label.text = errorText
        }
    }
    
    /** Text color for label when confirm button returns an error message
        Default to red */
    @IBInspectable var errorTxtColor: UIColor? = UIColor.redColor()
    
    /** Background color for label when confirm button returns an error message
        Default to white */
    @IBInspectable var errorBgColor: UIColor? = UIColor.whiteColor()

/// MARK: Initialization
    
    lazy var boundsWidth: CGFloat = {
        return self.bounds.size.width
    }()
    
    lazy var boundsHeight: CGFloat = {
        return self.bounds.size.height
    }()
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    /// Users can use both init functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    /// Initialize the component
    func setup() {
        
        clipsToBounds = true
        
        addSubview(label)
        addSubview(confirmButton)
        addSubview(primaryButton)
    }
    
    /// Called when the system wants update a layout
    override public func layoutSubviews() {
        
        primaryButton.frame = CGRect(x: 0, y: 0, width: boundsWidth, height: boundsHeight)
        originalCenter = primaryButton.center
        
        confirmButton.frame = CGRect(x: 0, y: 0, width: boundsWidth, height: boundsHeight)
        
        label.frame = CGRect(x: 0, y: 0, width: boundsWidth, height: boundsHeight)
        
        /// Setting up actions for buttons
        if reactsToTap {
            primaryButton.addTarget(self, action: "slideElementOutOfFrame:", forControlEvents: .TouchDown)
        }
        else {
            /// Adding pan gesture to primary button
            let panReconigzer = UIPanGestureRecognizer(target: self, action: "primaryHandlePan:")
            panReconigzer.maximumNumberOfTouches = 1
            primaryButton.addGestureRecognizer(panReconigzer)
        }
        
        confirmButton.addTarget(self, action: "confirmTap:", forControlEvents: .TouchDown)
    }
    
/// MARK: Button actions handlers
    
    /** Pan gesture of primary button
        When user slide the button beyond the center of the frame, it slides out of the frame */
    @IBAction func primaryHandlePan(gesture: UIPanGestureRecognizer) {
        
        switch gesture.state {
        case .Changed:
           
            if slidesHorizontally {
                slideElementHorizontally(primaryButton, panGesture: gesture)
            }
            else {
                slideElementVertically(primaryButton, panGesture: gesture)
            }
            
        case .Ended:
            
            if isHalfOutOfFrame(primaryButton) {
                slideElementOutOfFrame(primaryButton)
            }
            else {
                slideElementToOriginalPosition(primaryButton)
            }
            
        default: break
        }
    }
    
    func slideElementHorizontally(element: UIControl, panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translationInView(primaryButton)
        
        let minXTranslation = originalCenter.x - boundsWidth
        let maxXTranslation = originalCenter.x + boundsWidth
        
        element.center.x = max(minXTranslation,
            min(maxXTranslation, element.center.x + translation.x))
        
        panGesture.setTranslation(CGPointZero, inView: primaryButton)
    }
    
    func slideElementVertically(element: UIControl, panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translationInView(primaryButton)
        
        let minXTranslation = originalCenter.y - boundsWidth
        let maxXTranslation = originalCenter.y + boundsWidth
        
        element.center.y = max(minXTranslation,
            min(maxXTranslation, element.center.y + translation.y))

        panGesture.setTranslation(CGPointZero, inView: primaryButton)
    }
    
    func isHalfOutOfFrame(element: UIControl) -> Bool {
        return element.center.x <= 0 || element.center.y <= 0
    }
    
    /** Tap in the confirm button
        Calls to **functionToCall** to manage the response
        @remark functionToCall() returns a Boolean. If you want to change this definition, change also the functionToCall variable definition */
    @IBAction func confirmTap(sender: UIButton) {
        
        if functionToCall() {
            label.text = successText
            label.textColor = successTxtColor
            label.backgroundColor = successBgColor
            
            slideElementOutOfFrame(confirmButton)
        }
        else {
            label.text = errorText
            label.textColor = errorTxtColor
            label.backgroundColor = errorBgColor
            
            slideElementOutOfFrame(confirmButton)
            
            /// Reset the button if returns error
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.slideElementToOriginalPosition(self.primaryButton)
                self.slideElementToOriginalPosition(self.confirmButton)
            }
        }
    }
    
    /// Slides button out of the frame if the user slide it beyond the center of the component or if he taps in the primary button when primaryButtonReactsToTap is true
    func slideElementOutOfFrame(element: UIControl) {
        UIView.animateWithDuration(animationDuration, animations: {
            if self.slidesHorizontally {
                element.center.x = self.horizontalSlide
            }
            else {
                element.center.y = self.verticalSlide
            }
        })
    }
    
    /// Returns button to its original position when user doesn't slide it beyond the center of the component
    func slideElementToOriginalPosition(element: UIControl) {
        if element.center != originalCenter {
            UIView.animateWithDuration(animationDuration) {
                element.center = self.originalCenter
            }
        }
    }
}
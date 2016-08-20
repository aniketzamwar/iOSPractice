//
//  RatingControl.swift
//  FoodTracker
//
//  Created by Aniket Zamwar on 8/19/16.
//  Copyright © 2016 Aniket Zamwar. All rights reserved.
//

import UIKit

class RatingControl: UIView {
    
    // Mark: Properties
    
    var rating = 0 {
        didSet {
            // change of rating will trigger layout update 
            // to refresh the contents visible on UI
            self.setNeedsLayout()
        }
    }
    
    var ratingButtons = [UIButton]()
    let spacing = 5
    let starCount = 5

    override var intrinsicContentSize: CGSize {
        get {
            let buttonSize = Int(frame.size.height)
            let width = (buttonSize * starCount) + (spacing * (starCount - 1))
            
            return CGSize(width: width, height: buttonSize)
        }
    }

    // Mark: Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        frame.size.height = 44
        let filledStar = UIImage(named: "filledStar")
        let emptyStar = UIImage(named: "emptyStar")
        
        for _ in 0..<starCount {
            let button = UIButton()
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(filledStar, for: [.highlighted, .selected])
            button.adjustsImageWhenHighlighted = false
            
            button.addTarget(self, action: #selector(RatingControl.ratingButtonTapped(button:)), for: .touchDown)
            ratingButtons += [button]
            addSubview(button)
        }
        
        self.updateButtonSelectionStates()
    }
    
    // The layoutSubviews method gets called at the appropriate time by the system
    // and gives UIView subclasses a chance to perform a precise layout of their subviews. 
    // We need to override this method to place the buttons appropriately.
    override func layoutSubviews() {
        let buttonSize = Int(frame.size.height)
        var buttonFrame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        
        for (index, button) in ratingButtons.enumerated() {
            buttonFrame.origin.x = CGFloat(index * (buttonSize + spacing))
            button.frame = buttonFrame
        }
        
        self.updateButtonSelectionStates()
    }
    
    // Mark: Button Action
    func ratingButtonTapped(button: UIButton) {
        self.rating = ratingButtons.index(of: button)! + 1
        
        self.updateButtonSelectionStates()
    }
    
    func updateButtonSelectionStates() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
    
}

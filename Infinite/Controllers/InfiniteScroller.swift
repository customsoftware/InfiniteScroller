//
//  InfiniteScroller.swift
//  Infinite
//
//  Created by Kenneth Cluff on 6/6/19.
//  Copyright © 2019 Kenneth Cluff. All rights reserved.
//

import UIKit

enum NewFrameRelativeLocation {
    case above
    case below
    case same
}

class InfiniteScroller: UIScrollView {
    let cellHeight: CGFloat = 150
    
    var contentView: UIView?
    var currentFirstPointer = 0
    var currentLastPointer = 0
    var displayedModeratorViews = [DataView]()
    weak var passThroughDelegate: ShowLink?
    
    func configureView(in containerView: UIView) {
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        contentSize = CGSize(width: containerView.frame.width, height: containerView.frame.height * 5)
        contentView = subviews.first
        initialLoad()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        recenterIfNecessary()
        
        let visibleBounds = self.bounds
        let minimumVisibleY = visibleBounds.minY
        let maximumVisibleY = visibleBounds.maxY
        tileImagesFrom(from: minimumVisibleY, to: maximumVisibleY)
    }
}

fileprivate extension InfiniteScroller {
    func recenterIfNecessary() {
        let currentOffset = contentOffset
        let contentHeight = contentSize.height
        let centerOffsetY = (contentHeight - bounds.size.height)/2
        let distanceFromCenter = abs(currentOffset.y - centerOffsetY)
        
        if distanceFromCenter > (contentHeight/4) {
            self.contentOffset = CGPoint(x: currentOffset.x, y: centerOffsetY)
            
            displayedModeratorViews.forEach({
                var center = $0.center
                center.y += (centerOffsetY - currentOffset.y)
                $0.center = center
            })
        }
    }
    
    func tileImagesFrom(from minVisibleY: CGFloat, to maxVisibleY: CGFloat) {
        if displayedModeratorViews.count == 0,
            let monitor = ModeratorManager.shared.getModeratorAt(index: currentFirstPointer) {
            let newModeratorView = insertModerator()
            newModeratorView.owningModerator = monitor
            newModeratorView.delegate = passThroughDelegate
            let newFrame = setGetNextFrame(currentY: minVisibleY, in: .same)
            newModeratorView.frame = newFrame
            displayedModeratorViews.append(newModeratorView)
            currentLastPointer += 1
            currentFirstPointer -= 1
            print("Pointers set at initial: \(currentFirstPointer) - \(currentLastPointer)")
        }
        
        // Add moderators below visible
        if let lastModerator = displayedModeratorViews.last {
            var bottomEdge = lastModerator.frame.minY
            while bottomEdge < maxVisibleY {
                bottomEdge = addNewModeratorsBelow(bottom: bottomEdge, for: currentLastPointer)
            }
        }

        // Add moderators above visible
        if let firstModerator = displayedModeratorViews.first {
            var topEdge = firstModerator.frame.minY
            while topEdge > minVisibleY {
                topEdge = addNewModeratorsAbove(top: topEdge, for: currentFirstPointer)
            }
        }

        // Remove moderators below
        if var lastModerator = displayedModeratorViews.last {
            while lastModerator.frame.minY > maxVisibleY {
                lastModerator.removeFromSuperview()
                displayedModeratorViews.removeLast()
                if let last = displayedModeratorViews.last {
                    lastModerator = last
                }
                
                bumpDown(counter: &currentLastPointer)
            }
        }

        // Remove moderators above
        if var firstModerator = displayedModeratorViews.first {
            while firstModerator.frame.maxY < minVisibleY {
                firstModerator.removeFromSuperview()
                displayedModeratorViews.removeFirst()
                firstModerator = displayedModeratorViews[0]
                bumpUp(counter: &currentFirstPointer)
            }
        }
    }
    
    func bumpDown(counter: inout Int, _ shouldPrint: Bool = false) {
        if counter == 0 {
            counter = ModeratorManager.shared.getNumberOfModerators()
        }
        counter -= 1
        if shouldPrint {
            print("Bumped down Counter: \(counter)")
        }
    }
    
    func bumpUp(counter: inout Int, _ shouldPrint: Bool = false) {
        let workingCounter = ModeratorManager.shared.getNumberOfModerators()
        if counter == (workingCounter - 1) {
            counter = -1
        }
        counter += 1
        if shouldPrint {
            print("Bumped up Counter: \(counter)")
        }
    }
    
    func setGetNextFrame(currentY: CGFloat, in position: NewFrameRelativeLocation) -> CGRect {
        let offSet: CGFloat
        switch position {
        case .same:
            offSet = 0
        case .above:
            offSet = -150
        case .below:
            offSet = 150
        }
        
        return CGRect(x: 0, y: currentY + offSet, width: contentSize.width, height: cellHeight)
    }
    
    func insertModerator() -> DataView {
        let newView = Bundle.main.loadNibNamed("ModeratorView", owner: nil, options: nil)?.first as! DataView
        newView.delegate = passThroughDelegate
        addSubview(newView)
        return newView
    }
    
    func addNewModeratorsAbove(top: CGFloat, for startingIndex: Int) -> CGFloat {
        let newModeratorView = insertModerator()
        displayedModeratorViews.insert(newModeratorView, at: 0)
        let moderator = ModeratorManager.shared.getModeratorAt(index: currentFirstPointer)
        newModeratorView.owningModerator = moderator
        newModeratorView.delegate = passThroughDelegate
        newModeratorView.indexer.text = "\(currentFirstPointer + 1)"
        bumpDown(counter: &currentFirstPointer)
        newModeratorView.frame = setGetNextFrame(currentY: top, in: .above)
        return newModeratorView.frame.minY
    }
    
    func addNewModeratorsBelow(bottom: CGFloat, for endingIndex: Int) -> CGFloat {
        let newModeratorView = insertModerator()
        displayedModeratorViews.append(newModeratorView)
        let moderator = ModeratorManager.shared.getModeratorAt(index: currentLastPointer)
        newModeratorView.owningModerator = moderator
        newModeratorView.delegate = passThroughDelegate
        newModeratorView.indexer.text = "\(currentLastPointer + 1)"
        bumpUp(counter: &currentLastPointer)
        newModeratorView.frame = setGetNextFrame(currentY: bottom, in: .below)
        return newModeratorView.frame.minY
    }
    
    func initialLoad() {
        let maxCount = ModeratorManager.shared.getNumberOfModerators()
        let displayableCount = self.bounds.height / cellHeight
        let displayIndexOffset = Int(displayableCount/2)
        let midCount = maxCount/2
        let startCount = midCount - displayIndexOffset
        currentFirstPointer = startCount
        currentLastPointer = startCount
    }
}
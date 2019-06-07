//
//  InfiniteScroller.swift
//  Infinite
//
//  Created by Kenneth Cluff on 6/6/19.
//  Copyright © 2019 Kenneth Cluff. All rights reserved.
//

import UIKit

class InfiniteScroller: UIScrollView {
    let cellHeight: CGFloat = 150
    
    var contentView: UIView?
    var currentFirstPointer = 0
    var currentLastPointer = 0
    var displayedModeratorViews = [DataView]()
    weak var passThroughDelegate: ShowLink?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        recenterIfNecessary()
        
        let visibleBounds = self.bounds
        let minimumVisibleY = visibleBounds.minY
        let maximumVisibleY = visibleBounds.maxY
        tileImagesFrom(from: minimumVisibleY, to: maximumVisibleY)
    }
    
    func configureView(in containerView: UIView) {
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        contentSize = CGSize(width: containerView.frame.width, height: containerView.frame.height * 5)
        contentView = subviews.first
        initialLoad()
    }
    
    func refreshArt() {
        displayedModeratorViews.forEach({
            guard let moderatorUserID = $0.owningModerator?.userID,
                let moderator = ModeratorManager.shared.getModerator(with: moderatorUserID) else { return }
            
            $0.moderatorImage.image = moderator.userImage
        })
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
        addFirstTile(at: minVisibleY)
        addTrailingModerators(from: maxVisibleY)
        addPrecedingModerators(from: minVisibleY)
        removeTrailingModerators(from: maxVisibleY)
        removePrecedingModerators(from: minVisibleY)
    }
    
    func addFirstTile(at scrollPosition: CGFloat) {
        guard displayedModeratorViews.count == 0 else { return }
        let newModeratorView = createNewModeratorView(for: currentFirstPointer)
        let newFrame = getNextFrame(currentY: scrollPosition, in: .same)
        newModeratorView.frame = newFrame
        displayedModeratorViews.append(newModeratorView)
        currentLastPointer += 1
        currentFirstPointer -= 1
    }
    
    func addTrailingModerators(from scrollPosition: CGFloat) {
        if let lastModerator = displayedModeratorViews.last {
            var bottomEdge = lastModerator.frame.minY
            while bottomEdge < scrollPosition {
                bottomEdge = addNewModeratorsBelow(bottom: bottomEdge, for: currentLastPointer)
            }
        }
    }
    
    func addPrecedingModerators(from scrollPosition: CGFloat) {
        if let firstModerator = displayedModeratorViews.first {
            var topEdge = firstModerator.frame.minY
            while topEdge > scrollPosition {
                topEdge = addNewModeratorsAbove(top: topEdge, for: currentFirstPointer)
            }
        }
    }
    
    func removeTrailingModerators(from scrollPosition: CGFloat) {
        if var lastModerator = displayedModeratorViews.last {
            while lastModerator.frame.minY > scrollPosition {
                lastModerator.removeFromSuperview()
                displayedModeratorViews.removeLast()
                if let last = displayedModeratorViews.last {
                    lastModerator = last
                }
                
                bumpDown(counter: &currentLastPointer)
            }
        }
    }
    
    func removePrecedingModerators(from scrollPosition: CGFloat) {
        if var firstModerator = displayedModeratorViews.first {
            while firstModerator.frame.maxY < scrollPosition {
                firstModerator.removeFromSuperview()
                displayedModeratorViews.removeFirst()
                firstModerator = displayedModeratorViews[0]
                bumpUp(counter: &currentFirstPointer)
            }
        }
    }
    
    func bumpDown(counter: inout Int) {
        if counter == 0 {
            counter = ModeratorManager.shared.getNumberOfModerators()
        }
        counter -= 1
    }
    
    func bumpUp(counter: inout Int) {
        let workingCounter = ModeratorManager.shared.getNumberOfModerators()
        if counter == (workingCounter - 1) {
            counter = -1
        }
        counter += 1
    }
    
    func getNextFrame(currentY: CGFloat, in position: NewFrameRelativeLocation) -> CGRect {
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
    
    func createNewModeratorView(for index: Int) -> DataView {
        let newModeratorView = insertModerator()
        let moderator = ModeratorManager.shared.getModeratorAt(index: index)
        newModeratorView.owningModerator = moderator
        newModeratorView.delegate = passThroughDelegate
        newModeratorView.indexer.text = "\(index + 1)"
        return newModeratorView
    }
    
    func addNewModeratorsAbove(top: CGFloat, for startingIndex: Int) -> CGFloat {
        let newModeratorView = createNewModeratorView(for: currentFirstPointer)
        displayedModeratorViews.insert(newModeratorView, at: 0)
        bumpDown(counter: &currentFirstPointer)
        newModeratorView.frame = getNextFrame(currentY: top, in: .above)
        return newModeratorView.frame.minY
    }
    
    func addNewModeratorsBelow(bottom: CGFloat, for endingIndex: Int) -> CGFloat {
        let newModeratorView = createNewModeratorView(for: currentLastPointer)
        displayedModeratorViews.append(newModeratorView)
        bumpUp(counter: &currentLastPointer)
        newModeratorView.frame = getNextFrame(currentY: bottom, in: .below)
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

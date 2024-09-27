//
//  JiggleDocument.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 11/9/23.
//

import Foundation
import UIKit
import Combine

class JiggleDocument {
    
    var creatorMode = CreatorMode.none
    var documentMode = DocumentMode.__EDIT
    var editMode = EditMode.points
    var weightMode = WeightMode.points
    var isGuidesEnabled = true
    var isAnimationLoopsEnabled = false
    var isTimeLineEnabled = false
    
    func selectNextJiggle(displayMode: DisplayMode,
                          isGraphEnabled: Bool) {
        
        if let selectedJiggle = getSelectedJiggle() {
            var currentSelectedJiggleIndex = -1
            var checkJiggleIndex = selectedJiggleIndex + 1
            while (checkJiggleIndex < jiggleCount) && (currentSelectedJiggleIndex == -1) {
                let jiggle = jiggles[checkJiggleIndex]
                if jiggle !== selectedJiggle {
                    if jiggle.isFrozen == false {
                        currentSelectedJiggleIndex = checkJiggleIndex
                    }
                }
                checkJiggleIndex += 1
            }
            checkJiggleIndex = 0
            while (checkJiggleIndex < selectedJiggleIndex) && (currentSelectedJiggleIndex == -1) {
                let jiggle = jiggles[checkJiggleIndex]
                if jiggle !== selectedJiggle {
                    if jiggle.isFrozen == false {
                        currentSelectedJiggleIndex = checkJiggleIndex
                    }
                }
                checkJiggleIndex += 1
            }
            if currentSelectedJiggleIndex != -1 {
                switchSelectedJiggle(newSelectedJiggleIndex: currentSelectedJiggleIndex,
                                     displayMode: displayMode,
                                     isGraphEnabled: isGraphEnabled)
            }
        } else {
            var currentSelectedJiggleIndex = -1
            for jiggleIndex in 0..<jiggleCount {
                let jiggle = jiggles[jiggleIndex]
                if jiggle.isFrozen == false {
                    currentSelectedJiggleIndex = jiggleIndex
                    break
                }
            }
            switchSelectedJiggle(newSelectedJiggleIndex: currentSelectedJiggleIndex,
                                 displayMode: displayMode,
                                 isGraphEnabled: isGraphEnabled)
        }
    }
    
    func selectPreviousJiggle(displayMode: DisplayMode,
                              isGraphEnabled: Bool) {
        if let selectedJiggle = getSelectedJiggle() {
            var currentSelectedJiggleIndex = -1
            var checkJiggleIndex = selectedJiggleIndex - 1
            while (checkJiggleIndex >= 0) && (currentSelectedJiggleIndex == -1) {
                let jiggle = jiggles[checkJiggleIndex]
                if jiggle !== selectedJiggle {
                    if jiggle.isFrozen == false {
                        currentSelectedJiggleIndex = checkJiggleIndex
                    }
                }
                checkJiggleIndex -= 1
            }
            checkJiggleIndex = jiggleCount - 1
            while (checkJiggleIndex >= 0) && (currentSelectedJiggleIndex == -1) {
                let jiggle = jiggles[checkJiggleIndex]
                if jiggle !== selectedJiggle {
                    if jiggle.isFrozen == false {
                        currentSelectedJiggleIndex = checkJiggleIndex
                    }
                }
                checkJiggleIndex -= 1
            }
            if currentSelectedJiggleIndex != -1 {
                switchSelectedJiggle(newSelectedJiggleIndex: currentSelectedJiggleIndex,
                                     displayMode: displayMode,
                                     isGraphEnabled: isGraphEnabled)
            }
        } else {
            var currentSelectedJiggleIndex = -1
            for jiggleIndex in 0..<jiggleCount {
                let jiggle = jiggles[jiggleIndex]
                if jiggle.isFrozen == false {
                    currentSelectedJiggleIndex = jiggleIndex
                    break
                }
            }
            switchSelectedJiggle(newSelectedJiggleIndex: currentSelectedJiggleIndex,
                                 displayMode: displayMode,
                                 isGraphEnabled: isGraphEnabled)
        }
    }
    
    private func _selectWeightRing(jiggleWeightRing: JiggleWeightRing,
                                   displayMode: DisplayMode,
                                   isGraphEnabled: Bool) {
        for jiggleIndex in 0..<jiggleCount {
            let jiggle = jiggles[jiggleIndex]
            if jiggle.containsJiggleWeightRing(jiggleWeightRing) {
                if let newSelectedJiggleWeightRingIndex = jiggle.getJiggleWeightRingIndex(jiggleWeightRing) {
                    jiggle.switchSelectedWeightCurveControlIndex(index: newSelectedJiggleWeightRingIndex + 1)
                    switchSelectedJiggle(newSelectedJiggleIndex: jiggleIndex,
                                         displayMode: displayMode,
                                         isGraphEnabled: isGraphEnabled)
                }
                    
                return
            }
        }
    }
    
    func selectNextGuide(displayMode: DisplayMode,
                         isGraphEnabled: Bool) {
        var guideList = [JiggleWeightRing]()
        for jiggleIndex in 0..<jiggleCount {
            let jiggle = jiggles[jiggleIndex]
            if jiggle.isFrozen == false {
                let jiggleMesh = jiggle.jiggleMesh
                jiggleMesh.readAndSortValidWeightRings(jiggle: jiggle)
                for jiggleWeightRingIndex in 0..<jiggleMesh.jiggleWeightRingCount {
                    let jiggleWeightRing = jiggleMesh.jiggleWeightRings[jiggleWeightRingIndex]
                    if jiggleWeightRing.isFrozen == false {
                        guideList.append(jiggleWeightRing)
                    }
                }
            }
        }
        
        let guideListCount = guideList.count
        if guideListCount <= 0 { return }
        
        if let selectedJiggle = getSelectedJiggle(), let selectedWeightRing = selectedJiggle.getSelectedJiggleWeightRing() {
            
            var indexOfSelectedWeightRing = 0
            for index in 0..<guideListCount {
                if guideList[index] === selectedWeightRing {
                    indexOfSelectedWeightRing = index
                }
            }
            
            indexOfSelectedWeightRing += 1
            if indexOfSelectedWeightRing >= guideListCount {
                indexOfSelectedWeightRing = 0
            }
            
            _selectWeightRing(jiggleWeightRing: guideList[indexOfSelectedWeightRing],
                              displayMode: displayMode,
                              isGraphEnabled: isGraphEnabled)
            
        } else {
            _selectWeightRing(jiggleWeightRing: guideList[guideList.count - 1],
                              displayMode: displayMode,
                              isGraphEnabled: isGraphEnabled)
        }
    }
    
    func selectPreviousGuide(displayMode: DisplayMode,
                             isGraphEnabled: Bool) {
        var guideList = [JiggleWeightRing]()
        for jiggleIndex in 0..<jiggleCount {
            let jiggle = jiggles[jiggleIndex]
            if jiggle.isFrozen == false {
                let jiggleMesh = jiggle.jiggleMesh
                jiggleMesh.readAndSortValidWeightRings(jiggle: jiggle)
                for jiggleWeightRingIndex in 0..<jiggleMesh.jiggleWeightRingCount {
                    let jiggleWeightRing = jiggleMesh.jiggleWeightRings[jiggleWeightRingIndex]
                    if jiggleWeightRing.isFrozen == false {
                        guideList.append(jiggleWeightRing)
                    }
                }
            }
        }
        
        let guideListCount = guideList.count
        
        if guideListCount <= 0 { return }
        
        if let selectedJiggle = getSelectedJiggle(), let selectedWeightRing = selectedJiggle.getSelectedJiggleWeightRing() {
            var indexOfSelectedWeightRing = 0
            for index in 0..<guideListCount {
                if guideList[index] === selectedWeightRing {
                    indexOfSelectedWeightRing = index
                }
            }
            indexOfSelectedWeightRing -= 1
            if indexOfSelectedWeightRing < 0 {
                indexOfSelectedWeightRing = guideListCount - 1
            }
            _selectWeightRing(jiggleWeightRing: guideList[indexOfSelectedWeightRing],
                              displayMode: displayMode,
                              isGraphEnabled: isGraphEnabled)
        } else {
            _selectWeightRing(jiggleWeightRing: guideList[0],
                              displayMode: displayMode,
                              isGraphEnabled: isGraphEnabled)
        }
    }
    
    func selectNextJigglePoint(displayMode: DisplayMode,
                               isGraphEnabled: Bool) {
        if let selectedJiggle = getSelectedJiggle() {
            if selectedJiggle.jiggleControlPointCount > 1 {
                var newSelectedJiggleControlPointIndex = selectedJiggle.selectedJiggleControlPointIndex + 1
                if newSelectedJiggleControlPointIndex >= selectedJiggle.jiggleControlPointCount {
                    newSelectedJiggleControlPointIndex = 0
                }
                selectedJiggle.selectedJiggleControlPointIndex = newSelectedJiggleControlPointIndex
                switchSelectedJiggle(newSelectedJiggleIndex: selectedJiggleIndex,
                                     displayMode: displayMode,
                                     isGraphEnabled: isGraphEnabled)
            }
        } else {
            if jiggleCount > 0 {
                for jiggleIndex in 0..<jiggleCount {
                    let jiggle = jiggles[jiggleIndex]
                    if jiggle.jiggleControlPointCount > 0 {
                        if jiggle.isFrozen == false {
                            if jiggle.selectedJiggleControlPointIndex < 0 ||
                                jiggle.selectedJiggleControlPointIndex >= jiggle.jiggleControlPointCount {
                                jiggle.selectedJiggleControlPointIndex = 0
                            }
                            switchSelectedJiggle(newSelectedJiggleIndex: jiggleIndex,
                                                 displayMode: displayMode,
                                                 isGraphEnabled: isGraphEnabled)
                            return
                        }
                    }
                }
            }
        }
    }
    
    func selectPreviousJigglePoint(displayMode: DisplayMode,
                                   isGraphEnabled: Bool) {
        if let selectedJiggle = getSelectedJiggle() {
            if selectedJiggle.jiggleControlPointCount > 1 {
                var newSelectedJiggleControlPointIndex = selectedJiggle.selectedJiggleControlPointIndex - 1
                if newSelectedJiggleControlPointIndex < 0 {
                    newSelectedJiggleControlPointIndex = selectedJiggle.jiggleControlPointCount - 1
                }
                selectedJiggle.selectedJiggleControlPointIndex = newSelectedJiggleControlPointIndex
                switchSelectedJiggle(newSelectedJiggleIndex: selectedJiggleIndex,
                                     displayMode: displayMode,
                                     isGraphEnabled: isGraphEnabled)
            }
        } else {
            if jiggleCount > 0 {
                for jiggleIndex in 0..<jiggleCount {
                    let jiggle = jiggles[jiggleIndex]
                    if jiggle.jiggleControlPointCount > 0 {
                        if jiggle.isFrozen == false {
                            if jiggle.selectedJiggleControlPointIndex < 0 ||
                                jiggle.selectedJiggleControlPointIndex >= jiggle.jiggleControlPointCount {
                                jiggle.selectedJiggleControlPointIndex = 0
                            }
                            switchSelectedJiggle(newSelectedJiggleIndex: jiggleIndex,
                                                 displayMode: displayMode,
                                                 isGraphEnabled: isGraphEnabled)
                            return
                        }
                    }
                }
            }
        }
    }
    
    func selectNextGuidePoint(displayMode: DisplayMode,
                              isGraphEnabled: Bool) {
        
        if let selectedJiggle = getSelectedJiggle(),
            let selectedJiggleWeightRing = selectedJiggle.getSelectedJiggleWeightRing(),
            selectedJiggleWeightRing.jiggleControlPointCount > 0 {
            
            print("CASE-A, guideListCount")
            
            var newSelectedJiggleControlPointIndex = selectedJiggleWeightRing.selectedJiggleControlPointIndex + 1
            if newSelectedJiggleControlPointIndex >= selectedJiggleWeightRing.jiggleControlPointCount {
                newSelectedJiggleControlPointIndex = 0
            }
            selectedJiggleWeightRing.selectedJiggleControlPointIndex = newSelectedJiggleControlPointIndex
            
            
            
            
        } else {
            
            var guideList = [JiggleWeightRing]()
            for jiggleIndex in 0..<jiggleCount {
                let jiggle = jiggles[jiggleIndex]
                if jiggle.isFrozen == false {
                    let jiggleMesh = jiggle.jiggleMesh
                    jiggleMesh.readAndSortValidWeightRings(jiggle: jiggle)
                    for jiggleWeightRingIndex in 0..<jiggleMesh.jiggleWeightRingCount {
                        let jiggleWeightRing = jiggleMesh.jiggleWeightRings[jiggleWeightRingIndex]
                        if jiggleWeightRing.isFrozen == false {
                            guideList.append(jiggleWeightRing)
                        }
                    }
                }
            }
            
            let guideListCount = guideList.count
            print("CASE-B, guideListCount = \(guideListCount)")
            for guideIndex in 0..<guideListCount {
                let jiggleWeightRing = guideList[guideIndex]
                if jiggleWeightRing.jiggleControlPointCount > 0 {
                    if jiggleWeightRing.selectedJiggleControlPointIndex < 0 ||
                        jiggleWeightRing.selectedJiggleControlPointIndex >= jiggleWeightRing.jiggleControlPointCount {
                        jiggleWeightRing.selectedJiggleControlPointIndex = 0
                    }
                    _selectWeightRing(jiggleWeightRing: jiggleWeightRing,
                                      displayMode: displayMode,
                                      isGraphEnabled: isGraphEnabled)
                    return
                }
            }
        }
        
    }
    
    func selectPreviousGuidePoint(displayMode: DisplayMode,
                                  isGraphEnabled: Bool) {
        if let selectedJiggle = getSelectedJiggle(),
            let selectedJiggleWeightRing = selectedJiggle.getSelectedJiggleWeightRing(),
            selectedJiggleWeightRing.jiggleControlPointCount > 0 {
            
            print("CASE-A, guideListCount")
            
            var newSelectedJiggleControlPointIndex = selectedJiggleWeightRing.selectedJiggleControlPointIndex - 1
            if newSelectedJiggleControlPointIndex < 0 {
                newSelectedJiggleControlPointIndex = selectedJiggleWeightRing.jiggleControlPointCount - 1
            }
            selectedJiggleWeightRing.selectedJiggleControlPointIndex = newSelectedJiggleControlPointIndex
            
        } else {
            
            var guideList = [JiggleWeightRing]()
            for jiggleIndex in 0..<jiggleCount {
                let jiggle = jiggles[jiggleIndex]
                if jiggle.isFrozen == false {
                    let jiggleMesh = jiggle.jiggleMesh
                    jiggleMesh.readAndSortValidWeightRings(jiggle: jiggle)
                    for jiggleWeightRingIndex in 0..<jiggleMesh.jiggleWeightRingCount {
                        let jiggleWeightRing = jiggleMesh.jiggleWeightRings[jiggleWeightRingIndex]
                        if jiggleWeightRing.isFrozen == false {
                            guideList.append(jiggleWeightRing)
                        }
                    }
                }
            }
            
            let guideListCount = guideList.count
            print("CASE-B, guideListCount = \(guideListCount)")
            for guideIndex in (0..<guideListCount).reversed() {
                let jiggleWeightRing = guideList[guideIndex]
                if jiggleWeightRing.jiggleControlPointCount > 0 {
                    if jiggleWeightRing.selectedJiggleControlPointIndex < 0 ||
                        jiggleWeightRing.selectedJiggleControlPointIndex >= jiggleWeightRing.jiggleControlPointCount {
                        jiggleWeightRing.selectedJiggleControlPointIndex = 0
                    }
                    _selectWeightRing(jiggleWeightRing: jiggleWeightRing,
                                      displayMode: displayMode,
                                      isGraphEnabled: isGraphEnabled)
                    return
                }
            }
        }
    }
    
    
    
    func timeLineFlipAll(_ selectedJiggle: Jiggle?,
                         frameWidth: Float,
                         frameHeight: Float,
                         paddingH: Float,
                         paddingV: Float) {
        
        if let selectedJiggle = selectedJiggle {
            let selectedTimeLine = selectedJiggle.timeLine
            selectedTimeLine.swatchRotation.selectedChannel.invertVAndShift(frameWidth: frameWidth,
                                                                            frameHeight: frameHeight,
                                                                            paddingH: paddingH,
                                                                            paddingV: paddingV)
            selectedTimeLine.swatchPositionX.selectedChannel.invertVAndShift(frameWidth: frameWidth,
                                                                             frameHeight: frameHeight,
                                                                             paddingH: paddingH,
                                                                             paddingV: paddingV)
        }
    }
    
    func timeLineAmplify(_ selectedJiggle: Jiggle?,
                         frameWidth: Float,
                         frameHeight: Float,
                         paddingH: Float,
                         paddingV: Float) {
        print("JiggleDocument: timeLineAmplify")
        if let selectedJiggle = selectedJiggle {
            let selectedSwatch = selectedJiggle.timeLine.selectedSwatch
            let selectedChannel = selectedSwatch.selectedChannel
            selectedChannel.amplify(frameWidth: frameWidth,
                                    frameHeight: frameHeight,
                                    paddingH: paddingH,
                                    paddingV: paddingV)
        }
    }
    
    func timeLineDampen(_ selectedJiggle: Jiggle?,
                        frameWidth: Float,
                        frameHeight: Float,
                        paddingH: Float,
                        paddingV: Float) {
        print("JiggleDocument: timeLineDampen")
        if let selectedJiggle = selectedJiggle {
            let selectedSwatch = selectedJiggle.timeLine.selectedSwatch
            let selectedChannel = selectedSwatch.selectedChannel
            selectedChannel.dampen(frameWidth: frameWidth,
                                   frameHeight: frameHeight,
                                   paddingH: paddingH,
                                   paddingV: paddingV)
        }
    }
    
    
    func timeLineInvertH(_ selectedJiggle: Jiggle?,
                         frameWidth: Float,
                         frameHeight: Float,
                         paddingH: Float,
                         paddingV: Float) {
        print("JiggleDocument: timeLineInvertH")
        if let selectedJiggle = selectedJiggle {
            let selectedSwatch = selectedJiggle.timeLine.selectedSwatch
            let selectedChannel = selectedSwatch.selectedChannel
            selectedChannel.invertH(frameWidth: frameWidth,
                                    frameHeight: frameHeight,
                                    paddingH: paddingH,
                                    paddingV: paddingV)
        }
    }
    
    func timeLineInvertV(_ selectedJiggle: Jiggle?,
                         frameWidth: Float,
                         frameHeight: Float,
                         paddingH: Float,
                         paddingV: Float) {
        print("JiggleDocument: timeLineInvertV")
        if let selectedJiggle = selectedJiggle {
            let selectedSwatch = selectedJiggle.timeLine.selectedSwatch
            let selectedChannel = selectedSwatch.selectedChannel
            selectedChannel.invertV(frameWidth: frameWidth,
                                    frameHeight: frameHeight,
                                    paddingH: paddingH,
                                    paddingV: paddingV)
        }
    }
    
    func timeLineResetCurve(_ selectedJiggle: Jiggle?,
                            frameWidth: Float,
                            frameHeight: Float,
                            paddingH: Float,
                            paddingV: Float) {
        print("JiggleDocument: timeLineResetCurve")
        if let selectedJiggle = selectedJiggle {
            let selectedSwatch = selectedJiggle.timeLine.selectedSwatch
            let selectedChannel = selectedSwatch.selectedChannel
            selectedChannel.resetCurve(frameWidth: frameWidth,
                                       frameHeight: frameHeight,
                                       paddingH: paddingH,
                                       paddingV: paddingV)
        }
    }
    
    func timelinePointCountIncrement(_ selectedJiggle: Jiggle?) {
        print("JiggleDocument: timelinePointCountIncrement")
        //jiggleDocument.timelinePointCountIncrement()
        
        if let selectedJiggle = selectedJiggle {
            let selectedSwatch = selectedJiggle.timeLine.selectedSwatch
            selectedSwatch.incrementPointCount()
        }
        
    }
    
    func timelinePointCountDecrement(_ selectedJiggle: Jiggle?) {
        print("JiggleDocument: timelinePointCountDecrement")
        //jiggleDocument.timelinePointCountDecrement()
        if let selectedJiggle = selectedJiggle {
            let selectedSwatch = selectedJiggle.timeLine.selectedSwatch
            selectedSwatch.decrementPointCount()
        }
    }
    
    func timeLineBreakPoint(_ selectedJiggle: Jiggle?) {
        print("JiggleDocument: timeLineBreakPoint")
        
        if let selectedJiggle = selectedJiggle {
            let selectedSwatch = selectedJiggle.timeLine.selectedSwatch
            let selectedChannel = selectedSwatch.selectedChannel
            selectedChannel.breakSelectedPosition()
            selectedChannel.breakSelectedTan()
        }
    }
    
    func timeLineResetGraph(_ selectedJiggle: Jiggle?) {
        print("JiggleDocument: timeLineResetGraph")
        if let selectedJiggle = selectedJiggle {
            let selectedSwatch = selectedJiggle.timeLine.selectedSwatch
            let selectedChannel = selectedSwatch.selectedChannel
            selectedChannel.resetGraph()
        }
    }
    
    func timeLineDupeAll(_ selectedJiggle: Jiggle?) {
        print("JiggleDocument: timeLineDupeAll")
        //jiggleDocument.timelinePointCountIncrement()
        //toolInterfaceViewModel.handleTimelinePointCountDidChange()
        if let selectedJiggle = selectedJiggle {
            
            timeLineDupeSelectedSwatch(selectedJiggle)
            timeLineDupeSelectedChannelsAllSwatches(selectedJiggle)
            
            var selectedJiggleSwatches = [TimeLineSwatch]()
            selectedJiggleSwatches.append(selectedJiggle.timeLine.swatchPositionX)
            selectedJiggleSwatches.append(selectedJiggle.timeLine.swatchPositionY)
            selectedJiggleSwatches.append(selectedJiggle.timeLine.swatchScale)
            selectedJiggleSwatches.append(selectedJiggle.timeLine.swatchRotation)
            
            for jiggleIndex in 0..<jiggleCount {
                let jiggle = jiggles[jiggleIndex]
                
                if jiggle !== selectedJiggle {
                    
                    jiggle.animationInstructionBounce.keyFrame = selectedJiggle.animationInstructionBounce.keyFrame
                    jiggle.animationInstructionBounce.time = selectedJiggle.animationInstructionBounce.time
                    
                    for selectedJiggleSwatch in selectedJiggleSwatches {
                        
                        let otherJiggleSwatch = jiggle.timeLine.getSwatch(swatch: selectedJiggleSwatch.swatch)
                        
                        otherJiggleSwatch.timeOffset = selectedJiggleSwatch.timeOffset
                        
                        if selectedJiggleSwatch.channelCount != otherJiggleSwatch.channelCount {
                            print("DATAL FATAL FATAL!!! FATAL!!! selectedJiggleSwatch.channelCount = \(selectedJiggleSwatch.channelCount), otherJiggleSwatch.channelCount = \(otherJiggleSwatch.channelCount)")
                        }
                        
                        let channelCount = min(selectedJiggleSwatch.channelCount, otherJiggleSwatch.channelCount)
                        
                        var channelIndex = 0
                        while channelIndex < channelCount {
                            let selectedJiggleChannel = selectedJiggleSwatch.channels[channelIndex]
                            let otherJiggleChannel = otherJiggleSwatch.channels[channelIndex]
                            
                            otherJiggleChannel.read(selectedJiggleChannel)
                            
                            
                            channelIndex += 1
                            
                        }
                        
                        
                        
                    }
                }
            }
        }
    }
    
    func timeLineDupeDuration(_ selectedJiggle: Jiggle?) {
        print("JiggleDocument: timeLineDupeDuration")
        //jiggleDocument.timelinePointCountIncrement()
        //toolInterfaceViewModel.handleTimelinePointCountDidChange()
        if let selectedJiggle = selectedJiggle {
            let time = selectedJiggle.animationInstructionBounce.time
            for jiggleIndex in 0..<jiggleCount {
                let jiggle = jiggles[jiggleIndex]
                jiggle.animationInstructionBounce.time = time
                jiggle.animationInstructionBounce.keyFrame = 0.0
            }
        }
    }
    
    func timeLineDupeSelectedChannelsAllSwatches(_ selectedJiggle: Jiggle?) {
        print("JiggleDocument: timeLineDupeSelectedSwatch")
        
        if let selectedJiggle = selectedJiggle {
            for jiggleIndex in 0..<jiggleCount {
                let jiggle = jiggles[jiggleIndex]
                if jiggle !== selectedJiggle {
                    
                    let swatchYSelected = selectedJiggle.timeLine.swatchPositionY
                    let swatchYOther = jiggle.timeLine.swatchPositionY
                    if let selectedChannelOther = swatchYOther.getChannel(swatchYSelected.selectedChannel.channelIndex) {
                        swatchYOther.selectedChannel = selectedChannelOther
                    }
                    
                    let swatchXSelected = selectedJiggle.timeLine.swatchPositionX
                    let swatchXOther = jiggle.timeLine.swatchPositionX
                    if let selectedChannelOther = swatchXOther.getChannel(swatchXSelected.selectedChannel.channelIndex) {
                        swatchXOther.selectedChannel = selectedChannelOther
                    }
                    
                    let swatchScaleSelected = selectedJiggle.timeLine.swatchScale
                    let swatchScaleOther = jiggle.timeLine.swatchScale
                    if let selectedChannelOther = swatchScaleOther.getChannel(swatchScaleSelected.selectedChannel.channelIndex) {
                        swatchScaleOther.selectedChannel = selectedChannelOther
                    }
                    
                    let swatchRotationSelected = selectedJiggle.timeLine.swatchRotation
                    let swatchRotationOther = jiggle.timeLine.swatchRotation
                    if let selectedChannelOther = swatchRotationOther.getChannel(swatchRotationSelected.selectedChannel.channelIndex) {
                        swatchRotationOther.selectedChannel = selectedChannelOther
                    }
                }
            }
        }
    }
    
    func timeLineDupeSelectedSwatch(_ selectedJiggle: Jiggle?) {
        print("JiggleDocument: timeLineDupeSelectedSwatch")
        if let selectedJiggle = selectedJiggle {
            let selectedJiggleSwatch = selectedJiggle.timeLine.selectedSwatch
            for jiggleIndex in 0..<jiggleCount {
                let jiggle = jiggles[jiggleIndex]
                
                let selectedChannelIndex = selectedJiggleSwatch.selectedChannel.channelIndex
                switch selectedJiggleSwatch.swatch {
                case .x:
                    jiggle.timeLine.selectedSwatch = jiggle.timeLine.swatchPositionX
                    if let newSelectedChannel = jiggle.timeLine.swatchPositionX.getChannel(selectedChannelIndex) {
                        jiggle.timeLine.swatchPositionX.selectedChannel = newSelectedChannel
                    } else {
                        print("WHIFFFF!!!!TAA")
                    }
                case .y:
                    jiggle.timeLine.selectedSwatch = jiggle.timeLine.swatchPositionY
                    if let newSelectedChannel = jiggle.timeLine.swatchPositionY.getChannel(selectedChannelIndex) {
                        jiggle.timeLine.swatchPositionY.selectedChannel = newSelectedChannel
                    } else {
                        print("WHIFFFF!!!!ACCZ")
                    }
                case .scale:
                    jiggle.timeLine.selectedSwatch = jiggle.timeLine.swatchScale
                    if let newSelectedChannel = jiggle.timeLine.swatchScale.getChannel(selectedChannelIndex) {
                        jiggle.timeLine.swatchScale.selectedChannel = newSelectedChannel
                    } else {
                        print("WHIFFFF!!!!AA")
                    }
                case .rotation:
                    jiggle.timeLine.selectedSwatch = jiggle.timeLine.swatchRotation
                    if let newSelectedChannel = jiggle.timeLine.swatchRotation.getChannel(selectedChannelIndex) {
                        jiggle.timeLine.swatchRotation.selectedChannel = newSelectedChannel
                    } else {
                        print("WHIFFFF!!!!AF")
                    }
                }
            }
            
        }
    }
    
    func timeLineDupeCurrentChannel(_ selectedJiggle: Jiggle?) {
        print("JiggleDocument: timeLineDupeCurrentChannel")
        if let selectedJiggle = selectedJiggle {
            timeLineDupeSelectedSwatch(selectedJiggle)
            let selectedJiggleSwatch = selectedJiggle.timeLine.selectedSwatch
            let selectedJiggleChannel = selectedJiggleSwatch.selectedChannel
            for jiggleIndex in 0..<jiggleCount {
                let jiggle = jiggles[jiggleIndex]
                if jiggle !== selectedJiggle {
                    let swatch = jiggle.timeLine.getSwatch(swatch: selectedJiggleSwatch.swatch)
                    if let channel = swatch.getChannel(selectedJiggleChannel.channelIndex) {
                        channel.read(selectedJiggleChannel)
                    }
                }
            }
        }
    }
    
    func timeLineDupeChannel(_ selectedJiggle: Jiggle?, swatch: Swatch) {
        print("JiggleDocument: timeLineDupeCurrentChannel")
        if let selectedJiggle = selectedJiggle {
            let selectedJiggleSwatch = selectedJiggle.timeLine.getSwatch(swatch: swatch)
            let selectedJiggleChannel = selectedJiggleSwatch.selectedChannel
            for jiggleIndex in 0..<jiggleCount {
                let jiggle = jiggles[jiggleIndex]
                if jiggle !== selectedJiggle {
                    let otherJiggleSwatch = jiggle.timeLine.getSwatch(swatch: swatch)
                    if let otherJiggleChannel = otherJiggleSwatch.getChannel(selectedJiggleChannel.channelIndex) {
                        otherJiggleSwatch.selectedChannel = otherJiggleChannel
                        otherJiggleChannel.read(selectedJiggleChannel)
                    }
                }
            }
        }
    }
    
    func timeLineFlattenCurrentChannel(_ selectedJiggle: Jiggle?,
                                       frameWidth: Float,
                                       frameHeight: Float,
                                       paddingH: Float,
                                       paddingV: Float) {
        print("JiggleDocument: timeLineFlattenCurrentChannel")
        //jiggleDocument.timelinePointCountIncrement()
        //toolInterfaceViewModel.handleTimelinePointCountDidChange()
        if let selectedJiggle = selectedJiggle {
            let selectedSwatch = selectedJiggle.timeLine.selectedSwatch
            let selectedChannel = selectedSwatch.selectedChannel
            selectedChannel.flatten(frameWidth: frameWidth,
                                    frameHeight: frameHeight,
                                    paddingH: paddingH,
                                    paddingV: paddingV)
        }
    }
    
    func timeLineResetDefaultCurrentChannel(_ selectedJiggle: Jiggle?) {
        print("JiggleDocument: timeLineResetDefaultCurrentChannel")
        //jiggleDocument.timelinePointCountIncrement()
        //toolInterfaceViewModel.handleTimelinePointCountDidChange()
        
    }
    
    
    
    
    
    func getTimelinePointCountString() -> String {
        if let selectedJiggle = getSelectedJiggle() {
            return selectedJiggle.timeLine.getPointCountString()
        } else {
            return "|"
        }
    }
    
    func getProcessPointsCenterX() -> Float {
        if processPointCount > 1 {
            var minX = processPoints[0].x
            var maxX = processPoints[0].x
            for processPointIndex in 0..<processPointCount {
                let processPoint = processPoints[processPointIndex]
                minX = min(minX, processPoint.x)
                maxX = max(maxX, processPoint.x)
            }
            let result = minX + (maxX - minX) * 0.5
            return result
        } else if processPointCount == 1 {
            return processPoints[0].x
        } else {
            return 0.0
        }
    }
    
    func getProcessPointsCenterY() -> Float {
        if processPointCount > 1 {
            var minY = processPoints[0].y
            var maxY = processPoints[0].y
            for processPointIndex in 0..<processPointCount {
                let processPoint = processPoints[processPointIndex]
                minY = min(minY, processPoint.y)
                maxY = max(maxY, processPoint.y)
            }
            let result = minY + (maxY - minY) * 0.5
            return result
        } else if processPointCount == 1 {
            return processPoints[0].y
        } else {
            return 0.0
        }
    }
    
    var processPoints = [JiggleWeightPoint]()
    var processPointCount = 0
    func addProcessPoint(_ point: JiggleWeightPoint) {
        while processPoints.count <= processPointCount {
            processPoints.append(point)
        }
        processPoints[processPointCount] = point
        processPointCount += 1
    }
    
    func purgeProcessPoints() {
        for processPointIndex in 0..<processPointCount {
            JigglePartsFactory.shared.depositJiggleWeightPoint(processPoints[processPointIndex])
        }
        processPointCount = 0
    }
    
    func rotateJiggleRight(selectedJiggle: Jiggle,
                           displayMode: DisplayMode,
                           isGraphEnabled: Bool) {
        
        purgeProcessPoints()
        
        for jiggleControlPointIndex in 0..<selectedJiggle.jiggleControlPointCount {
            let jiggleControlPoint = selectedJiggle.jiggleControlPoints[jiggleControlPointIndex]
            let converted = selectedJiggle.transformPoint(jiggleControlPoint.x, jiggleControlPoint.y)
            let point = JigglePartsFactory.shared.withdrawJiggleWeightPoint()
            point.x = converted.x
            point.y = converted.y
            addProcessPoint(point)
        }
        
        for jiggleWeightRingIndex in 0..<selectedJiggle.jiggleWeightRingCount {
            let jiggleWeightRing = selectedJiggle.jiggleWeightRings[jiggleWeightRingIndex]
            
            jiggleWeightRing.purgeProcessPoints()
            for jiggleControlPointIndex in 0..<jiggleWeightRing.jiggleControlPointCount {
                let weightControlPoint = jiggleWeightRing.jiggleControlPoints[jiggleControlPointIndex]
                
                let convertedA = jiggleWeightRing.transformPoint(point: weightControlPoint.point)
                let convertedB = selectedJiggle.transformPoint(point: convertedA)
                
                let point = JigglePartsFactory.shared.withdrawJiggleWeightPoint()
                point.x = convertedB.x
                point.y = convertedB.y
                jiggleWeightRing.addProcessPoint(point)
            }
            
            jiggleWeightRing.centerTemp = selectedJiggle.transformPoint(point: jiggleWeightRing.center)
            
            jiggleWeightRing.purgeJiggleControlPoints()
            jiggleWeightRing.scale = 1.0 // These can be normalized. No effect on mesh.
            jiggleWeightRing.rotation = 0.0 // These can be normalized. No effect on mesh.
        }
        
        let worldCenterX = getProcessPointsCenterX()
        let worldCenterY = getProcessPointsCenterY()
        
        let offsetCenterConverted = selectedJiggle.transformPointScaleAndRotationOnly(point: selectedJiggle.offsetCenter)
        let jiggleCenterPoint = selectedJiggle.center + offsetCenterConverted
        let jiggleCenterPointFlipped = Point(x: worldCenterX + (worldCenterY - jiggleCenterPoint.y),
                                             y: worldCenterY + (jiggleCenterPoint.x - worldCenterX))
        
        let guideCenterOffsetConverted = selectedJiggle.transformPointScaleAndRotationOnly(point: selectedJiggle.guideCenter)
        let guideCenterPoint = selectedJiggle.center + guideCenterOffsetConverted
        let guideCenterPointFlipped = Point(x: worldCenterX + (worldCenterY - guideCenterPoint.y),
                                            y: worldCenterY + (guideCenterPoint.x - worldCenterX))
        
        selectedJiggle.offsetCenter.x = 0.0
        selectedJiggle.offsetCenter.y = 0.0
        selectedJiggle.center.x = jiggleCenterPointFlipped.x
        selectedJiggle.center.y = jiggleCenterPointFlipped.y
        
        let guideCenterPointDeconverted = selectedJiggle.untransformPoint(point: guideCenterPointFlipped)
        selectedJiggle.guideCenter.x = guideCenterPointDeconverted.x
        selectedJiggle.guideCenter.y = guideCenterPointDeconverted.y
        
        selectedJiggle.purgeJiggleControlPoints()
        for processPointIndex in 0..<processPointCount {
            let processPoint = processPoints[processPointIndex]
            let startX = processPoint.x
            let startY = processPoint.y
            processPoint.x = worldCenterX + (worldCenterY - startY)
            processPoint.y = worldCenterY + (startX - worldCenterX)
            
            let deconverted = selectedJiggle.untransformPoint(processPoint.x, processPoint.y)
            selectedJiggle.addJiggleControlPoint(deconverted.x, deconverted.y)
        }
        
        for jiggleWeightRingIndex in 0..<selectedJiggle.jiggleWeightRingCount {
            let jiggleWeightRing = selectedJiggle.jiggleWeightRings[jiggleWeightRingIndex]
            
            jiggleWeightRing.center = selectedJiggle.untransformPoint(point: jiggleWeightRing.centerTemp)
            
            for processPointIndex in 0..<jiggleWeightRing.processPointCount {
                let processPoint = jiggleWeightRing.processPoints[processPointIndex]
                let startX = processPoint.x
                let startY = processPoint.y
                processPoint.x = worldCenterX + (worldCenterY - startY)
                processPoint.y = worldCenterY + (startX - worldCenterX)
                
                let deconvertedA = selectedJiggle.untransformPoint(point: processPoint.point)
                let deconvertedB = jiggleWeightRing.untransformPoint(point: deconvertedA)
                
                jiggleWeightRing.addJiggleControlPoint(deconvertedB.x, deconvertedB.y)
                
            }
        }
        
        let meshType = JiggleMeshCommand.getMeshTypeForced(documentMode: documentMode,
                                                           isGuidesEnabled: isGuidesEnabled)
        let meshCommand = JiggleMeshCommand(spline: true,
                                            triangulationType: .beautiful,
                                            meshType: meshType,
                                            outlineType: .forced,
                                            swivelType: .none,
                                            weightCurveType: .none)
        let weightRingCommand = JiggleWeightRingCommand(spline: true, outlineType: .forced)
        let worldScale = getWorldScale()
        selectedJiggle.execute(meshCommand: meshCommand,
                               isSelected: true,
                               isDarkModeEnabled: ApplicationController.isDarkModeEnabled,
                               worldScale: worldScale,
                               weightRingCommand: weightRingCommand,
                               forceWeightRingCommand: false,
                               orientation: orientation)
    }
    
    func rotateJiggleLeft(selectedJiggle: Jiggle,
                          displayMode: DisplayMode,
                          isGraphEnabled: Bool) {
        
        purgeProcessPoints()
        
        for jiggleControlPointIndex in 0..<selectedJiggle.jiggleControlPointCount {
            let jiggleControlPoint = selectedJiggle.jiggleControlPoints[jiggleControlPointIndex]
            let converted = selectedJiggle.transformPoint(jiggleControlPoint.x, jiggleControlPoint.y)
            let point = JigglePartsFactory.shared.withdrawJiggleWeightPoint()
            point.x = converted.x
            point.y = converted.y
            addProcessPoint(point)
        }
        
        for jiggleWeightRingIndex in 0..<selectedJiggle.jiggleWeightRingCount {
            let jiggleWeightRing = selectedJiggle.jiggleWeightRings[jiggleWeightRingIndex]
            
            jiggleWeightRing.purgeProcessPoints()
            for jiggleControlPointIndex in 0..<jiggleWeightRing.jiggleControlPointCount {
                let weightControlPoint = jiggleWeightRing.jiggleControlPoints[jiggleControlPointIndex]
                
                let convertedA = jiggleWeightRing.transformPoint(point: weightControlPoint.point)
                let convertedB = selectedJiggle.transformPoint(point: convertedA)
                
                let point = JigglePartsFactory.shared.withdrawJiggleWeightPoint()
                point.x = convertedB.x
                point.y = convertedB.y
                jiggleWeightRing.addProcessPoint(point)
            }
            
            jiggleWeightRing.centerTemp = selectedJiggle.transformPoint(point: jiggleWeightRing.center)
            
            jiggleWeightRing.purgeJiggleControlPoints()
            jiggleWeightRing.scale = 1.0 // These can be normalized. No effect on mesh.
            jiggleWeightRing.rotation = 0.0 // These can be normalized. No effect on mesh.
        }
        
        let worldCenterX = getProcessPointsCenterX()
        let worldCenterY = getProcessPointsCenterY()
        
        let offsetCenterConverted = selectedJiggle.transformPointScaleAndRotationOnly(point: selectedJiggle.offsetCenter)
        let jiggleCenterPoint = selectedJiggle.center + offsetCenterConverted
        let jiggleCenterPointFlipped = Point(x: worldCenterX + (jiggleCenterPoint.y - worldCenterY),
                                             y: worldCenterY + (worldCenterX - jiggleCenterPoint.x))
        
        let guideCenterOffsetConverted = selectedJiggle.transformPointScaleAndRotationOnly(point: selectedJiggle.guideCenter)
        let guideCenterPoint = selectedJiggle.center + guideCenterOffsetConverted
        let guideCenterPointFlipped = Point(x: worldCenterX + (guideCenterPoint.y - worldCenterY),
                                            y: worldCenterY + (worldCenterX - guideCenterPoint.x))
        
        selectedJiggle.offsetCenter.x = 0.0
        selectedJiggle.offsetCenter.y = 0.0
        selectedJiggle.center.x = jiggleCenterPointFlipped.x
        selectedJiggle.center.y = jiggleCenterPointFlipped.y
        
        let guideCenterPointDeconverted = selectedJiggle.untransformPoint(point: guideCenterPointFlipped)
        selectedJiggle.guideCenter.x = guideCenterPointDeconverted.x
        selectedJiggle.guideCenter.y = guideCenterPointDeconverted.y
        
        selectedJiggle.purgeJiggleControlPoints()
        for processPointIndex in 0..<processPointCount {
            let processPoint = processPoints[processPointIndex]
            let startX = processPoint.x
            let startY = processPoint.y
            processPoint.x = worldCenterX + (startY - worldCenterY)
            processPoint.y = worldCenterY + (worldCenterX - startX)
            
            let deconverted = selectedJiggle.untransformPoint(processPoint.x, processPoint.y)
            selectedJiggle.addJiggleControlPoint(deconverted.x, deconverted.y)
        }
        
        for jiggleWeightRingIndex in 0..<selectedJiggle.jiggleWeightRingCount {
            let jiggleWeightRing = selectedJiggle.jiggleWeightRings[jiggleWeightRingIndex]
            
            jiggleWeightRing.center = selectedJiggle.untransformPoint(point: jiggleWeightRing.centerTemp)
            
            for processPointIndex in 0..<jiggleWeightRing.processPointCount {
                let processPoint = jiggleWeightRing.processPoints[processPointIndex]
                let startX = processPoint.x
                let startY = processPoint.y
                processPoint.x = worldCenterX + (startY - worldCenterY)
                processPoint.y = worldCenterY + (worldCenterX - startX)
                
                let deconvertedA = selectedJiggle.untransformPoint(point: processPoint.point)
                let deconvertedB = jiggleWeightRing.untransformPoint(point: deconvertedA)
                
                jiggleWeightRing.addJiggleControlPoint(deconvertedB.x, deconvertedB.y)
                
            }
        }
        
        let meshType = JiggleMeshCommand.getMeshTypeForced(documentMode: documentMode,
                                                           isGuidesEnabled: isGuidesEnabled)
        let meshCommand = JiggleMeshCommand(spline: true,
                                            triangulationType: .beautiful,
                                            meshType: meshType,
                                            outlineType: .forced,
                                            swivelType: .none,
                                            weightCurveType: .none)
        let weightRingCommand = JiggleWeightRingCommand(spline: true, outlineType: .forced)
        let worldScale = getWorldScale()
        selectedJiggle.execute(meshCommand: meshCommand,
                               isSelected: true,
                               isDarkModeEnabled: ApplicationController.isDarkModeEnabled,
                               worldScale: worldScale,
                               weightRingCommand: weightRingCommand,
                               forceWeightRingCommand: false,
                               orientation: orientation)
    }
    
    func flipJiggleHorizontal(selectedJiggle: Jiggle,
                              displayMode: DisplayMode,
                              isGraphEnabled: Bool) {
        
        purgeProcessPoints()
        
        for jiggleControlPointIndex in 0..<selectedJiggle.jiggleControlPointCount {
            let jiggleControlPoint = selectedJiggle.jiggleControlPoints[jiggleControlPointIndex]
            let converted = selectedJiggle.transformPoint(jiggleControlPoint.x, jiggleControlPoint.y)
            let point = JigglePartsFactory.shared.withdrawJiggleWeightPoint()
            point.x = converted.x
            point.y = converted.y
            addProcessPoint(point)
        }
        
        for jiggleWeightRingIndex in 0..<selectedJiggle.jiggleWeightRingCount {
            let jiggleWeightRing = selectedJiggle.jiggleWeightRings[jiggleWeightRingIndex]
            
            jiggleWeightRing.purgeProcessPoints()
            for jiggleControlPointIndex in 0..<jiggleWeightRing.jiggleControlPointCount {
                let weightControlPoint = jiggleWeightRing.jiggleControlPoints[jiggleControlPointIndex]
                
                let convertedA = jiggleWeightRing.transformPoint(point: weightControlPoint.point)
                let convertedB = selectedJiggle.transformPoint(point: convertedA)
                
                let point = JigglePartsFactory.shared.withdrawJiggleWeightPoint()
                point.x = convertedB.x
                point.y = convertedB.y
                jiggleWeightRing.addProcessPoint(point)
            }
            
            jiggleWeightRing.centerTemp = selectedJiggle.transformPoint(point: jiggleWeightRing.center)
            
            jiggleWeightRing.purgeJiggleControlPoints()
            jiggleWeightRing.scale = 1.0 // These can be normalized. No effect on mesh.
            jiggleWeightRing.rotation = 0.0 // These can be normalized. No effect on mesh.
        }
        
        let worldCenterX = getProcessPointsCenterX()
        
        let offsetCenterConverted = selectedJiggle.transformPointScaleAndRotationOnly(point: selectedJiggle.offsetCenter)
        let jiggleCenterPoint = selectedJiggle.center + offsetCenterConverted
        let jiggleCenterPointFlipped = Point(x: worldCenterX + (worldCenterX - jiggleCenterPoint.x),
                                             y: jiggleCenterPoint.y)
        
        
        let guideCenterOffsetConverted = selectedJiggle.transformPointScaleAndRotationOnly(point: selectedJiggle.guideCenter)
        let guideCenterPoint = selectedJiggle.center + guideCenterOffsetConverted
        let guideCenterPointFlipped = Point(x: worldCenterX + (worldCenterX - guideCenterPoint.x),
                                            y: guideCenterPoint.y)
        
        //let centerPointDeconverted = selectedJiggle.untransformPoint(point: centerPointFlipped)
        selectedJiggle.offsetCenter.x = 0.0
        selectedJiggle.offsetCenter.y = 0.0
        selectedJiggle.center.x = jiggleCenterPointFlipped.x
        selectedJiggle.center.y = jiggleCenterPointFlipped.y
        
        let guideCenterPointDeconverted = selectedJiggle.untransformPoint(point: guideCenterPointFlipped)
        selectedJiggle.guideCenter.x = guideCenterPointDeconverted.x
        selectedJiggle.guideCenter.y = guideCenterPointDeconverted.y
        
        selectedJiggle.purgeJiggleControlPoints()
        for processPointIndex in 0..<processPointCount {
            let processPoint = processPoints[processPointIndex]
            processPoint.x = worldCenterX + (worldCenterX - processPoint.x)
            let deconverted = selectedJiggle.untransformPoint(processPoint.x, processPoint.y)
            selectedJiggle.addJiggleControlPoint(deconverted.x, deconverted.y)
        }
        
        
        for jiggleWeightRingIndex in 0..<selectedJiggle.jiggleWeightRingCount {
            let jiggleWeightRing = selectedJiggle.jiggleWeightRings[jiggleWeightRingIndex]
            
            jiggleWeightRing.center = selectedJiggle.untransformPoint(point: jiggleWeightRing.centerTemp)
            
            for processPointIndex in 0..<jiggleWeightRing.processPointCount {
                let processPoint = jiggleWeightRing.processPoints[processPointIndex]
                processPoint.x = worldCenterX + (worldCenterX - processPoint.x)
                let deconvertedA = selectedJiggle.untransformPoint(point: processPoint.point)
                let deconvertedB = jiggleWeightRing.untransformPoint(point: deconvertedA)
                
                jiggleWeightRing.addJiggleControlPoint(deconvertedB.x, deconvertedB.y)
                
            }
        }
        
        let meshType = JiggleMeshCommand.getMeshTypeForced(documentMode: documentMode,
                                                           isGuidesEnabled: isGuidesEnabled)
        let meshCommand = JiggleMeshCommand(spline: true,
                                            triangulationType: .beautiful,
                                            meshType: meshType,
                                            outlineType: .forced,
                                            swivelType: .none,
                                            weightCurveType: .none)
        let weightRingCommand = JiggleWeightRingCommand(spline: true, outlineType: .forced)
        let worldScale = getWorldScale()
        selectedJiggle.execute(meshCommand: meshCommand,
                               isSelected: true,
                               isDarkModeEnabled: ApplicationController.isDarkModeEnabled,
                               worldScale: worldScale,
                               weightRingCommand: weightRingCommand,
                               forceWeightRingCommand: false,
                               orientation: orientation)
    }
    
    func flipJiggleVertical(selectedJiggle: Jiggle,
                            displayMode: DisplayMode,
                            isGraphEnabled: Bool) {
        
        purgeProcessPoints()
        
        for jiggleControlPointIndex in 0..<selectedJiggle.jiggleControlPointCount {
            let jiggleControlPoint = selectedJiggle.jiggleControlPoints[jiggleControlPointIndex]
            let converted = selectedJiggle.transformPoint(jiggleControlPoint.x, jiggleControlPoint.y)
            let point = JigglePartsFactory.shared.withdrawJiggleWeightPoint()
            point.x = converted.x
            point.y = converted.y
            addProcessPoint(point)
        }
        
        for jiggleWeightRingIndex in 0..<selectedJiggle.jiggleWeightRingCount {
            let jiggleWeightRing = selectedJiggle.jiggleWeightRings[jiggleWeightRingIndex]
            
            jiggleWeightRing.purgeProcessPoints()
            for jiggleControlPointIndex in 0..<jiggleWeightRing.jiggleControlPointCount {
                let weightControlPoint = jiggleWeightRing.jiggleControlPoints[jiggleControlPointIndex]
                
                let convertedA = jiggleWeightRing.transformPoint(point: weightControlPoint.point)
                let convertedB = selectedJiggle.transformPoint(point: convertedA)
                
                let point = JigglePartsFactory.shared.withdrawJiggleWeightPoint()
                point.x = convertedB.x
                point.y = convertedB.y
                jiggleWeightRing.addProcessPoint(point)
            }
            
            jiggleWeightRing.centerTemp = selectedJiggle.transformPoint(point: jiggleWeightRing.center)
            
            jiggleWeightRing.purgeJiggleControlPoints()
            jiggleWeightRing.scale = 1.0 // These can be normalized. No effect on mesh.
            jiggleWeightRing.rotation = 0.0 // These can be normalized. No effect on mesh.
        }
        
        let worldCenterY = getProcessPointsCenterY()
        
        let offsetCenterConverted = selectedJiggle.transformPointScaleAndRotationOnly(point: selectedJiggle.offsetCenter)
        let jiggleCenterPoint = selectedJiggle.center + offsetCenterConverted
        let jiggleCenterPointFlipped = Point(x: jiggleCenterPoint.x,
                                             y: worldCenterY + (worldCenterY - jiggleCenterPoint.y))
        
        
        let guideCenterOffsetConverted = selectedJiggle.transformPointScaleAndRotationOnly(point: selectedJiggle.guideCenter)
        let guideCenterPoint = selectedJiggle.center + guideCenterOffsetConverted
        let guideCenterPointFlipped = Point(x: guideCenterPoint.x,
                                            y: worldCenterY + (worldCenterY - guideCenterPoint.y))
        
        selectedJiggle.offsetCenter.x = 0.0
        selectedJiggle.offsetCenter.y = 0.0
        selectedJiggle.center.x = jiggleCenterPointFlipped.x
        selectedJiggle.center.y = jiggleCenterPointFlipped.y
        
        let guideCenterPointDeconverted = selectedJiggle.untransformPoint(point: guideCenterPointFlipped)
        selectedJiggle.guideCenter.x = guideCenterPointDeconverted.x
        selectedJiggle.guideCenter.y = guideCenterPointDeconverted.y
        
        selectedJiggle.purgeJiggleControlPoints()
        for processPointIndex in 0..<processPointCount {
            let processPoint = processPoints[processPointIndex]
            processPoint.y = worldCenterY + (worldCenterY - processPoint.y)
            let deconverted = selectedJiggle.untransformPoint(processPoint.x, processPoint.y)
            selectedJiggle.addJiggleControlPoint(deconverted.x, deconverted.y)
        }
        
        for jiggleWeightRingIndex in 0..<selectedJiggle.jiggleWeightRingCount {
            let jiggleWeightRing = selectedJiggle.jiggleWeightRings[jiggleWeightRingIndex]
            jiggleWeightRing.center = selectedJiggle.untransformPoint(point: jiggleWeightRing.centerTemp)
            for processPointIndex in 0..<jiggleWeightRing.processPointCount {
                let processPoint = jiggleWeightRing.processPoints[processPointIndex]
                processPoint.y = worldCenterY + (worldCenterY - processPoint.y)
                let deconvertedA = selectedJiggle.untransformPoint(point: processPoint.point)
                let deconvertedB = jiggleWeightRing.untransformPoint(point: deconvertedA)
                
                jiggleWeightRing.addJiggleControlPoint(deconvertedB.x, deconvertedB.y)
                
            }
        }
        
        let meshType = JiggleMeshCommand.getMeshTypeForced(documentMode: documentMode,
                                                           isGuidesEnabled: isGuidesEnabled)
        let meshCommand = JiggleMeshCommand(spline: true,
                                            triangulationType: .beautiful,
                                            meshType: meshType,
                                            outlineType: .forced,
                                            swivelType: .none,
                                            weightCurveType: .none)
        let weightRingCommand = JiggleWeightRingCommand(spline: true, outlineType: .forced)
        let worldScale = getWorldScale()
        selectedJiggle.execute(meshCommand: meshCommand,
                               isSelected: true,
                               isDarkModeEnabled: ApplicationController.isDarkModeEnabled,
                               worldScale: worldScale,
                               weightRingCommand: weightRingCommand,
                               forceWeightRingCommand: false,
                               orientation: orientation)
    }
    
    func isAddJigglePointsPossible() -> Bool {
        if getSelectedJiggle() !== nil {
            return true
        }
        return false
    }
    
    func isRemoveJigglePointsPossible() -> Bool {
        for jiggleIndex in 0..<jiggleCount {
            let jiggle = jiggles[jiggleIndex]
            if jiggle.isFrozen == false {
                if jiggle.jiggleControlPointCount > Jiggle.minPointCount {
                    return true
                }
            }
        }
        return false
    }
    
    
    func isAnyJiggleFrozen() -> Bool {
        for jiggleIndex in 0..<jiggleCount {
            let jiggle = jiggles[jiggleIndex]
            if jiggle.isFrozen {
                return true
            }
        }
        return false
    }
    
    func countUnfrozenJiggles() -> Int {
        var result = 0
        for jiggleIndex in 0..<jiggleCount {
            let jiggle = jiggles[jiggleIndex]
            if jiggle.isFrozen == false {
                result += 1
            }
        }
        return result
    }
    
    func unfreezeAllJiggles(displayMode: DisplayMode,
                            isGraphEnabled: Bool) {
        for jiggleIndex in 0..<jiggleCount {
            let jiggle = jiggles[jiggleIndex]
            jiggle.isFrozen = false
        }
        
        let meshType = JiggleMeshCommand.getMeshTypeIfNeeded(documentMode: documentMode,
                                                             isGuidesEnabled: isGuidesEnabled)
        
        let swivelType = JiggleMeshCommand.getSwivelTypeIfNeeded(documentMode: documentMode,
                                                                 displayMode: displayMode,
                                                                 isGuidesEnabled: isGuidesEnabled,
                                                                 isGraphEnabled: isGraphEnabled)
        
        let weightCurveType = ForceableTypeWithNone.none
        let weightRingCommand = JiggleWeightRingCommand.none
        let worldScale = getWorldScale()
        for jiggleIndex in 0..<jiggleCount {
            let jiggle = jiggles[jiggleIndex]
            let triangulationType = jiggle.currentHashPoly.triangulationType
            let meshCommand = JiggleMeshCommand(spline: false,
                                                triangulationType: triangulationType,
                                                meshType: meshType,
                                                outlineType: .ifNeeded,
                                                swivelType: swivelType,
                                                weightCurveType: weightCurveType)
            jiggle.execute(meshCommand: meshCommand,
                           isSelected: (jiggleIndex == selectedJiggleIndex),
                           isDarkModeEnabled: ApplicationController.isDarkModeEnabled,
                           worldScale: worldScale,
                           weightRingCommand: weightRingCommand,
                           forceWeightRingCommand: false,
                           orientation: orientation)
        }
    }
    
    func freezeSelectedJiggle(displayMode: DisplayMode,
                              isGraphEnabled: Bool) {
        if let selectedJiggle = getSelectedJiggle() {
            selectedJiggle.isFrozen = true
            self.selectedJiggleAffine = nil
            
            var selectedOffsetCenter = selectedJiggle.offsetCenter
            selectedOffsetCenter = selectedJiggle.transformPoint(point: selectedOffsetCenter)
            
            var currentSelectedJiggleIndex = -1
            var bestDistance = Float(100_000_000.0)
            for checkJiggleIndex in 0..<jiggleCount {
                let checkJiggle = jiggles[checkJiggleIndex]
                if checkJiggle !== selectedJiggle, checkJiggle.isFrozen == false {
                    var checkOffsetCenter = checkJiggle.offsetCenter
                    checkOffsetCenter = checkJiggle.transformPoint(point: checkOffsetCenter)
                    let diffX = selectedOffsetCenter.x - checkOffsetCenter.x
                    let diffY = selectedOffsetCenter.y - checkOffsetCenter.y
                    let distanceSquared = diffX * diffX + diffY * diffY
                    if distanceSquared < bestDistance {
                        bestDistance = distanceSquared
                        currentSelectedJiggleIndex = checkJiggleIndex
                    }
                }
            }
            
            switchSelectedJiggle(newSelectedJiggleIndex: currentSelectedJiggleIndex,
                                 displayMode: displayMode,
                                 isGraphEnabled: isGraphEnabled)
            
        }
    }
    
    func unfreezeAllGuides(displayMode: DisplayMode,
                           isGraphEnabled: Bool) {
        for jiggleIndex in 0..<jiggleCount {
            let jiggle = jiggles[jiggleIndex]
            for jiggleWeightRingIndex in 0..<jiggle.jiggleWeightRingCount {
                let jiggleWeightRing = jiggle.jiggleWeightRings[jiggleWeightRingIndex]
                jiggleWeightRing.isFrozen = false
            }
        }
        
        /*
         switchSelectedJiggle(newSelectedJiggleIndex: selectedJiggleIndex,
         displayMode: displayMode,
         isGraphEnabled: isGraphEnabled)
         */
        
        let meshType = JiggleMeshCommand.getMeshTypeIfNeeded(documentMode: documentMode,
                                                             isGuidesEnabled: isGuidesEnabled)
        
        let swivelType = JiggleMeshCommand.getSwivelTypeIfNeeded(documentMode: documentMode,
                                                                 displayMode: displayMode,
                                                                 isGuidesEnabled: isGuidesEnabled,
                                                                 isGraphEnabled: isGraphEnabled)
        
        let weightCurveType = ForceableTypeWithNone.none
        let weightRingCommand = JiggleWeightRingCommand.none
        let worldScale = getWorldScale()
        for jiggleIndex in 0..<jiggleCount {
            let jiggle = jiggles[jiggleIndex]
            let triangulationType = jiggle.currentHashPoly.triangulationType
            let meshCommand = JiggleMeshCommand(spline: false,
                                                triangulationType: triangulationType,
                                                meshType: meshType,
                                                outlineType: .ifNeeded,
                                                swivelType: swivelType,
                                                weightCurveType: weightCurveType)
            jiggle.execute(meshCommand: meshCommand,
                           isSelected: (jiggleIndex == selectedJiggleIndex),
                           isDarkModeEnabled: ApplicationController.isDarkModeEnabled,
                           worldScale: worldScale,
                           weightRingCommand: weightRingCommand,
                           forceWeightRingCommand: false,
                           orientation: orientation)
        }
        
        
    }
    
    func freezeSelectedGuide(displayMode: DisplayMode,
                             isGraphEnabled: Bool) {
        
        if let selectedJiggle = getSelectedJiggle() {
            if let selectedJiggleWeightRing = selectedJiggle.getSelectedJiggleWeightRing() {
                
                selectedJiggleWeightRing.isFrozen = true
                
                let jiggleMesh = selectedJiggle.jiggleMesh
                jiggleMesh.readAndSortValidWeightRings(jiggle: selectedJiggle)
                
                var newSelectedJiggleWeightRing: JiggleWeightRing?
                var bestBignessDifference = Float(100_000_000.0)
                for jiggleWeightRingIndex in 0..<jiggleMesh.jiggleWeightRingCount {
                    let jiggleWeightRing = jiggleMesh.jiggleWeightRings[jiggleWeightRingIndex]
                    if jiggleWeightRing !== selectedJiggleWeightRing {
                        if jiggleWeightRing.isFrozen == false {
                            let bignessDifference = fabsf(selectedJiggleWeightRing.bigness - jiggleWeightRing.bigness)
                            if bignessDifference < bestBignessDifference {
                                bestBignessDifference = bignessDifference
                                newSelectedJiggleWeightRing = jiggleWeightRing
                            }
                        }
                    }
                }
                
                if let newSelectedJiggleWeightRing = newSelectedJiggleWeightRing,
                   let newSelectedJiggleWeightRingIndex = selectedJiggle.getJiggleWeightRingIndex(newSelectedJiggleWeightRing) {
                    
                    selectedJiggle.switchSelectedWeightCurveControlIndex(index: newSelectedJiggleWeightRingIndex + 1)
                    //switchSelectedJiggle(newSelectedJiggleIndex: selectedJiggleIndex, displayMode: displayMode, isGraphEnabled: isGraphEnabled)
                    
                    
                    
                } else {
                    selectedJiggle.switchSelectedWeightCurveControlIndex(index: 0)
                    //switchSelectedJiggle(newSelectedJiggleIndex: selectedJiggleIndex, displayMode: displayMode, isGraphEnabled: isGraphEnabled)
                    
                }
                
                let meshType = JiggleMeshCommand.getMeshTypeIfNeeded(documentMode: documentMode,
                                                                     isGuidesEnabled: isGuidesEnabled)
                
                let swivelType = JiggleMeshCommand.getSwivelTypeIfNeeded(documentMode: documentMode,
                                                                         displayMode: displayMode,
                                                                         isGuidesEnabled: isGuidesEnabled,
                                                                         isGraphEnabled: isGraphEnabled)
                
                let weightCurveType = ForceableTypeWithNone.none
                let weightRingCommand = JiggleWeightRingCommand.none
                let worldScale = getWorldScale()
                for jiggleIndex in 0..<jiggleCount {
                    let jiggle = jiggles[jiggleIndex]
                    let triangulationType = jiggle.currentHashPoly.triangulationType
                    let meshCommand = JiggleMeshCommand(spline: false,
                                                        triangulationType: triangulationType,
                                                        meshType: meshType,
                                                        outlineType: .ifNeeded,
                                                        swivelType: swivelType,
                                                        weightCurveType: weightCurveType)
                    jiggle.execute(meshCommand: meshCommand,
                                   isSelected: (jiggleIndex == selectedJiggleIndex),
                                   isDarkModeEnabled: ApplicationController.isDarkModeEnabled,
                                   worldScale: worldScale,
                                   weightRingCommand: weightRingCommand,
                                   forceWeightRingCommand: false,
                                   orientation: orientation)
                }
                
            }
        }
    }
    
    func countUnfrozenGuides() -> Int {
        var result = 0
        for jiggleIndex in 0..<jiggleCount {
            let jiggle = jiggles[jiggleIndex]
            if jiggle.isFrozen == false {
                for jiggleWeightRingIndex in 0..<jiggle.jiggleWeightRingCount {
                    let jiggleWeightRing = jiggle.jiggleWeightRings[jiggleWeightRingIndex]
                    if jiggleWeightRing.isFrozen == false {
                        result += 1
                    }
                }
            }
        }
        return result
    }
    
    func setJiggleOpacity(_ jiggleOpacity: Float) {
        ApplicationController.jiggleOpacity = jiggleOpacity
        
        if isViewMode == false {
            if isGuidesMode {
                for jiggleIndex in 0..<jiggleCount {
                    let jiggle = jiggles[jiggleIndex]
                    jiggle.refreshTriangleBufferEditWeights(isSelected: jiggleIndex == selectedJiggleIndex,
                                                            isDarkModeEnabled: jiggle.isShowingDarkMode)
                }
            } else if isJigglesOrPointsMode {
                for jiggleIndex in 0..<jiggleCount {
                    let jiggle = jiggles[jiggleIndex]
                    jiggle.refreshTriangleBufferEditStandard(isSelected: jiggleIndex == selectedJiggleIndex,
                                                             isDarkModeEnabled: jiggle.isShowingDarkMode)
                }
            }
        }
    }
    
    typealias Point = Math.Point
    typealias Vector = Math.Vector
    
    static let maxJiggleCount = 31
    
    var isWebScene = false
    var isDemo = false
    
    var isWakeUpComplete = false
    
    var isImageWrittenToRecent = false
    
    var documentWidth = 800
    var documentHeight = 800
    var documentName = "Untitled Scene"
    var isDocumentNameUserDirected = false
    
    
    
    var animationMode = AnimationMode.bounce
    
    weak var jiggleScene: JiggleScene?
    
    let animationController = AnimationController()
    
    //var isCreateJiggleCentersModificationEnabled = false
    //var isCreateGuideCentersModificationEnabled = false
    
    //var isCreateJiggleStandardEnabled = false
    //var isCreateJiggleDrawingEnabled = false
    
    //var isCreateWeightRingsStandardEnabled = false
    //var isCreateWeightRingsDrawingEnabled = false
    
    //var isCreatePointsEnabled = false
    //var isRemovePointsEnabled = false
    
    //var isCreateWeightRingPointsEnabled = false
    //var isRemoveWeightRingPointsEnabled = false
    
    var isViewMode: Bool {
        switch documentMode {
        case .__VIEW:
            return true
        default:
            return false
        }
    }
    
    var isTimeLineMode: Bool {
        switch documentMode {
        case .__VIEW:
            if isAnimationLoopsEnabled {
                switch animationMode {
                case .bounce:
                    if isTimeLineEnabled {
                        return true
                    } else {
                        return false
                    }
                default:
                    return false
                }
                
            } else {
                return false
            }
        default:
            return false
        }
    }
    
    var isEditMode: Bool {
        switch documentMode {
        case .__VIEW:
            return false
        case .__EDIT:
            return true
        }
    }
    
    var isJigglesOrPointsMode: Bool {
        switch documentMode {
        case .__VIEW:
            return false
        case .__EDIT:
            if isGuidesEnabled {
                return false
            } else {
                return true
            }
        }
    }
    
    var isJigglesMode: Bool {
        switch documentMode {
        case .__VIEW:
            return false
        case .__EDIT:
            if isGuidesEnabled {
                return false
            } else {
                switch editMode {
                case .jiggles:
                    return true
                case .points:
                    return false
                }
            }
        }
    }
    
    var isPointsMode: Bool {
        switch documentMode {
        case .__VIEW:
            return false
        case .__EDIT:
            if isGuidesEnabled {
                return false
            } else {
                switch editMode {
                case .jiggles:
                    return false
                case .points:
                    return true
                }
            }
        }
    }
    
    var isGuidesMode: Bool {
        switch documentMode {
        case .__VIEW:
            return false
        case .__EDIT:
            if isGuidesEnabled {
                return true
            } else {
                return false
            }
        }
    }
    
    var isGuidesAffineMode: Bool {
        switch documentMode {
        case .__VIEW:
            return false
        case .__EDIT:
            if isGuidesEnabled {
                switch weightMode {
                case .affine:
                    return true
                case .points:
                    return false
                }
            } else {
                return false
            }
        }
    }
    
    var isGuidesPointMode: Bool {
        switch documentMode {
        case .__VIEW:
            return false
        case .__EDIT:
            if isGuidesEnabled {
                switch weightMode {
                case .affine:
                    return false
                case .points:
                    return true
                }
            } else {
                return false
            }
        }
    }
    
    struct AttemptRemoveControlPointResult {
        let jiggleIndex: Int
        let controlPointIndex: Int
        let point: Point
    }
    
    struct AttemptRemoveWeightRingControlPointResult {
        let jiggleIndex: Int
        let weightCurveIndex: Int
        let weightRingControlPointIndex: Int
        let point: Point
    }
    
    typealias CreateJiggleData = JiggleDocumentPublisherLibrary.CreateJiggleData
    typealias RemoveJiggleData = JiggleDocumentPublisherLibrary.RemoveJiggleData
    typealias TransformJiggleData = JiggleDocumentPublisherLibrary.TransformJiggleData
    typealias TransformJiggleWeightRingData = JiggleDocumentPublisherLibrary.TransformJiggleWeightRingData
    
    typealias CreateWeightRingData = JiggleDocumentPublisherLibrary.CreateWeightRingData
    typealias CreateReplaceWeightRingListData = JiggleDocumentPublisherLibrary.CreateReplaceWeightRingListData
    
    typealias RemoveWeightRingData = JiggleDocumentPublisherLibrary.RemoveWeightRingData
    
    typealias GrabControlPointData = JiggleDocumentPublisherLibrary.GrabControlPointData
    typealias GrabWeightControlPointData = JiggleDocumentPublisherLibrary.GrabWeightControlPointData
    typealias GrabWeightCenterData = JiggleDocumentPublisherLibrary.GrabWeightCenterData
    
    
    typealias GrabJiggleCenterData = JiggleDocumentPublisherLibrary.GrabJiggleCenterData
    
    
    //typealias SelectedJiggleData = JiggleDocumentPublisherLibrary.SelectedJiggleData
    //typealias SelectedWeightCurveData = JiggleDocumentPublisherLibrary.SelectedWeightCurveData
    
    static let selectControlPointDistanceThresholdBase = Float(Device.isPad ? 32.0 : 24.0)
    static let selectControlTanDistanceThresholdBase = Float(Device.isPad ? 32.0 : 24.0)
    static let selectWeightCenterDistanceThresholdBase = Float(Device.isPad ? 44.0 : 36.0)
    static let selectDepthControlPointDistanceThreshold = Float(Device.isPad ? 44.0 : 32.0)
    static let selectDepthControlTanDistanceThreshold = Float(Device.isPad ? 44.0 : 32.0)
    
    var jigglesDidChangePublisher = PassthroughSubject<Void, Never>()
    var weightRingsDidChangePublisher = PassthroughSubject<Void, Never>()
    var controlPointsDidChangePublisher = PassthroughSubject<Void, Never>()
    var weightRingControlPointsDidChangePublisher = PassthroughSubject<Void, Never>()
    
    var creatorModeUpdatePublisher = PassthroughSubject<Void, Never>()
    
    //var createJiggleCentersModificationUpdatePublisher = PassthroughSubject<Bool, Never>()
    //var createGuideCentersModificationUpdatePublisher = PassthroughSubject<Bool, Never>()
    //var createJigglesStandardUpdatePublisher = PassthroughSubject<Bool, Never>()
    //var createJigglesDrawingUpdatePublisher = PassthroughSubject<Bool, Never>()
    
    //var createPointsUpdatePublisher = PassthroughSubject<Bool, Never>()
    //var removePointsUpdatePublisher = PassthroughSubject<Bool, Never>()
    
    //var createWeightRingsStandardUpdatePublisher = PassthroughSubject<Bool, Never>()
    //var createWeightRingsDrawingUpdatePublisher = PassthroughSubject<Bool, Never>()
    
    //var createWeightRingPointsUpdatePublisher = PassthroughSubject<Bool, Never>()
    //var removeWeightRingPointsUpdatePublisher = PassthroughSubject<Bool, Never>()
    
    var _createJiggleData = CreateJiggleData()
    let createJigglePublisher = PassthroughSubject<CreateJiggleData, Never>()
    
    var _removeJiggleData = RemoveJiggleData()
    let removeJigglePublisher = PassthroughSubject<RemoveJiggleData, Never>()
    
    var _createWeightRingData = CreateWeightRingData()
    let createWeightRingPublisher = PassthroughSubject<CreateWeightRingData, Never>()
    
    var _createReplaceWeightRingListData = CreateReplaceWeightRingListData()
    let createReplaceWeightRingListPublisher = PassthroughSubject<CreateReplaceWeightRingListData, Never>()
    
    var _removeWeightRingData = RemoveWeightRingData()
    let removeWeightRingPublisher = PassthroughSubject<RemoveWeightRingData, Never>()
    
    var _transformJiggleData = TransformJiggleData()
    let transformJigglePublisher = PassthroughSubject<TransformJiggleData, Never>()
    
    var _transformJiggleWeightRingData = TransformJiggleWeightRingData()
    let transformJiggleWeightRingPublisher = PassthroughSubject<TransformJiggleWeightRingData, Never>()
    
    let selectedJiggleDidChangePublisher = PassthroughSubject<Void, Never>()
    
    let selectedTimeLineSwatchUpdatePublisher = PassthroughSubject<Void, Never>()
    
    
    var _grabControlPointData = GrabControlPointData()
    let grabControlPointStopPublisher = PassthroughSubject<GrabControlPointData, Never>()
    
    var _grabWeightControlPointData = GrabWeightControlPointData()
    var grabWeightControlPointStopPublisher = PassthroughSubject<GrabWeightControlPointData, Never>()
    
    var _grabWeightCenterData = GrabWeightCenterData()
    var grabWeightCenterStopPublisher = PassthroughSubject<GrabWeightCenterData, Never>()
    
    var _grabJiggleCenterData = GrabJiggleCenterData()
    var grabJiggleCenterStopPublisher = PassthroughSubject<GrabJiggleCenterData, Never>()
    
    var drawingCaptureTool = DrawingCaptureTool()
    
    let drawJigglesSolidLineBuffer = SolidLineBufferOpen()
    let drawJigglesSolidLineBufferStroke = SolidLineBufferOpen()
    
    let drawWeightRingsSolidLineBuffer = SolidLineBufferOpen()
    let drawWeightRingsSolidLineBufferStroke = SolidLineBufferOpen()
    
    enum PointCreateMode {
        case nearest
        case after
        case before
    }
    
    enum WeightPointCreateMode {
        case nearest
        case after
        case before
    }
    
    enum TanType {
        case `in`
        case out
    }
    
    /*
     var isWeight: Bool {
     switch documentMode {
     case .weights:
     return true
     default:
     return false
     }
     }
     */
    
    var jiggles = [Jiggle]()
    var jiggleCount = 0
    
    var selectedJiggleIndex = 0
    func getSelectedJiggle() -> Jiggle? {
        if selectedJiggleIndex >= 0 && selectedJiggleIndex < jiggleCount {
            return jiggles[selectedJiggleIndex]
        }
        return nil
    }
    
    func getSelectedJiggleWeightRing() -> JiggleWeightRing? {
        if let selectedJiggle = getSelectedJiggle() {
            if let selectedJiggleWeightRing = selectedJiggle.getSelectedJiggleWeightRing() {
                return selectedJiggleWeightRing
            }
        }
        return nil
    }
    
    func getJiggle(_ index: Int) -> Jiggle? {
        if index >= 0 && index < jiggleCount {
            return jiggles[index]
        }
        return nil
    }
    
    func getJiggleIndex(_ jiggle: Jiggle) -> Int? {
        for index in 0..<jiggleCount {
            if jiggles[index] === jiggle {
                return index
            }
        }
        return nil
    }
    
    func getJiggleWeightRing(_ jiggleIndex: Int, _ jiggleWeightRingIndex: Int) -> JiggleWeightRing? {
        if jiggleIndex >= 0 && jiggleIndex < jiggleCount {
            let jiggle = jiggles[jiggleIndex]
            if jiggleWeightRingIndex >= 0 && jiggleWeightRingIndex < jiggle.jiggleWeightRingCount {
                return jiggle.jiggleWeightRings[jiggleWeightRingIndex]
            }
        }
        return nil
    }
    
    func getJiggleIndexWithWeightRing(weightRing: JiggleWeightRing) -> Int? {
        for jiggleIndex in 0..<jiggleCount {
            let jiggle = jiggles[jiggleIndex]
            if jiggle.containsJiggleWeightRing(weightRing) {
                return jiggleIndex
            }
        }
        return nil
    }
    
    func getJiggleWithWeightRing(weightRing: JiggleWeightRing) -> Jiggle? {
        for jiggleIndex in 0..<jiggleCount {
            let jiggle = jiggles[jiggleIndex]
            if jiggle.containsJiggleWeightRing(weightRing) {
                return jiggle
            }
        }
        return nil
    }
    
    func getWeightRingIndex(weightRing: JiggleWeightRing) -> Int? {
        for jiggleIndex in 0..<jiggleCount {
            let jiggle = jiggles[jiggleIndex]
            if let result = jiggle.getJiggleWeightRingIndex(weightRing) {
                return result
            }
        }
        return nil
    }
    
    func getWeightCurveIndex(weightRing: JiggleWeightRing) -> Int? {
        if let weightRingIndex = getWeightRingIndex(weightRing: weightRing) {
            return weightRingIndex + 1
        }
        return nil
    }
    
    func switchSelectedJiggle(newSelectedJiggleIndex: Int,
                              displayMode: DisplayMode,
                              isGraphEnabled: Bool) {
        
        print("switchSelectedJiggle: \(newSelectedJiggleIndex)")
        
        let meshType = JiggleMeshCommand.getMeshTypeIfNeeded(documentMode: documentMode,
                                                             isGuidesEnabled: isGuidesEnabled)
        
        let swivelType = JiggleMeshCommand.getSwivelTypeIfNeeded(documentMode: documentMode,
                                                                 displayMode: displayMode,
                                                                 isGuidesEnabled: isGuidesEnabled,
                                                                 isGraphEnabled: isGraphEnabled)
        let weightCurveType = ForceableTypeWithNone.none
        
        let weightRingCommand = JiggleWeightRingCommand.none
        let worldScale = getWorldScale()
        
        for jiggleIndex in 0..<jiggleCount {
            let jiggle = jiggles[jiggleIndex]
            let triangulationType = jiggle.currentHashPoly.triangulationType
            let meshCommand = JiggleMeshCommand(spline: false,
                                                triangulationType: triangulationType,
                                                meshType: meshType,
                                                outlineType: .ifNeeded,
                                                swivelType: swivelType,
                                                weightCurveType: weightCurveType)
            
            jiggle.execute(meshCommand: meshCommand,
                           isSelected: (jiggleIndex == newSelectedJiggleIndex),
                           isDarkModeEnabled: ApplicationController.isDarkModeEnabled,
                           worldScale: worldScale,
                           weightRingCommand: weightRingCommand,
                           forceWeightRingCommand: false,
                           orientation: orientation)
            
        }
        selectedJiggleIndex = newSelectedJiggleIndex
        selectedJiggleDidChangePublisher.send(())
        selectedTimeLineSwatchUpdatePublisher.send(())
    }
    
    func purgeJiggles() {
        for jiggleIndex in 0..<jiggleCount {
            let jiggle = jiggles[jiggleIndex]
            PolyMeshPartsFactory.shared.depositRingContent(jiggle.polyMesh.ring)
            JigglePartsFactory.shared.depositJiggle(jiggle)
        }
        jiggleCount = 0
        selectedJiggleIndex = -1
        selectedJiggleDidChangePublisher.send(())
        jigglesDidChangePublisher.send(())
        selectedTimeLineSwatchUpdatePublisher.send(())
    }
    
    var checkCheckJiggles = [Jiggle]()
    var checkCheckJiggleCount = 0
    
    func addCheckJiggle(_ checkCheckJiggle: Jiggle) {
        while checkCheckJiggles.count <= checkCheckJiggleCount {
            checkCheckJiggles.append(checkCheckJiggle)
        }
        checkCheckJiggles[checkCheckJiggleCount] = checkCheckJiggle
        checkCheckJiggleCount += 1
    }
    
    func resetCheckJiggles() {
        checkCheckJiggleCount = 0
    }
    
    // WeightCenter
    var selectedWeightCenterTouch: UITouch?
    var selectedWeightCenterStartTouchX = Float(0.0)
    var selectedWeightCenterStartTouchY = Float(0.0)
    var selectedWeightCenterStartX = Float(0.0)
    var selectedWeightCenterStartY = Float(0.0)
    
    // Points
    var selectedControlPointTouch: UITouch?
    var selectedControlPointStartTouchX = Float(0.0)
    var selectedControlPointStartTouchY = Float(0.0)
    var selectedControlPointStartX = Float(0.0)
    var selectedControlPointStartY = Float(0.0)
    
    // Weight Points
    var selectedWeightControlPointTouch: UITouch?
    var selectedWeightControlPointStartTouchX = Float(0.0)
    var selectedWeightControlPointStartTouchY = Float(0.0)
    var selectedWeightControlPointStartX = Float(0.0)
    var selectedWeightControlPointStartY = Float(0.0)
    
    // JiggleCenter
    var selectedJiggleCenterTouch: UITouch?
    var selectedJiggleCenterStartTouchX = Float(0.0)
    var selectedJiggleCenterStartTouchY = Float(0.0)
    var selectedJiggleCenterStartX = Float(0.0)
    var selectedJiggleCenterStartY = Float(0.0)
    
    // Affine Pan, Jiggles!
    weak var selectedJiggleAffine: Jiggle?
    var gestureCenterStartJiggleAffine = Point.zero
    var gestureCenterJiggleAffine = Point.zero
    var selectedJiggleStartCenterJiggleAffine = Point.zero
    var selectedJiggleStartScaleJiggleAffine = Float(1.0)
    var selectedJiggleStartRotationJiggleAffine = Float(0.0)
    var isPanningJiggleAffine = false
    var panStartCenterJiggleAffine = Point.zero
    var panCenterJiggleAffine = Point.zero
    var isPinchingJiggleAffine = false
    var pinchScaleJiggleAffine = Float(1.0)
    var isRotatingJiggleAffine = false
    var rotationJiggleAffine = Float(0.0)
    var _didUpdateJiggleAffine = false
    
    // Affine Pan, Weight Rings
    weak var selectedJiggleWeightRingAffine: JiggleWeightRing?
    var gestureCenterStartJiggleWeightRingAffine = Point.zero
    var gestureCenterJiggleWeightRingAffine = Point.zero
    var selectedJiggleWeightRingStartCenterJiggleWeightRingAffine = Point.zero
    var selectedJiggleWeightRingStartScaleJiggleWeightRingAffine = Float(1.0)
    var selectedJiggleWeightRingStartRotationJiggleWeightRingAffine = Float(0.0)
    var isPanningJiggleWeightRingAffine = false
    var panStartCenterJiggleWeightRingAffine = Point.zero
    var panCenterJiggleWeightRingAffine = Point.zero
    var isPinchingJiggleWeightRingAffine = false
    var pinchScaleJiggleWeightRingAffine = Float(1.0)
    var isRotatingJiggleWeightRingAffine = false
    var rotationJiggleWeightRingAffine = Float(0.0)
    var _didUpdateJiggleWeightRingAffine = false
    
    func getFullSizedImage() -> UIImage? {
        if let image = image {
            return image
        } else {
            if let savedFile = savedFile {
                let imagePath = FileUtils.shared.getSavedJigglesFilePath(fileName: savedFile.relativeFullSizedImagePath)
                if let image = FileUtils.shared.loadImage(imagePath) {
                    if image.size.width > 8.0, image.size.height > 8.0 {
                        return image
                    }
                }
            }
        }
        return nil
    }
    
    func getThumb() -> UIImage? {
        if let fullSizedImage = getFullSizedImage() {
            let squareImage: UIImage?
            if thumbCropFrame.width > 8 && thumbCropFrame.height > 8 {
                squareImage = fullSizedImage.crop(thumbCropFrame: thumbCropFrame)
            } else {
                
                let imageWidthI = Int(fullSizedImage.size.width + 0.5)
                let imageHeightI = Int(fullSizedImage.size.height + 0.5)
                
                if imageWidthI == imageHeightI {
                    squareImage = fullSizedImage.crop(x: 0, y: 0, width: imageWidthI, height: imageHeightI)
                } else if imageWidthI > imageHeightI {
                    
                    let shiftX = (imageWidthI - imageHeightI) >> 1
                    squareImage = fullSizedImage.crop(x: shiftX, y: 0, width: imageHeightI, height: imageHeightI)
                    
                } else {
                    let shiftY = (imageHeightI - imageWidthI) >> 1
                    squareImage = fullSizedImage.crop(x: 0, y: shiftY, width: imageWidthI, height: imageWidthI)
                }
            }
            if let squareImage = squareImage {
                if squareImage.size.width == 320.0 && squareImage.size.height == 320.0 {
                    return squareImage
                } else {
                    return squareImage.resize(CGSize(width: 320.0, height: 320.0))
                }
            }
        }
        return nil
    }
    
    let width: Float
    let width2: Float
    let height: Float
    let height2: Float
    let orientation: Orientation
    var image: UIImage?
    
    var thumbCropFrame = ThumbCropFrame()
    var savedFile: SavedFile?
    
    init(image: UIImage?,
         orientation: Orientation,
         documentWidth: Int,
         documentHeight: Int) {
        
        self.documentWidth = documentWidth
        self.documentHeight = documentHeight
        
        self.image = image
        self.orientation = orientation
        self.width = Float(documentWidth)
        self.height = Float(documentHeight)
        
        width2 = Float(Int(width * 0.5 + 0.5))
        height2 = Float(Int(height * 0.5 + 0.5))
        
        _init()
    }
    
    private func _init() {
        
        ApplicationController.shared.jiggleDocument = self
        
        drawJigglesSolidLineBuffer.thickness = ApplicationController.drawLineThickness
        drawJigglesSolidLineBuffer.red = 1.0
        drawJigglesSolidLineBuffer.green = 0.895
        drawJigglesSolidLineBuffer.blue = 0.0
        
        drawJigglesSolidLineBufferStroke.thickness = ApplicationController.drawStrokeLineThickness
        drawJigglesSolidLineBufferStroke.red = 0.125
        drawJigglesSolidLineBufferStroke.green = 0.125
        drawJigglesSolidLineBufferStroke.blue = 0.125
        
        drawWeightRingsSolidLineBuffer.thickness = ApplicationController.drawLineThickness
        drawWeightRingsSolidLineBuffer.red = 0.56
        drawWeightRingsSolidLineBuffer.green = 1.0
        drawWeightRingsSolidLineBuffer.blue = 0.7
        
        drawWeightRingsSolidLineBufferStroke.thickness = ApplicationController.drawStrokeLineThickness
        drawWeightRingsSolidLineBufferStroke.red = 0.125
        drawWeightRingsSolidLineBufferStroke.green = 0.125
        drawWeightRingsSolidLineBufferStroke.blue = 0.125
    }
    
    deinit {
        if ApplicationController.DEBUG_DEALLOCS {
            print("[--] JiggleDocument")
        }
    }
    
    func update(deltaTime: Float,
                displayMode: DisplayMode,
                weightMode: WeightMode,
                isStereoscopicEnabled: Bool,
                untransformScale: Float,
                isGraphEnabled: Bool) {
        
        animationController.update(deltaTime: deltaTime,
                                   jiggleDocument: self,
                                   untransformScale: untransformScale)
        
        for jiggleIndex in 0..<jiggleCount {
            let jiggle = jiggles[jiggleIndex]
            let isSelected = (jiggleIndex == selectedJiggleIndex)
            jiggle.update(deltaTime: deltaTime,
                          documentMode: documentMode,
                          displayMode: displayMode,
                          weightMode: weightMode,
                          isSelected: isSelected,
                          isStereoscopicEnabled: isStereoscopicEnabled,
                          isViewMode: isViewMode,
                          isJigglesMode: isJigglesMode,
                          isPointsMode: isPointsMode,
                          isGuidesMode: isGuidesMode,
                          isGuideCentersMode: (creatorMode == .moveGuideCenter))
        }
        
        // Is any type of active drag going on?
        
        if isWakeUpComplete {
            
            var isAnyJiggleTouchActive = false
            var isAnyJiggleWeightTouchActive = false
            
            if selectedWeightCenterTouch !== nil {
                isAnyJiggleWeightTouchActive = true
            }
            
            if selectedControlPointTouch !== nil {
                isAnyJiggleTouchActive = true
            }
            
            if selectedJiggleAffine !== nil {
                isAnyJiggleTouchActive = true
            }
            
            if selectedWeightControlPointTouch !== nil {
                isAnyJiggleWeightTouchActive = true
            }
            
            if selectedJiggleWeightRingAffine !== nil {
                isAnyJiggleWeightTouchActive = true
            }
            
            if selectedWeightCenterTouch !== nil {
                isAnyJiggleWeightTouchActive = true
            }
            
            let worldScale = getWorldScale()
            
            if isViewMode {
                if isStereoscopicEnabled {
                    for jiggleIndex in 0..<jiggleCount {
                        let jiggle = jiggles[jiggleIndex]
                        if !jiggle.isShowingLocked {
                            if jiggle.currentHashTrianglesViewStereoscopic.polyHash.triangulationType != .beautiful {
                                if jiggle.triangulationFastTick <= 0 {
                                    jiggle.triangulationFastTick = Jiggle.triangulationFastFixTime
                                } else {
                                    jiggle.triangulationFastTick -= 1
                                    if jiggle.triangulationFastTick <= 0 {
                                        print("Forcing Beautiful [View Stereo] @ \(jiggleIndex)")
                                        let meshCommand = JiggleMeshCommand(spline: false,
                                                                            triangulationType: .beautiful,
                                                                            meshType: .weightsIfNeeded,
                                                                            outlineType: .ifNeeded,
                                                                            swivelType: .none,
                                                                            weightCurveType: .ifNeeded)
                                        jiggle.execute(meshCommand: meshCommand,
                                                       isSelected: jiggleIndex == selectedJiggleIndex,
                                                       isDarkModeEnabled: ApplicationController.isDarkModeEnabled,
                                                       worldScale: worldScale,
                                                       weightRingCommand: .none,
                                                       forceWeightRingCommand: false,
                                                       orientation: orientation)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    for jiggleIndex in 0..<jiggleCount {
                        let jiggle = jiggles[jiggleIndex]
                        if !jiggle.isShowingLocked {
                            if jiggle.currentHashTrianglesViewStandard.polyHash.triangulationType != .beautiful {
                                if jiggle.triangulationFastTick <= 0 {
                                    jiggle.triangulationFastTick = Jiggle.triangulationFastFixTime
                                } else {
                                    jiggle.triangulationFastTick -= 1
                                    if jiggle.triangulationFastTick <= 0 {
                                        print("Forcing Beautiful [View Standard] @ \(jiggleIndex)")
                                        let meshCommand = JiggleMeshCommand(spline: false,
                                                                            triangulationType: .beautiful,
                                                                            meshType: .weightsIfNeeded,
                                                                            outlineType: .ifNeeded,
                                                                            swivelType: .none,
                                                                            weightCurveType: .ifNeeded)
                                        jiggle.execute(meshCommand: meshCommand,
                                                       isSelected: jiggleIndex == selectedJiggleIndex,
                                                       isDarkModeEnabled: ApplicationController.isDarkModeEnabled,
                                                       worldScale: worldScale,
                                                       weightRingCommand: .none,
                                                       forceWeightRingCommand: false,
                                                       orientation: orientation)
                                    }
                                }
                            }
                        }
                    }
                }
                
            } else if isJigglesOrPointsMode {
                if isAnyJiggleTouchActive == false {
                    for jiggleIndex in 0..<jiggleCount {
                        let jiggle = jiggles[jiggleIndex]
                        if !jiggle.isShowingLocked {
                            if jiggle.currentHashTrianglesStandard.polyHash.triangulationType != .beautiful {
                                if jiggle.triangulationFastTick <= 0 {
                                    jiggle.triangulationFastTick = Jiggle.triangulationFastFixTime
                                } else {
                                    jiggle.triangulationFastTick -= 1
                                    if jiggle.triangulationFastTick <= 0 {
                                        print("Forcing Beautiful [Edit Standard] @ \(jiggleIndex)")
                                        let meshCommand = JiggleMeshCommand(spline: false,
                                                                            triangulationType: .beautiful,
                                                                            meshType: .standardIfNeeded,
                                                                            outlineType: .ifNeeded,
                                                                            swivelType: .none,
                                                                            weightCurveType: .none)
                                        jiggle.execute(meshCommand: meshCommand,
                                                       isSelected: jiggleIndex == selectedJiggleIndex,
                                                       isDarkModeEnabled: ApplicationController.isDarkModeEnabled,
                                                       worldScale: worldScale,
                                                       weightRingCommand: .none,
                                                       forceWeightRingCommand: false,
                                                       orientation: orientation)
                                    }
                                }
                            }
                        }
                    }
                }
            } else if isGuidesMode {
                if isAnyJiggleWeightTouchActive == false {
                    for jiggleIndex in 0..<jiggleCount {
                        let jiggle = jiggles[jiggleIndex]
                        if !jiggle.isShowingLocked {
                            if jiggle.currentHashTrianglesWeights.polyHash.triangulationType != .beautiful {
                                if jiggle.triangulationFastTick <= 0 {
                                    jiggle.triangulationFastTick = Jiggle.triangulationFastFixTime
                                } else {
                                    jiggle.triangulationFastTick -= 1
                                    if jiggle.triangulationFastTick <= 0 {
                                        print("Forcing Beautiful [Edit Weights] @ \(jiggleIndex)")
                                        let swivelType = JiggleMeshCommand.getSwivelTypeIfNeeded(documentMode: documentMode,
                                                                                                 displayMode: displayMode,
                                                                                                 isGuidesEnabled: isGuidesEnabled,
                                                                                                 isGraphEnabled: isGraphEnabled)
                                        let meshCommand = JiggleMeshCommand(spline: false,
                                                                            triangulationType: .beautiful,
                                                                            meshType: .weightsIfNeeded,
                                                                            outlineType: .ifNeeded,
                                                                            swivelType: swivelType,
                                                                            weightCurveType: .ifNeeded)
                                        jiggle.execute(meshCommand: meshCommand,
                                                       isSelected: jiggleIndex == selectedJiggleIndex,
                                                       isDarkModeEnabled: ApplicationController.isDarkModeEnabled,
                                                       worldScale: worldScale,
                                                       weightRingCommand: .none,
                                                       forceWeightRingCommand: false,
                                                       orientation: orientation)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if isViewMode == false {
            animationController.killDragAll(jiggleDocument: self)
        }
    }
    
    func getMeshCommandForNewLoad(displayMode: DisplayMode,
                                  isGraphEnabled: Bool) -> JiggleMeshCommand {
        let meshType = JiggleMeshCommand.getMeshTypeIfNeeded(documentMode: documentMode,
                                                             isGuidesEnabled: isGuidesEnabled)
        let swivelType = JiggleMeshCommand.getSwivelTypeIfNeeded(documentMode: documentMode,
                                                                 displayMode: displayMode,
                                                                 isGuidesEnabled: isGuidesEnabled,
                                                                 isGraphEnabled: isGraphEnabled)
        let weightCurveType = JiggleMeshCommand.getWeightCurveTypeIfNeeded(documentMode: documentMode,
                                                                           isGuidesEnabled: isGuidesEnabled,
                                                                           isGraphEnabled: isGraphEnabled)
        
        return JiggleMeshCommand(spline: true,
                                 triangulationType: .fast,
                                 meshType: meshType,
                                 outlineType: .forced,
                                 swivelType: swivelType,
                                 weightCurveType: weightCurveType)
    }
    
    func getMeshCommandForNewJiggle(displayMode: DisplayMode,
                                    isGraphEnabled: Bool) -> JiggleMeshCommand {
        let meshType = JiggleMeshCommand.getMeshTypeIfNeeded(documentMode: documentMode,
                                                             isGuidesEnabled: isGuidesEnabled)
        let swivelType = JiggleMeshCommand.getSwivelTypeIfNeeded(documentMode: documentMode,
                                                                 displayMode: displayMode,
                                                                 isGuidesEnabled: isGuidesEnabled,
                                                                 isGraphEnabled: isGraphEnabled)
        let weightCurveType = JiggleMeshCommand.getWeightCurveTypeIfNeeded(documentMode: documentMode,
                                                                           isGuidesEnabled: isGuidesEnabled,
                                                                           isGraphEnabled: isGraphEnabled)
        return JiggleMeshCommand(spline: true,
                                 triangulationType: .beautiful,
                                 meshType: meshType,
                                 outlineType: .forced,
                                 swivelType: swivelType,
                                 weightCurveType: weightCurveType)
    }
    
    func getWeightRingCommandForNewJiggle() -> JiggleWeightRingCommand {
        JiggleWeightRingCommand(spline: true, outlineType: .ifNeeded)
    }
    
    func attemptJiggleAffineSelectWithTouch(at point: Point,
                                            displayMode: DisplayMode,
                                            isGraphEnabled: Bool) -> Bool {
        if isPanningJiggleAffine || isPinchingJiggleAffine || isRotatingJiggleAffine {
            return false
        }
        attemptSelectJiggle(at: point,
                            displayMode: displayMode,
                            isGraphEnabled: isGraphEnabled)
        if selectedJiggleIndex != -1 {
            selectedJiggleAffine = getSelectedJiggle()
            if let selectedAffineJiggle = selectedJiggleAffine {
                beginJiggleAffinePanScaleRotate(jiggle: selectedAffineJiggle)
            }
            return true
        }
        
        return false
    }
    
    func attemptJiggleWeightRingAffineSelectWithTouch(at point: Point,
                                                      displayMode: DisplayMode,
                                                      isGraphEnabled: Bool) -> Bool {
        if isPanningJiggleWeightRingAffine || isPinchingJiggleWeightRingAffine || isRotatingJiggleWeightRingAffine {
            return false
        }
        attemptSelectJiggleWeightRing(at: point,
                                      displayMode: displayMode,
                                      isGraphEnabled: isGraphEnabled)
        if selectedJiggleIndex != -1 {
            selectedJiggleWeightRingAffine = getSelectedJiggleWeightRing()
            if let selectedJiggleWeightRingAffine = selectedJiggleWeightRingAffine {
                beginJiggleWeightRingAffinePanScaleRotate(jiggleWeightRing: selectedJiggleWeightRingAffine)
            }
            return true
        }
        return false
    }
    
    
    
    func attemptGrabDrawJiggles(touch: UITouch, at point: Point) -> Bool {
        if drawingCaptureTool.isRecording == false {
            drawingCaptureTool.start(x: point.x, y: point.y, touch: touch)
            return true
        } else {
            return false
        }
    }
    
    func attemptGrabDrawWeightRings(touch: UITouch, at point: Point) -> Bool {
        if drawingCaptureTool.isRecording == false {
            drawingCaptureTool.start(x: point.x, y: point.y, touch: touch)
            return true
        } else {
            return false
        }
    }
    
    func attemptUpdateDrawJiggles(touch: UITouch,
                                  at point: Point,
                                  baseAdjustScale: Float,
                                  isFromRelease: Bool) -> Bool {
        if drawingCaptureTool.isRecording, drawingCaptureTool.touch === touch {
            let worldScale = getWorldScale()
            drawingCaptureTool.track(x: point.x, y: point.y)
            drawJigglesSolidLineBuffer.thickness = ApplicationController.drawLineThickness
            drawJigglesSolidLineBufferStroke.thickness = ApplicationController.drawStrokeLineThickness
            drawingCaptureTool.fillBuffer(drawJigglesSolidLineBuffer, worldScale: worldScale)
            drawingCaptureTool.fillBuffer(drawJigglesSolidLineBufferStroke, worldScale: worldScale)
            return true
        } else {
            return false
        }
    }
    
    func attemptUpdateDrawWeightRings(touch: UITouch,
                                      at point: Point,
                                      baseAdjustScale: Float,
                                      isFromRelease: Bool) -> Bool {
        if drawingCaptureTool.isRecording, drawingCaptureTool.touch === touch {
            let worldScale = getWorldScale()
            drawingCaptureTool.track(x: point.x, y: point.y)
            drawJigglesSolidLineBuffer.thickness = ApplicationController.drawLineThickness
            drawJigglesSolidLineBufferStroke.thickness = ApplicationController.drawStrokeLineThickness
            drawingCaptureTool.fillBuffer(drawWeightRingsSolidLineBuffer, worldScale: worldScale)
            drawingCaptureTool.fillBuffer(drawWeightRingsSolidLineBufferStroke, worldScale: worldScale)
            return true
        } else {
            return false
        }
    }
    
    func attemptReleaseDrawJiggles(touch: UITouch,
                                   at point: Point,
                                   jiggleEngine: JiggleEngine,
                                   displayMode: DisplayMode,
                                   isGraphEnabled: Bool) -> Bool {
        if drawingCaptureTool.isRecording, drawingCaptureTool.touch === touch {
            drawingCaptureTool.finish()
            drawJigglesSolidLineBuffer.removeAll(keepingCapacity: true)
            drawJigglesSolidLineBufferStroke.removeAll(keepingCapacity: true)
            if attemptCreateJiggle(spline: drawingCaptureTool.splineReduced,
                                   jiggleEngine: jiggleEngine,
                                   displayMode: displayMode,
                                   isGraphEnabled: isGraphEnabled) {
                drawingCaptureTool.reset()
                return true
            } else {
                drawingCaptureTool.reset()
                return false
            }
        } else {
            return false
        }
    }
    
    // TODO: If you exit the app, this goes weird?
    func attemptReleaseDrawWeightRings(touch: UITouch,
                                       at point: Point,
                                       jiggleEngine: JiggleEngine,
                                       displayMode: DisplayMode,
                                       isGraphEnabled: Bool) -> Bool {
        if drawingCaptureTool.isRecording, drawingCaptureTool.touch === touch {
            drawingCaptureTool.finish()
            drawWeightRingsSolidLineBuffer.removeAll(keepingCapacity: true)
            drawWeightRingsSolidLineBufferStroke.removeAll(keepingCapacity: true)
            if attemptCreateWeightRing(spline: drawingCaptureTool.splineReduced,
                                       jiggleEngine: jiggleEngine,
                                       displayMode: displayMode,
                                       isGraphEnabled: isGraphEnabled,
                                       isUntransformRequired: true) {
                drawingCaptureTool.reset()
                return true
            } else {
                drawingCaptureTool.reset()
                return false
            }
            
        } else {
            return false
        }
    }
    
    func attemptGrabJiggleJustToSelect(touches: [UITouch],
                                       at points: [Point],
                                       allTouchCount: Int,
                                       displayMode: DisplayMode,
                                       isGraphEnabled: Bool) {
        
        for point in points {
            let currentSelectedJiggleIndex = getIndexOfJiggleToSelect(at: point)
            if currentSelectedJiggleIndex != -1 {
                switchSelectedJiggle(newSelectedJiggleIndex: currentSelectedJiggleIndex,
                                     displayMode: displayMode,
                                     isGraphEnabled: isGraphEnabled)
                return
            }
        }
        switchSelectedJiggle(newSelectedJiggleIndex: -1,
                             displayMode: displayMode,
                             isGraphEnabled: isGraphEnabled)
    }
    
    func attemptGrabJiggleAnimationCursor(touches: [UITouch],
                                          at points: [Point],
                                          allTouchCount: Int,
                                          displayMode: DisplayMode,
                                          isGraphEnabled: Bool) {
        animationController.attemptGrabJiggleAnimationCursor(jiggleDocument: self,
                                                             touches: touches,
                                                             at: points,
                                                             allTouchCount: allTouchCount,
                                                             displayMode: displayMode,
                                                             isGraphEnabled: isGraphEnabled)
    }
    
    func attemptUpdateJiggleAnimationCursor(touches: [UITouch],
                                            at points: [Point],
                                            allTouchCount: Int,
                                            displayMode: DisplayMode,
                                            isGraphEnabled: Bool) {
        animationController.attemptUpdateJiggleAnimationCursor(jiggleDocument: self,
                                                               touches: touches,
                                                               at: points,
                                                               allTouchCount: allTouchCount,
                                                               displayMode: displayMode,
                                                               isGraphEnabled: isGraphEnabled)
    }
    
    func attemptReleaseJiggleAnimationCursor(touches: [UITouch],
                                             at points: [Point],
                                             allTouchCount: Int,
                                             untransformScale: Float) {
        animationController.attemptReleaseJiggleAnimationCursor(jiggleDocument: self,
                                                                touches: touches,
                                                                at: points,
                                                                allTouchCount: allTouchCount,
                                                                untransformScale: untransformScale)
    }
    
    func attemptResetWeightGraph(displayMode: DisplayMode,
                                 isGraphEnabled: Bool) -> Bool {
        if let selectedJiggle = getSelectedJiggle() {
            
            selectedJiggle.resetWeightGraph()
            
            refreshGraphModify(jiggle: selectedJiggle,
                               displayMode: displayMode,
                               isGraphEnabled: isGraphEnabled)
            selectedJiggle.refreshWeightCurve()
            return true
        }
        return false
    }
    
    func attemptBreakManualWeightGraph(displayMode: DisplayMode,
                                       isGraphEnabled: Bool) -> Bool {
        if let selectedJiggle = getSelectedJiggle() {
            if let selectedWeightCurveControlPoint = selectedJiggle.getSelectedWeightCurveControlPoint() {
                selectedWeightCurveControlPoint.isManualHeightEnabled = false
                selectedWeightCurveControlPoint.isManualTanHandleEnabled = false
                refreshGraphModify(jiggle: selectedJiggle,
                                   displayMode: displayMode,
                                   isGraphEnabled: isGraphEnabled)
                selectedJiggle.refreshWeightCurve()
                return true
            }
        }
        return false
    }
    
    func selectAnyJiggleIfNoneSelected(displayMode: DisplayMode, isGraphEnabled: Bool) {
        if getSelectedJiggle() !== nil {
            return
        } else {
            if jiggleCount > 0 {
                selectedJiggleIndex = jiggleCount - 1
                switchSelectedJiggle(newSelectedJiggleIndex: selectedJiggleIndex,
                                     displayMode: displayMode,
                                     isGraphEnabled: isGraphEnabled)
            }
        }
    }
    
    func killDragAll() {
        killDragNormal()
        animationController.killDragAll(jiggleDocument: self)
    }
    
    func killDragNormal() {
        killDragJiggleCenter()
        killDragWeightCenter()
        killDragControlPoint()
        killDragWeightControlPoint()
        if (isPanningJiggleWeightRingAffine == false) &&
            (isPinchingJiggleWeightRingAffine == false) &&
            (isRotatingJiggleWeightRingAffine == false) {
            selectedJiggleWeightRingAffine = nil
        }
    }
    
    func killDragWeightCenter() {
        if selectedWeightCenterTouch !== nil {
            if let selectedJiggle = getSelectedJiggle() {
                if _grabWeightCenterData.jiggleIndex == selectedJiggleIndex {
                    grabWeightCenterStopPublisher.send(_grabWeightCenterData)
                }
                selectedJiggle.currentHashPoly.triangulationType = .none
                selectedJiggle.currentHashTrianglesWeights.polyHash.triangulationType = .none
                selectedJiggle.currentHashTrianglesStandard.polyHash.triangulationType = .none
            }
        }
        selectedWeightCenterTouch = nil
    }
    
    func killDragJiggleCenter() {
        if selectedJiggleCenterTouch !== nil {
            if getSelectedJiggle() !== nil {
                if _grabJiggleCenterData.jiggleIndex == selectedJiggleIndex {
                    grabJiggleCenterStopPublisher.send(_grabJiggleCenterData)
                }
            }
        }
        selectedJiggleCenterTouch = nil
    }
    
    func killDragControlPoint() {
        if selectedControlPointTouch !== nil {
            if let selectedJiggle = getSelectedJiggle() {
                if selectedJiggle.getSelectedJiggleControlPoint() != nil {
                    if _grabControlPointData.jiggleIndex == selectedJiggleIndex &&
                        _grabControlPointData.controlPointIndex == selectedJiggle.selectedJiggleControlPointIndex {
                        grabControlPointStopPublisher.send(_grabControlPointData)
                        _grabControlPointData.didChange = false
                    }
                }
                selectedJiggle.currentHashPoly.triangulationType = .none
                selectedJiggle.currentHashTrianglesWeights.polyHash.triangulationType = .none
                selectedJiggle.currentHashTrianglesStandard.polyHash.triangulationType = .none
            }
        }
        selectedControlPointTouch = nil
    }
    
    func killDragWeightControlPoint() {
        if selectedWeightControlPointTouch !== nil {
            if let selectedJiggle = getSelectedJiggle() {
                if let selectedJiggleWeightRing = selectedJiggle.getSelectedJiggleWeightRing() {
                    if selectedJiggleWeightRing.getSelectedJiggleControlPoint() != nil {
                        if _grabWeightControlPointData.jiggleIndex == selectedJiggleIndex &&
                            _grabWeightControlPointData.weightCurveIndex == selectedJiggle.selectedWeightCurveControlIndex &&
                            _grabWeightControlPointData.weightControlPointIndex == selectedJiggleWeightRing.selectedJiggleControlPointIndex {
                            grabWeightControlPointStopPublisher.send(_grabWeightControlPointData)
                        }
                    }
                }
                selectedJiggle.currentHashPoly.triangulationType = .none
                selectedJiggle.currentHashTrianglesWeights.polyHash.triangulationType = .none
                selectedJiggle.currentHashTrianglesStandard.polyHash.triangulationType = .none
            }
        }
        selectedWeightControlPointTouch = nil
    }
    
    func clear() {
        purgeJiggles()
    }
    
    func getWorldScale() -> Float {
        var result = Float(1.0)
        if let jiggleScene = jiggleScene {
            if fabsf(jiggleScene.sceneScale) > Math.epsilon {
                result = (1.0 / jiggleScene.sceneScale)
            }
        }
        return result
    }
    
    func handleSceneScaleDidChange(displayMode: DisplayMode,
                                   isGraphEnabled: Bool) {
        let meshType = JiggleMeshCommand.getMeshTypeIfNeeded(documentMode: documentMode,
                                                             isGuidesEnabled: isGuidesEnabled)
        let swivelType = JiggleMeshCommand.getSwivelTypeIfNeeded(documentMode: documentMode,
                                                                 displayMode: displayMode,
                                                                 isGuidesEnabled: isGuidesEnabled,
                                                                 isGraphEnabled: isGraphEnabled)
        let weightCurveType = JiggleMeshCommand.getWeightCurveTypeIfNeeded(documentMode: documentMode,
                                                                           isGuidesEnabled: isGuidesEnabled,
                                                                           isGraphEnabled: isGraphEnabled)
        let meshCommand = JiggleMeshCommand(spline: false,
                                            triangulationType: .beautiful,
                                            meshType: meshType,
                                            outlineType: .ifNeeded,
                                            swivelType: swivelType,
                                            weightCurveType: weightCurveType)
        let weightRingCommand = JiggleWeightRingCommand(spline: false,
                                                        outlineType: .ifNeeded)
        applyMeshCommandAllJiggles(meshCommand: meshCommand,
                                   weightRingCommand: weightRingCommand)
    }
    
    func lockShowingState() {
        for jiggleIndex in 0..<jiggleCount {
            jiggles[jiggleIndex].lockShowingState()
        }
    }
    
    func unlockShowingState() {
        for jiggleIndex in 0..<jiggleCount {
            jiggles[jiggleIndex].unlockShowingState()
        }
    }
    
    func applyMeshCommandAllJiggles(meshCommand: JiggleMeshCommand,
                                    weightRingCommand: JiggleWeightRingCommand) {
        let worldScale = getWorldScale()
        for jiggleIndex in 0..<jiggleCount {
            let isSelected = (selectedJiggleIndex == jiggleIndex)
            jiggles[jiggleIndex].execute(meshCommand: meshCommand,
                                         isSelected: isSelected,
                                         isDarkModeEnabled: ApplicationController.isDarkModeEnabled,
                                         worldScale: worldScale,
                                         weightRingCommand: weightRingCommand,
                                         forceWeightRingCommand: false,
                                         orientation: orientation)
        }
    }
    
    func applyMeshCommandOneJiggle(meshCommand: JiggleMeshCommand,
                                   weightRingCommand: JiggleWeightRingCommand,
                                   jiggle: Jiggle) {
        let worldScale = getWorldScale()
        for jiggleIndex in 0..<jiggleCount {
            if jiggles[jiggleIndex] === jiggle {
                let isSelected = (selectedJiggleIndex == jiggleIndex)
                jiggles[jiggleIndex].execute(meshCommand: meshCommand,
                                             isSelected: isSelected,
                                             isDarkModeEnabled: ApplicationController.isDarkModeEnabled,
                                             worldScale: worldScale,
                                             weightRingCommand: weightRingCommand,
                                             forceWeightRingCommand: false,
                                             orientation: orientation)
            }
        }
    }
    
    // [Verified]
    // Mesh Actions:
    //  a.) affine only
    //  b.) switchSelectedJiggle
    func refreshJiggleAffineAndSelect(at index: Int,
                                      displayMode: DisplayMode,
                                      isGraphEnabled: Bool) {
        if let jiggle = getJiggle(index) {
            refreshJiggleAffineStandard(jiggle: jiggle,
                                        displayMode: displayMode,
                                        isGraphEnabled: isGraphEnabled)
            switchSelectedJiggle(newSelectedJiggleIndex: index,
                                 displayMode: displayMode,
                                 isGraphEnabled: isGraphEnabled)
        }
    }
    
    // [Verified]
    // Mesh Actions:
    //  a.) affine only
    func refreshJiggleAffineStandard(jiggle: Jiggle,
                                     displayMode: DisplayMode,
                                     isGraphEnabled: Bool) {
        
        let worldScale = getWorldScale()
        let swivelType = JiggleMeshCommand.getSwivelTypeIfNeeded(documentMode: documentMode,
                                                                 displayMode: displayMode,
                                                                 isGuidesEnabled: isGuidesEnabled,
                                                                 isGraphEnabled: isGraphEnabled)
        let weightCurveType = JiggleMeshCommand.getWeightCurveTypeIfNeeded(documentMode: documentMode,
                                                                           isGuidesEnabled: isGuidesEnabled,
                                                                           isGraphEnabled: isGraphEnabled)
        let meshCommand = JiggleMeshCommand(spline: false,
                                            triangulationType: .beautiful,
                                            meshType: .affineOnlyStandard,
                                            outlineType: .ifNeeded,
                                            swivelType: swivelType,
                                            weightCurveType: weightCurveType)
        let isSelected = (getSelectedJiggle() === jiggle)
        jiggle.execute(meshCommand: meshCommand,
                       isSelected: isSelected,
                       isDarkModeEnabled: ApplicationController.isDarkModeEnabled,
                       worldScale: worldScale,
                       weightRingCommand: .none,
                       forceWeightRingCommand: false,
                       orientation: orientation)
    }
    
    // [Verified]
    // Mesh Actions:
    //  a.) Spline to selected jiggle.
    //  b.) switchSelectedJiggle
    func refreshFlipOrRotateJiggleAndSelect(at index: Int,
                                            displayMode: DisplayMode,
                                            isGraphEnabled: Bool,
                                            isCreateOrRemove: Bool) {
        if let jiggle = getJiggle(index) {
            refreshFlipOrRotateJiggle(jiggle: jiggle,
                                      displayMode: displayMode,
                                      isGraphEnabled: isGraphEnabled,
                                      isCreateOrRemove: isCreateOrRemove)
            switchSelectedJiggle(newSelectedJiggleIndex: index,
                                 displayMode: displayMode,
                                 isGraphEnabled: isGraphEnabled)
        }
    }
    
    // [Verified]
    // Mesh Actions:
    //  a.) Spline to selected jiggle.
    func refreshFlipOrRotateJiggle(jiggle: Jiggle,
                                   displayMode: DisplayMode,
                                   isGraphEnabled: Bool,
                                   isCreateOrRemove: Bool) {
        let worldScale = getWorldScale()
        let meshType = JiggleMeshCommand.getMeshTypeIfNeeded(documentMode: documentMode,
                                                             isGuidesEnabled: isGuidesEnabled)
        let swivelType = JiggleMeshCommand.getSwivelTypeIfNeeded(documentMode: documentMode,
                                                                 displayMode: displayMode,
                                                                 isGuidesEnabled: isGuidesEnabled,
                                                                 isGraphEnabled: isGraphEnabled)
        let weightCurveType = JiggleMeshCommand.getWeightCurveTypeIfNeeded(documentMode: documentMode,
                                                                           isGuidesEnabled: isGuidesEnabled,
                                                                           isGraphEnabled: isGraphEnabled)
        let meshCommand = JiggleMeshCommand(spline: true,
                                            triangulationType: .fast,
                                            meshType: meshType,
                                            outlineType: .ifNeeded,
                                            swivelType: swivelType,
                                            weightCurveType: weightCurveType)
        
        let weightRingCommand = JiggleWeightRingCommand(spline: true, outlineType: .ifNeeded)
        
        let isSelected = (getSelectedJiggle() === jiggle)
        jiggle.execute(meshCommand: meshCommand,
                       isSelected: isSelected,
                       isDarkModeEnabled: ApplicationController.isDarkModeEnabled,
                       worldScale: worldScale,
                       weightRingCommand: weightRingCommand,
                       forceWeightRingCommand: false,
                       orientation: orientation)
        if isCreateOrRemove {
            controlPointsDidChangePublisher.send(())
        }
    }
    
    
    
    // [Verified]
    // Mesh Actions:
    //  a.) Spline to selected jiggle.
    //  b.) switchSelectedJiggle
    func refreshJiggleControlPointAndSelect(at index: Int,
                                            displayMode: DisplayMode,
                                            isGraphEnabled: Bool) {
        if let jiggle = getJiggle(index) {
            refreshJiggleControlPoint(jiggle: jiggle,
                                      displayMode: displayMode,
                                      isGraphEnabled: isGraphEnabled)
            switchSelectedJiggle(newSelectedJiggleIndex: index,
                                 displayMode: displayMode,
                                 isGraphEnabled: isGraphEnabled)
        }
    }
    
    // [Verified]
    // Mesh Actions:
    //  a.) Spline to selected jiggle.
    func refreshJiggleControlPoint(jiggle: Jiggle,
                                   displayMode: DisplayMode,
                                   isGraphEnabled: Bool) {
        let worldScale = getWorldScale()
        let meshType = JiggleMeshCommand.getMeshTypeIfNeeded(documentMode: documentMode,
                                                             isGuidesEnabled: isGuidesEnabled)
        let swivelType = JiggleMeshCommand.getSwivelTypeIfNeeded(documentMode: documentMode,
                                                                 displayMode: displayMode,
                                                                 isGuidesEnabled: isGuidesEnabled,
                                                                 isGraphEnabled: isGraphEnabled)
        let weightCurveType = JiggleMeshCommand.getWeightCurveTypeIfNeeded(documentMode: documentMode,
                                                                           isGuidesEnabled: isGuidesEnabled,
                                                                           isGraphEnabled: isGraphEnabled)
        let meshCommand = JiggleMeshCommand(spline: true,
                                            triangulationType: .fast,
                                            meshType: meshType,
                                            outlineType: .ifNeeded,
                                            swivelType: swivelType,
                                            weightCurveType: weightCurveType)
        let isSelected = (getSelectedJiggle() === jiggle)
        jiggle.execute(meshCommand: meshCommand,
                       isSelected: isSelected,
                       isDarkModeEnabled: ApplicationController.isDarkModeEnabled,
                       worldScale: worldScale,
                       weightRingCommand: .none,
                       forceWeightRingCommand: false,
                       orientation: orientation)
    }
    
    // [Verified]
    // Mesh Actions:
    //  a.) AffineOnlyWeights, Forced-Graph to selected jiggle.
    //  b.) Re-Spline affine weight ring.
    //  c.) Re-Paint other weight rings.
    //  d.) switchSelectedJiggle
    func refreshWeightRingAffineAndSelect(jiggleIndex: Int,
                                          weightRingIndex: Int,
                                          displayMode: DisplayMode,
                                          isGraphEnabled: Bool) {
        if let jiggle = getJiggle(jiggleIndex) {
            if let jiggleWeightRing = jiggle.getJiggleWeightRing(weightRingIndex) {
                
                refreshWeightRingAffine(jiggle: jiggle,
                                        jiggleWeightRing: jiggleWeightRing,
                                        displayMode: displayMode,
                                        isGraphEnabled: isGraphEnabled)
                
                let weightCurveControlIndex = (weightRingIndex + 1)
                jiggle.switchSelectedWeightCurveControlIndex(index: weightCurveControlIndex)
                
                switchSelectedJiggle(newSelectedJiggleIndex: jiggleIndex,
                                     displayMode: displayMode,
                                     isGraphEnabled: isGraphEnabled)
                
                jiggle.currentHashPoly.triangulationType = .none
                jiggle.currentHashTrianglesWeights.polyHash.triangulationType = .none
                jiggle.currentHashTrianglesStandard.polyHash.triangulationType = .none
                
            }
        }
    }
    
    // [Verified]
    // Mesh Actions:
    //  a.) AffineOnlyWeights, Forced-Graph to selected jiggle.
    //  b.) Re-Spline affine weight ring.
    //  c.) Re-Paint other weight rings.
    func refreshWeightRingAffine(jiggle: Jiggle,
                                 jiggleWeightRing: JiggleWeightRing,
                                 displayMode: DisplayMode,
                                 isGraphEnabled: Bool) {
        
        let swivelType = JiggleMeshCommand.getSwivelTypeIfNeeded(documentMode: documentMode,
                                                                 displayMode: displayMode,
                                                                 isGuidesEnabled: isGuidesEnabled,
                                                                 isGraphEnabled: isGraphEnabled)
        let meshCommand = JiggleMeshCommand(spline: false,
                                            triangulationType: .beautiful,
                                            meshType: .affineOnlyWeights,
                                            outlineType: .ifNeeded,
                                            swivelType: swivelType,
                                            weightCurveType: .forced)
        
        let worldScale = getWorldScale()
        let isDarkModeEnabled = ApplicationController.isDarkModeEnabled
        let weightRingCommandForTarget = JiggleWeightRingCommand(spline: true, outlineType: .forced)
        let weightRingCommandForOthers = JiggleWeightRingCommand.none
        let isSelected = (getSelectedJiggle() === jiggle)
        jiggle.execute(meshCommand: meshCommand,
                       isSelected: isSelected,
                       isDarkModeEnabled: isDarkModeEnabled,
                       worldScale: worldScale,
                       targetWeightRing: jiggleWeightRing,
                       weightRingCommandForTarget: weightRingCommandForTarget,
                       weightRingCommandForOthers: weightRingCommandForOthers,
                       orientation: orientation)
        
    }
    
    
    // [Verified]
    // Mesh Actions:
    //  a.) AffineOnlyWeights, Forced-Graph to selected jiggle.
    //  b.) Re-Spline affine weight ring.
    //  c.) Re-Paint other weight rings.
    func refreshWeightRingModify(jiggle: Jiggle,
                                 jiggleWeightRing: JiggleWeightRing,
                                 displayMode: DisplayMode,
                                 isGraphEnabled: Bool) {
        
        let swivelType = JiggleMeshCommand.getSwivelTypeIfNeeded(documentMode: documentMode,
                                                                 displayMode: displayMode,
                                                                 isGuidesEnabled: isGuidesEnabled,
                                                                 isGraphEnabled: isGraphEnabled)
        let meshCommand = JiggleMeshCommand(spline: false,
                                            triangulationType: .beautiful,
                                            meshType: .affineOnlyWeights,
                                            outlineType: .ifNeeded,
                                            swivelType: swivelType,
                                            weightCurveType: .none)
        
        if let weightRingIndex = jiggle.getJiggleWeightRingIndex(jiggleWeightRing) {
            jiggle.switchSelectedWeightCurveControlIndex(index: weightRingIndex + 1)
        }
        
        let worldScale = getWorldScale()
        let isDarkModeEnabled = ApplicationController.isDarkModeEnabled
        let weightRingCommandForTarget = JiggleWeightRingCommand(spline: true, outlineType: .forced)
        let weightRingCommandForOthers = JiggleWeightRingCommand.none
        jiggle.execute(meshCommand: meshCommand,
                       isSelected: true,
                       isDarkModeEnabled: isDarkModeEnabled,
                       worldScale: worldScale,
                       targetWeightRing: jiggleWeightRing,
                       weightRingCommandForTarget: weightRingCommandForTarget,
                       weightRingCommandForOthers: weightRingCommandForOthers,
                       orientation: orientation)
        
        let jiggleIndex = getJiggleIndex(jiggle) ?? -1
        switchSelectedJiggle(newSelectedJiggleIndex: jiggleIndex,
                             displayMode: displayMode,
                             isGraphEnabled: isGraphEnabled)
        
        jiggle.currentHashPoly.triangulationType = .none
        jiggle.currentHashMeshWeights.polyHash.triangulationType = .none
        jiggle.currentHashTrianglesWeights.polyHash.triangulationType = .none
        jiggle.currentHashTrianglesStandard.polyHash.triangulationType = .none
    }
    
    func refreshWeightRingModifyList(jiggle: Jiggle,
                                     displayMode: DisplayMode,
                                     isGraphEnabled: Bool) {
        
        let swivelType = JiggleMeshCommand.getSwivelTypeIfNeeded(documentMode: documentMode,
                                                                 displayMode: displayMode,
                                                                 isGuidesEnabled: isGuidesEnabled,
                                                                 isGraphEnabled: isGraphEnabled)
        let meshCommand = JiggleMeshCommand(spline: false,
                                            triangulationType: .beautiful,
                                            meshType: .affineOnlyWeights,
                                            outlineType: .ifNeeded,
                                            swivelType: swivelType,
                                            weightCurveType: .ifNeeded)
        
        let worldScale = getWorldScale()
        let isDarkModeEnabled = ApplicationController.isDarkModeEnabled
        let weightRingCommand = JiggleWeightRingCommand(spline: true, outlineType: .forced)
        jiggle.execute(meshCommand: meshCommand,
                       isSelected: true,
                       isDarkModeEnabled: isDarkModeEnabled,
                       worldScale: worldScale,
                       weightRingCommand: weightRingCommand,
                       forceWeightRingCommand: true,
                       orientation: orientation)
        
        let jiggleIndex = getJiggleIndex(jiggle) ?? -1
        switchSelectedJiggle(newSelectedJiggleIndex: jiggleIndex,
                             displayMode: displayMode,
                             isGraphEnabled: isGraphEnabled)
        
        jiggle.currentHashPoly.triangulationType = .none
        jiggle.currentHashTrianglesWeights.polyHash.triangulationType = .none
        jiggle.currentHashTrianglesStandard.polyHash.triangulationType = .none
    }
    
    // [Verified]
    // Mesh Actions:
    //  a.) AffineOnlyWeights, Forced-Graph to selected jiggle.
    //  b.) Re-Spline affine weight ring.
    //  c.) Re-Paint other weight rings.
    func refreshWeightRingModify(jiggle: Jiggle,
                                 displayMode: DisplayMode,
                                 isGraphEnabled: Bool) {
        
        let swivelType = JiggleMeshCommand.getSwivelTypeIfNeeded(documentMode: documentMode,
                                                                 displayMode: displayMode,
                                                                 isGuidesEnabled: isGuidesEnabled,
                                                                 isGraphEnabled: isGraphEnabled)
        let meshCommand = JiggleMeshCommand(spline: false,
                                            triangulationType: .beautiful,
                                            meshType: .affineOnlyWeights,
                                            outlineType: .ifNeeded,
                                            swivelType: swivelType,
                                            weightCurveType: .none)
        
        let worldScale = getWorldScale()
        let isDarkModeEnabled = ApplicationController.isDarkModeEnabled
        let weightRingCommand = JiggleWeightRingCommand.none
        jiggle.execute(meshCommand: meshCommand,
                       isSelected: true,
                       isDarkModeEnabled: isDarkModeEnabled,
                       worldScale: worldScale,
                       weightRingCommand: weightRingCommand,
                       forceWeightRingCommand: true,
                       orientation: orientation)
        
        let jiggleIndex = getJiggleIndex(jiggle) ?? -1
        switchSelectedJiggle(newSelectedJiggleIndex: jiggleIndex,
                             displayMode: displayMode,
                             isGraphEnabled: isGraphEnabled)
        
        jiggle.currentHashPoly.triangulationType = .none
        jiggle.currentHashTrianglesWeights.polyHash.triangulationType = .none
        jiggle.currentHashTrianglesStandard.polyHash.triangulationType = .none
    }
    
    // [Verified]
    // Mesh Actions:
    //  a.) AffineOnlyWeights, Forced-Graph to selected jiggle.
    //  b.) Re-Spline affine weight ring.
    //  c.) Re-Paint other weight rings.
    func refreshWeightCenterModify(jiggle: Jiggle,
                                   displayMode: DisplayMode,
                                   isGraphEnabled: Bool) {
        
        let swivelType = JiggleMeshCommand.getSwivelTypeIfNeeded(documentMode: documentMode,
                                                                 displayMode: displayMode,
                                                                 isGuidesEnabled: isGuidesEnabled,
                                                                 isGraphEnabled: isGraphEnabled)
        let meshCommand = JiggleMeshCommand(spline: false,
                                            triangulationType: .beautiful,
                                            meshType: .affineOnlyWeights,
                                            outlineType: .ifNeeded,
                                            swivelType: swivelType,
                                            weightCurveType: .none)
        
        let worldScale = getWorldScale()
        let isDarkModeEnabled = ApplicationController.isDarkModeEnabled
        let weightRingCommand = JiggleWeightRingCommand.none
        jiggle.execute(meshCommand: meshCommand,
                       isSelected: true,
                       isDarkModeEnabled: isDarkModeEnabled,
                       worldScale: worldScale,
                       weightRingCommand: weightRingCommand,
                       forceWeightRingCommand: false,
                       orientation: orientation)
        
        let jiggleIndex = getJiggleIndex(jiggle) ?? -1
        switchSelectedJiggle(newSelectedJiggleIndex: jiggleIndex,
                             displayMode: displayMode,
                             isGraphEnabled: isGraphEnabled)
        
        jiggle.currentHashPoly.triangulationType = .none
        jiggle.currentHashTrianglesWeights.polyHash.triangulationType = .none
        jiggle.currentHashTrianglesStandard.polyHash.triangulationType = .none
    }
    
    // [Verified]
    // Mesh Actions:
    //  a.) AffineOnlyWeights, Forced-Graph to selected jiggle.
    //  b.) Re-Spline affine weight ring.
    //  c.) Re-Paint other weight rings.
    func refreshGraphModify(jiggle: Jiggle,
                            weightCurveControlIndex: Int,
                            displayMode: DisplayMode,
                            isGraphEnabled: Bool) {
        
        jiggle.switchSelectedWeightCurveControlIndex(index: weightCurveControlIndex)
        
        let swivelType = ForceableTypeWithNone.forced
        let meshCommand = JiggleMeshCommand(spline: false,
                                            triangulationType: .beautiful,
                                            meshType: .weightsOnly,
                                            outlineType: .ifNeeded,
                                            swivelType: swivelType,
                                            weightCurveType: .ifNeeded)
        let weightRingCommand = JiggleWeightRingCommand.none
        let worldScale = getWorldScale()
        let isDarkModeEnabled = ApplicationController.isDarkModeEnabled
        
        jiggle.execute(meshCommand: meshCommand,
                       isSelected: true,
                       isDarkModeEnabled: isDarkModeEnabled,
                       worldScale: worldScale,
                       weightRingCommand: weightRingCommand,
                       forceWeightRingCommand: false,
                       orientation: orientation)
        
        let jiggleIndex = getJiggleIndex(jiggle) ?? -1
        switchSelectedJiggle(newSelectedJiggleIndex: jiggleIndex,
                             displayMode: displayMode,
                             isGraphEnabled: true)
        
        /*
         let swivelType = ForceableTypeWithNone.forced
         let meshCommand = JiggleMeshCommand(spline: false,
         triangulationType: .beautiful,
         meshType: .none,
         outlineType: .ifNeeded,
         swivelType: swivelType,
         weightCurveType: .none)
         
         let worldScale = getWorldScale()
         let isDarkModeEnabled = ApplicationController.isDarkModeEnabled
         let weightRingCommand = JiggleWeightRingCommand.none
         jiggle.execute(meshCommand: meshCommand,
         isSelected: true,
         isDarkModeEnabled: isDarkModeEnabled,
         worldScale: worldScale,
         weightRingCommand: weightRingCommand,
         forceWeightRingCommand: false,
         orientation: orientation)
         
         let jiggleIndex = getJiggleIndex(jiggle) ?? -1
         switchSelectedJiggle(newSelectedJiggleIndex: jiggleIndex,
         displayMode: displayMode,
         isGraphEnabled: true)
         */
    }
    
    func refreshGraphModify(jiggle: Jiggle,
                            displayMode: DisplayMode,
                            isGraphEnabled: Bool) {
        
        let swivelType = ForceableTypeWithNone.forced
        let meshCommand = JiggleMeshCommand(spline: false,
                                            triangulationType: .beautiful,
                                            meshType: .weightsOnly,
                                            outlineType: .ifNeeded,
                                            swivelType: swivelType,
                                            weightCurveType: .ifNeeded)
        let weightRingCommand = JiggleWeightRingCommand.none
        let worldScale = getWorldScale()
        let isDarkModeEnabled = ApplicationController.isDarkModeEnabled
        
        jiggle.execute(meshCommand: meshCommand,
                       isSelected: true,
                       isDarkModeEnabled: isDarkModeEnabled,
                       worldScale: worldScale,
                       weightRingCommand: weightRingCommand,
                       forceWeightRingCommand: false,
                       orientation: orientation)
        
        let jiggleIndex = getJiggleIndex(jiggle) ?? -1
        switchSelectedJiggle(newSelectedJiggleIndex: jiggleIndex,
                             displayMode: displayMode,
                             isGraphEnabled: true)
        
        /*
         let swivelType = ForceableTypeWithNone.forced
         let meshCommand = JiggleMeshCommand(spline: false,
         triangulationType: .beautiful,
         meshType: .none,
         outlineType: .ifNeeded,
         swivelType: swivelType,
         weightCurveType: .none)
         
         let worldScale = getWorldScale()
         let isDarkModeEnabled = ApplicationController.isDarkModeEnabled
         let weightRingCommand = JiggleWeightRingCommand.none
         jiggle.execute(meshCommand: meshCommand,
         isSelected: true,
         isDarkModeEnabled: isDarkModeEnabled,
         worldScale: worldScale,
         weightRingCommand: weightRingCommand,
         forceWeightRingCommand: false,
         orientation: orientation)
         
         let jiggleIndex = getJiggleIndex(jiggle) ?? -1
         switchSelectedJiggle(newSelectedJiggleIndex: jiggleIndex,
         displayMode: displayMode,
         isGraphEnabled: true)
         */
    }
    
    func refreshWeightCurve() {
        if let selectedJiggle = getSelectedJiggle() {
            selectedJiggle.refreshWeightCurve()
        }
    }
    
    func handleWakeUpBegin(jiggleEngine: JiggleEngine,
                           displayMode: DisplayMode,
                           isGraphEnabled: Bool,
                           jiggleScene: JiggleScene) {
        print(".....handleWakeUpBegin (Part 0000).....")
        
        
        for jiggleIndex in 0..<jiggleCount {
            let jiggle = jiggles[jiggleIndex]
            jiggle.load(jiggleEngine: jiggleEngine)
        }
        
        let worldScale = getWorldScale()
        let meshCommand = getMeshCommandForNewLoad(displayMode: displayMode,
                                                   isGraphEnabled: isGraphEnabled)
        let weightRingCommand = getWeightRingCommandForNewJiggle()
        for jiggleIndex in 0..<jiggleCount {
            let jiggle = jiggles[jiggleIndex]
            let isSelected = (jiggleIndex == (jiggleCount - 1))
            jiggle.switchSelectedWeightCurveControlIndexToDefault(isSelected: isSelected)
            jiggle.execute(meshCommand: meshCommand,
                           isSelected: isSelected,
                           isDarkModeEnabled: ApplicationController.isDarkModeEnabled,
                           worldScale: worldScale,
                           weightRingCommand: weightRingCommand,
                           forceWeightRingCommand: true,
                           orientation: orientation)
        }
        
        switchSelectedJiggle(newSelectedJiggleIndex: jiggleCount - 1,
                             displayMode: displayMode,
                             isGraphEnabled: isGraphEnabled)
        
        jigglesDidChangePublisher.send(())
        
        if let selectedJiggle = getSelectedJiggle() {
            let camera = jiggleScene.camera
            let jiggleMesh = selectedJiggle.jiggleMesh
            let smartDistance = camera.calculateSmartDistance(cameraCalibrationPointCount: jiggleMesh.cameraCalibrationPointCount,
                                                              cameraCalibrationPoints: jiggleMesh.cameraCalibrationPoints)
            camera.distance = smartDistance
            
            print("$$$ $$$ $$$ $$$ $$$ $$$ $$$ $$$ $$$  $$$ $$$")
            print("$$$  SMART DISTANCE -> \(smartDistance)  $$$")
            print("$$$ $$$  $$$ $$$ $$$ $$$ $$$ $$$ $$$ $$$ $$$")
            
        }
    }
    
    func handleWakeUpComplete_PartA(jiggleEngine: JiggleEngine,
                                    displayMode: DisplayMode,
                                    isGraphEnabled: Bool) {
        
    }
    
    func handleWakeUpComplete_PartB(jiggleEngine: JiggleEngine,
                                    displayMode: DisplayMode,
                                    isGraphEnabled: Bool) {
        
        if !writeImageToRecent() {
            ApplicationController.rootViewController.pushDialogBox(.couldNotCopyFileLowMemory)
            return
        }
        
        if !writeSceneFileToRecent() {
            ApplicationController.rootViewController.pushDialogBox(.couldNotCopyFileLowMemory)
            return
        }
    }
    
    func writeImageToRecent() -> Bool {
        if let image = image {
            if image.size.width > 8.0 && image.size.height > 8.0 {
                let recentDocumentFullSizedImageFilePath = SavedFileManager.shared.recentDocumentFullSizedImageFilePath
                if FileUtils.shared.saveImagePNG(image: image, filePath: recentDocumentFullSizedImageFilePath) {
                    return true
                } else {
                    return false
                }
            }
        }
        return false
    }
    
    func writeSceneFileToRecent() -> Bool {
        let recentDocumentFullSizedImageFilePath = SavedFileManager.shared.recentDocumentSceneFilePath
        let fileBuffer = FileBuffer()
        save(fileBuffer: fileBuffer)
        if fileBuffer.save(filePath: recentDocumentFullSizedImageFilePath) {
            return true
        } else {
            return false
        }
    }
    
    func handleExit() {
        print("JiggleDocument.handleExit()")
        _ = writeSceneFileToRecent()
    }
    
    func handleAnimationModeDidChange() {
        print("JiggleDocument.handleAnimationModeDidChange()")
        animationController.handleAnimationModeDidChange(jiggleDocument: self)
    }
    
    func handleJigglesDidChange() {
        print("JiggleDocument.handleJigglesDidChange()")
        animationController.handleJigglesDidChange(jiggleDocument: self)
    }
    
    func handleControlPointsDidChange() {
        print("JiggleDocument.handleControlPointsDidChange()")
    }
    
    
    func handleDocumentModeDidChange() {
        print("JiggleDocument.handleDocumentModeDidChange()")
        animationController.handleDocumentModeDidChange(jiggleDocument: self)
    }
    
    func handleEditModeDidChange() {
        print("JiggleDocument.handleEditModeDidChange()")
    }
    
    func applicationWillResignActive() {
        print("JiggleDocument.applicationWillResignActive")
        animationController.applicationWillResignActive(jiggleDocument: self)
    }
    
    func applicationDidBecomeActive() {
        print("JiggleDocument.applicationDidBecomeActive")
        animationController.applicationDidBecomeActive(jiggleDocument: self)
    }
    
    
    func attemptGrabJiggleCenter(touch: UITouch,
                                 at point: Point,
                                 sceneScaleBase: Float,
                                 displayMode: DisplayMode,
                                 isGraphEnabled: Bool) {
        
        guard selectedJiggleCenterTouch === nil else {
            return
        }
        
        killDragAll()
        
        
        var currentSelectedJiggleIndex = -1
        
        let selectJiggleCenterDistanceThreshold = Self.selectWeightCenterDistanceThresholdBase / sceneScaleBase
        var bestDistance = selectJiggleCenterDistanceThreshold * selectJiggleCenterDistanceThreshold
        for jiggleIndex in 0..<jiggleCount {
            let jiggle = jiggles[jiggleIndex]
            if jiggle.isFrozen == false {
                var jiggleJiggleCenter = jiggle.offsetCenter
                jiggleJiggleCenter = jiggle.transformPoint(point: jiggleJiggleCenter)
                let dist = jiggle.offsetCenterDistanceSquaredToPoint(point)
                if dist < bestDistance {
                    selectedJiggleCenterTouch = touch
                    selectedJiggleCenterStartTouchX = point.x
                    selectedJiggleCenterStartTouchY = point.y
                    selectedJiggleCenterStartX = jiggleJiggleCenter.x
                    selectedJiggleCenterStartY = jiggleJiggleCenter.y
                    currentSelectedJiggleIndex = jiggleIndex
                    bestDistance = dist
                }
            }
        }
        
        if currentSelectedJiggleIndex == -1 {
            attemptSelectJiggleCenterDefaultCase(at: point,
                                                     displayMode: displayMode,
                                                     isGraphEnabled: isGraphEnabled)
        } else {
            switchSelectedJiggle(newSelectedJiggleIndex: currentSelectedJiggleIndex,
                                 displayMode: displayMode,
                                 isGraphEnabled: isGraphEnabled)
            
            let selectedJiggle = jiggles[currentSelectedJiggleIndex]
            
            _grabJiggleCenterData.startX = selectedJiggle.offsetCenter.x
            _grabJiggleCenterData.startY = selectedJiggle.offsetCenter.y
            _grabJiggleCenterData.endX = selectedJiggle.offsetCenter.x
            _grabJiggleCenterData.endY = selectedJiggle.offsetCenter.y
            _grabJiggleCenterData.jiggleIndex = currentSelectedJiggleIndex
            _grabJiggleCenterData.didChange = false
        }
    }
    
    func attemptUpdateJiggleCenter(touch: UITouch, at point: Point, isFromRelease: Bool) {
        
        guard let selectedJiggle = getSelectedJiggle() else {
            killDragAll()
            return
        }
        guard let selectedJiggleCenterTouch = selectedJiggleCenterTouch else {
            killDragAll()
            return
        }
        
        guard touch === selectedJiggleCenterTouch else {
            return
        }
        
        let delta = selectedJiggle.untransformPointScaleAndRotationOnly(point.x - selectedJiggleCenterStartTouchX,
                                                                        point.y - selectedJiggleCenterStartTouchY)
        let startPoint = selectedJiggle.untransformPoint(selectedJiggleCenterStartX,
                                                         selectedJiggleCenterStartY)
        
        let pointX = startPoint.x + delta.x
        let pointY = startPoint.y + delta.y
        
        selectedJiggle.offsetCenter.x = pointX
        selectedJiggle.offsetCenter.y = pointY
        
        _grabJiggleCenterData.endX = selectedJiggle.offsetCenter.x
        _grabJiggleCenterData.endY = selectedJiggle.offsetCenter.y
        
        if !isFromRelease {
            _grabJiggleCenterData.didChange = true
        }
    }
    
    func attemptReleaseJiggleCenter(touch: UITouch, at point: Point) {
        if touch == selectedJiggleCenterTouch {
            killDragAll()
        }
    }
    
    func attemptSelectJiggleCenterDefaultCase(at point: Point,
                                              displayMode: DisplayMode,
                                              isGraphEnabled: Bool) {
        let currentSelectedJiggleIndex = getIndexOfJiggleToSelect(at: point)
        switchSelectedJiggle(newSelectedJiggleIndex: currentSelectedJiggleIndex,
                             displayMode: displayMode,
                             isGraphEnabled: isGraphEnabled)
    }
    
    // [Verified]
    // Mesh Actions:
    //  a.) AffineOnlyWeights, Forced-Graph to selected jiggle.
    //  b.) Re-Spline added weight ring.
    //  c.) Re-Paint other weight rings.
    //  d.) select
    func addWeightRing(_ newWeightRing: JiggleWeightRing,
                       jiggle: Jiggle,
                       isHistoryAction: Bool,
                       displayMode: DisplayMode,
                       isGraphEnabled: Bool) {
        if jiggle.jiggleWeightRingCount >= Jiggle.maxWeightRingCount {
            ApplicationController.rootViewController.showAlertMessageMaxWeightRingCountOverflow()
            JigglePartsFactory.shared.depositJiggleWeightRing(newWeightRing)
            return
        }
        if newWeightRing.jiggleControlPointCount > JiggleWeightRing.maxPointCount {
            ApplicationController.rootViewController.showAlertMessageTooManyPoints()
            JigglePartsFactory.shared.depositJiggleWeightRing(newWeightRing)
            return
        }
        
        jiggle.addJiggleWeightRingNotFromLoad(newWeightRing)
        
        refreshWeightRingModify(jiggle: jiggle,
                                jiggleWeightRing: newWeightRing,
                                displayMode: displayMode,
                                isGraphEnabled: isGraphEnabled)
        
        _createWeightRingData.weightRing = newWeightRing
        _createWeightRingData.isHistoryAction = isHistoryAction
        createWeightRingPublisher.send(_createWeightRingData)
        weightRingsDidChangePublisher.send(())
    }
    
    func addWeightRingListReplacingAll(_ newWeightRings: [JiggleWeightRing],
                                       jiggle: Jiggle,
                                       isHistoryAction: Bool,
                                       displayMode: DisplayMode,
                                       isGraphEnabled: Bool,
                                       isFixWeightCenterRequired: Bool) {
        
        if isFixWeightCenterRequired {
            if newWeightRings.count > 0 {
                let lastWeightRing = newWeightRings[newWeightRings.count - 1]
                jiggle.guideCenter = lastWeightRing.getControlPointCenter()
            }
        }
        
        
        _createReplaceWeightRingListData.startWeightRingBuffers.removeAll(keepingCapacity: true)
        _createReplaceWeightRingListData.endWeightRingBuffers.removeAll(keepingCapacity: true)
        
        for jiggleWeightRingIndex in 0..<jiggle.jiggleWeightRingCount {
            let jiggleWeightRing = jiggle.jiggleWeightRings[jiggleWeightRingIndex]
            let fileBuffer = FileBuffer()
            jiggleWeightRing.save(fileBuffer: fileBuffer)
            _createReplaceWeightRingListData.startWeightRingBuffers.append(fileBuffer)
        }
        
        for jiggleWeightRingIndex in 0..<newWeightRings.count {
            let jiggleWeightRing = newWeightRings[jiggleWeightRingIndex]
            let fileBuffer = FileBuffer()
            jiggleWeightRing.save(fileBuffer: fileBuffer)
            _createReplaceWeightRingListData.endWeightRingBuffers.append(fileBuffer)
        }
        
        jiggle.purgeJiggleWeightRings()
        
        for jiggleWeightRingIndex in 0..<newWeightRings.count {
            let jiggleWeightRing = newWeightRings[jiggleWeightRingIndex]
            jiggle.addJiggleWeightRingNotFromLoad(jiggleWeightRing)
        }
        
        refreshWeightRingModifyList(jiggle: jiggle,
                                    displayMode: displayMode,
                                    isGraphEnabled: isGraphEnabled)
        
        _createReplaceWeightRingListData.isHistoryAction = isHistoryAction
        createReplaceWeightRingListPublisher.send(_createReplaceWeightRingListData)
        weightRingsDidChangePublisher.send(())
    }
    
    func attemptRemoveSelectedWeightRing(isHistoryAction: Bool,
                                         displayMode: DisplayMode,
                                         isGraphEnabled: Bool) -> Bool {
        if let selectedJiggle = getSelectedJiggle() {
            if attemptRemoveWeightRing(selectedJiggle,
                                       selectedJiggle.selectedWeightCurveControlIndex - 1,
                                       isHistoryAction: isHistoryAction,
                                       displayMode: displayMode,
                                       isGraphEnabled: isGraphEnabled) {
                selectedJiggleWeightRingAffine = nil
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    // [Verified]
    // Mesh Actions:
    //  a.) AffineOnlyWeights, Forced-Graph to selected jiggle.
    //  b.) Re-Spline added weight ring.
    //  c.) Re-Paint other weight rings.
    //  d.) select
    func insertWeightRingHistoryAction(_ jiggle: Jiggle,
                                       _ newWeightRing: JiggleWeightRing,
                                       at index: Int,
                                       displayMode: DisplayMode,
                                       isGraphEnabled: Bool) {
        jiggle.insertJiggleWeightRing(newWeightRing,
                                      at: index)
        
        refreshWeightRingModify(jiggle: jiggle,
                                jiggleWeightRing: newWeightRing,
                                displayMode: displayMode,
                                isGraphEnabled: isGraphEnabled)
        
        _createWeightRingData.weightRing = newWeightRing
        _createWeightRingData.isHistoryAction = true
        _createWeightRingData.jiggleIndex = getJiggleIndex(jiggle)
        
        createWeightRingPublisher.send(_createWeightRingData)
        
        weightRingsDidChangePublisher.send(())
    }
    
    // [Verified]
    // Mesh Actions:
    //  a.) AffineOnlyWeights, Forced-Graph to selected jiggle.
    //  b.) Re-Spline added weight ring.
    //  c.) Re-Paint other weight rings.
    //  d.) select
    func attemptRemoveWeightRing(_ jiggle: Jiggle,
                                 _ index: Int,
                                 isHistoryAction: Bool,
                                 displayMode: DisplayMode,
                                 isGraphEnabled: Bool) -> Bool {
        
        guard let jiggleIndex = getJiggleIndex(jiggle) else {
            return false
        }
        
        if index >= 0 && index < jiggle.jiggleWeightRingCount {
            
            let weightRing = jiggle.jiggleWeightRings[index]
            
            _removeWeightRingData.weightRing = weightRing
            _removeWeightRingData.jiggleIndex = jiggleIndex
            _removeWeightRingData.weightCurveIndex = (index + 1)
            _removeWeightRingData.isHistoryAction = isHistoryAction
            removeWeightRingPublisher.send(_removeWeightRingData)
            
            _ = jiggle.removeJiggleWeightRing(weightRing,
                                              jiggleIndex: jiggleIndex)
            
            if let newSelectedWeightRing = jiggle.getSelectedJiggleWeightRing() {
                refreshWeightRingModify(jiggle: jiggle,
                                        jiggleWeightRing: newSelectedWeightRing,
                                        displayMode: displayMode,
                                        isGraphEnabled: isGraphEnabled)
            } else {
                refreshWeightRingModify(jiggle: jiggle,
                                        displayMode: displayMode,
                                        isGraphEnabled: isGraphEnabled)
            }
            
            weightRingsDidChangePublisher.send(())
            
            return true
        } else {
            return false
        }
    }
    
    func attemptCreateWeightRing(_ point: Point,
                                 jiggleEngine: JiggleEngine,
                                 displayMode: DisplayMode,
                                 isGraphEnabled: Bool) -> Bool {
        
        guard let selectedJiggle = getSelectedJiggle() else {
            ApplicationController.rootViewController.showAlertMessageSelectedJiggleRequired()
            return false
        }
        
        if selectedJiggle.jiggleWeightRingCount >= Jiggle.maxWeightRingCount {
            ApplicationController.rootViewController.showAlertMessageMaxWeightRingCountOverflow()
            return false
        }
        
        let point = selectedJiggle.untransformPoint(point: point)
        let jiggleWeightRing = JigglePartsFactory.shared.withdrawJiggleWeightRing()
        jiggleWeightRing.load(jiggleEngine: jiggleEngine, jiggle: selectedJiggle)
        jiggleWeightRing.center = point
        
        var radius = selectedJiggle.getRadius(defaultRadius: 144.0, epsilon: 80.0 / selectedJiggle.scale)
        var angleCount: Int
        if Device.isPad {
            angleCount = 12
        } else {
            angleCount = 8
        }
        
        if selectedJiggle.jiggleWeightRingCount <= 0 {
            radius *= 0.8
        } else if selectedJiggle.jiggleWeightRingCount <= 1 {
            radius *= 0.65
        } else if selectedJiggle.jiggleWeightRingCount <= 2 {
            radius *= 0.5
            angleCount -= 2
        } else if selectedJiggle.jiggleWeightRingCount <= 3 {
            radius *= 0.35
            angleCount -= 2
        } else {
            radius *= 0.2
            angleCount -= 4
        }
        
        for angleIndex in 0..<angleCount {
            let anglePercent = Float(angleIndex) / Float(angleCount)
            let angle = Math.pi2 * anglePercent
            let dirX = sinf(angle)
            let dirY = -cosf(angle)
            let x = radius * dirX
            let y = radius * dirY
            jiggleWeightRing.addJiggleControlPoint(x, y)
        }
        
        addWeightRing(jiggleWeightRing,
                      jiggle: selectedJiggle,
                      isHistoryAction: false,
                      displayMode: displayMode,
                      isGraphEnabled: isGraphEnabled)
        
        killDragAll()
        return true
    }
    
    private func weightRingFromSpline(spline: ManualSpline,
                                      jiggle: Jiggle,
                                      jiggleEngine: JiggleEngine,
                                      isUntransformRequired: Bool) -> JiggleWeightRing {
        var sumX = Float(0.0)
        var sumY = Float(0.0)
        
        if isUntransformRequired {
            for index in 0..<spline.count {
                let splineX = spline._x[index]
                let splineY = spline._y[index]
                
                var point = Point(x: splineX,
                                  y: splineY)
                
                point = jiggle.untransformPoint(point: point)
                
                spline._x[index] = point.x
                spline._y[index] = point.y
                
                sumX += point.x
                sumY += point.y
            }
        } else {
            for index in 0..<spline.count {
                let splineX = spline._x[index]
                let splineY = spline._y[index]
                
                let point = Point(x: splineX,
                                  y: splineY)
                
                spline._x[index] = point.x
                spline._y[index] = point.y
                
                sumX += point.x
                sumY += point.y
            }
        }
        
        let centerX = sumX / Float(spline.count)
        let centerY = sumY / Float(spline.count)
        
        let newJiggleWeightRing = JigglePartsFactory.shared.withdrawJiggleWeightRing()
        newJiggleWeightRing.load(jiggleEngine: jiggleEngine, jiggle: jiggle)
        newJiggleWeightRing.center = Point(x: centerX,
                                           y: centerY)
        for index in 0..<spline.count {
            let splineX = spline._x[index]
            let splineY = spline._y[index]
            newJiggleWeightRing.addJiggleControlPoint(splineX - centerX,
                                                      splineY - centerY)
        }
        
        return newJiggleWeightRing
    }
    
    func attemptCreateWeightRing(spline: ManualSpline,
                                 jiggleEngine: JiggleEngine,
                                 displayMode: DisplayMode,
                                 isGraphEnabled: Bool,
                                 isUntransformRequired: Bool) -> Bool {
        
        guard let selectedJiggle = getSelectedJiggle() else {
            ApplicationController.rootViewController.showAlertMessageSelectedJiggleRequired()
            return false
        }
        
        if selectedJiggle.jiggleWeightRingCount >= Jiggle.maxWeightRingCount {
            ApplicationController.rootViewController.showAlertMessageMaxWeightRingCountOverflow()
            return false
        }
        
        let newJiggleWeightRing = weightRingFromSpline(spline: spline,
                                                       jiggle: selectedJiggle,
                                                       jiggleEngine: jiggleEngine,
                                                       isUntransformRequired: isUntransformRequired)
        
        addWeightRing(newJiggleWeightRing,
                      jiggle: selectedJiggle,
                      isHistoryAction: false,
                      displayMode: displayMode,
                      isGraphEnabled: isGraphEnabled)
        
        killDragAll()
        
        return true
    }
    
    
    func createWeightRingsFromSplines(splines: [ManualSpline],
                                     jiggleEngine: JiggleEngine,
                                     displayMode: DisplayMode,
                                     isGraphEnabled: Bool,
                                     isUntransformRequired: Bool,
                                     isFixWeightCenterRequired: Bool) -> Bool {
        
        guard let selectedJiggle = getSelectedJiggle() else {
            ApplicationController.rootViewController.showAlertMessageSelectedJiggleRequired()
            return false
        }
        
        var newWeightRings = [JiggleWeightRing]()
        for spline in splines {
            let newJiggleWeightRing = weightRingFromSpline(spline: spline,
                                                           jiggle: selectedJiggle,
                                                           jiggleEngine: jiggleEngine,
                                                           isUntransformRequired: isUntransformRequired)
            newWeightRings.append(newJiggleWeightRing)
        }

        if newWeightRings.count > 0 {
            addWeightRingListReplacingAll(newWeightRings,
                                          jiggle: selectedJiggle,
                                          isHistoryAction: false,
                                          displayMode: displayMode,
                                          isGraphEnabled: isGraphEnabled,
                                          isFixWeightCenterRequired: isFixWeightCenterRequired)
        } else {
            return false
        }
        
        return true
    }
    
    func attemptRemoveSelectedJiggle(isHistoryAction: Bool,
                                     displayMode: DisplayMode,
                                     isGraphEnabled: Bool) -> Bool {
        if attemptRemoveJiggle(selectedJiggleIndex,
                               isHistoryAction: isHistoryAction,
                               displayMode: displayMode,
                               isGraphEnabled: isGraphEnabled) {
            return true
        } else {
            return false
        }
    }
    
    // [Verified]
    // Mesh Actions:
    //  a.) getMeshCommandForNewJiggle
    // Weight Ring Actions:
    //  a.) getWeightRingCommandForNewJiggle (to all)
    func insertJiggleHistoryAction(_ newJiggle: Jiggle,
                                   at index: Int,
                                   displayMode: DisplayMode,
                                   isGraphEnabled: Bool) {
        
        while jiggles.count <= jiggleCount {
            jiggles.append(newJiggle)
        }
        var jiggleIndex = jiggleCount
        while jiggleIndex > index {
            jiggles[jiggleIndex] = jiggles[jiggleIndex - 1]
            jiggleIndex -= 1
        }
        
        jiggles[index] = newJiggle
        jiggleCount += 1
        
        newJiggle.switchSelectedWeightCurveControlIndexToDefault(isSelected: true)
        
        let worldScale = getWorldScale()
        let meshCommand = getMeshCommandForNewJiggle(displayMode: displayMode,
                                                       isGraphEnabled: isGraphEnabled)
        let weightRingCommand = getWeightRingCommandForNewJiggle()
        newJiggle.execute(meshCommand: meshCommand,
                          isSelected: true,
                          isDarkModeEnabled: ApplicationController.isDarkModeEnabled,
                          worldScale: worldScale,
                          weightRingCommand: weightRingCommand,
                          forceWeightRingCommand: false,
                          orientation: orientation)
        
        
        switchSelectedJiggle(newSelectedJiggleIndex: jiggleCount - 1,
                             displayMode: displayMode,
                             isGraphEnabled: isGraphEnabled)
        _createJiggleData.jiggle = newJiggle
        _createJiggleData.isHistoryAction = true
        createJigglePublisher.send(_createJiggleData)
        jigglesDidChangePublisher.send(())
    }
    
    // [Verified]
    // Mesh Actions:
    //  a.) getMeshCommandForNewJiggle
    // Weight Ring Actions:
    //  a.) getWeightRingCommandForNewJiggle (to all)
    func addJiggleNotFromLoad(_ newJiggle: Jiggle,
                              isHistoryAction: Bool,
                              displayMode: DisplayMode,
                              isGraphEnabled: Bool) {
        
        newJiggle.switchSelectedWeightCurveControlIndexToDefault(isSelected: true)
        
        let worldScale = getWorldScale()
        let meshCommand = getMeshCommandForNewJiggle(displayMode: displayMode,
                                                       isGraphEnabled: isGraphEnabled)
        let weightRingCommand = getWeightRingCommandForNewJiggle()
        newJiggle.execute(meshCommand: meshCommand,
                          isSelected: true,
                          isDarkModeEnabled: ApplicationController.isDarkModeEnabled,
                          worldScale: worldScale,
                          weightRingCommand: weightRingCommand,
                          forceWeightRingCommand: false,
                          orientation: orientation)
        
        if newJiggle.polyMesh.ring.isBroken {
            ApplicationController.rootViewController.showAlertMessageBrokenJiggle()
            JigglePartsFactory.shared.depositJiggle(newJiggle)
            return
        }
        addJiggleFromLoad(newJiggle)
        
        switchSelectedJiggle(newSelectedJiggleIndex: jiggleCount - 1,
                             displayMode: displayMode,
                             isGraphEnabled: isGraphEnabled)
        _createJiggleData.jiggle = newJiggle
        _createJiggleData.isHistoryAction = isHistoryAction
        createJigglePublisher.send(_createJiggleData)
        jigglesDidChangePublisher.send(())
    }
    
    // [Verified]
    func addJiggleFromLoad(_ newJiggle: Jiggle) {
        if jiggleCount >= JiggleDocument.maxJiggleCount {
            ApplicationController.rootViewController.showAlertMessageMaxJiggleCountOverflow()
            JigglePartsFactory.shared.depositJiggle(newJiggle)
            return
        }
        if newJiggle.jiggleControlPointCount > Jiggle.maxPointCount {
            ApplicationController.rootViewController.showAlertMessageTooManyPoints()
            JigglePartsFactory.shared.depositJiggle(newJiggle)
            return
        }
        while jiggles.count <= jiggleCount {
            jiggles.append(newJiggle)
        }
        jiggles[jiggleCount] = newJiggle
        jiggleCount += 1
    }
    
    // [Verified]
    // Mesh Actions:
    //  a.) getMeshCommandForNewJiggle
    // Weight Ring Actions:
    //  a.) getWeightRingCommandForNewJiggle (to all)
    func attemptCreateJiggle(at point: Point,
                             jiggleEngine: JiggleEngine,
                             displayMode: DisplayMode,
                             isGraphEnabled: Bool) -> Bool {
        let newJiggle = JigglePartsFactory.shared.withdrawJiggle()
        newJiggle.load(jiggleEngine: jiggleEngine)
        newJiggle.center = point
        let angleCount: Int
        if Device.isPad {
            angleCount = 12
        } else {
            angleCount = 8
        }
        
        var radius = min(width2, height2)
        if Device.isPad {
            radius *= 0.4
        } else {
            radius *= 0.5
        }
        
        for angleIndex in 0..<angleCount {
            let anglePercent = Float(angleIndex) / Float(angleCount)
            let angle = Math.pi2 * anglePercent
            let dirX = sinf(angle)
            let dirY = -cosf(angle)
            let x = radius * dirX
            let y = radius * dirY
            newJiggle.addJiggleControlPoint(x, y)
        }
        addJiggleNotFromLoad(newJiggle,
                             isHistoryAction: false,
                             displayMode: displayMode,
                             isGraphEnabled: isGraphEnabled)
        return true
    }
    
    // [Verified]
    // Mesh Actions:
    //  a.) getMeshCommandForNewJiggle
    // Weight Ring Actions:
    //  a.) getWeightRingCommandForNewJiggle (to all)
    func attemptCreateJiggle(spline: ManualSpline,
                             jiggleEngine: JiggleEngine,
                             displayMode: DisplayMode,
                             isGraphEnabled: Bool) -> Bool {
        guard spline.count >= 3 else {
            ApplicationController.rootViewController.showAlertMessageDrawJiggleTooFewPoints()
            return false
        }
        var sumX = Float(0.0)
        var sumY = Float(0.0)
        for index in 0..<spline.count {
            let splineX = spline._x[index]
            let splineY = spline._y[index]
            sumX += splineX
            sumY += splineY
        }
        let centerX = sumX / Float(spline.count)
        let centerY = sumY / Float(spline.count)
        let point = Point(x: centerX, y: centerY)
        let newJiggle = JigglePartsFactory.shared.withdrawJiggle()
        newJiggle.load(jiggleEngine: jiggleEngine)
        newJiggle.center = point
        for index in 0..<spline.count {
            let splineX = spline._x[index]
            let splineY = spline._y[index]
            newJiggle.addJiggleControlPoint(splineX - centerX, splineY - centerY)
        }
        addJiggleNotFromLoad(newJiggle,
                             isHistoryAction: false,
                             displayMode: displayMode,
                             isGraphEnabled: isGraphEnabled)
        return true
    }
    
    
    // [Verified]
    // Mesh Actions:
    //  a.) getMeshCommandForNewJiggle
    // Weight Ring Actions:
    //  a.) getWeightRingCommandForNewJiggle (to all)
    func attemptCloneJiggle(displayMode: DisplayMode,
                            isGraphEnabled: Bool,
                            jiggleEngine: JiggleEngine) -> Bool {
        
        guard let selectedJiggle = getSelectedJiggle() else {
            ApplicationController.rootViewController.showAlertMessageSelectedJiggleRequired()
            return false
        }
        
        if jiggleCount >= Self.maxJiggleCount {
            ApplicationController.rootViewController.showAlertMessageMaxJiggleCountOverflow()
            return false
        }
        
        guard let jiggleScene = jiggleScene else {
            return false
        }
        
        // Try a bunch of spots and see where it makes the
        // most sense...
        let hopSize = min(width, height) * (Device.isPad ? 0.05 : 0.1)
        var tryX = [Float]()
        var tryY = [Float]()
        tryX.append(hopSize)
        tryY.append(0.0)
        tryX.append(0.0)
        tryY.append(hopSize)
        tryX.append(0.0)
        tryY.append(-hopSize)
        tryX.append(-hopSize)
        tryY.append(0.0)
        tryX.append(-hopSize)
        tryY.append(-hopSize)
        tryX.append(hopSize)
        tryY.append(-hopSize)
        tryX.append(-hopSize)
        tryY.append(hopSize)
        tryX.append(hopSize)
        tryY.append(hopSize)
        tryX.append(hopSize * 2.0)
        tryY.append(0.0)
        tryX.append(0.0)
        tryY.append(hopSize * 2.0)
        tryX.append(0.0)
        tryY.append(-hopSize * 2.0)
        tryX.append(-hopSize * 2.0)
        tryY.append(0.0)
        tryX.append(-hopSize * 2.0)
        tryY.append(-hopSize * 2.0)
        tryX.append(hopSize * 2.0)
        tryY.append(-hopSize * 2.0)
        tryX.append(-hopSize * 2.0)
        tryY.append(hopSize * 2.0)
        tryX.append(hopSize * 2.0)
        tryY.append(hopSize * 2.0)
        
        let screenWidth: Float
        let screenHeight: Float
        switch orientation {
        case .landscape:
            screenWidth = ApplicationController.device.widthLandscape
            screenHeight = ApplicationController.device.heightLandscape
        case .portrait:
            screenWidth = ApplicationController.device.widthPortrait
            screenHeight = ApplicationController.device.heightPortrait
        }
        
        let jiggleCenter = jiggleScene.convertFromSceneToWorld(point: selectedJiggle.center)
        
        var screenRight = Point(x: screenWidth - hopSize,
                                y: jiggleCenter.y)
        
        var screenLeft = Point(x: hopSize,
                               y: jiggleCenter.y)
        
        var screenTop = Point(x: jiggleCenter.x,
                              y: hopSize)
        
        var screenBottom = Point(x: jiggleCenter.x,
                                 y: screenHeight - hopSize)
        
        screenRight = jiggleScene.convertFromWorldToScene(point: screenRight)
        screenLeft = jiggleScene.convertFromWorldToScene(point: screenLeft)
        screenTop = jiggleScene.convertFromWorldToScene(point: screenTop)
        screenBottom = jiggleScene.convertFromWorldToScene(point: screenBottom)
        
        let tooCloseToAnotherJiggle = Float(Device.isPad ? 40.0 : 20.0)
        let tooCloseToAnotherJiggleSquared = (tooCloseToAnotherJiggle * tooCloseToAnotherJiggle)
        
        for index in 0..<tryX.count {
            let x = tryX[index] + selectedJiggle.center.x
            let y = tryY[index] + selectedJiggle.center.y
            
            var isTooCloseToAnotherJiggle = false
            for jiggleIndex in 0..<jiggleCount {
                let jiggle = jiggles[jiggleIndex]
                let diffX = jiggle.center.x - x
                let diffY = jiggle.center.y - y
                let distanceSquared = diffX * diffX + diffY * diffY
                if distanceSquared < tooCloseToAnotherJiggleSquared {
                    isTooCloseToAnotherJiggle = true
                }
            }
            
            var isOffScreen = false
            if x >= screenRight.x {
                isOffScreen = true
            }
            if x <= screenLeft.x {
                isOffScreen = true
            }
            if y >= screenBottom.y {
                isOffScreen = true
            }
            if y <= screenTop.y {
                isOffScreen = true
            }
            
            if isTooCloseToAnotherJiggle == false && isOffScreen == false {
                
                let fileBuffer = FileBuffer()
                selectedJiggle.save(fileBuffer: fileBuffer)
                let newJiggle = Jiggle()
                newJiggle.load(jiggleEngine: selectedJiggle.jiggleEngine)
                _ = newJiggle.load(fileBuffer: fileBuffer,
                               isSelected: true)
                
                for jiggleWeightRingIndex in 0..<newJiggle.jiggleWeightRingCount {
                    let jiggleWeightRing = newJiggle.jiggleWeightRings[jiggleWeightRingIndex]
                    jiggleWeightRing.load(jiggleEngine: jiggleEngine, jiggle: newJiggle)
                }
                
                newJiggle.center = Point(x: x, y: y)
                addJiggleNotFromLoad(newJiggle,
                                     isHistoryAction: false,
                                     displayMode: displayMode,
                                     isGraphEnabled: isGraphEnabled)

                return true
            }
        }
        
        ApplicationController.rootViewController.showAlertMessageCannotPlaceJiggle()
        return false
    }
    
    // [Verified]
    // Mesh Actions:
    //  a.) switchSelectedJiggle
    @discardableResult func attemptRemoveJiggle(_ jiggle: Jiggle,
                                                isHistoryAction: Bool,
                                                displayMode: DisplayMode,
                                                isGraphEnabled: Bool) -> Bool {
        for checkIndex in 0..<jiggleCount {
            if jiggles[checkIndex] === jiggle {
                if attemptRemoveJiggle(checkIndex,
                                       isHistoryAction: isHistoryAction,
                                       displayMode: displayMode,
                                       isGraphEnabled: isGraphEnabled) {
                    return true
                }
            }
        }
        return false
    }
    
    // [Verified]
    // Mesh Actions:
    //  a.) switchSelectedJiggle
    @discardableResult func attemptRemoveJiggle(_ index: Int,
                                                isHistoryAction: Bool,
                                                displayMode: DisplayMode,
                                                isGraphEnabled: Bool) -> Bool {
        if index >= 0 && index < jiggleCount {
            let jiggle = jiggles[index]
            
            _removeJiggleData.jiggle = jiggle
            _removeJiggleData.jiggleIndex = index
            _removeJiggleData.isHistoryAction = isHistoryAction
            removeJigglePublisher.send(_removeJiggleData)
            
            //PolyMeshPartsFactory.shared.depositJiggleContent(jiggle)
            PolyMeshPartsFactory.shared.depositRingContent(jiggle.polyMesh.ring)
            JigglePartsFactory.shared.depositJiggle(jiggle)
            
            let jiggleCount1 = jiggleCount - 1
            var jiggleIndex = index
            while jiggleIndex < jiggleCount1 {
                jiggles[jiggleIndex] = jiggles[jiggleIndex + 1]
                jiggleIndex += 1
            }
            jiggleCount -= 1

            if selectedJiggleIndex >= jiggleCount {
                selectedJiggleIndex = jiggleCount - 1
            }
            
            switchSelectedJiggle(newSelectedJiggleIndex: selectedJiggleIndex,
                                 displayMode: displayMode,
                                 isGraphEnabled: isGraphEnabled)
            
            jigglesDidChangePublisher.send(())
            return true
        } else {
            return false
        }
    }
    
    
    func attemptCreateWeightControlPoint(_ point: Point,
                                         displayMode: DisplayMode,
                                         isGraphEnabled: Bool) -> Bool {
        
        guard let selectedJiggle = getSelectedJiggle() else {
            ApplicationController.rootViewController.showAlertMessageSelectedJiggleRequired()
            return false
        }
        
        guard let selectedJiggleWeightRing = selectedJiggle.getSelectedJiggleWeightRing() else {
            ApplicationController.rootViewController.showAlertMessageSelectedWeightRingRequired()
            return false
        }
        
        if selectedJiggleWeightRing.jiggleControlPointCount >= JiggleWeightRing.maxPointCount {
            ApplicationController.rootViewController.showAlertMessageTooManyPoints()
            return false
        }
        
        let point = selectedJiggleWeightRing.untransformPoint(point: selectedJiggle.untransformPoint(point: point))
        
        guard let insertIndex = selectedJiggleWeightRing.calculateNearestInsertIndex(point.x, point.y) else {
            return false
        }
        
        selectedJiggleWeightRing.insertJiggleControlPoint(point.x, point.y, at: insertIndex)
        
        refreshWeightRingModify(jiggle: selectedJiggle,
                                jiggleWeightRing: selectedJiggleWeightRing,
                                displayMode: displayMode,
                                isGraphEnabled: isGraphEnabled)
        /*
        refreshWeightRingAffine(jiggle: selectedJiggle,
                                jiggleWeightRing: selectedJiggleWeightRing,
                                displayMode: displayMode,
                                isGraphEnabled: isGraphEnabled)
        */
        
        weightRingControlPointsDidChangePublisher.send(())
        
        killDragAll()

        return true
    }
    
    func attemptRemoveWeightRingControlPoint(_ point: Point,
                                             sceneScaleBase: Float,
                                             displayMode: DisplayMode,
                                             isGraphEnabled: Bool) -> AttemptRemoveWeightRingControlPointResult? {
        var _jiggleIndex: Int?
        var _jiggleWeightRingIndex: Int?
        var _jiggleWeightRingControlPointIndex: Int?
        let selectWeightRingControlPointDistanceThreshold = Self.selectControlPointDistanceThresholdBase / sceneScaleBase
        var bestDistance = selectWeightRingControlPointDistanceThreshold * selectWeightRingControlPointDistanceThreshold
        for jiggleIndex in 0..<jiggleCount {
            let jiggle = jiggles[jiggleIndex]
            if jiggle.isFrozen == false {
                for jiggleWeightRingIndex in 0..<jiggle.jiggleWeightRingCount {
                    let jiggleWeightRing = jiggle.jiggleWeightRings[jiggleWeightRingIndex]
                    
                    for jiggleWeightRingControlPointIndex in 0..<jiggleWeightRing.jiggleControlPointCount {
                        let jiggleWeightRingControlPoint = jiggleWeightRing.jiggleControlPoints[jiggleWeightRingControlPointIndex]
                        var controlPointPosition = jiggleWeightRingControlPoint.point
                        
                        controlPointPosition = jiggleWeightRing.transformPoint(point: controlPointPosition)
                        controlPointPosition = jiggle.transformPoint(point: controlPointPosition)
                        
                        let diffX = controlPointPosition.x - point.x
                        let diffY = controlPointPosition.y - point.y
                        let dist = diffX * diffX + diffY * diffY
                        if dist < bestDistance {
                            bestDistance = dist
                            _jiggleIndex = jiggleIndex
                            _jiggleWeightRingIndex = jiggleWeightRingIndex
                            _jiggleWeightRingControlPointIndex = jiggleWeightRingControlPointIndex
                        }
                    }
                }
            }
        }
        
        if let jiggleIndex = _jiggleIndex,
           let jiggleWeightRingIndex = _jiggleWeightRingIndex,
            let jiggleWeightRingControlPointIndex = _jiggleWeightRingControlPointIndex {
            
            let jiggle = jiggles[jiggleIndex]
            let jiggleWeightRing = jiggle.jiggleWeightRings[jiggleWeightRingIndex]
            if jiggleWeightRing.jiggleControlPointCount > JiggleWeightRing.minPointCount {
                
                let controlPoint = jiggleWeightRing.jiggleControlPoints[jiggleWeightRingControlPointIndex]
                let result = AttemptRemoveWeightRingControlPointResult(jiggleIndex: jiggleIndex,
                                                                       weightCurveIndex: jiggleWeightRingIndex + 1,
                                                                       weightRingControlPointIndex: jiggleWeightRingControlPointIndex,
                                                                       point: controlPoint.point)
                
                _ = jiggleWeightRing.removeJiggleControlPoint(jiggleWeightRingControlPointIndex)
                
                jiggle.switchSelectedWeightCurveControlIndex(index: jiggleWeightRingIndex + 1)
                
                refreshWeightRingModify(jiggle: jiggle,
                                        jiggleWeightRing: jiggleWeightRing,
                                        displayMode: displayMode,
                                        isGraphEnabled: isGraphEnabled)
                
                weightRingControlPointsDidChangePublisher.send(())
                
                killDragAll()
                return result
            } else {
                ApplicationController.rootViewController.showAlertMessageTooFewPoints()
            }
        }
        
        return nil
    }
        
    func attemptRemoveSelectedWeightRingControlPoint(displayMode: DisplayMode,
                                                     isGraphEnabled: Bool) -> AttemptRemoveWeightRingControlPointResult? {
        guard let selectedJiggle = getSelectedJiggle() else {
            return nil
        }
        guard let selectedJiggleWeightRing = selectedJiggle.getSelectedJiggleWeightRing() else {
            return nil
        }
        
        guard let selectedJiggleControlPoint = selectedJiggleWeightRing.getSelectedJiggleControlPoint() else {
            return nil
        }
        
        guard selectedJiggleWeightRing.jiggleControlPointCount > JiggleWeightRing.minPointCount else {
            ApplicationController.rootViewController.showAlertMessageTooFewPoints()
            return nil
        }
        
        
        let result = AttemptRemoveWeightRingControlPointResult(jiggleIndex: selectedJiggleIndex,
                                                               weightCurveIndex: selectedJiggle.selectedWeightCurveControlIndex,
                                                               weightRingControlPointIndex: selectedJiggleWeightRing.selectedJiggleControlPointIndex,
                                                               point: selectedJiggleControlPoint.point)
        
        if selectedJiggleWeightRing.removeJiggleControlPoint(selectedJiggleControlPoint) {
            
            refreshWeightRingModify(jiggle: selectedJiggle,
                                    jiggleWeightRing: selectedJiggleWeightRing,
                                    displayMode: displayMode,
                                    isGraphEnabled: isGraphEnabled)
            
            weightRingControlPointsDidChangePublisher.send(())
            
            killDragAll()
        }
        return result
    }
    
    func getSelectedJiggleControlPoint() -> JiggleControlPoint? {
        if let selectedJiggle = getSelectedJiggle() {
            return selectedJiggle.getSelectedJiggleControlPoint()
        }
        return nil
    }
    
    func attemptCreateControlPoint(_ point: Point,
                                   displayMode: DisplayMode,
                                   isGraphEnabled: Bool) -> Bool {
        guard let selectedJiggle = getSelectedJiggle() else {
            ApplicationController.rootViewController.showAlertMessageSelectedJiggleRequired()
            return false
        }
        if selectedJiggle.jiggleControlPointCount >= Jiggle.maxPointCount {
            ApplicationController.rootViewController.showAlertMessageTooManyPoints()
            return false
        }
        guard let insertIndex = selectedJiggle.calculateNearestInsertIndex(point.x, point.y) else {
            return false
        }
        let point = selectedJiggle.untransformPoint(point: point)
        selectedJiggle.insertJiggleControlPoint(point.x, point.y, at: insertIndex)
        
        refreshJiggleControlPoint(jiggle: selectedJiggle,
                                  displayMode: displayMode,
                                  isGraphEnabled: isGraphEnabled)
        controlPointsDidChangePublisher.send(())
        
        killDragAll()
        return true
    }
    
    func attemptRemoveControlPoint(_ point: Point,
                                   sceneScaleBase: Float,
                                   displayMode: DisplayMode,
                                   isGraphEnabled: Bool) -> AttemptRemoveControlPointResult? {
        var _jiggleIndex: Int?
        var _jiggleControlPointIndex: Int?
        let selectControlPointDistanceThreshold = Self.selectControlPointDistanceThresholdBase / sceneScaleBase
        var bestDistance = selectControlPointDistanceThreshold * selectControlPointDistanceThreshold
        for jiggleIndex in 0..<jiggleCount {
            let jiggle = jiggles[jiggleIndex]
            if jiggle.isFrozen == false {
                for jiggleControlPointIndex in 0..<jiggle.jiggleControlPointCount {
                    let jiggleControlPoint = jiggle.jiggleControlPoints[jiggleControlPointIndex]
                    let controlPointPosition = jiggle.transformPoint(jiggleControlPoint.x, jiggleControlPoint.y)
                    let diffX = controlPointPosition.x - point.x
                    let diffY = controlPointPosition.y - point.y
                    let dist = diffX * diffX + diffY * diffY
                    if dist < bestDistance {
                        bestDistance = dist
                        _jiggleIndex = jiggleIndex
                        _jiggleControlPointIndex = jiggleControlPointIndex
                    }
                }
            }
        }
        
        if let jiggleIndex = _jiggleIndex, let jiggleControlPointIndex = _jiggleControlPointIndex {
            let jiggle = jiggles[jiggleIndex]
            if jiggle.jiggleControlPointCount > Jiggle.minPointCount {
                let jiggleControlPoint = jiggle.jiggleControlPoints[jiggleControlPointIndex]
                let result = AttemptRemoveControlPointResult(jiggleIndex: jiggleIndex,
                                                             controlPointIndex: jiggleControlPointIndex,
                                                             point: jiggleControlPoint.point)
                _ = jiggle.removeJiggleControlPoint(jiggleControlPoint)
                refreshJiggleControlPointAndSelect(at: jiggleIndex,
                                                   displayMode: displayMode,
                                                   isGraphEnabled: isGraphEnabled)
                killDragAll()
                controlPointsDidChangePublisher.send(())
                return result
            } else {
                ApplicationController.rootViewController.showAlertMessageTooFewPoints()
            }
        }
        return nil
    }
    
    func attemptRemoveSelectedControlPoint(displayMode: DisplayMode,
                                           isGraphEnabled: Bool) -> AttemptRemoveControlPointResult? {
        guard let selectedJiggle = getSelectedJiggle() else {
            return nil
        }
        guard let selectedControlPoint = selectedJiggle.getSelectedJiggleControlPoint() else {
            return nil
        }
        
        if selectedJiggle.jiggleControlPointCount > Jiggle.minPointCount {
            let result = AttemptRemoveControlPointResult(jiggleIndex: selectedJiggleIndex,
                                                         controlPointIndex: selectedJiggle.selectedJiggleControlPointIndex,
                                                         point: selectedControlPoint.point)
            if selectedJiggle.removeJiggleControlPoint(selectedControlPoint) {
                refreshJiggleControlPoint(jiggle: selectedJiggle,
                                          displayMode: displayMode,
                                          isGraphEnabled: isGraphEnabled)
                controlPointsDidChangePublisher.send(())
                killDragAll()
            }
            return result
        } else {
            ApplicationController.rootViewController.showAlertMessageTooFewPoints()
        }
        return nil
    }
    
    func attemptJiggleWeightRingAffinePanBegan(center: Math.Point,
                                               displayMode: DisplayMode,
                                               isGraphEnabled: Bool) -> Bool {
        
        if creatorMode != .none {
            killJiggleWeightRingAffinePanScaleRotate()
            return false
        }
        
        if selectedJiggleWeightRingAffine === nil {
            attemptSelectJiggleWeightRing(at: center,
                                          displayMode: displayMode,
                                          isGraphEnabled: isGraphEnabled)
            selectedJiggleWeightRingAffine = getSelectedJiggleWeightRing()
            if let selectedAffineJiggleWeightRing = selectedJiggleWeightRingAffine {
                beginJiggleWeightRingAffinePanScaleRotate(jiggleWeightRing: selectedAffineJiggleWeightRing)
            }
        }
        
        if let selectedAffineJiggleWeightRing = selectedJiggleWeightRingAffine {
            isPanningJiggleWeightRingAffine = true
            panStartCenterJiggleWeightRingAffine = center
            panCenterJiggleWeightRingAffine = center
            gestureCenterJiggleWeightRingAffine = center
            selectedJiggleWeightRingStartCenterJiggleWeightRingAffine = selectedAffineJiggleWeightRing.center
            gestureCenterStartJiggleWeightRingAffine = selectedAffineJiggleWeightRing.jiggle.untransformPoint(point: center)
            gestureCenterStartJiggleWeightRingAffine = selectedAffineJiggleWeightRing.untransformPoint(point: gestureCenterStartJiggleWeightRingAffine)
            return true
        } else {
            return false
        }
    }

    func attemptJiggleWeightRingAffinePanMoved(center: Math.Point,
                                               displayMode: DisplayMode,
                                               isGraphEnabled: Bool) -> Bool {
        if creatorMode != .none {
            killJiggleWeightRingAffinePanScaleRotate()
            return false
        }
        guard isPanningJiggleWeightRingAffine else {
            return false
        }
        panCenterJiggleWeightRingAffine = center
        gestureCenterJiggleWeightRingAffine = center
        gestureUpdateJiggleWeightRingAffine(displayMode: displayMode,
                                            isGraphEnabled: isGraphEnabled)
        return true
    }

    func attemptJiggleWeightRingAffinePanEnded(center: Math.Point) -> Bool {
        killJiggleWeightRingAffinePanScaleRotate()
        return true
    }
    
    func attemptJiggleWeightRingAffinePinchBegan(center: Point,
                                                 scale: Float,
                                                 displayMode: DisplayMode,
                                                 isGraphEnabled: Bool) -> Bool {
        if creatorMode != .none {
            killJiggleWeightRingAffinePanScaleRotate()
            return false
        }
        if selectedJiggleWeightRingAffine === nil {
            attemptSelectJiggleWeightRing(at: center,
                                          displayMode: displayMode,
                                          isGraphEnabled: isGraphEnabled)
            selectedJiggleWeightRingAffine = getSelectedJiggleWeightRing()
            if let selectedAffineJiggleWeightRing = selectedJiggleWeightRingAffine {
                beginJiggleWeightRingAffinePanScaleRotate(jiggleWeightRing: selectedAffineJiggleWeightRing)
            }
        }
        if let selectedAffineJiggleWeightRing = selectedJiggleWeightRingAffine {
            isPinchingJiggleWeightRingAffine = true
            gestureCenterJiggleWeightRingAffine = center
            pinchScaleJiggleWeightRingAffine = scale
            selectedJiggleWeightRingStartScaleJiggleWeightRingAffine = selectedAffineJiggleWeightRing.scale
            selectedJiggleWeightRingStartCenterJiggleWeightRingAffine = selectedAffineJiggleWeightRing.center
            gestureCenterStartJiggleWeightRingAffine = selectedAffineJiggleWeightRing.jiggle.untransformPoint(point: center)
            gestureCenterStartJiggleWeightRingAffine = selectedAffineJiggleWeightRing.untransformPoint(point: gestureCenterStartJiggleWeightRingAffine)
            return true
        } else {
            return false
        }
    }
    
    func attemptJiggleWeightRingAffinePinchMoved(center: Point,
                                                 scale: Float,
                                                 displayMode: DisplayMode,
                                                 isGraphEnabled: Bool) -> Bool {
        if creatorMode != .none {
            killJiggleWeightRingAffinePanScaleRotate()
            return false
        }
        guard isPinchingJiggleWeightRingAffine else {
            return false
        }
        pinchScaleJiggleWeightRingAffine = scale
        gestureCenterJiggleWeightRingAffine = center
        gestureUpdateJiggleWeightRingAffine(displayMode: displayMode,
                                            isGraphEnabled: isGraphEnabled)
        return true
    }

    func attemptJiggleWeightRingAffinePinchEnded(center: Point, scale: Float) -> Bool {
        killJiggleWeightRingAffinePanScaleRotate()
        return true
    }

    func attemptJiggleWeightRingAffineRotateBegan(center: Point,
                                                  rotation: Float,
                                                  displayMode: DisplayMode,
                                                  isGraphEnabled: Bool) -> Bool {
        
        if creatorMode != .none {
            killJiggleWeightRingAffinePanScaleRotate()
            return false
        }
        
        if selectedJiggleWeightRingAffine === nil {
            attemptSelectJiggleWeightRing(at: center,
                                          displayMode: displayMode,
                                          isGraphEnabled: isGraphEnabled)
            selectedJiggleWeightRingAffine = getSelectedJiggleWeightRing()
            
            if let selectedAffineJiggleWeightRing = selectedJiggleWeightRingAffine {
                beginJiggleWeightRingAffinePanScaleRotate(jiggleWeightRing: selectedAffineJiggleWeightRing)
            }
        }
        
        if let selectedAffineJiggleWeightRing = selectedJiggleWeightRingAffine {
            isRotatingJiggleWeightRingAffine = true
            rotationJiggleWeightRingAffine = rotation
            gestureCenterJiggleWeightRingAffine = center
            selectedJiggleWeightRingStartRotationJiggleWeightRingAffine = selectedAffineJiggleWeightRing.rotation
            selectedJiggleWeightRingStartCenterJiggleWeightRingAffine = selectedAffineJiggleWeightRing.center
            gestureCenterStartJiggleWeightRingAffine = selectedAffineJiggleWeightRing.jiggle.untransformPoint(point: center)
            gestureCenterStartJiggleWeightRingAffine = selectedAffineJiggleWeightRing.untransformPoint(point: gestureCenterStartJiggleWeightRingAffine)
            return true
        } else {
            return false
        }
    }

    func attemptJiggleWeightRingAffineRotateMoved(center: Point,
                                                  rotation: Float,
                                                  displayMode: DisplayMode,
                                                  isGraphEnabled: Bool) -> Bool {
        if creatorMode != .none {
            killJiggleWeightRingAffinePanScaleRotate()
            return false
        }
        guard isRotatingJiggleWeightRingAffine else {
            return false
        }
        rotationJiggleWeightRingAffine = rotation
        gestureCenterJiggleWeightRingAffine = center
        gestureUpdateJiggleWeightRingAffine(displayMode: displayMode,
                                            isGraphEnabled: isGraphEnabled)
        return true
    }

    func attemptJiggleWeightRingAffineRotateEnded(center: Point, rotation: Float) -> Bool {
        killJiggleWeightRingAffinePanScaleRotate()
        return true
    }
        
    func gestureUpdateJiggleWeightRingAffine(displayMode: DisplayMode,
                                             isGraphEnabled: Bool) {
        if let selectedAffineJiggleWeightRing = selectedJiggleWeightRingAffine,
           let selectedJiggle = getJiggleWithWeightRing(weightRing: selectedAffineJiggleWeightRing) {
            
            //
            // We don't record history unless we moved.
            // Otherwise, the user can create unwanted history.
            //
            _didUpdateJiggleWeightRingAffine = true
            
            if isPanningJiggleWeightRingAffine {
                let x = selectedJiggleWeightRingStartCenterJiggleWeightRingAffine.x + (panCenterJiggleWeightRingAffine.x - panStartCenterJiggleWeightRingAffine.x)
                let y = selectedJiggleWeightRingStartCenterJiggleWeightRingAffine.y + (panCenterJiggleWeightRingAffine.y - panStartCenterJiggleWeightRingAffine.y)
                selectedAffineJiggleWeightRing.center.x = x
                selectedAffineJiggleWeightRing.center.y = y
            }
            if isPinchingJiggleWeightRingAffine {
                selectedAffineJiggleWeightRing.scale = selectedJiggleWeightRingStartScaleJiggleWeightRingAffine * pinchScaleJiggleWeightRingAffine
            }
            if isRotatingJiggleWeightRingAffine {
                var newRotation = selectedJiggleWeightRingStartRotationJiggleWeightRingAffine + rotationJiggleWeightRingAffine
                while newRotation > Math.pi2 { newRotation -= Math.pi2 }
                while newRotation < 0.0 { newRotation += Math.pi2 }
                selectedAffineJiggleWeightRing.rotation = newRotation
            }
            
            var startCenter = selectedAffineJiggleWeightRing.transformPoint(point: gestureCenterStartJiggleWeightRingAffine)
            startCenter = selectedAffineJiggleWeightRing.jiggle.transformPoint(point: startCenter)
            var delta = Point(x: gestureCenterJiggleWeightRingAffine.x - startCenter.x,
                              y: gestureCenterJiggleWeightRingAffine.y - startCenter.y)
            delta = selectedAffineJiggleWeightRing.jiggle.untransformPointScaleAndRotationOnly(point: delta)
            selectedAffineJiggleWeightRing.center.x = selectedAffineJiggleWeightRing.center.x + delta.x
            selectedAffineJiggleWeightRing.center.y = selectedAffineJiggleWeightRing.center.y + delta.y
        
            let swivelType = JiggleMeshCommand.getSwivelTypeIfNeeded(documentMode: documentMode,
                                                                     displayMode: displayMode,
                                                                     isGuidesEnabled: isGuidesEnabled,
                                                                     isGraphEnabled: isGraphEnabled)
            
            let meshCommand = JiggleMeshCommand(spline: false,
                                                triangulationType: .beautiful,
                                                meshType: .affineOnlyWeights,
                                                outlineType: .ifNeeded,
                                                swivelType: swivelType,
                                                weightCurveType: .none)
            let worldScale = getWorldScale()
            let isDarkModeEnabled = ApplicationController.isDarkModeEnabled
            let weightRingCommandForTarget = JiggleWeightRingCommand(spline: true, outlineType: .ifNeeded)
            let weightRingCommandForOthers = JiggleWeightRingCommand.none
            let isSelected = (getSelectedJiggle() === selectedJiggle)
            selectedJiggle.execute(meshCommand: meshCommand,
                                   isSelected: isSelected,
                                   isDarkModeEnabled: isDarkModeEnabled,
                                   worldScale: worldScale,
                                   targetWeightRing: selectedAffineJiggleWeightRing,
                                   weightRingCommandForTarget: weightRingCommandForTarget,
                                   weightRingCommandForOthers: weightRingCommandForOthers,
                                   orientation: orientation)
            
            //selectedJiggle.currentHashPoly.triangulationType = .none
            //selectedJiggle.currentHashTrianglesWeights.polyHash.triangulationType = .none
            //selectedJiggle.currentHashTrianglesStandard.polyHash.triangulationType = .none
            
        }
    }
    
    func beginJiggleWeightRingAffinePanScaleRotate(jiggleWeightRing: JiggleWeightRing) {
        _didUpdateJiggleWeightRingAffine = false
        _transformJiggleWeightRingData.jiggle = selectedJiggleAffine
        _transformJiggleWeightRingData.jiggleWeightRing = jiggleWeightRing
        _transformJiggleWeightRingData.jiggleIndex = getJiggleIndexWithWeightRing(weightRing: jiggleWeightRing)
        _transformJiggleWeightRingData.weightCurveIndex = getWeightCurveIndex(weightRing: jiggleWeightRing)
        _transformJiggleWeightRingData.startCenter = jiggleWeightRing.center
        _transformJiggleWeightRingData.startScale = jiggleWeightRing.scale
        _transformJiggleWeightRingData.startRotation = jiggleWeightRing.rotation
    }
        
    func killJiggleWeightRingAffinePanScaleRotate() {
        if isRotatingJiggleWeightRingAffine || isPanningJiggleWeightRingAffine || isPinchingJiggleWeightRingAffine {
            if let selectedAffineJiggleWeightRing = selectedJiggleWeightRingAffine,
               let selectedJiggle = getJiggleWithWeightRing(weightRing: selectedAffineJiggleWeightRing) {
                if _didUpdateJiggleWeightRingAffine {
                    
                    //
                    // Weird way to solve this, but we will
                    // let the "clean up" process fix our coloring...
                    // It is too laggy to compute all the distances
                    // on every "tick of the mouse..."
                    //
                    selectedJiggle.currentHashPoly.triangulationType = .fast
                    selectedJiggle.currentHashTrianglesWeights.polyHash.triangulationType = .fast
                    
                    _transformJiggleWeightRingData.endCenter = selectedAffineJiggleWeightRing.center
                    _transformJiggleWeightRingData.endScale = selectedAffineJiggleWeightRing.scale
                    _transformJiggleWeightRingData.endRotation = selectedAffineJiggleWeightRing.rotation
                    transformJiggleWeightRingPublisher.send(_transformJiggleWeightRingData)
                }
            }
        }
        _didUpdateJiggleWeightRingAffine = false
        selectedJiggleWeightRingAffine = nil
        isRotatingJiggleWeightRingAffine = false
        isPanningJiggleWeightRingAffine = false
        isPinchingJiggleWeightRingAffine = false
    }
    
    func attemptJiggleAffinePanBegan(center: Math.Point,
                                     displayMode: DisplayMode,
                                     isGraphEnabled: Bool) -> Bool {
        
        if creatorMode != .none {
            killJiggleAffinePanScaleRotate()
            return false
        }
        
        if selectedJiggleAffine === nil {
            attemptSelectJiggle(at: center,
                                displayMode: displayMode,
                                isGraphEnabled: isGraphEnabled)
            selectedJiggleAffine = getSelectedJiggle()
            if let selectedAffineJiggle = selectedJiggleAffine {
                beginJiggleAffinePanScaleRotate(jiggle: selectedAffineJiggle)
            }
        }
        
        if let selectedAffineJiggle = selectedJiggleAffine {
            isPanningJiggleAffine = true
            panStartCenterJiggleAffine = center
            panCenterJiggleAffine = center
            gestureCenterJiggleAffine = center
            selectedJiggleStartCenterJiggleAffine = selectedAffineJiggle.center
            gestureCenterStartJiggleAffine = selectedAffineJiggle.untransformPoint(point: center)
            return true
        } else {
            return false
        }
    }

    func attemptJiggleAffinePanMoved(center: Math.Point,
                                     displayMode: DisplayMode,
                                     isGraphEnabled: Bool) -> Bool {
        if creatorMode != .none {
            killJiggleAffinePanScaleRotate()
            return false
        }
        guard isPanningJiggleAffine else {
            return false
        }
        panCenterJiggleAffine = center
        gestureCenterJiggleAffine = center
        gestureUpdateJiggleAffine(displayMode: displayMode,
                                  isGraphEnabled: isGraphEnabled)
        return true
    }

    func attemptJiggleAffinePanEnded(center: Math.Point) -> Bool {
        killJiggleAffinePanScaleRotate()
        return true
    }

    func attemptJiggleAffinePinchBegan(center: Point,
                                       scale: Float,
                                       displayMode: DisplayMode,
                                       isGraphEnabled: Bool) -> Bool {
        
        if creatorMode != .none {
            killJiggleAffinePanScaleRotate()
            return false
        }
        
        if selectedJiggleAffine === nil {
            attemptSelectJiggle(at: center,
                                displayMode: displayMode,
                                isGraphEnabled: isGraphEnabled)
            selectedJiggleAffine = getSelectedJiggle()
            if let selectedAffineJiggle = selectedJiggleAffine {
                beginJiggleAffinePanScaleRotate(jiggle: selectedAffineJiggle)
            }
        }
        
        if let selectedAffineJiggle = selectedJiggleAffine {
            isPinchingJiggleAffine = true
            gestureCenterJiggleAffine = center
            pinchScaleJiggleAffine = scale
            selectedJiggleStartScaleJiggleAffine = selectedAffineJiggle.scale
            selectedJiggleStartCenterJiggleAffine = selectedAffineJiggle.center
            gestureCenterStartJiggleAffine = selectedAffineJiggle.untransformPoint(point: center)
            return true
        } else {
            return false
        }
    }

    func attemptJiggleAffinePinchMoved(center: Point,
                                       scale: Float,
                                       displayMode: DisplayMode,
                                       isGraphEnabled: Bool) -> Bool {
        if creatorMode != .none {
            killJiggleAffinePanScaleRotate()
            return false
        }
        
        guard isPinchingJiggleAffine else {
            return false
        }
        
        pinchScaleJiggleAffine = scale
        gestureCenterJiggleAffine = center
        gestureUpdateJiggleAffine(displayMode: displayMode,
                                  isGraphEnabled: isGraphEnabled)
        return true
    }

    func attemptJiggleAffinePinchEnded(center: Point, scale: Float) -> Bool {
        killJiggleAffinePanScaleRotate()
        return true
    }

    func attemptJiggleAffineRotateBegan(center: Point,
                                        rotation: Float,
                                        displayMode: DisplayMode,
                                        isGraphEnabled: Bool) -> Bool {
        
        if creatorMode != .none {
            killJiggleAffinePanScaleRotate()
            return false
        }
        
        if selectedJiggleAffine === nil {
            attemptSelectJiggle(at: center,
                                displayMode: displayMode,
                                isGraphEnabled: isGraphEnabled)
            selectedJiggleAffine = getSelectedJiggle()
            
            if let selectedAffineJiggle = selectedJiggleAffine {
                beginJiggleAffinePanScaleRotate(jiggle: selectedAffineJiggle)
            }
        }
        
        if let selectedAffineJiggle = selectedJiggleAffine {
            isRotatingJiggleAffine = true
            rotationJiggleAffine = rotation
            gestureCenterJiggleAffine = center
            selectedJiggleStartRotationJiggleAffine = selectedAffineJiggle.rotation
            selectedJiggleStartCenterJiggleAffine = selectedAffineJiggle.center
            gestureCenterStartJiggleAffine = selectedAffineJiggle.untransformPoint(point: center)
            
            return true
        } else {
            return false
        }
    }

    func attemptJiggleAffineRotateMoved(center: Point,
                                        rotation: Float,
                                        displayMode: DisplayMode,
                                        isGraphEnabled: Bool) -> Bool {
        if creatorMode != .none {
            killJiggleAffinePanScaleRotate()
            return false
        }
        guard isRotatingJiggleAffine else {
            return false
        }
        rotationJiggleAffine = rotation
        gestureCenterJiggleAffine = center
        gestureUpdateJiggleAffine(displayMode: displayMode,
                                  isGraphEnabled: isGraphEnabled)
        return true
    }

    func attemptJiggleAffineRotateEnded(center: Point, rotation: Float) -> Bool {
        killJiggleAffinePanScaleRotate()
        return true
    }
    
    func gestureUpdateJiggleAffine(displayMode: DisplayMode,
                                   isGraphEnabled: Bool) {
        if let selectedAffineJiggle = selectedJiggleAffine {
            
            _didUpdateJiggleAffine = true
            
            if isPanningJiggleAffine {
                let x = selectedJiggleStartCenterJiggleAffine.x + (panCenterJiggleAffine.x - panStartCenterJiggleAffine.x)
                let y = selectedJiggleStartCenterJiggleAffine.y + (panCenterJiggleAffine.y - panStartCenterJiggleAffine.y)
                selectedAffineJiggle.center.x = x
                selectedAffineJiggle.center.y = y
            }
            if isPinchingJiggleAffine {
                selectedAffineJiggle.scale = selectedJiggleStartScaleJiggleAffine * pinchScaleJiggleAffine
            }
            if isRotatingJiggleAffine {
                var newRotation = selectedJiggleStartRotationJiggleAffine + rotationJiggleAffine
                while newRotation > Math.pi2 { newRotation -= Math.pi2 }
                while newRotation < 0.0 { newRotation += Math.pi2 }
                selectedAffineJiggle.rotation = newRotation
            }
            
            let startCenter = selectedAffineJiggle.transformPoint(point: gestureCenterStartJiggleAffine)
            selectedAffineJiggle.center.x = selectedAffineJiggle.center.x + (gestureCenterJiggleAffine.x - startCenter.x)
            selectedAffineJiggle.center.y = selectedAffineJiggle.center.y + (gestureCenterJiggleAffine.y - startCenter.y)
            
            refreshJiggleAffineStandard(jiggle: selectedAffineJiggle,
                                displayMode: displayMode,
                                isGraphEnabled: isGraphEnabled)
                
        }
    }
    
    func beginJiggleAffinePanScaleRotate(jiggle: Jiggle) {
        _didUpdateJiggleAffine = false
        _transformJiggleData.jiggle = jiggle
        _transformJiggleData.jiggleIndex = getJiggleIndex(jiggle)
        _transformJiggleData.startCenter = jiggle.center
        _transformJiggleData.startScale = jiggle.scale
        _transformJiggleData.startRotation = jiggle.rotation
    }
    
    func killJiggleAffinePanScaleRotate() {
        if isRotatingJiggleAffine || isPanningJiggleAffine || isPinchingJiggleAffine {
            if let selectedJiggleAffine = selectedJiggleAffine {
                if _didUpdateJiggleAffine {
                    _transformJiggleData.jiggleIndex = getJiggleIndex(selectedJiggleAffine)
                    _transformJiggleData.endCenter = selectedJiggleAffine.center
                    _transformJiggleData.endScale = selectedJiggleAffine.scale
                    _transformJiggleData.endRotation = selectedJiggleAffine.rotation
                    transformJigglePublisher.send(_transformJiggleData)
                }
            }
        }
        
        _didUpdateJiggleAffine = false
        selectedJiggleAffine = nil
        isRotatingJiggleAffine = false
        isPanningJiggleAffine = false
        isPinchingJiggleAffine = false
    }
    
    func attemptGrabWeightCenter(touch: UITouch,
                                 at point: Point,
                                 sceneScaleBase: Float,
                                 displayMode: DisplayMode,
                                 isGraphEnabled: Bool) {
        
        guard selectedWeightCenterTouch === nil else {
            return
        }
        
        killDragAll()
        
        var currentSelectedJiggleIndex = -1
        
        let selectWeightCenterDistanceThreshold = Self.selectWeightCenterDistanceThresholdBase / sceneScaleBase
        var bestDistance = selectWeightCenterDistanceThreshold * selectWeightCenterDistanceThreshold
        for jiggleIndex in 0..<jiggleCount {
            let jiggle = jiggles[jiggleIndex]
            if jiggle.isFrozen == false {
                var jiggleWeightCenter = jiggle.guideCenter
                jiggleWeightCenter = jiggle.transformPoint(point: jiggleWeightCenter)
                let dist = jiggle.guideCenterDistanceSquaredToPoint(point)
                if dist < bestDistance {
                    selectedWeightCenterTouch = touch
                    selectedWeightCenterStartTouchX = point.x
                    selectedWeightCenterStartTouchY = point.y
                    selectedWeightCenterStartX = jiggleWeightCenter.x
                    selectedWeightCenterStartY = jiggleWeightCenter.y
                    currentSelectedJiggleIndex = jiggleIndex
                    bestDistance = dist
                }
            }
        }
        
        if currentSelectedJiggleIndex == -1 {
            attemptSelectJiggleWeightModeDefaultCase(at: point,
                                                     displayMode: displayMode,
                                                     isGraphEnabled: isGraphEnabled)
        } else {
            switchSelectedJiggle(newSelectedJiggleIndex: currentSelectedJiggleIndex,
                                 displayMode: displayMode,
                                 isGraphEnabled: isGraphEnabled)
            
            let selectedJiggle = jiggles[currentSelectedJiggleIndex]
            
            _grabWeightCenterData.startX = selectedJiggle.guideCenter.x
            _grabWeightCenterData.startY = selectedJiggle.guideCenter.y
            _grabWeightCenterData.endX = selectedJiggle.guideCenter.x
            _grabWeightCenterData.endY = selectedJiggle.guideCenter.y
            _grabWeightCenterData.jiggleIndex = currentSelectedJiggleIndex
            _grabWeightCenterData.didChange = false
        }
    }
    
    func attemptUpdateWeightCenter(touch: UITouch, at point: Point, isFromRelease: Bool) {
        
        guard let selectedJiggle = getSelectedJiggle() else {
            killDragAll()
            return
        }
        guard let selectedWeightCenterTouch = selectedWeightCenterTouch else {
            killDragAll()
            return
        }
        
        guard touch === selectedWeightCenterTouch else {
            return
        }
        
        let delta = selectedJiggle.untransformPointScaleAndRotationOnly(point.x - selectedWeightCenterStartTouchX,
                                                                        point.y - selectedWeightCenterStartTouchY)
        let startPoint = selectedJiggle.untransformPoint(selectedWeightCenterStartX,
                                                         selectedWeightCenterStartY)
        
        let pointX = startPoint.x + delta.x
        let pointY = startPoint.y + delta.y
        
        selectedJiggle.guideCenter.x = pointX
        selectedJiggle.guideCenter.y = pointY
        
        _grabWeightCenterData.endX = selectedJiggle.guideCenter.x
        _grabWeightCenterData.endY = selectedJiggle.guideCenter.y
        
        selectedJiggle.currentHashPoly.triangulationType = .none
        selectedJiggle.currentHashTrianglesWeights.polyHash.triangulationType = .none
        selectedJiggle.currentHashTrianglesStandard.polyHash.triangulationType = .none
        
        if !isFromRelease {
            _grabWeightCenterData.didChange = true
        }
    }
    
    func attemptReleaseWeightCenter(touch: UITouch, at point: Point) {
        if touch == selectedWeightCenterTouch {
            killDragAll()
        }
    }
    
    func attemptGrabControlPoint(touch: UITouch,
                                 at point: Point,
                                 sceneScaleBase: Float,
                                 displayMode: DisplayMode,
                                 isGraphEnabled: Bool) {
        
        guard selectedControlPointTouch === nil else {
            return
        }
        
        killDragAll()
        
        if creatorMode != .none {
            return
        }
        
        var currentSelectedJiggleIndex = -1
        var currentSelectedJiggleControlPointIndex = -1
        
        let selectControlPointDistanceThreshold = Self.selectControlPointDistanceThresholdBase / sceneScaleBase
        var bestDistance = selectControlPointDistanceThreshold * selectControlPointDistanceThreshold
        for jiggleIndex in 0..<jiggleCount {
            let jiggle = jiggles[jiggleIndex]
            if jiggle.isFrozen == false {
                for jiggleControlPointIndex in 0..<jiggle.jiggleControlPointCount {
                    let jiggleControlPoint = jiggle.jiggleControlPoints[jiggleControlPointIndex]
                    let controlPointPosition = jiggle.transformPoint(jiggleControlPoint.x, jiggleControlPoint.y)
                    let diffX = controlPointPosition.x - point.x
                    let diffY = controlPointPosition.y - point.y
                    let dist = diffX * diffX + diffY * diffY
                    if dist < bestDistance {
                        selectedControlPointTouch = touch
                        selectedControlPointStartTouchX = point.x
                        selectedControlPointStartTouchY = point.y
                        selectedControlPointStartX = controlPointPosition.x
                        selectedControlPointStartY = controlPointPosition.y
                        currentSelectedJiggleIndex = jiggleIndex
                        currentSelectedJiggleControlPointIndex = jiggleControlPointIndex
                        bestDistance = dist
                    }
                }
            }
        }
        
        if currentSelectedJiggleControlPointIndex == -1 {
            attemptSelectControlPointDefaultCase(at: point,
                                                 displayMode: displayMode,
                                                 isGraphEnabled: isGraphEnabled)
        } else {
            
            let selectedJiggle = jiggles[currentSelectedJiggleIndex]
            
            
            selectedJiggle.selectedJiggleControlPointIndex = currentSelectedJiggleControlPointIndex
            let selectedControlPoint = selectedJiggle.jiggleControlPoints[currentSelectedJiggleControlPointIndex]
            _grabControlPointData.startX = selectedControlPoint.x
            _grabControlPointData.startY = selectedControlPoint.y
            _grabControlPointData.endX = selectedControlPoint.x
            _grabControlPointData.endY = selectedControlPoint.y
            _grabControlPointData.jiggleIndex = selectedJiggleIndex
            _grabControlPointData.controlPointIndex = currentSelectedJiggleControlPointIndex
            _grabControlPointData.didChange = false
            
            switchSelectedJiggle(newSelectedJiggleIndex: currentSelectedJiggleIndex,
                                 displayMode: displayMode,
                                 isGraphEnabled: isGraphEnabled)
        }
    }
    
    func attemptUpdateControlPoint(touch: UITouch,
                                   at point: Point,
                                   isFromRelease: Bool,
                                   displayMode: DisplayMode,
                                   isGraphEnabled: Bool) {
        
        if creatorMode != .none {
            killDragAll()
            return
        }
        
        guard let selectedJiggle = getSelectedJiggle() else {
            killDragAll()
            return
        }
        guard let selectedControlPointTouch = selectedControlPointTouch else {
            killDragAll()
            return
        }
        guard let selectedJiggleControlPoint = selectedJiggle.getSelectedJiggleControlPoint() else {
            killDragAll()
            return
        }
        
        guard touch === selectedControlPointTouch else {
            return
        }
        
        let delta = selectedJiggle.untransformPointScaleAndRotationOnly(point.x - selectedControlPointStartTouchX,
                                                                        point.y - selectedControlPointStartTouchY)
        let startPoint = selectedJiggle.untransformPoint(selectedControlPointStartX,
                                                         selectedControlPointStartY)
        let pointX = startPoint.x + delta.x
        let pointY = startPoint.y + delta.y
        
        selectedJiggleControlPoint.x = pointX
        selectedJiggleControlPoint.y = pointY
        
        refreshJiggleControlPoint(jiggle: selectedJiggle,
                                  displayMode: displayMode,
                                  isGraphEnabled: isGraphEnabled)
        
        _grabControlPointData.endX = pointX
        _grabControlPointData.endY = pointY
        if !isFromRelease {
            _grabControlPointData.didChange = true
        }
    }
    
    func attemptReleaseControlPoint(touch: UITouch, at point: Point) {
        if touch == selectedControlPointTouch {
            killDragAll()
        }
    }
    
    func attemptSelectControlPointDefaultCase(at point: Point,
                                              displayMode: DisplayMode,
                                              isGraphEnabled: Bool) {
        let currentSelectedJiggleIndex = getIndexOfJiggleToSelect(at: point)
        if let selectedJiggle = getJiggle(currentSelectedJiggleIndex) {
            selectedJiggle.selectedJiggleControlPointIndex = -1
        }
        switchSelectedJiggle(newSelectedJiggleIndex: currentSelectedJiggleIndex,
                             displayMode: displayMode,
                             isGraphEnabled: isGraphEnabled)
    }
    
    func attemptGrabWeightControlPoint(touch: UITouch,
                                       at point: Point,
                                       sceneScaleBase: Float,
                                       displayMode: DisplayMode,
                                       isGraphEnabled: Bool) {
        
        guard selectedWeightControlPointTouch === nil else {
            return
        }
        
        killDragAll()
        
        if creatorMode != .none {
            return
        }
        
        var currentSelectedJiggleIndex = -1
        var currentSelectedWeightRingIndex = -1
        var currentSelectedJiggleControlPointIndex = -1
        let selectWeightControlPointDistanceThreshold = Self.selectControlPointDistanceThresholdBase / sceneScaleBase
        var bestDistance = selectWeightControlPointDistanceThreshold * selectWeightControlPointDistanceThreshold
        for jiggleIndex in 0..<jiggleCount {
            let jiggle = jiggles[jiggleIndex]
            if jiggle.isFrozen == false {
                for jiggleWeightRingIndex in 0..<jiggle.jiggleWeightRingCount {
                    let jiggleWeightRing = jiggle.jiggleWeightRings[jiggleWeightRingIndex]
                    if jiggleWeightRing.isFrozen == false {
                        for jiggleControlPointIndex in 0..<jiggleWeightRing.jiggleControlPointCount {
                            let jiggleControlPoint = jiggleWeightRing.jiggleControlPoints[jiggleControlPointIndex]
                            var controlPointPosition = jiggleControlPoint.point
                            controlPointPosition = jiggleWeightRing.transformPoint(point: controlPointPosition)
                            controlPointPosition = jiggle.transformPoint(point: controlPointPosition)
                            let diffX = controlPointPosition.x - point.x
                            let diffY = controlPointPosition.y - point.y
                            let dist = diffX * diffX + diffY * diffY
                            if dist < bestDistance {
                                selectedWeightControlPointTouch = touch
                                selectedWeightControlPointStartTouchX = point.x
                                selectedWeightControlPointStartTouchY = point.y
                                selectedWeightControlPointStartX = controlPointPosition.x
                                selectedWeightControlPointStartY = controlPointPosition.y
                                currentSelectedJiggleIndex = jiggleIndex
                                currentSelectedWeightRingIndex = jiggleWeightRingIndex
                                currentSelectedJiggleControlPointIndex = jiggleControlPointIndex
                                bestDistance = dist
                            }
                        }
                    }
                }
            }
        }
        
        if currentSelectedJiggleControlPointIndex == -1 {
            attemptSelectJiggleWeightModeDefaultCase(at: point,
                                                     displayMode: displayMode,
                                                     isGraphEnabled: isGraphEnabled)
        } else {
            
            let selectedJiggle = jiggles[currentSelectedJiggleIndex]
            let selectedJiggleWeightRing = selectedJiggle.jiggleWeightRings[currentSelectedWeightRingIndex]
            
            selectedJiggle.switchSelectedWeightCurveControlIndex(index: currentSelectedWeightRingIndex + 1)
            
            selectedJiggleWeightRing.selectedJiggleControlPointIndex = currentSelectedJiggleControlPointIndex
            let selectedJiggleControlPoint = selectedJiggleWeightRing.jiggleControlPoints[currentSelectedJiggleControlPointIndex]
            
            _grabWeightControlPointData.didChange = false
            _grabWeightControlPointData.startX = selectedJiggleControlPoint.x
            _grabWeightControlPointData.startY = selectedJiggleControlPoint.y
            _grabWeightControlPointData.endX = selectedJiggleControlPoint.x
            _grabWeightControlPointData.endY = selectedJiggleControlPoint.y
            _grabWeightControlPointData.jiggleIndex = currentSelectedJiggleIndex
            _grabWeightControlPointData.weightCurveIndex = (currentSelectedWeightRingIndex + 1)
            _grabWeightControlPointData.weightControlPointIndex = currentSelectedJiggleControlPointIndex
            
            switchSelectedJiggle(newSelectedJiggleIndex: currentSelectedJiggleIndex,
                                 displayMode: displayMode,
                                 isGraphEnabled: isGraphEnabled)
        }
    }
    
    func attemptUpdateWeightControlPoint(touch: UITouch,
                                         at point: Point,
                                         isFromRelease: Bool,
                                         displayMode: DisplayMode,
                                         isGraphEnabled: Bool) {
        
        if creatorMode != .none {
            killDragAll()
            return
        }
        
        guard let selectedJiggle = getSelectedJiggle() else {
            killDragAll()
            return
        }
        
        guard let selectedJiggleWeightRing = selectedJiggle.getSelectedJiggleWeightRing() else {
            killDragAll()
            return
        }
        
        guard let selectedWeightControlPointTouch = selectedWeightControlPointTouch else {
            killDragAll()
            return
        }
        
        guard let selectedJiggleControlPoint = selectedJiggleWeightRing.getSelectedJiggleControlPoint() else {
            killDragAll()
            return
        }
        
        guard touch === selectedWeightControlPointTouch else {
            return
        }
        
        var delta = selectedJiggle.untransformPointScaleAndRotationOnly(point.x - selectedWeightControlPointStartTouchX, point.y - selectedWeightControlPointStartTouchY)
        delta = selectedJiggleWeightRing.untransformPointScaleAndRotationOnly(delta.x, delta.y)
        
        var startPoint = selectedJiggle.untransformPoint(selectedWeightControlPointStartX, selectedWeightControlPointStartY)
        startPoint = selectedJiggleWeightRing.untransformPoint(startPoint.x, startPoint.y)
        
        let pointX = startPoint.x + delta.x
        let pointY = startPoint.y + delta.y
        
        selectedJiggleControlPoint.x = pointX
        selectedJiggleControlPoint.y = pointY
        
        let swivelType = JiggleMeshCommand.getSwivelTypeIfNeeded(documentMode: documentMode,
                                                                 displayMode: displayMode,
                                                                 isGuidesEnabled: isGraphEnabled,
                                                                 isGraphEnabled: isGraphEnabled)
            
        let meshCommand = JiggleMeshCommand(spline: false,
                                            triangulationType: .beautiful,
                                            meshType: .affineOnlyWeights,
                                            outlineType: .ifNeeded,
                                            swivelType: swivelType,
                                            weightCurveType: .none)
        let worldScale = getWorldScale()
        let isDarkModeEnabled = ApplicationController.isDarkModeEnabled
        let weightRingCommandForTarget = JiggleWeightRingCommand(spline: true, outlineType: .ifNeeded)
        let weightRingCommandForOthers = JiggleWeightRingCommand.none
        let isSelected = (getSelectedJiggle() === selectedJiggle)
        selectedJiggle.execute(meshCommand: meshCommand,
                               isSelected: isSelected,
                               isDarkModeEnabled: isDarkModeEnabled,
                               worldScale: worldScale,
                               targetWeightRing: selectedJiggleWeightRing,
                               weightRingCommandForTarget: weightRingCommandForTarget,
                               weightRingCommandForOthers: weightRingCommandForOthers,
                               orientation: orientation)
        
        //selectedJiggle.currentHashPoly.triangulationType = .none
        //selectedJiggle.currentHashTrianglesWeights.polyHash.triangulationType = .none
        //selectedJiggle.currentHashTrianglesStandard.polyHash.triangulationType = .none
        
        _grabWeightControlPointData.endX = pointX
        _grabWeightControlPointData.endY = pointY
        if !isFromRelease {
            _grabWeightControlPointData.didChange = true
        }
    }
    
    func attemptReleaseWeightControlPoint(touch: UITouch, at point: Point) {
        if touch == selectedWeightControlPointTouch {
            killDragAll()
        }
    }
 
    
    func attemptSelectJiggleWeightRing(at point: Point,
                                       displayMode: DisplayMode,
                                       isGraphEnabled: Bool) {
        
        let selectJiggleWeightRingThreshold = Device.isPad ? Float(44.0) : Float(32.0)
        let selectJiggleWeightRingThresholdSquared = selectJiggleWeightRingThreshold * selectJiggleWeightRingThreshold
        
        var currentSelectedJiggleIndex = -1
        var currentSelectedWeightRingIndex = -1
        
        //
        // First try to pick the ring closest to the point...
        // This seems to make the most sense...
        //
        var bestDistance = selectJiggleWeightRingThresholdSquared
        for jiggleIndex in 0..<jiggleCount {
            let jiggle = jiggles[jiggleIndex]
            if jiggle.isFrozen == false {
                for jiggleWeightRingIndex in 0..<jiggle.jiggleWeightRingCount {
                    let jiggleWeightRing = jiggle.jiggleWeightRings[jiggleWeightRingIndex]
                    if jiggleWeightRing.isFrozen == false {
                        let distanceSquared = jiggleWeightRing.outlineDistanceSquaredToPoint(point)
                        if distanceSquared < bestDistance {
                            currentSelectedJiggleIndex = jiggleIndex
                            currentSelectedWeightRingIndex = jiggleWeightRingIndex
                            bestDistance = distanceSquared
                        }
                    }
                }
            }
        }
        
        //
        // Maybe we missed the selection; In this case, see if we
        // are "inside" any of the weight rings...
        //
        if currentSelectedWeightRingIndex == -1 {
            bestDistance = (100_000.0 * 100_000.0)
            for jiggleIndex in 0..<jiggleCount {
                let jiggle = jiggles[jiggleIndex]
                if jiggle.isFrozen == false {
                    for jiggleWeightRingIndex in 0..<jiggle.jiggleWeightRingCount {
                        let jiggleWeightRing = jiggle.jiggleWeightRings[jiggleWeightRingIndex]
                        if jiggleWeightRing.isFrozen == false {
                            if jiggleWeightRing.outlineContainsPoint(point) {
                                let distanceSquared = jiggleWeightRing.outlineDistanceSquaredToPoint(point)
                                if distanceSquared < bestDistance {
                                    currentSelectedJiggleIndex = jiggleIndex
                                    currentSelectedWeightRingIndex = jiggleWeightRingIndex
                                    bestDistance = distanceSquared
                                }
                            }
                        }
                    }
                }
            }
        }
        
        
        if currentSelectedWeightRingIndex == -1 {
            //
            // Maybe we missed the selection; In this case, let's
            // use the default behavior, which may select a jiggle.
            //
            attemptSelectJiggleWeightModeDefaultCase(at: point,
                                                     displayMode: displayMode,
                                                     isGraphEnabled: isGraphEnabled)
            
        } else {
            //
            // Maybe we made the selection; In this case, let's
            // tell the world and update the visual appropriately.
            //
            let selectedJiggle = jiggles[currentSelectedJiggleIndex]
            selectedJiggle.switchSelectedWeightCurveControlIndex(index: currentSelectedWeightRingIndex + 1)
            switchSelectedJiggle(newSelectedJiggleIndex: currentSelectedJiggleIndex,
                                 displayMode: displayMode,
                                 isGraphEnabled: isGraphEnabled)
        }
    }
    
    func getIndexOfJiggleToGrab(at point: Point) -> Int {
        let selectJiggleThreshold = Device.isPad ? Float(44.0) : Float(32.0)
        let selectJiggleThresholdSquared = selectJiggleThreshold * selectJiggleThreshold
        var result = -1
        var jiggleIndex = jiggleCount - 1
        while jiggleIndex >= 0 {
            let jiggle = jiggles[jiggleIndex]
            if jiggle.outlineContainsPoint(point) {
                result = jiggleIndex
                break
            }
            jiggleIndex -= 1
        }
        
        if result == -1 {
            var bestDistance = selectJiggleThresholdSquared
            jiggleIndex = 0
            while jiggleIndex < jiggleCount {
                let jiggle = jiggles[jiggleIndex]
                
                let distanceSquared = jiggle.outlineDistanceSquaredToPoint(point)
                if distanceSquared < bestDistance {
                    result = jiggleIndex
                    bestDistance = distanceSquared
                }
                jiggleIndex += 1
            }
        }
        return result
    }
    
    func getIndexOfJiggleToSelect(at point: Point) -> Int {
        let selectJiggleThreshold = Device.isPad ? Float(44.0) : Float(32.0)
        let selectJiggleThresholdSquared = selectJiggleThreshold * selectJiggleThreshold
        var result = -1
        var jiggleIndex = jiggleCount - 1
        while jiggleIndex >= 0 {
            let jiggle = jiggles[jiggleIndex]
            if jiggle.isFrozen == false {
                if jiggle.outlineContainsPoint(point) {
                    result = jiggleIndex
                    break
                }
            }
            jiggleIndex -= 1
        }
        
        if result == -1 {
            var bestDistance = selectJiggleThresholdSquared
            jiggleIndex = 0
            while jiggleIndex < jiggleCount {
                let jiggle = jiggles[jiggleIndex]
                if jiggle.isFrozen == false {
                    let distanceSquared = jiggle.outlineDistanceSquaredToPoint(point)
                    if distanceSquared < bestDistance {
                        result = jiggleIndex
                        bestDistance = distanceSquared
                    }
                }
                jiggleIndex += 1
            }
        }
        return result
    }
    
    func attemptSelectJiggle(at point: Point,
                             displayMode: DisplayMode,
                             isGraphEnabled: Bool) {
        let currentSelectedJiggleIndex = getIndexOfJiggleToSelect(at: point)
        switchSelectedJiggle(newSelectedJiggleIndex: currentSelectedJiggleIndex,
                             displayMode: displayMode,
                             isGraphEnabled: isGraphEnabled)
    }
    
    func attemptSelectJiggleWeightModeDefaultCase(at point: Point,
                                                  displayMode: DisplayMode,
                                                  isGraphEnabled: Bool) {
        let currentSelectedJiggleIndex = getIndexOfJiggleToSelect(at: point)
        if let selectedJiggle = getJiggle(currentSelectedJiggleIndex) {
            
            let distanceSquaredToOutline = selectedJiggle.outlineDistanceSquaredToPoint(point)
            let distanceSquaredToWeightCenter = selectedJiggle.guideCenterDistanceSquaredToPoint(point)
            
            var bestWeightRingIndex = -1
            var bestDistanceToWeightRing = Float(100_000.0 * 100_000.0)
            for jiggleWeightRingIndex in 0..<selectedJiggle.jiggleWeightRingCount {
                let jiggleWeightRing = selectedJiggle.jiggleWeightRings[jiggleWeightRingIndex]
                
                if jiggleWeightRing.isFrozen == false {
                    let distanceSquared = jiggleWeightRing.outlineDistanceSquaredToPoint(point)
                    if distanceSquared < bestDistanceToWeightRing {
                        bestWeightRingIndex = jiggleWeightRingIndex
                        bestDistanceToWeightRing = distanceSquared
                    }
                }
            }
            
            let selectedIndex: Int
            if (bestDistanceToWeightRing <= distanceSquaredToWeightCenter) && (bestDistanceToWeightRing <= distanceSquaredToOutline) {
                selectedIndex = bestWeightRingIndex + 1
            } else if distanceSquaredToWeightCenter <= distanceSquaredToOutline {
                selectedIndex = (selectedJiggle.jiggleWeightRingCount + 1)
            } else {
                selectedIndex = 0
            }
            selectedJiggle.switchSelectedWeightCurveControlIndex(index: selectedIndex)
        }
        switchSelectedJiggle(newSelectedJiggleIndex: currentSelectedJiggleIndex,
                             displayMode: displayMode,
                             isGraphEnabled: isGraphEnabled)
    }
    
    func setCreatorMode(_ creatorMode: CreatorMode) {
        
        if self.creatorMode != creatorMode {
            self.creatorMode = creatorMode
            creatorModeUpdatePublisher.send(())
        }
    }
    
    func save(fileBuffer: FileBuffer) {
        
        fileBuffer.writeInt16(Int16(documentWidth))
        fileBuffer.writeInt16(Int16(documentHeight))
        
        fileBuffer.writeString(documentName)
        
        fileBuffer.writeBool(isWebScene)
        
        //fileBuffer.writeBool(isDemo) // We are always *not* a demo, if we saved...
        fileBuffer.writeBool(false)
        
        thumbCropFrame.save(fileBuffer: fileBuffer)

        fileBuffer.writeUInt16(UInt16(jiggleCount))
        for jiggleIndex in 0..<jiggleCount {
            let jiggle = jiggles[jiggleIndex]
            jiggle.save(fileBuffer: fileBuffer)
        }

    }
    
    func load(fileBuffer: FileBuffer) -> Bool {
        
        clear()
        
        let _documentWidth = Int(fileBuffer.readInt16() ?? 0)
        if _documentWidth < 64 || _documentWidth > 20_000 {
            print("Illegal Document, Read \(_documentWidth) Width")
            return false
        }
        let _documentHeight = Int(fileBuffer.readInt16() ?? 0)
        if _documentHeight < 64 || _documentWidth > 20_000 {
            print("Illegal Document, Read \(_documentHeight) Height")
            return false
        }
        
        documentWidth = _documentWidth
        documentHeight = _documentHeight
        
        print("Loaded, documentSize = [\(documentWidth) x \(documentHeight)]")
        
        if let _documentName = fileBuffer.readString() {
            documentName = _documentName
        }
        
        isWebScene = fileBuffer.readBool() ?? false
        isDemo = fileBuffer.readBool() ?? false
        
        thumbCropFrame.load(fileBuffer: fileBuffer)
        
        let _jiggleCount = Int(fileBuffer.readUInt16() ?? 0)
        if _jiggleCount > JiggleDocument.maxJiggleCount {
            print("Illegal Document, Read \(_jiggleCount) Jiggles, of Max \(JiggleDocument.maxJiggleCount)")
            return false
        }
        
        //let worldScale = getWorldScale()
        
        let _jiggleCount1 = _jiggleCount - 1
        
        for jiggleIndex in 0..<_jiggleCount {
        
            let newJiggle = JigglePartsFactory.shared.withdrawJiggle()
            //newJiggle.load(jiggleEngine: jiggleEngine)
            if !newJiggle.load(fileBuffer: fileBuffer,
                               isSelected: (jiggleIndex == _jiggleCount1)) {
                return false
            }
            addJiggleFromLoad(newJiggle)
            
        }

        return true
    }
        
}

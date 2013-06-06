//
//  MainSegmentedControlView.h
//  RotationAnimationError
//
//  Created by Angelika Ophagen on 27.05.13.
//  Copyright (c) 2013 Dornheim Medical Images. All rights reserved.
//

#import <CoconutKit/CoconutKit.h>

// Forward declarations
@protocol MainSegmentedControlViewDelegate;

@interface MainSegmentedControlView : HLSViewController

@property (nonatomic, assign) IBOutlet id<MainSegmentedControlViewDelegate> delegate;

@end

@protocol MainSegmentedControlViewDelegate <NSObject>
@required

/**
 * Called when the user has changed the value of the segmented control
 */
- (void)valueHasChangedToIndex:(NSInteger)index;

@end

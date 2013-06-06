//
//  MainPlaceholderViewController.m
//  RotationAnimationError
//
//  Created by Angelika Ophagen on 22.05.13.
//  Copyright (c) 2013 Dornheim Medical Images. All rights reserved.
//

#import "MainSegmentedControlView.h"
#import "MainPlaceholderViewController.h"

@interface MainPlaceholderViewController ()

#define kMainStoryboardName @"MainStoryboard"
#define kTabOneStoryboardID @"FirstViewController"
#define kTabTwoStoryboardID @"SecondViewController"

@property (strong, nonatomic) MainSegmentedControlView *mainControls;
@property (weak, nonatomic) IBOutlet UIView *mainPlaceholderView;
@property (weak, nonatomic) IBOutlet UIView *mainControlsPlaceholderView;
@property (nonatomic) CGRect framePortraitMainPlaceholder;
@property (nonatomic) CGRect framePortraitControls;
@property (nonatomic) CGRect frameLandscapeMainPlaceholder;
@property (nonatomic) CGRect frameLandscapeControls;
@property (nonatomic) int animationCounter;

@end

@implementation MainPlaceholderViewController

@synthesize mainControls = m_mainControls;
@synthesize mainPlaceholderView = m_mainPlaceholderView;
@synthesize mainControlsPlaceholderView = m_mainControlsPlaceholderView;
@synthesize framePortraitMainPlaceholder = m_framePortraitMainPlaceholder;
@synthesize frameLandscapeMainPlaceholder = m_frameLandscapeMainPlaceholder;
@synthesize framePortraitControls = m_framePortraitControls;
@synthesize frameLandscapeControls = m_frameLandscapeControls;
@synthesize animationCounter = m_animationCounter;

- (int) animationCounter
{
    if (!m_animationCounter)
    {
        m_animationCounter = 0;
    }
    return m_animationCounter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setDelegate:self];
    // set the segmented controls view to the placeholder view at index 0
    [self setMainControls];
    // set the camera storyboard start view controllers view to the placeholder view at index 1
    [self setAutorotationMode:HLSAutorotationModeContainerAndTopChildren];
    UIStoryboard *aStoryboard = [UIStoryboard storyboardWithName:kMainStoryboardName bundle:[NSBundle mainBundle]];
    HLSViewController *firstViewController = [aStoryboard instantiateViewControllerWithIdentifier:kTabOneStoryboardID];
    [self setInsetViewController:firstViewController atIndex:1 withTransitionClass:[HLSTransitionCoverFromBottom class]];
    // set default values to differentiate between initial and saved values 
    [self setFramePortraitControls: CGRectMake(-1., -1., -1., -1.)];
    [self setFramePortraitMainPlaceholder: CGRectMake(-1., -1., -1., -1.)];
    [self setFrameLandscapeControls: CGRectMake(-1., -1., -1., -1.)];
    [self setFrameLandscapeMainPlaceholder: CGRectMake(-1., -1., -1., -1.)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setMainControls
{
    // We can even assign a transition animation. Since the view controller has been preloaded, it won't be played,
    // but it will later be used if we set the inset to nil
    [self setMainControls: [[MainSegmentedControlView alloc] init]];
    [[self mainControls] setDelegate:self];
    [self setInsetViewController:[self mainControls] atIndex:0 withTransitionClass:[HLSTransitionCoverFromBottom class]];
}

#pragma mark - MainSegmentedControlViewDelegate
- (void)valueHasChangedToIndex:(NSInteger)index
{
    /*
     0 == First
     1 == Second
     */
    switch (index) {
        case 0:
        {
            UIStoryboard *aStoryboard = [UIStoryboard storyboardWithName:kMainStoryboardName bundle:[NSBundle mainBundle]];
            HLSViewController *firstViewController = [aStoryboard instantiateViewControllerWithIdentifier:kTabOneStoryboardID];
            [self setInsetViewController:firstViewController atIndex:1 withTransitionClass:[HLSTransitionCoverFromBottom class]];
            break;
        }
        case 1:
        {
            UIStoryboard *aStoryboard = [UIStoryboard storyboardWithName:kMainStoryboardName bundle:[NSBundle mainBundle]];
            HLSViewController *secondViewController = [aStoryboard instantiateViewControllerWithIdentifier:kTabTwoStoryboardID];
            [self setInsetViewController:secondViewController atIndex:1 withTransitionClass:[HLSTransitionCoverFromBottom class]];
            break;
        }
        default:
        {
            HLSLoggerFatal(@"Not a valid segmented control index: %f", index);
            break;
        }
    }
}

# pragma mark - orientation management

- (BOOL)shouldAutorotate
{
    return [self animationCounter] == 0;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // the frames are not touched yet - get the frames before orientation change
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (currentOrientation == UIInterfaceOrientationPortrait)
    {
        if ([self framePortraitControls].origin.x < 0.0f)
        {
            [self setFramePortraitControls: [[self placeholderViewAtIndex:0] frame]];
        }
        if ([self framePortraitMainPlaceholder].origin.x < 0.0f)
        {
            [self setFramePortraitMainPlaceholder: [[self placeholderViewAtIndex:1] frame]];
        }
    }
    if (currentOrientation == UIInterfaceOrientationLandscapeLeft || currentOrientation == UIInterfaceOrientationLandscapeRight)
    {
        if ([self frameLandscapeControls].origin.x < 0.0f)
        {
            [self setFrameLandscapeControls: [[self placeholderViewAtIndex:0] frame]];
        }
        if ([self frameLandscapeMainPlaceholder].origin.x < 0.0f)
        {
            [self setFrameLandscapeMainPlaceholder: [[self placeholderViewAtIndex:1] frame]];
        }
    }
    
    [[self insetViewControllerAtIndex:0] willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [[self insetViewControllerAtIndex:1] willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [[self insetViewControllerAtIndex:0] didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [[self insetViewControllerAtIndex:1] didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [[self insetViewControllerAtIndex:0] willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [[self insetViewControllerAtIndex:1] willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // the frames are finalized - get the frames after orientation
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait)
    {
        if ([self framePortraitControls].origin.x < 0.0f)
        {
            [self setFramePortraitControls: [[self placeholderViewAtIndex:0] frame]];
        }
        if ([self framePortraitMainPlaceholder].origin.x < 0.0f)
        {
            [self setFramePortraitMainPlaceholder: [[self placeholderViewAtIndex:1] frame]];
        }
    }
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        if ([self frameLandscapeControls].origin.x < 0.0f)
        {
            [self setFrameLandscapeControls: [[self placeholderViewAtIndex:0] frame]];
        }
        if ([self frameLandscapeMainPlaceholder].origin.x < 0.0f)
        {
            [self setFrameLandscapeMainPlaceholder: [[self placeholderViewAtIndex:1] frame]];
        }
    }
    
    [self hideShowMainControlsAnimationToOrientation: toInterfaceOrientation duration: duration];
    
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration: duration];
}

# pragma - mark ANIMATION

- (void) hideShowMainControlsAnimationToOrientation: (UIInterfaceOrientation) toOrientation duration:(NSTimeInterval)duration
{
    if (toOrientation == UIInterfaceOrientationPortrait)
    {
        HLSLoggerInfo(@"Portrait, controls old rect: x %f, y %f, width %f, height %f.",
                      [self framePortraitControls].origin.x,
                      [self framePortraitControls].origin.y+CGRectGetHeight([self framePortraitControls]),
                      CGRectGetWidth([self framePortraitControls]),
                      CGRectGetHeight([self framePortraitControls]));
        HLSLoggerInfo(@"Portrait, controls new rect: x %f, y %f, width %f, height %f.",
                      [self framePortraitControls].origin.x,
                      [self framePortraitControls].origin.y,
                      CGRectGetWidth([self framePortraitControls]),
                      CGRectGetHeight([self framePortraitControls]));
        
        //controls: old rect from saved rect but zero height and higher y-position
        CGRect oldControlsRectPortrait = CGRectMake([self framePortraitControls].origin.x,
                                                    [self framePortraitControls].origin.y+CGRectGetHeight([self framePortraitControls]),
                                                    CGRectGetWidth([self framePortraitControls]),
                                                    CGRectGetHeight([self framePortraitControls]));
        //controls: new rect is equal to saved rect
        CGRect newControlsRectPortrait = CGRectMake([self framePortraitControls].origin.x,
                                                    [self framePortraitControls].origin.y,
                                                    CGRectGetWidth([self framePortraitControls]),
                                                    CGRectGetHeight([self framePortraitControls]));
        
        
        HLSViewAnimation * controlsViewAnimationPortrait = [HLSViewAnimation animation];
        [controlsViewAnimationPortrait transformFromRect:oldControlsRectPortrait toRect:newControlsRectPortrait];
        
        HLSLoggerInfo(@"Portrait, main placeholder old rect: x %f, y %f, width %f, height %f.",
                      [self framePortraitMainPlaceholder].origin.x,
                      [self framePortraitMainPlaceholder].origin.y,
                      CGRectGetWidth([self framePortraitMainPlaceholder]),
                      CGRectGetHeight([self framePortraitMainPlaceholder])+CGRectGetHeight([self framePortraitControls]));
        HLSLoggerInfo(@"Portrait, main placeholder new rect: x %f, y %f, width %f, height %f.",
                      [self framePortraitMainPlaceholder].origin.x,
                      [self framePortraitMainPlaceholder].origin.y,
                      CGRectGetWidth([self framePortraitMainPlaceholder]),
                      CGRectGetHeight([self framePortraitMainPlaceholder]));
        
        //main placeholder: old rect from saved rect, but with added height of the controls
        CGRect oldMainRectPortrait = CGRectMake([self framePortraitMainPlaceholder].origin.x,
                                                [self framePortraitMainPlaceholder].origin.y,
                                                CGRectGetWidth([self framePortraitMainPlaceholder]),
                                                CGRectGetHeight([self framePortraitMainPlaceholder])+CGRectGetHeight([self framePortraitControls]));
        
        //main placeholder: new rect is equal to saved rect
        CGRect newMainRectPortrait = CGRectMake([self framePortraitMainPlaceholder].origin.x,
                                                [self framePortraitMainPlaceholder].origin.y,
                                                CGRectGetWidth([self framePortraitMainPlaceholder]),
                                                CGRectGetHeight([self framePortraitMainPlaceholder]));
        
        HLSViewAnimation * mainViewAnimationPortrait = [HLSViewAnimation animation];
        [mainViewAnimationPortrait transformFromRect:oldMainRectPortrait toRect:newMainRectPortrait];
        
        HLSViewAnimationStep * animationStepOnePortrait = [HLSViewAnimationStep animationStep];
        [animationStepOnePortrait setTag:@"RotatedToPortraitStep1"];
        [animationStepOnePortrait setDuration: duration];
        [animationStepOnePortrait addViewAnimation:controlsViewAnimationPortrait forView:[self placeholderViewAtIndex:0]];
        [animationStepOnePortrait addViewAnimation:mainViewAnimationPortrait forView:[self placeholderViewAtIndex:1]];
        HLSAnimation *thePortraitAnimation = [HLSAnimation animationWithAnimationStep:animationStepOnePortrait];
        [thePortraitAnimation setDelegate:self];
        [thePortraitAnimation playAnimated:YES];
    }
    
    
    if (toOrientation == UIInterfaceOrientationLandscapeLeft || toOrientation == UIInterfaceOrientationLandscapeRight)
    {
        HLSLoggerInfo(@"Landscape, controls old rect: x %f, y %f, width %f, height %f.",
                      [self frameLandscapeControls].origin.x,
                      [self frameLandscapeControls].origin.y,
                      CGRectGetWidth([self frameLandscapeControls]),
                      CGRectGetHeight([self frameLandscapeControls]));
        HLSLoggerInfo(@"Landscape, controls new rect: x %f, y %f, width %f, height %f.",
                      [self frameLandscapeControls].origin.x,
                      [self frameLandscapeControls].origin.y+CGRectGetHeight([self frameLandscapeControls]),
                      CGRectGetWidth([self frameLandscapeControls]),
                      CGRectGetHeight([self frameLandscapeControls]));
        
        //controls: old rect from saved rect
        CGRect oldControlsRectLandscape = CGRectMake([self frameLandscapeControls].origin.x,
                                                     [self frameLandscapeControls].origin.y,
                                                     CGRectGetWidth([self frameLandscapeControls]),
                                                     CGRectGetHeight([self frameLandscapeControls]));
        //controls: new rect has zero height + the y-coordinate is plus the height of the old rect
        CGRect newControlsRectLandscape = CGRectMake([self frameLandscapeControls].origin.x,
                                                     [self frameLandscapeControls].origin.y+CGRectGetHeight([self frameLandscapeControls]),
                                                     CGRectGetWidth([self frameLandscapeControls]),
                                                     CGRectGetHeight([self frameLandscapeControls]));
        
        HLSViewAnimation * controlsViewAnimationLandscape = [HLSViewAnimation animation];
        [controlsViewAnimationLandscape transformFromRect:oldControlsRectLandscape toRect:newControlsRectLandscape];
        
        HLSLoggerInfo(@"Landscape, main placeholder old rect: x %f, y %f, width %f, height %f.",
                      [self frameLandscapeMainPlaceholder].origin.x,
                      [self frameLandscapeMainPlaceholder].origin.y,
                      CGRectGetWidth([self frameLandscapeMainPlaceholder]),
                      CGRectGetHeight([self frameLandscapeMainPlaceholder]));
        HLSLoggerInfo(@"Landscape, main placeholder new rect: x %f, y %f, width %f, height %f.",
                      [self frameLandscapeMainPlaceholder].origin.x,
                      [self frameLandscapeMainPlaceholder].origin.y,
                      CGRectGetWidth([self frameLandscapeMainPlaceholder]),
                      CGRectGetHeight([self frameLandscapeMainPlaceholder])+CGRectGetHeight([self frameLandscapeControls]));
        
        //main placeholder: old rect has been saved
        CGRect oldMainRectLandscape = CGRectMake([self frameLandscapeMainPlaceholder].origin.x,
                                                 [self frameLandscapeMainPlaceholder].origin.y,
                                                 CGRectGetWidth([self frameLandscapeMainPlaceholder]),
                                                 CGRectGetHeight([self frameLandscapeMainPlaceholder]));
        
        //main placeholder: new rect needs to be longer by the height of the controls
        CGRect newMainRectLandscape = CGRectMake([self frameLandscapeMainPlaceholder].origin.x,
                                                 [self frameLandscapeMainPlaceholder].origin.y,
                                                 CGRectGetWidth([self frameLandscapeMainPlaceholder]),
                                                 CGRectGetHeight([self frameLandscapeMainPlaceholder])+CGRectGetHeight([self frameLandscapeControls]));
        
        HLSViewAnimation * mainViewAnimationLandscape = [HLSViewAnimation animation];
        [mainViewAnimationLandscape transformFromRect:oldMainRectLandscape toRect:newMainRectLandscape];
        
        HLSViewAnimationStep * animationStepOneLandscape = [HLSViewAnimationStep animationStep];
        [animationStepOneLandscape setTag:@"RotatedToLandscapeStep1"];
        [animationStepOneLandscape setDuration:duration];
        [animationStepOneLandscape addViewAnimation:controlsViewAnimationLandscape forView:[self placeholderViewAtIndex:0]];
        [animationStepOneLandscape addViewAnimation:mainViewAnimationLandscape forView:[self placeholderViewAtIndex:1]];
        HLSAnimation *theLandscapeAnimation = [HLSAnimation animationWithAnimationStep:animationStepOneLandscape];
        [theLandscapeAnimation setDelegate:self];
        [theLandscapeAnimation playAnimated:YES];
    }
}
# pragma mark - HLSAnimationDelegate

/**
 * Called right before the first animation step is executed, but after any delay which might have been set
 */
- (void)animationWillStart:(HLSAnimation *)animation animated:(BOOL)animated
{
    [self setAnimationCounter:[self animationCounter]+1];
}

/**
 * Called right after the last animation step has been executed. You can check -terminating or -cancelling
 * to find if the animation ended normally
 */
- (void)animationDidStop:(HLSAnimation *)animation animated:(BOOL)animated
{
    [self setAnimationCounter:[self animationCounter]-1];
}

/**
 * Called when a step has been executed. Since animation steps are deeply copied when assigned to an animation,
 * you must not use animation step pointers to identify animation steps when implementing this method. Use
 * animation step tags instead
 */
- (void)animation:(HLSAnimation *)animation didFinishStep:(HLSAnimationStep *)animationStep animated:(BOOL)animated
{
    HLSLoggerDebug(@"Animation step done: %@", [animationStep tag]);
}

@end
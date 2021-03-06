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
@property (strong, nonatomic) HLSAnimation *theAnimation;
@property (strong, nonatomic) HLSAnimation *theReverseAnimation;
@property (nonatomic) BOOL hasAnimatedToLandscape;
@property (nonatomic) int animationCounter;

@end

@implementation MainPlaceholderViewController

@synthesize mainControls = m_mainControls;
@synthesize mainPlaceholderView = m_mainPlaceholderView;
@synthesize mainControlsPlaceholderView = m_mainControlsPlaceholderView;
@synthesize theAnimation = m_theAnimation;
@synthesize theReverseAnimation = m_theReverseAnimation;
@synthesize hasAnimatedToLandscape = m_hasAnimatedToLandscape;
@synthesize animationCounter = m_animationCounter;

- (int) animationCounter
{
    if (!m_animationCounter)
    {
        m_animationCounter = 0;
    }
    return m_animationCounter;
}

- (HLSAnimation *) theReverseAnimation
{
    if (m_theReverseAnimation)
    {
        return m_theReverseAnimation;
    }
    
    if ([self theAnimation])
    {
        m_theReverseAnimation = [[self theAnimation] reverseAnimation];
        return m_theReverseAnimation;
    }
    return nil;
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
    [[self insetViewControllerAtIndex:0] willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [[self insetViewControllerAtIndex:1] willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self hideControlsAnimateToLandscapeOrientation:toInterfaceOrientation duration:duration];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self showControlsAnimateToPortrait: [[UIApplication sharedApplication] statusBarOrientation]];
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [[self insetViewControllerAtIndex:0] didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [[self insetViewControllerAtIndex:1] didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [[self insetViewControllerAtIndex:0] willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [[self insetViewControllerAtIndex:1] willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration: duration];
}

# pragma - mark ANIMATION

- (void) showControlsAnimateToPortrait: (UIInterfaceOrientation) toOrientation
{
    if (toOrientation == UIInterfaceOrientationPortrait)
    {
        if ([self theReverseAnimation])
        {
            [self setHasAnimatedToLandscape:NO];
            [[self theReverseAnimation] playAnimated:YES];
        }
    }
}

- (void) hideControlsAnimateToLandscapeOrientation: (UIInterfaceOrientation) toOrientation duration:(NSTimeInterval)duration
{
    if (toOrientation == UIInterfaceOrientationLandscapeLeft || toOrientation == UIInterfaceOrientationLandscapeRight)
    {
        if ([self theAnimation])
        {
            if (![self hasAnimatedToLandscape])
            {
                [self setHasAnimatedToLandscape:YES];
                [[self theAnimation] playAnimated:YES];
            }
            return;
        }
        
        HLSLoggerInfo(@"Landscape, controls old rect: x %f, y %f, width %f, height %f.",
                      [[self mainControlsPlaceholderView] frame].origin.x,
                      [[self mainControlsPlaceholderView] frame].origin.y,
                      CGRectGetWidth([[self mainControlsPlaceholderView] frame]),
                      CGRectGetHeight([[self mainControlsPlaceholderView] frame]));
        HLSLoggerInfo(@"Landscape, controls new rect: x %f, y %f, width %f, height %f.",
                      [[self mainControlsPlaceholderView] frame]].origin.x,
                      [[self mainControlsPlaceholderView] frame].origin.y+CGRectGetHeight([[self mainControlsPlaceholderView] frame]),
                      CGRectGetWidth([[self mainControlsPlaceholderView] frame]),
                      CGRectGetHeight([[self mainControlsPlaceholderView] frame]));
        
        //controls: old rect from saved rect
        CGRect oldControlsRectLandscape = CGRectMake([[self mainControlsPlaceholderView] frame].origin.x,
                                                     [[self mainControlsPlaceholderView] frame].origin.y,
                                                     CGRectGetWidth([[self mainControlsPlaceholderView] frame]),
                                                     CGRectGetHeight([[self mainControlsPlaceholderView] frame]));
        //controls: new rect has zero height + the y-coordinate is plus the height of the old rect
        CGRect newControlsRectLandscape = CGRectMake([[self mainControlsPlaceholderView] frame].origin.x,
                                                     [[self mainControlsPlaceholderView] frame].origin.y+CGRectGetHeight([[self mainControlsPlaceholderView] frame]),
                                                     CGRectGetWidth([[self mainControlsPlaceholderView] frame]),
                                                     CGRectGetHeight([[self mainControlsPlaceholderView] frame]));
        
        HLSViewAnimation * controlsViewAnimationLandscape = [HLSViewAnimation animation];
        [controlsViewAnimationLandscape transformFromRect:oldControlsRectLandscape toRect:newControlsRectLandscape];
        
        HLSLoggerInfo(@"Landscape, main placeholder old rect: x %f, y %f, width %f, height %f.",
                      [[self mainPlaceholderView] frame].origin.x,
                      [[self mainPlaceholderView] frame].origin.y,
                      CGRectGetWidth([[self mainPlaceholderView] frame]),
                      CGRectGetHeight([[self mainPlaceholderView] frame]));
        HLSLoggerInfo(@"Landscape, main placeholder new rect: x %f, y %f, width %f, height %f.",
                      [[self mainPlaceholderView] frame].origin.x,
                      [[self mainPlaceholderView] frame].origin.y,
                      CGRectGetWidth([[self mainPlaceholderView] frame]),
                      CGRectGetHeight([[self mainPlaceholderView] frame])+CGRectGetHeight([[self mainControlsPlaceholderView] frame]));
        
        //main placeholder: old rect has been saved
        CGRect oldMainRectLandscape = CGRectMake([[self mainPlaceholderView] frame].origin.x,
                                                 [[self mainPlaceholderView] frame].origin.y,
                                                 CGRectGetWidth([[self mainPlaceholderView] frame]),
                                                 CGRectGetHeight([[self mainPlaceholderView] frame]));
        
        //main placeholder: new rect needs to be longer by the height of the controls
        CGRect newMainRectLandscape = CGRectMake([[self mainPlaceholderView] frame].origin.x,
                                                 [[self mainPlaceholderView] frame].origin.y,
                                                 CGRectGetWidth([[self mainPlaceholderView] frame]),
                                                 CGRectGetHeight([[self mainPlaceholderView] frame])+CGRectGetHeight([[self mainControlsPlaceholderView] frame]));
        
        HLSViewAnimation * mainViewAnimationLandscape = [HLSViewAnimation animation];
        [mainViewAnimationLandscape transformFromRect:oldMainRectLandscape toRect:newMainRectLandscape];
        
        HLSViewAnimationStep * animationStepOneLandscape = [HLSViewAnimationStep animationStep];
        [animationStepOneLandscape setTag:@"RotatedToLandscapeStep1"];
        [animationStepOneLandscape setDuration:duration];
        [animationStepOneLandscape addViewAnimation:controlsViewAnimationLandscape forView:[self placeholderViewAtIndex:0]];
        [animationStepOneLandscape addViewAnimation:mainViewAnimationLandscape forView:[self placeholderViewAtIndex:1]];
        [self setTheAnimation:[HLSAnimation animationWithAnimationStep:animationStepOneLandscape]];
        [[self theAnimation] setDelegate:self];
        [self setTheReverseAnimation:[[self theAnimation] reverseAnimation]];
        [self setHasAnimatedToLandscape:YES];
        [[self theAnimation] playAnimated:YES];
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
//
//  MainSegmentedControlView.m
//  RotationAnimationError
//
//  Created by Angelika Ophagen on 27.05.13.
//  Copyright (c) 2013 Dornheim Medical Images. All rights reserved.
//

#import "MainSegmentedControlView.h"

@interface MainSegmentedControlView ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *tabSelector;
- (IBAction)selectTab:(UISegmentedControl *)sender;

@end

@implementation MainSegmentedControlView

@synthesize tabSelector;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectTab:(UISegmentedControl *)sender
{
    if ([self delegate])
    {
        if ([[self delegate] respondsToSelector:@selector(valueHasChangedToIndex:)])
        {
            [[self delegate] valueHasChangedToIndex:[sender selectedSegmentIndex]];
        }
    }
}

#pragma mark - orientation management

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

@end

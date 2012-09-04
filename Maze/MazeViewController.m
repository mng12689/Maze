//
//  MazeViewController.m
//  Maze
//
//  Created by Michael Ng on 9/3/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import "MazeViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "MazeView.h"

@interface MazeViewController () <MazeViewDelegate, UIAlertViewDelegate>
@property CGPoint ballLocation;

@property (strong) CMMotionManager *motionManager;
@property (strong) NSTimer *timer;
@property (weak) MazeView *mazeView;

@end

@implementation MazeViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.motionManager = [CMMotionManager new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self resetGame];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"view appear!");
    [self.motionManager startDeviceMotionUpdates];
    //[self resetGame];
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"view disappear!");
    [self.motionManager stopDeviceMotionUpdates];
    [self.timer invalidate];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)updateBallPosition
{
    double pitch = [[self.motionManager deviceMotion] attitude].pitch;
    double roll = [[self.motionManager deviceMotion] attitude].roll;
    self.mazeView.ballLocation = self.ballLocation;
    [self.mazeView moveBallWithPitch:pitch andRoll:roll];
    self.ballLocation = self.mazeView.ballLocation;
}

-(void)playerDidWin
{
    [self.timer invalidate];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You win!" message:@"Good job!" delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles:nil];
    alert.delegate = self;
    [alert show];
}

-(void)resetGame {
    MazeView *mazeView = [[MazeView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    mazeView.delegate = self;
    self.view = mazeView;
    self.mazeView = mazeView;
    self.ballLocation = self.mazeView.ballLocation;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(updateBallPosition) userInfo:nil repeats:YES];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self resetGame];
}

@end

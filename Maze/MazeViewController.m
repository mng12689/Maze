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

@interface MazeViewController () <MazeViewDelegate>
@property CGPoint ballLocation;

@property (strong) CMMotionManager *motionManager;
@property (strong) NSTimer *timer;
@property (weak) MazeView *mazeView;
//@property (strong) BallView *ball;

@end

@implementation MazeViewController
-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    [self.mazeView createWalls];
    self.ballLocation = CGPointMake((arc4random() %(300-20))+20, (arc4random() %(460-20))+20);

}


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
    //self.ball = [[BallView alloc]initWithFrame:CGRectMake((arc4random() %(300-20))+20, (arc4random() %(460-20))+20, 40, 40)];
    //[self.view addSubview:self.ball];
    MazeView *mazeView = [[MazeView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    mazeView.delegate = self;
    self.view = mazeView;
    self.mazeView = mazeView;
    self.ballLocation = CGPointMake((arc4random() %(300-20))+20, (arc4random() %(460-20))+20);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [self.motionManager startDeviceMotionUpdates];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(updateBallPosition) userInfo:nil repeats:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
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
    //NSLog(@"Pitch: %f",[[self.motionManager deviceMotion] attitude].pitch);
    //NSLog(@"Roll: %f",[[self.motionManager deviceMotion] attitude].roll);
    self.mazeView.ballLocation = self.ballLocation;
    [self.mazeView moveBallWithPitch:pitch andRoll:roll];
    self.ballLocation = self.mazeView.ballLocation;
}

-(void)playerDidWin
{
    [self.timer invalidate];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You win!" message:@"Good job!" delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles:nil];
    [alert show];
}

@end

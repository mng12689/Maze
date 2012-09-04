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
#import <GameKit/GameKit.h>

@interface MazeViewController () <MazeViewDelegate, UIAlertViewDelegate, GKSessionDelegate>
@property CGPoint ballLocation;
@property CGPoint enemyLocation;

@property (strong) CMMotionManager *motionManager;
@property (strong) NSTimer *timer;
@property (weak) MazeView *mazeView;
@property (strong) GKSession *session;

@end

@implementation MazeViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.session = [[GKSession alloc]initWithSessionID:@"ManeeshMaze" displayName:@"Maneesh" sessionMode:GKSessionModePeer];
        [self.session setDataReceiveHandler:self withContext:nil];
        self.session.delegate = self;
        self.session.available = YES;
        
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
    [self sendData];
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

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    [self.session acceptConnectionFromPeer:peerID error:nil];
    self.session.available = NO;
    NSLog(@"Connection accepted");
}

-(void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    if (state == GKPeerStateAvailable) {
        NSLog(@"found peer");
        [self.session connectToPeer:peerID withTimeout:2];
    } else if (state == GKPeerStateConnected) {
        NSLog(@"connected");
        session.available = NO;
    }
    
}

-(void)receiveData:(NSData*)data fromPeer:(NSString*)peer inSession:(GKSession*)session context:(void*)context
{
    self.enemyLocation = CGPointFromString([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    self.mazeView.enemyLocation = self.enemyLocation;
    [self.mazeView setNeedsDisplay];
    
}

-(void)sendData
{
    NSData *payload =  [NSStringFromCGPoint(self.ballLocation) dataUsingEncoding:NSUTF8StringEncoding];
    [self.session sendDataToAllPeers:payload withDataMode:GKSendDataReliable error:nil];
}

@end

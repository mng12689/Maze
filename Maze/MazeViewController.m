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
@property BOOL primary;

@property (strong) CMMotionManager *motionManager;
//@property (strong) NSTimer *timer;
@property (weak) MazeView *mazeView;
@property (strong) GKSession *session;

@end

@implementation MazeViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.session = [[GKSession alloc]initWithSessionID:@"ManeeshMaze" displayName:@"Mike" sessionMode:GKSessionModePeer];
        [self.session setDataReceiveHandler:self withContext:nil];
        self.session.delegate = self;
        self.session.available = YES;
        
        self.motionManager = [CMMotionManager new];
        self.motionManager.deviceMotionUpdateInterval = .01;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    
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
    //[self.timer invalidate];
    [self.motionManager stopDeviceMotionUpdates];
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
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]  withHandler:^(CMDeviceMotion *motion, NSError *error) {
        [self updateBallPosition];
    }];
    [self sendMap];
}

-(void)resetGameAsReceiver {
    MazeView *mazeView = [[MazeView alloc] initAsReceiver];
    mazeView.delegate = self;
    self.view = mazeView;
    self.mazeView = mazeView;
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]  withHandler:^(CMDeviceMotion *motion, NSError *error) {
        [self updateBallPosition];
    }];

}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (self.primary) {
        [self resetGame];
    }
    else{
        [self resetGameAsReceiver];
    }
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    //NSLog(@"connection requested");
    [self.session acceptConnectionFromPeer:peerID error:nil];
    self.session.available = NO;
    //NSLog(@"Connection accepted");
    self.primary = YES;
}

-(void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    if (state == GKPeerStateAvailable) {
        //NSLog(@"Connecting to peer: %@\n", peerID);
        
        [self.session connectToPeer:peerID withTimeout:2];
        //NSLog(@"after peer connect");
    } else if (state == GKPeerStateConnected) {
        //NSLog(@"connected");
        self.session.available = NO;
        if (self.primary) {
            [self resetGame];
        } else {
            [self resetGameAsReceiver];
        }
    } else if (state == GKPeerStateDisconnected) {
        self.session.available = YES;
    }
}

-(void)receiveData:(NSData*)data fromPeer:(NSString*)peer inSession:(GKSession*)session context:(void*)context
{
    id received = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if ([received isKindOfClass:[NSMutableArray class]]) {
        //NSLog(@"walls received");
        //NSLog(@"recieved is %@", received);
        //NSLog(@"mazeview is %@", self.mazeView);
        self.mazeView.walls = (NSMutableArray *)received;
        //NSLog(@"walls are %@", self.mazeView.walls);
        [self.mazeView placeBall];
        self.ballLocation = self.mazeView.ballLocation;
    } else if ([received isKindOfClass:[NSString class]]) {
       // NSLog(@"received location");
        self.enemyLocation = CGPointFromString(received);
        //NSLog(@"%f, %f", self.enemyLocation.x, self.enemyLocation.y);
        self.mazeView.enemyLocation = self.enemyLocation;
    };
    
}

-(void)sendMap {
    //encode self.mazeView.walls
    NSData *mapData = [NSKeyedArchiver archivedDataWithRootObject:self.mazeView.walls];
    [self.session sendDataToAllPeers:mapData withDataMode:GKSendDataReliable error:nil];
    //NSLog(@"map sent");
}

-(void)sendData
{
    NSData *payload =  [NSKeyedArchiver archivedDataWithRootObject:NSStringFromCGPoint(self.ballLocation)];
    [self.session sendDataToAllPeers:payload withDataMode:GKSendDataUnreliable error:nil];
    //NSLog(@"data sent!");
}

@end

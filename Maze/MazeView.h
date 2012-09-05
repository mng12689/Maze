//
//  MazeView.h
//  Maze
//
//  Created by Michael Ng on 9/3/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MazeView;

@protocol MazeViewDelegate <NSObject>
- (void) gameOverPlayerDidWin:(BOOL)won;
@end

@interface MazeView : UIView

@property id<MazeViewDelegate> delegate;
@property CGPoint ballLocation;
@property CGPoint enemyLocation;
@property (strong) NSMutableArray *walls;
-(void)moveBallWithPitch:(double)pitch andRoll:(double)roll;
-(void)createMaze;
-(void)placeBall;

@end

//
//  MazeView.m
//  Maze
//
//  Created by Michael Ng on 9/3/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import "MazeView.h"

@interface MazeView ()

@property (strong) NSMutableArray *walls;

@end

@implementation MazeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor blackColor];
        [self createWalls];
        
    }
    return self;
}

-(void)createWalls {
    self.walls = [NSMutableArray new];
    NSMutableArray *wallPoints = [NSMutableArray new];
    
    for (int i = 0; i< 20; i++) {
        CGPoint point = CGPointMake(arc4random() % 320, arc4random() % 480);
        [wallPoints addObject:[NSValue valueWithCGPoint:point]];
    }
    for (int i= 0; i< wallPoints.count; i=i+2) {
        CGPoint p1 = [[wallPoints objectAtIndex:i] CGPointValue];
        CGPoint p2 = [[wallPoints objectAtIndex:i+1] CGPointValue];
        if (arc4random() %2 ==0)  {
            [self.walls addObject:[NSValue valueWithCGRect:CGRectMake(p1.x, p1.y, 5, [self distanceFromLocation:p1 toLocation:p2])]];
        } else {
            [self.walls addObject:[NSValue valueWithCGRect:CGRectMake(p1.x, p1.y,[self distanceFromLocation:p1 toLocation:p2],5)]];
        }
    }
}
    
- (double) distanceFromLocation:(CGPoint)p1 toLocation:(CGPoint)p2
{
    CGFloat xDist = (p2.x - p1.x);
    CGFloat yDist = (p2.y - p1.y);
    return sqrt((xDist * xDist) + (yDist * yDist));
}
    
-(void)checkWin {
    CGRect winningLocation = CGRectMake(240, 400, 80, 80);
    if (CGRectContainsPoint(winningLocation, self.ballLocation)) {
        [self.delegate playerDidWin];
    }
}

-(void)moveBallWithPitch:(double)pitch andRoll:(double)roll {
    double updatedX = self.ballLocation.x + roll*20;
    double updatedY = self.ballLocation.y + pitch*20;
    
    if (updatedX < 20 || updatedX > 300) {
        updatedX = self.ballLocation.x;
    }
    if (updatedY < 20 || updatedY > 460) {
        updatedY = self.ballLocation.y;
    }
    
    for (NSValue *value in self.walls) {
        CGRect wall = [value CGRectValue];
        CGRect ballRect = CGRectMake(updatedX-20,updatedY-20,40,40);
        if (CGRectIntersectsRect(wall, ballRect)) {
            if (pitch > 0 && (CGRectGetMinY(ballRect) <= CGRectGetMaxY(wall)) && (CGRectGetMidX(ballRect) >= CGRectGetMinX(wall)) && (CGRectGetMidX(ballRect) <= CGRectGetMaxX(wall))){// && wall.size.height == 5) {
                NSLog(@"bottom of ball hits top of wall");
                updatedY = self.ballLocation.y;
            }
            if (pitch < 0 && (CGRectGetMaxY(ballRect) >= CGRectGetMinY(wall))&& (CGRectGetMidX(ballRect) >= CGRectGetMinX(wall)) && (CGRectGetMidX(ballRect) <= CGRectGetMaxX(wall))){// && wall.size.height == 5){
                NSLog(@"top of ball hits bottom of wall");
                updatedY = self.ballLocation.y;
            }
            if (roll < 0 && (CGRectGetMinX(ballRect) <= CGRectGetMaxX(wall))&& (CGRectGetMidY(ballRect) >= CGRectGetMinY(wall)) && (CGRectGetMidY(ballRect) <= CGRectGetMaxY(wall))){// && wall.size.width == 5){
                NSLog(@"left side of ball hits right side of wall");
                updatedX = self.ballLocation.x;
            }
            if (roll > 0 && (CGRectGetMaxX(ballRect) >= CGRectGetMinX(wall))&& (CGRectGetMidY(ballRect) >= CGRectGetMinY(wall)) && (CGRectGetMidY(ballRect) <= CGRectGetMaxY(wall))){// && wall.size.width == 5){
                NSLog(@"right side of ball hits left side of wall");
                updatedX = self.ballLocation.x;
            }
            /*if (wall.size.height == 5) {
                updatedY = self.ballLocation.y;
            }
            else{
                updatedX = self.ballLocation.x;
            }*/
        }
    }
    self.ballLocation = CGPointMake(updatedX, updatedY);
    
    //self.frame = CGRectMake(self.frame.origin.x + roll*20 ,self.frame.origin.y + pitch*20,40,40);
    [self checkWin];
    [self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context= UIGraphicsGetCurrentContext();
    
    [[UIColor redColor]set];
    CGContextMoveToPoint(context, self.ballLocation.x, self.ballLocation.y);
    CGContextAddArc(context,self.ballLocation.x , self.ballLocation.y, 20, 0, 2*M_PI, YES);
    //CGContextFillEllipseInRect(context, CGRectMake(self.ballLocation.x-20, self.ballLocation.y-20, self.ballLocation.x +20, self.ballLocation.y+20));
    CGContextFillPath(context);
    
    [[UIColor greenColor] set];
    //BOOL draw = YES;
    for (NSValue *value in self.walls) {
        CGContextFillRect(context, [value CGRectValue]);
        
    }
    
    [[UIColor blueColor] set];
    CGContextFillRect(context, CGRectMake(240, 400, 80, 80));
 
 
}


@end

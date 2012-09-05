//
//  MazeView.m
//  Maze
//
//  Created by Michael Ng on 9/3/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import "MazeView.h"

@interface MazeView ()
@end

@implementation MazeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

-(void)createMaze {
    self.walls = [NSMutableArray new];
    while (self.walls.count < 15) {
        CGRect wallCandidate;
        if (arc4random() %2 ==0)  {
            wallCandidate = CGRectMake(arc4random()%320, arc4random()%480, 5, arc4random()%50+60);
        } else {
            wallCandidate = CGRectMake(arc4random()%320, arc4random()%480,arc4random()%50+60,5);
        }
        BOOL intersects = NO;
        for (NSValue *val in self.walls) {
            CGRect bigRect = CGRectMake([val CGRectValue].origin.x-55, [val CGRectValue].origin.y-55, [val CGRectValue].size.width+90, [val CGRectValue].size.height+90);
            if (CGRectIntersectsRect(bigRect, wallCandidate)) {
                intersects = YES;
                break;
            }
        }
        if (!intersects) {
            [self.walls addObject:[NSValue valueWithCGRect:wallCandidate]];
        }
    }
}

-(void)placeBall {
    BOOL intersects = YES;
    while (intersects) {
        self.ballLocation = CGPointMake((arc4random() %(300-20))+20, (arc4random() %(460-20))+20);
        CGRect ballRect = CGRectMake(self.ballLocation.x-20, self.ballLocation.y-20, 40, 40);
        intersects = NO;
        for (NSValue *val in self.walls) {
            if (CGRectIntersectsRect([val CGRectValue], ballRect)) {
                intersects = YES;
                break;
            }
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
        [self.delegate gameOverPlayerDidWin:YES];
    }
    else if(CGRectContainsPoint(winningLocation, self.enemyLocation)) {
        [self.delegate gameOverPlayerDidWin:NO];
    }
}

-(void)moveBallWithPitch:(double)pitch andRoll:(double)roll {
    double updatedX = self.ballLocation.x + roll*5;
    double updatedY = self.ballLocation.y + pitch*5;
    
    if (updatedX < 20 || updatedX > 300) {
        updatedX = self.ballLocation.x;
    }
    if (updatedY < 20 || updatedY > 460) {
        updatedY = self.ballLocation.y;
    }
    
    for (NSValue *value in self.walls) {
        CGRect wall = [value CGRectValue];
        CGRect xMove = CGRectMake(updatedX-20, self.ballLocation.y-20, 40, 40);
        CGRect yMove = CGRectMake(self.ballLocation.x-20, updatedY-20, 40, 40);
        if (CGRectIntersectsRect(wall, xMove)) {
            updatedX = self.ballLocation.x;
        }
        if (CGRectIntersectsRect(wall, yMove)) {
            updatedY = self.ballLocation.y;
        }
    }
    self.ballLocation = CGPointMake(updatedX, updatedY);
    
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
    CGContextFillPath(context);
    
    [[UIColor greenColor]set];
    //NSLog(@"%f, %f", self.enemyLocation.x, self.enemyLocation.y);
    CGContextMoveToPoint(context, self.enemyLocation.x, self.enemyLocation.y);
    CGContextAddArc(context,self.enemyLocation.x , self.enemyLocation.y, 20, 0, 2*M_PI, YES);
    CGContextFillPath(context);
    
    [[UIColor greenColor] set];
    for (NSValue *value in self.walls) {
        CGContextFillRect(context, [value CGRectValue]);
        
    }
    
    [[UIColor blueColor] set];
    CGContextFillRect(context, CGRectMake(240, 400, 80, 80));
 
 
}


@end

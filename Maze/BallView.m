//
//  BallView.m
//  Maze
//
//  Created by Michael Ng on 9/3/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import "BallView.h"
@interface BallView()

@property CGPoint center;
@end

@implementation BallView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    }
    return self;
}

-(void)moveBallWithPitch:(double)pitch andRoll:(double)roll {
    double updatedX = self.center.x + roll*20;
    double updatedY = self.center.y + pitch*20;
    
    if (updatedX < 20 || updatedX > 300) {
        updatedX = self.center.x;
    }
    if (updatedY < 20 || updatedY > 460) {
        updatedY = self.center.y;
    }
    self.frame = CGRectMake(self.frame.origin.x + roll*20 ,self.frame.origin.y + pitch*20,40,40);
    
    [self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context= UIGraphicsGetCurrentContext();
    
    [[UIColor redColor]set];
    CGContextFillEllipseInRect(context, CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height));
}


@end

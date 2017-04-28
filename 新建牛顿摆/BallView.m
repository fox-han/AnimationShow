//
//  BallView.m
//  NewtonCradle
//
//  Created by wang xinkai on 15/9/6.
//  Copyright © 2015年 wxk. All rights reserved.
//

#import "BallView.h"

@implementation BallView


-(id)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        CGRect new = self.frame;
        new.size.width = new.size.height;
        self.frame = new;
        
        //边框
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        //背景色和圆角
        //        self.layer.cornerRadius = new.size.height/2;
        self.layer.backgroundColor = [UIColor groupTableViewBackgroundColor].CGColor;
        
        self.isTouchEnabled = NO;
    }
    return self;
}

-(void)setIsBall:(BOOL)isBall{
    if (isBall) {
        //背景色和圆角
        self.layer.cornerRadius = self.frame.size.height/2;
    }else{
        self.layer.cornerRadius = 0;
    }
    _isBall = isBall;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (self.isTouchEnabled) {
        UITouch *touch = [touches anyObject];
        self.center = [touch locationInView:self.superview];
    }
}



@end

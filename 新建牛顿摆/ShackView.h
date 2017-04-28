//
//  ShackView.h
//  新建牛顿摆
//
//  Created by Mac on 15-9-7.
//  Copyright (c) 2015年 Hwg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShackView : UIView {
    //半径
    CGFloat _radius;
    //线 legth
    CGFloat _lineLength;
    //球
    NSMutableArray *_balls;
    //保存数据（中心点坐标）
    CGPoint _anchors[100];
    CGPoint _centers[100];
    //物理仿真器
    UIDynamicAnimator *_animator;
    
}
@end

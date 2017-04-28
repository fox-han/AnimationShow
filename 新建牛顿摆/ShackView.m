//
//  ShackView.m
//  新建牛顿摆
//
//  Created by Mac on 15-9-7.
//  Copyright (c) 2015年 Hwg. All rights reserved.
//

/*
    1.创建几个小球试图
    2.画线
    3.添加行为描述
    4.手势
 */

#import "ShackView.h"
#import "BallView.h"

@implementation ShackView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        _balls = [[NSMutableArray alloc] init];
        
        [self loadSettings];
        
        [self createView];
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _balls = [[NSMutableArray alloc] init];
    
    [self loadSettings];
    [self createView];
}

//重写  layoutSubviews  重新布局
- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    [self loadSettings];
    
//    重新调用一遍
    [self createView];
    
    [self addBehavior];

}

//默认配置
- (void)loadSettings {
    //初始化物理仿真器（通过一个视图初始化）
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    //半径
    _radius = 20;
    //线的长度
    _lineLength = 200;
}

//创建小球
- (void)createView {
    
    CGPoint center = self.center;
    //小球的中心点数组
    CGPoint centers[] = {
        CGPointMake(center.x - 4 * _radius, center.y),
        CGPointMake(center.x - 2 * _radius, center.y),
        CGPointMake(center.x, center.y),
        CGPointMake(center.x + 2 * _radius, center.y),
        CGPointMake(center.x + 4 * _radius, center.y)
    };
    
    //计算个数
    int count = sizeof(centers)/sizeof(CGPoint);
    
    //更新2个数组
    for (int i = 0; i < count; i ++) {
        
        _centers[i] = centers[i];
        _anchors[i] = centers[i];
        
        //锚点的位置：向上提高线的的距离
        _anchors[i].y -= _lineLength;
    }
    
    if (_balls.count) {
        int i = 0;
        
        for (BallView *bv in _balls) {
            
            bv.center = centers[i];
            i ++;
        }
        //1、setNeedsDisplay会调用自动调用drawRect方法
        //2、setNeedsLayout会默认调用layoutSubViews
        //相当于间接调用layoutSubViews，异步执行
        [self setNeedsDisplay];
        return;
    }
    
    
    //创建ball
    for (int i = 0; i < count; i ++) {
        
        BallView *ball = [[BallView alloc] initWithFrame:CGRectMake(0, 0, _radius * 2 - 1, _radius * 2 - 1)];
        
        ball.isBall = YES;
        
        ball.center = centers[i];
        
        //KVO
        [ball addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionNew context:nil];
        
        [self addSubview:ball];
        
        [_balls addObject:ball];
    }
    
    [self setNeedsDisplay];
}

//KVO 监听
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //
    [self setNeedsDisplay];
}

//添加行为描述
- (void)addBehavior {
    /**
     *  UIGravityBehavior：重力行为
     *  UICollisionBehavior：碰撞行为
     *  UIAttachmentBehavior：附着行为
     *  UISnapBehavior：吸附行为
     *  UIPushBehavior：推行为
     *  UIDynamicItemBehavior：动力学元素行为
     */
    //添加小球的属性行为描述
    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:_balls];
    //弹性
    itemBehavior.elasticity = 1;
    //阻尼
    itemBehavior.resistance = 1;
    //密度
    itemBehavior.density = 1;
    //不允许旋转
    itemBehavior.allowsRotation = NO;
    
    [_animator addBehavior:itemBehavior];
    
    //重力
    UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:_balls];
    gravity.magnitude = 5;
    [_animator addBehavior:gravity];
    //碰撞
    UICollisionBehavior *collison = [[UICollisionBehavior alloc] initWithItems:_balls];
    //不添加的话，会出现摆动越界（可注释代码自行查看）
    [_animator addBehavior:collison];
    
    //链接(附着行为)
    for (int i = 0; i < _balls.count; i ++) {
        
        UIAttachmentBehavior *attachment = [[UIAttachmentBehavior alloc] initWithItem:_balls[i] offsetFromCenter:UIOffsetMake(0, -_radius) attachedToAnchor:_anchors[i]];
        
        [_animator addBehavior:attachment];
    }
    
    //添加手势（整个仿真器：view）
    UISwipeGestureRecognizer *swipeGes = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAct:)];
    
    swipeGes.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self addGestureRecognizer:swipeGes];
    
}

#pragma mark - 手势
- (void)swipeAct:(UISwipeGestureRecognizer *)ges {
    //推力
    UIPushBehavior *push = [[UIPushBehavior alloc] initWithItems:@[_balls[0]] mode:UIPushBehaviorModeInstantaneous];
    //
    push.pushDirection = CGVectorMake(-1, 0);
    push.magnitude = 2;
    
    [_animator addBehavior:push];
}


// 绘制小球
- (void)drawRect:(CGRect)rect {

    for (int i = 0 ; i < _balls.count; i ++) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextAddArc(context, _anchors[i].x, _anchors[i].y, 5, 0, M_PI * 2, true);
        //    填充颜色
        CGContextFillPath(context);
        
        CGContextMoveToPoint(context, [_balls[i] center].x, [_balls[i] center].y);

        CGContextAddLineToPoint(context, _anchors[i].x, _anchors[i].y);
        
        CGContextStrokePath(context);
    }
}

//移除  防止内存泄漏
- (void)dealloc {
    
    for (BallView *ball in _balls) {
        [ball removeObserver:self forKeyPath:@"center"];
    }
}



@end

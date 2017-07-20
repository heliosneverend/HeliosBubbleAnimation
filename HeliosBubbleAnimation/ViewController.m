//
//  ViewController.m
//  HeliosBubbleAnimation
//
//  Created by beyo-zhaoyf on 2017/7/20.
//  Copyright © 2017年 beyo-zhaoyf. All rights reserved.
//

#import "ViewController.h"
#define Screen_Width ([[UIScreen mainScreen] bounds].size.width)
#define Screen_Height ([[UIScreen mainScreen] bounds].size.height)
#define centerX _currentBtn.frame.origin.x //_currentBtn 的X
#define centerY _currentBtn.frame.origin.y //_currentBtn 的Y
#define HeliosRandomColor [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0]
#define btnWHalf btnW / 2
#define adjushY  45
#define space 7
#define margin 29.5
#define btnW 45
#define btnCount 7
#define LeftCount 2
#define PICWIDTH (([[UIScreen mainScreen] bounds].size.width-114)/3)
#define VideoWIDTH ([[UIScreen mainScreen] bounds].size.width-104)

typedef NS_ENUM(NSUInteger, BYAnimationType){
    BYAnimationTypeShowUp = 100,
    BYAnimationTypeShowLeft,
    BYAnimationTypeShowRight,
    BYAnimationTypeShowLevel
}BYbtnAnimationType;

typedef void (^createPointLeft)(BOOL, NSInteger index);
typedef void (^createPointRight)(BOOL, NSInteger index);
@interface ViewController ()<UIGestureRecognizerDelegate>
{
    UIButton *_topBtn;
    UIView *_couldView;
    UIButton *_btn;
    NSIndexPath *_dIndexPath;
    NSString *_dString;


}
@property (nonatomic, assign) BYAnimationType animationType;
@property (nonatomic, strong)NSMutableArray *btnMarr;
@property (nonatomic, strong)UIButton *currentBtn;
@property (nonatomic, assign)NSTimeInterval currentTime;
@property (nonatomic, copy)createPointLeft pointLeft;
@property (nonatomic, copy)createPointRight pointRight;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self bymabSetTopBut];
}

#pragma mark 动画
- (void)bymabSetTopBut {
    CALayer *layer=  [CALayer layer];
    layer.frame = CGRectMake(Screen_Width-65, Screen_Height-150, 45, 45);
    layer.backgroundColor = [UIColor blackColor].CGColor;
    layer.shadowOffset = CGSizeMake(3, 3);
    layer.shadowOpacity = 0.2;
    layer.cornerRadius = 22.5;
    [self.view.layer addSublayer:layer];
    
    _topBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:_topBtn];
    _topBtn.frame = CGRectMake(Screen_Width-65, Screen_Height-150, 45, 45);
    [_topBtn addTarget:self action:@selector(topButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_topBtn setBackgroundImage:[UIImage imageNamed:@"record_add_all.png"] forState:UIControlStateNormal];
    _topBtn.layer.masksToBounds = YES;
    _topBtn.layer.cornerRadius = 22.5;
    _currentBtn = _topBtn;
    _currentBtn.tag = BYAnimationTypeShowUp;
    [self setUpBtns];
    [self.view bringSubviewToFront:_currentBtn];
    
}
#pragma mark buttonClick
- (void)topButtonClick:(UIButton *)button {
    if(!button.selected){
        [UIView animateWithDuration:0.3 animations:^{
            _topBtn.transform = CGAffineTransformMakeRotation(M_PI_4);
        } completion:^(BOOL finished) {
            
        }];
        _couldView.hidden = NO;
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            _topBtn.transform = CGAffineTransformMakeRotation(0);
        } completion:^(BOOL finished) {
            
        }];
        
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3* NSEC_PER_SEC));
        
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            _couldView.hidden = YES;
            
        });
    }
    button.selected = !button.isSelected;
    if(button.tag >= BYAnimationTypeShowUp){
        button.enabled = NO;
        [self showAnimation];
    }else {
        [UIView animateWithDuration:0.3 animations:^{
            _topBtn.transform = CGAffineTransformMakeRotation(0);
        } completion:^(BOOL finished) {
            
        }];
        _couldView.hidden = YES;
        NSLog(@"button.tag=%ld",button.tag);
    }
}
- (void)showAnimation{
    _currentTime = CACurrentMediaTime();
    for (int  i = 0; i< _btnMarr.count; i++) {
        UIButton *btn=_btnMarr[i];
        [btn.layer removeAllAnimations];
        NSDictionary *pointDic = [self returnStartPoint:_currentBtn.tag withIndex:i];
        
        CGPoint startPoint = [(NSValue *)pointDic[@"startPoint"] CGPointValue];
        CGPoint endPoint = [(NSValue *)pointDic[@"endPoint"] CGPointValue];
        
        CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.duration=.3;
        positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:startPoint];
        positionAnimation.toValue = [NSValue valueWithCGPoint:endPoint];
        
        CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.additive = YES;
        scaleAnimation.values = @[@0,@(-1),@0];
        scaleAnimation.keyTimes =_currentBtn.isSelected ? @[@0,@0,@1] : @[@0,@1,@1];
        scaleAnimation.duration=.3;
        CAAnimationGroup *animationGG = [CAAnimationGroup animation];
        animationGG.duration = .3;
        animationGG.repeatCount = 1;
        animationGG.animations = @[positionAnimation, scaleAnimation];
        animationGG.fillMode = kCAFillModeBoth;
        animationGG.removedOnCompletion = YES;
        animationGG.beginTime =  _currentTime + (0.3/(float)_btnMarr.count * (float)i);
        [btn.layer addAnimation:animationGG forKey:nil];
        btn.layer.position = endPoint;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(((0.5/(float)_btnMarr.count * (float)_btnMarr.count )) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _currentBtn.enabled = YES;
    });
    
}
- (NSDictionary *)returnStartPoint:(BYAnimationType )type withIndex:(NSInteger)index{
   
    __block CGPoint startPoint = CGPointZero;
    __block CGPoint endPoint = CGPointZero;
    
    NSMutableDictionary *mdic = [NSMutableDictionary dictionary];
    self.pointLeft = ^(BOOL sure, NSInteger index){
        startPoint = _currentBtn.isSelected ? CGPointMake(centerX -btnWHalf, centerY +adjushY - btnWHalf) : CGPointMake(centerX -btnWHalf - index * (btnW + space) - margin, centerY +adjushY - btnWHalf);
        endPoint = _currentBtn.isSelected ? CGPointMake(centerX - btnWHalf - index * (btnW + space) - margin, centerY +adjushY - btnWHalf) : CGPointMake(centerX +btnWHalf, centerY +adjushY - btnWHalf);
    };
    self.pointRight = ^(BOOL sure, NSInteger index){
        startPoint = _currentBtn.isSelected ? CGPointMake(centerX +btnW, centerY +adjushY - btnWHalf) : CGPointMake(centerX +btnW + index * (btnW + space) + margin + btnWHalf, centerY +adjushY - btnWHalf);
        endPoint = _currentBtn.isSelected ? CGPointMake(centerX +btnW + index * (btnW + space) + margin + +btnWHalf, centerY +adjushY - btnWHalf) : CGPointMake(centerX +btnWHalf, centerY +adjushY - btnWHalf);
    };

    switch (type) {
        case BYAnimationTypeShowUp :
            startPoint = _currentBtn.isSelected ? CGPointMake(centerX +btnWHalf-20, centerY +adjushY - btnWHalf) : CGPointMake(centerX +btnWHalf-20, centerY - index * (btnW + space) - btnW - margin +adjushY);
            endPoint = _currentBtn.isSelected ? CGPointMake(centerX +btnWHalf-20, centerY - index * (btnW + space) - btnW - margin +adjushY) : CGPointMake(centerX +btnWHalf-20, centerY +adjushY - btnWHalf);
            break;
        case BYAnimationTypeShowLeft:{
            self.pointLeft(YES,index);
            break;
        }
        case BYAnimationTypeShowRight:{
            self.pointRight(YES,index);
            break;
        }
        case BYAnimationTypeShowLevel:
            if (index <= LeftCount) {
                self.pointLeft(YES,index);
            }else{
                self.pointRight(YES,index - LeftCount - 1);
            }
            break;
        default:
            break;
    }
    [mdic setObject:[NSValue valueWithCGPoint:startPoint] forKey:@"startPoint"];
    [mdic setObject:[NSValue valueWithCGPoint:endPoint] forKey:@"endPoint"];
    return [mdic copy];
}
- (void)setAnimationType:(BYAnimationType )animationType{
    _currentBtn.tag = animationType;
    [_currentBtn setTitle:[NSString stringWithFormat:@"%ldT", animationType] forState:UIControlStateNormal];
}

- (void)setUpBtns{
    _couldView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
    _couldView.backgroundColor = [UIColor whiteColor];
    _couldView.alpha = 0.9;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bymab_handleSingleTap)];
    tap.delegate =self;
    [_couldView addGestureRecognizer:tap];
    
    _couldView.hidden = YES;
    [self.view addSubview:_couldView];
    NSArray *buttonArr = @[@"record_bigThing.png",@"record_room_en.png",@"record_baby_look.png",@"record_mom_look.png",@"record_suiyiji.png",@"record_shipin.png",@"record_newTakePhoto.png"];
    NSMutableArray *marr = [NSMutableArray array];
    for (NSInteger i = 0; i < btnCount; i++) {
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        _btn.backgroundColor = HeliosRandomColor;
        [_btn setBackgroundImage:[UIImage imageNamed:buttonArr[i]] forState:UIControlStateNormal];
        _btn.frame = CGRectMake(_currentBtn.frame.origin.x, _currentBtn.frame.origin.y, 110, 45);
        [_btn addTarget:self action:@selector(topButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _btn.tag = i;
        [_couldView addSubview:_btn];
        [marr addObject:_btn];
    }
    _btnMarr = marr;
}
#pragma mark 单击手势
-(void)bymab_handleSingleTap {
    [UIView animateWithDuration:0.3 animations:^{
        _topBtn.transform = CGAffineTransformMakeRotation(0);
    } completion:^(BOOL finished) {
        
    }];
    
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3* NSEC_PER_SEC));
    
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        _couldView.hidden = YES;
        
    });
    _topBtn.selected = !_topBtn.isSelected;
   
    if(_topBtn.tag >= BYAnimationTypeShowUp){
        _topBtn.enabled = NO;
        [self showAnimation];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

//
//  UIView+Category.m
//  BaseProject
//
//  Created by my on 16/3/24.
//  Copyright © 2016年 base. All rights reserved.
//

#import "UIView+Category.h"
#import <objc/runtime.h>

static char tapKey;

@implementation UIView (Category)


#pragma mark - 添加单击手势
- (void)tapHandle:(TapAction)block {
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
    objc_setAssociatedObject(self, &tapKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    TapAction blcok = objc_getAssociatedObject(self, &tapKey);
    if (blcok) {
        blcok();
    }
}

#pragma mark 抖动
- (void)shakeView
{
//    CGFloat t =4.0;
//    CGAffineTransform translateRight  =CGAffineTransformTranslate(CGAffineTransformIdentity, t,0.0);
//    CGAffineTransform translateLeft =CGAffineTransformTranslate(CGAffineTransformIdentity,-t,0.0);
//    self.transform = translateLeft;
//    [UIView animateWithDuration:0.07 delay:0.0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{
//        [UIView setAnimationRepeatCount:2.0];
//        self.transform = translateRight;
//    } completion:^(BOOL finished){
//        if(finished){
//            [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
//                self.transform =CGAffineTransformIdentity;
//            } completion:NULL];
//        }
//    }];
    
    //view抖动
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    anim.repeatCount = 1;
    anim.values = @[@-4,@4,@-4,@4];
    [self.layer addAnimation:anim forKey:nil];
    


    
}

- (void)shakeRotation:(CGFloat)rotation {
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    anim.repeatCount = 2;
    anim.duration = .2;
    anim.values = @[@0,@(rotation),@0,@(-rotation),@0];
    [self.layer addAnimation:anim forKey:nil];
}
@end

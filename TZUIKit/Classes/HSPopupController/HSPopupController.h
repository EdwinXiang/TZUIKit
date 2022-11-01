//
//  HSPopupController.h
//  HSUIKit
//
//  Created by Edwin on 2022/8/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSPopupController : UIPresentationController<UIViewControllerTransitioningDelegate>

/// 点击界面外自动关闭，默认 YES
@property (nonatomic, assign) BOOL tapDimmViewGestureEnable;

/// 转场动画时长，默认 0.3
@property (nonatomic, assign) double transitionDuration;

@property (nonatomic, assign) CGFloat           alpha;
@end

NS_ASSUME_NONNULL_END

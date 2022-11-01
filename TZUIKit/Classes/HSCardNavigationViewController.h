//
//  HSCardNavigationViewController.h
//  HSUIKit
//
//  Created by Edwin on 2022/8/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HSCardNavigationViewController;
@protocol HSCardNavigationViewControllerProtocol <NSObject>

@required
@property (nonatomic, weak) HSCardNavigationViewController *cardNavigationController;
@property (nonatomic, strong) UIView *containerView;

- (BOOL)autoTapDismiss;
@end

@interface HSCardNavigationViewController : UIViewController
- (instancetype)initWithRootViewController:(UIViewController<HSCardNavigationViewControllerProtocol> *)viewControler;
+ (void)showRootViewController:(UIViewController<HSCardNavigationViewControllerProtocol> *)viewController;
- (void)pushViewController:(UIViewController<HSCardNavigationViewControllerProtocol> *)viewController animation:(BOOL)animation;
- (void)popViewControllerWithAnimation:(BOOL)animation;
- (void)dismissViewControllerAnimated:(BOOL)animation;
@end



NS_ASSUME_NONNULL_END

//
//  HSCardNavigationViewController.m
//  HSUIKit
//
//  Created by Edwin on 2022/8/19.
//

#import "HSCardNavigationViewController.h"
#import <objc/runtime.h>
#import "UIView+Frame.h"
#import "UIViewController+ViewController.h"
#import <Masonry/Masonry.h>

@interface UIViewController (pushing)
@property (nonatomic, assign) BOOL pushing;
@end

@implementation UIViewController (pushing)

- (BOOL)pushing {
    NSNumber *number = objc_getAssociatedObject(self, @selector(pushing));
    return number != nil ? [number boolValue] : NO;
}
- (void)setPushing:(BOOL)pushing {
    objc_setAssociatedObject(self, @selector(pushing), @(pushing), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@interface HSCardNavigationViewController ()

@end

static const CGFloat loginCardViewAnimationTime = .25;
@implementation HSCardNavigationViewController

- (instancetype)initWithRootViewController:(UIViewController<HSCardNavigationViewControllerProtocol> *)viewControler {
    if (self = [super initWithNibName:nil bundle:nil]) {
        [self pushViewController:viewControler animation:YES];
        if (viewControler.autoTapDismiss) { // 自定关闭
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundAutoTap)];
            [viewControler.view addGestureRecognizer:tap];
        }
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    [UIDevice.currentDevice beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}
- (BOOL)shouldAutorotate {
    return  YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    UIViewController<HSCardNavigationViewControllerProtocol> *vc = self.childViewControllers.lastObject; // 最上层的vc
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context){
        NSLog(@"转屏前调入");
        vc.containerView.alpha = 0;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context){
        [self changeDeviceOrientation:vc];
        NSLog(@"size = %@,.current vc = %@, frame = %@", NSStringFromCGSize(size), NSStringFromClass(vc.class), NSStringFromCGRect(vc.containerView.frame));
    }];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
}

#pragma mark --public
+ (void)showRootViewController:(UIViewController<HSCardNavigationViewControllerProtocol> *)viewController{
    HSCardNavigationViewController *vc = [[HSCardNavigationViewController alloc] init];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [[UIViewController hs_topViewController] presentViewController:vc animated:NO completion:^{
        [vc pushViewController:viewController animation:YES];
    }];
}

-(void)pushViewController:(UIViewController<HSCardNavigationViewControllerProtocol> *)viewController animation:(BOOL)animation{
    viewController.pushing = YES;
    
    CGRect prevVCFrame = CGRectZero;
    UIViewController *prevVC = self.childViewControllers.lastObject;
    if (prevVC) {
        prevVCFrame = prevVC.view.frame;
        [prevVC.view removeFromSuperview];
    }
    
    viewController.cardNavigationController = self;
    [viewController willMoveToParentViewController:self];
    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
    if (viewController.autoTapDismiss) { // 自定关闭
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundAutoTap)];
        [viewController.view addGestureRecognizer:tap];
    }
    
    CGFloat endY = self.view.height - viewController.view.height;
    if (animation) {
        viewController.view.top = prevVC ? (CGRectGetMaxY(prevVCFrame) - viewController.view.height) : self.view.height;
        viewController.containerView.alpha = 0;
        [self.view layoutIfNeeded];
        [self.view setNeedsDisplay];
        CGRect frame = viewController.containerView.frame;
        UIDeviceOrientation orientation = UIDevice.currentDevice.orientation;
        NSLog(@"current dice orientation = %ld, frame = %@， endy = %.f", (long)orientation, NSStringFromCGRect(frame), endY);
        viewController.containerView.alpha = 0.0;
        
        switch (orientation) {
            case UIDeviceOrientationLandscapeLeft:
            case UIDeviceOrientationLandscapeRight: {
                [UIView animateWithDuration:loginCardViewAnimationTime animations:^{
                    viewController.view.top = endY;
                    [viewController.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.right.top.bottom.equalTo(viewController.containerView.superview);
                        make.width.mas_equalTo(frame.size.height);
                    }];
                    viewController.containerView.alpha = 1.0;
                } completion:^(BOOL finished) {
                    NSLog(@"animateWithDuration containerFrame = %@", NSStringFromCGRect(viewController.containerView.frame));
                }];
            }
                break;
            case UIDeviceOrientationFaceUp:
            case UIDeviceOrientationFaceDown: {
                viewController.containerView.alpha = 0;
                [UIView animateWithDuration:loginCardViewAnimationTime animations:^{
                    [viewController.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.bottom.right.equalTo(viewController.containerView.superview);
                        make.height.mas_equalTo(UIScreen.mainScreen.bounds.size.height);
                        make.width.mas_equalTo(frame.size.height);
                    }];
                    viewController.view.top = endY;
                    viewController.containerView.alpha = 1;
                } completion:^(BOOL finished) {
                    NSLog(@"animateWithDuration containerFrame = %@", NSStringFromCGRect(viewController.containerView.frame));
                }];
            }
                break;
            default: {
                viewController.containerView.alpha = 0;
                [UIView animateWithDuration:loginCardViewAnimationTime animations:^{
                    [viewController.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.leading.trailing.bottom.equalTo(viewController.containerView.superview);
                        make.height.mas_equalTo(frame.size.height);
                    }];
                    viewController.view.top = endY;
                    viewController.containerView.alpha = 1;
                } completion:^(BOOL finished) {
                    NSLog(@"animateWithDuration containerFrame = %@", NSStringFromCGRect(viewController.containerView.frame));
                }];
            }
                break;
        }
    } else {
        viewController.view.top = endY;
    }
    
    viewController.pushing = NO;
}

- (void)changeDeviceOrientation:(UIViewController<HSCardNavigationViewControllerProtocol> *)vc {
    CGRect frame = vc.containerView.frame;
    UIDeviceOrientation orientation = UIDevice.currentDevice.orientation;
    NSLog(@"current dice orientation = %ld", (long)orientation);
    switch (orientation) {
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight: {
            vc.containerView.alpha = 0.0;
            [UIView animateWithDuration:loginCardViewAnimationTime animations:^{
                [vc.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.right.top.bottom.equalTo(vc.containerView.superview);
                    make.width.mas_equalTo(frame.size.height);
                }];
                vc.containerView.alpha = 1.0;
            } completion:^(BOOL finished) {

            }];
        }
            break;
        default: {
            vc.containerView.alpha = 0;
            [UIView animateWithDuration:loginCardViewAnimationTime animations:^{
                [vc.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.leading.trailing.bottom.equalTo(vc.containerView.superview);
                    make.height.mas_equalTo(frame.size.width);
                }];
                vc.containerView.alpha = 1;
            } completion:^(BOOL finished) {

            }];
        }
            break;
    }
}

- (void)backgroundAutoTap {
    [self dismissViewControllerAnimated:YES];
}

-(void)popViewControllerWithAnimation:(BOOL)animation{
    UIViewController *viewController = [self.childViewControllers lastObject];
    
    void(^completionHandle)(void) = ^{
        [viewController willMoveToParentViewController:nil];
        [viewController removeFromParentViewController];
        [viewController.view removeFromSuperview];
        [viewController didMoveToParentViewController:nil];
        
        UIView *showView = self.childViewControllers.lastObject.view;
        [self.view addSubview:showView];
    };
    
    if (animation) {
        CGFloat height = CGRectGetHeight(viewController.view.frame);
        [UIView animateWithDuration:loginCardViewAnimationTime animations:^{
            [viewController.view setTransform:CGAffineTransformMakeTranslation(0, height)];
        } completion:^(BOOL finished) {
            completionHandle();
        }];
    } else {
        completionHandle();
    }
}

-(void)dismissViewControllerAnimated:(BOOL)animation{
    if (animation) {
        UIViewController *lastVC = self.childViewControllers.lastObject;
        [UIView animateWithDuration:loginCardViewAnimationTime animations:^{
            [lastVC.view setTransform:CGAffineTransformMakeTranslation(0, lastVC.view.height)];
        } completion:^(BOOL finished) {
            if (finished) {
                [self dismissViewControllerAnimated:NO completion:nil];
            }
        }];
    } else {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

@end

//
//  HSPopupNavigationController.m
//  HSUIKit
//
//  Created by Edwin on 2022/8/2.
//

#import "HSPopupNavigationController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"

@interface HSPopupNavigationController ()<UINavigationControllerDelegate>

@end

@implementation HSPopupNavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithRootViewController:rootViewController]) {
        self.navigationBarHidden = YES;
    }
    return self;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super pushViewController:viewController animated:animated];
    self.preferredContentSize = viewController.preferredContentSize;
    __weak typeof(viewController) weakViewController = viewController;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.001), dispatch_get_main_queue(), ^{
        if (CGSizeEqualToSize(viewController.preferredContentSize, CGSizeZero)) {
            weakViewController.preferredContentSize = UIScreen.mainScreen.bounds.size;
        }
    });
    viewController.navigationController.delegate = self;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [viewController setFd_prefersNavigationBarHidden:YES];
    [viewController.navigationController setNavigationBarHidden:YES animated:NO];
    viewController.fd_prefersNavigationBarHidden = YES;
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    NSInteger index = self.viewControllers.count - 2;
    if (index >= 0) {
        self.preferredContentSize = self.viewControllers[index].preferredContentSize;
    }
    return [super popViewControllerAnimated:animated];
}

- (NSArray<__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.preferredContentSize = viewController.preferredContentSize;
    return [super popToViewController:viewController animated:animated];
}

- (NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    self.preferredContentSize = self.viewControllers.firstObject.preferredContentSize;
    return [super popToRootViewControllerAnimated:animated];
}

@end

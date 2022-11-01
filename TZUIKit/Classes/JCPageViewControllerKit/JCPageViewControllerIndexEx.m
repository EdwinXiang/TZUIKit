//
//  JCPageViewControllerIndexEx.m
//  JCPageViewControllerDemo
//
//  Created by huajiao on 2018/4/13.
//  Copyright © 2018年 huajiao. All rights reserved.
//

#import "JCPageViewControllerIndexEx.h"
#import <objc/runtime.h>
#import "JCPageScrollView.h"

@interface JCPageViewControllerIndexEx ()

@end

@implementation JCPageViewControllerIndexEx

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        __weak typeof(self) weakSelf = self;
        [self setControllerBeforeSelectedViewControllerBlock:^UIViewController * _Nullable(__kindof JCPageViewControllerIndexEx * _Nonnull thePageViewController, __kindof UIViewController * _Nonnull selectedViewController) {
            NSInteger maxCount = thePageViewController.pageCount;
            if (maxCount <= 0) {
                return nil;
            }
            
            
            NSInteger index = selectedViewController.selectedIndexForPage - 1;
            
            
            if (index < 0) {
                if (!weakSelf.isCanLoop) {
                    return nil;
                }else{
                    index = maxCount - 1;
                }
            }
            
            if (weakSelf.viewControllerAtIndexBlock) {
                UIViewController *theViewController = weakSelf.viewControllerAtIndexBlock(weakSelf, index);
                
                if (!theViewController) {
                    return nil;
                }
                
                theViewController.selectedIndexForPage = index;
                return theViewController;
            }
            
            return nil;
        }];
        
        [self setControllerAfterSelectedViewControllerBlock:^UIViewController * _Nullable(__kindof JCPageViewControllerIndexEx * _Nonnull thePageViewController, __kindof UIViewController * _Nonnull selectedViewController) {
            NSInteger maxCount = thePageViewController.pageCount;
            
            if (maxCount <= 0) {
                return nil;
            }
            
            NSInteger index = selectedViewController.selectedIndexForPage + 1;
            
            if (index > maxCount - 1) {
                if (!weakSelf.isCanLoop) {
                    return nil;
                }else{
                    index = 0;
                }
            }
            
            if (weakSelf.viewControllerAtIndexBlock) {
                UIViewController *theViewController = weakSelf.viewControllerAtIndexBlock(weakSelf, index);
                if (!theViewController) {
                    return nil;
                }
                theViewController.selectedIndexForPage = index;
                return theViewController;
            }
            
            return nil;
        }];
        
        [self setControllerWillTransitionBlock:^(__kindof JCPageViewControllerIndexEx * _Nonnull thePageViewController, __kindof UIViewController * _Nonnull fromViewController, __kindof UIViewController * _Nonnull toViewController) {
            //判断是否需要加载新数据
            
            if (JCPageViewControllerIndexExStatusNormal != weakSelf.loadingStatus) {
                return;
            }
            
            if (weakSelf.needLoadMoreBlock) {
                NSInteger count = thePageViewController.pageCount;
                BOOL needLoadMore = weakSelf.needLoadMoreBlock(weakSelf, weakSelf.selectedViewController.selectedIndexForPage, count);
                
                if (needLoadMore) {
                    weakSelf.loadingStatus = JCPageViewControllerIndexExStatusLoadingMore;
                    if (weakSelf.loadMoreBlock) {
                        weakSelf.loadMoreBlock(weakSelf, weakSelf.selectedViewController.selectedIndexForPage, count);
                    }
                }
            }
        }];
    }
    return self;
}


- (NSInteger)selectedIndex{
    return self.selectedViewController.selectedIndexForPage;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex{
    UIViewController *viewController = [self controllerAtidx:selectedIndex];
    if (!viewController) {
        return ;
    }
    self.selectedViewController = viewController;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated{
    UIViewController *viewController = [self controllerAtidx:selectedIndex];
    if (!viewController) {
        return ;
    }

    if (animated) {
        self.scrollView.needTriggerScrollCallbacks = YES;
        if (selectedIndex > self.selectedViewController.selectedIndexForPage) {
            [self setSelectedViewControllerToRight:viewController];
            return ;
        }
        
        if (selectedIndex < self.selectedViewController.selectedIndexForPage) {
            [self setSelectedViewControllerToLeft:viewController];
            return ;
        }
        
        if (!self.selectedViewController ) {
            self.selectedViewController = viewController;
            return ;
        }
        return ;
    }
    self.selectedViewController = viewController;
}

- (NSInteger)pageCount{
    if (!_viewControllerCountBlock) {
        return 0;
    }
    return _viewControllerCountBlock(self);
}

- (UIViewController *)controllerAtidx:(NSInteger)selectedIndex{
    NSInteger min = 0;
    NSInteger max = self.pageCount;
    if (selectedIndex < min || selectedIndex >= max) {
        return nil;
    }
    
    UIViewController *viewController = nil;
    if (self.viewControllerAtIndexBlock) {
        viewController = self.viewControllerAtIndexBlock(self, selectedIndex);
    }
    
    if (!viewController) {
        return nil;
    }
    
    viewController.selectedIndexForPage = selectedIndex;
    return viewController;
}


- (void)endRefreshing{
    self.loadingStatus = JCPageViewControllerIndexExStatusNormal;
}

- (void)reloadSelectedViewController{
    if (!self.selectedViewController) {
        return;
    }
    [self setCanLoadBeforeAndAfterViewController];
}

@end


@implementation UIViewController (JCPageViewControllerIndexExItemVC)

- (void)setSelectedIndexForPage:(NSInteger)selectedIndexForPage{
       objc_setAssociatedObject(self, @selector(selectedIndexForPage), @(selectedIndexForPage), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)selectedIndexForPage{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}


@end

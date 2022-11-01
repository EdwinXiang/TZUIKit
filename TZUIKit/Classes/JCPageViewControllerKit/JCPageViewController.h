//
//  JCPageViewController.h
//  JCPageViewControllerDemo
//
//  Created by huajiao on 2018/4/11.
//  Copyright © 2018年 huajiao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JCPageViewController;
@class JCPageScrollView;

typedef  UIViewController * _Nullable  (^JCPageViewControllerControllerGetBlock)(__kindof JCPageViewController *thePageViewController, __kindof UIViewController *selectedViewController);
typedef  void (^JCPageViewControllerTransitionBlock)(__kindof JCPageViewController *thePageViewController, __kindof UIViewController *fromViewController, __kindof UIViewController *toViewController);

typedef BOOL(^JCPageViewControllerCanScrollBlock)(__kindof JCPageViewController *thePageViewController,__kindof UIViewController *currentViewController, UIGestureRecognizer *recognizer);

typedef NS_ENUM(NSUInteger, JCPageViewControllerNavigationOrientation) {
    JCPageViewControllerNavigationOrientationHorizontal = 0,
    JCPageViewControllerNavigationOrientationVertical = 1
};

@interface JCPageViewController : UIViewController

#pragma mark - publics & properties
@property (nonatomic, readonly) JCPageScrollView *scrollView;

@property (nonatomic, assign) JCPageViewControllerNavigationOrientation navigationOrientationType;

///当前选中的ViewController
@property (nonatomic, strong) __kindof UIViewController *selectedViewController;

- (void)setSelectedViewControllerToLeft:(__kindof UIViewController * _Nonnull)selectedViewController;
- (void)setSelectedViewControllerToRight:(__kindof UIViewController * _Nonnull)selectedViewController;

///可再次加载前一个和后一个,并清掉beforeViewController 和afterViewController
- (void)setCanLoadBeforeAndAfterViewController;
///清掉beforeView并标记为需要重新加载
- (void)setNeedReloadBeforeViewController;
///清掉afterView并标记为需要重新加载
- (void)setNeedReloadAfterViewController;
///开启、关闭滑动
@property (nonatomic, assign, getter = isScrollEnabled) BOOL scrollEnabled;

#pragma mark - 重用机制
///从缓存中取出一个ViewController，如果没有则为nil
- (nullable __kindof UIViewController *)dequeueReusableViewControllerWithIdentifier:(NSString *)identifier;
///注册一个类的Class，调用dequeueRegisteredReusableViewControllerWithIdentifier时如果缓存中没有，则根据对应的key创建
- (void)registerClass:(nullable Class)controllerClass forControllerReuseIdentifier:(NSString *)identifier;
///先调用dequeueReusableViewControllerWithIdentifier，如果没有，则从已注册的Class中获取对应的key的Class,来创建相应的Controller
- (__kindof UIViewController *)dequeueRegisteredReusableViewControllerWithIdentifier:(NSString *)identifier;

#pragma mark - callbacks
///获取当前controller之前的Controller的Block
@property (nonatomic, copy) JCPageViewControllerControllerGetBlock controllerBeforeSelectedViewControllerBlock;
///获取当前controller之后的Controller的Block
@property (nonatomic, copy) JCPageViewControllerControllerGetBlock controllerAfterSelectedViewControllerBlock;
///Controller将要切换的回调
@property (nonatomic, copy, nullable) JCPageViewControllerTransitionBlock controllerWillTransitionBlock;
///滑动过程中切换了Controller的回调
@property (nonatomic, copy, nullable) JCPageViewControllerTransitionBlock controllerDidTransitionBlock;
///滑动停止了的回调
@property (nonatomic, copy, nullable) JCPageViewControllerTransitionBlock controllerDidEndScrollTransitionBlock;
///滑动是否可以的回调
@property (nonatomic, copy, nullable) JCPageViewControllerCanScrollBlock canScrollBlock;

@end

@protocol JCPageViewControllerItemVC <NSObject>
///从当前中查找PageViewController
@property (nonatomic, readonly, nullable) __kindof JCPageViewController *jc_thePageViewController;
///重用标记
@property (nonatomic, strong) NSString *jc_pageScrollViewControllerReuseIdentifier;
@end

@interface UIViewController (JCPageViewController) <JCPageViewControllerItemVC>


@end


NS_ASSUME_NONNULL_END

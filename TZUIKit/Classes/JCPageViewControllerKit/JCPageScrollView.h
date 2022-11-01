//
//  JCPageScrollView.h
//  JCPageViewControllerDemo
//
//  Created by huajiao on 2018/4/11.
//  Copyright © 2018年 huajiao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JCPageScrollView;

typedef  UIView * _Nullable  (^JCPageScrollViewGetViewBlock)(__kindof JCPageScrollView *thePageScrollView, __kindof UIView *selectedView);
typedef void(^JCPageScrollViewAppearanceBlock)(__kindof JCPageScrollView *thePageScrollView, __kindof UIView *selectedView);
typedef void(^JCPageScrollViewViewTransitionBlock)(__kindof JCPageScrollView *thePageScrollView,__kindof UIView *fromView,__kindof UIView *toView);
typedef void(^JCPageScrollViewViewTransitionEndBlock)(__kindof JCPageScrollView *thePageScrollView, __kindof UIView * _Nullable fromView,__kindof UIView *toView, BOOL isTransitionComplete);
typedef BOOL(^JCPageScrollViewCanScrollBlock)(__kindof JCPageScrollView *thePageScrollView, __kindof UIView *currentView, UIGestureRecognizer *recognizer);

typedef NS_ENUM(NSUInteger, JCPageScrollViewNavigationOrientation) {
    JCPageScrollViewNavigationOrientationHorizontal = 0,
    JCPageScrollViewNavigationOrientationVertical = 1
};

@interface JCPageScrollView : UIScrollView
#pragma mark - 初始化
- (instancetype)initWithOrientationType:(JCPageScrollViewNavigationOrientation)orientationType;
///init Default JCPageScrollViewNavigationOrientationVertical
- (instancetype)initWithFrame:(CGRect)frame orientationType:(JCPageScrollViewNavigationOrientation)orientationType;

#pragma mark - publics & properties
- (__kindof UIView *)containerViewAtIndex:(NSInteger)index;

///当前显示的视图
@property (nonatomic, strong) UIView *selectedView;
///可以滑动方向，可随时设置
@property (nonatomic, assign) JCPageScrollViewNavigationOrientation navigationOrientationType;
///设置Offset到SelectView的位置
- (void)setContentOffsetToSelectView;
///将needLoadBefore 和needLoadAfter字段都设为YES，方便下次加载新View,并清清掉beforeView和afterView
- (void)setCanLoadBeforeAndAfterView;
///有拖动的时候设为YES，滑动停止设为NO
@property (nonatomic, assign, getter = isNeedTriggerScrollCallbacks) BOOL needTriggerScrollCallbacks;
///获取beforView的contentOffset
- (CGPoint)contentOffsetForBeforeView;
///将View向前滑动并选中selectView
- (void)setSelectedViewToLeft:(UIView * _Nonnull)selectedView;
///获取afterView的contentOffset
- (CGPoint)contentOffsetForAfterView;
///将View向后滑动并选中selectView
- (void)setSelectedViewToRight:(UIView * _Nonnull)selectedView;
///移除beforeView，并标记为需要重新加载
- (void)setNeedReloadBeforeView;
///移除afterView，并标记为需要重新加载
- (void)setNeedReloadAfterView;
#pragma mark - 重用机制
///从缓存中取出一个ViewController
- (nullable __kindof UIView *)dequeueReusableViewWithIdentifier:(NSString *)identifier;
///每种identifier最多缓存几个 default 1 默认一种identifer缓存一个
@property (assign, nonatomic) NSUInteger maxCacheCountPerIdentifier;

#pragma mark - callbacks
///获取当前视图之前的视图的回调
@property (nonatomic, copy, nullable) JCPageScrollViewGetViewBlock viewBeforeSelectedViewBlock;
///获取当前视图之后的视图的回调
@property (nonatomic, copy, nullable) JCPageScrollViewGetViewBlock viewAfterSelectedViewBlock;
///视图开始发生切换时的回调
@property (nonatomic, copy, nullable) JCPageScrollViewViewTransitionBlock viewWillTransitionBlock;
///视图切换后的回调
@property (nonatomic, copy, nullable) JCPageScrollViewViewTransitionBlock viewDidTransitionBlock;
///视图切换后的回调
@property (nonatomic, copy, nullable) JCPageScrollViewViewTransitionBlock transitionViewDidChangeBlock;
///滚动停止的回调
@property (nonatomic, copy, nullable) JCPageScrollViewViewTransitionEndBlock scrollDidEndBlock;
///当视图划走移除之后的回调
@property (nonatomic, copy, nullable) JCPageScrollViewAppearanceBlock viewDidRemoveFromSuperViewBlock;
///是否可以滑动的回调
@property (nonatomic, copy, nullable) JCPageScrollViewCanScrollBlock canScrollBlock;

@end

@interface UIView (JCPageScrollView)
///重用标志
@property (nonatomic, strong) NSString *jc_pageScrollViewReuseIdentifier;

@end


NS_ASSUME_NONNULL_END

//
//  JCPageViewControllerIndexEx.h
//  JCPageViewControllerDemo
//
//  Created by huajiao on 2018/4/13.
//  Copyright © 2018年 huajiao. All rights reserved.
//

#import "JCPageViewController.h"

NS_ASSUME_NONNULL_BEGIN


typedef __kindof UIViewController * _Nonnull (^JCPageViewControllerIndexExBlock)(__kindof JCPageViewController *thePageViewController, NSInteger idx);
typedef NSInteger (^JCPageViewControllerIndexExCountBlock)(__kindof JCPageViewController *thePageViewController);
typedef BOOL (^JCPageViewControllerIndexExNeedLoaddMoreBlock)(__kindof JCPageViewController *thePageViewController, NSInteger idx, NSInteger count);
typedef void (^JCPageViewControllerIndexExLoaddMoreBlock)(__kindof JCPageViewController *thePageViewController, NSInteger idx, NSInteger count);
/**
 当前状态
 
 - JCPageViewControllerIndexExStatusNormal: 普通状态，可以加载更多
 - JCPageViewControllerIndexExStatusLoadingMore: 正在加载更多中
 - JCPageViewControllerIndexExStatusNoMore: 没有更多数据了
 */
typedef NS_ENUM(NSUInteger, JCPageViewControllerIndexExStatus) {
    JCPageViewControllerIndexExStatusNormal,
    JCPageViewControllerIndexExStatusLoadingMore,
    JCPageViewControllerIndexExStatusNoMore
};

@interface JCPageViewControllerIndexEx : JCPageViewController
///当前选中的Index, 设置此index不会触发 viewControllerDidCompleteTransitionBlock回调
@property (nonatomic, assign) NSInteger selectedIndex;
- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;
///是否可以无限循环
@property (nonatomic, assign, getter = isCanLoop) BOOL canLoop;
///调用viewControllerCountBlock获得
@property (assign, nonatomic, readonly) NSInteger pageCount;
#pragma mark 加载更多的逻辑
///是否需要加载更多的回调，如果当前状态为HJBasePageViewControllerLoadStatusNormal才会回调
@property (nonatomic, copy, nullable) JCPageViewControllerIndexExNeedLoaddMoreBlock needLoadMoreBlock;
///状态为HJBasePageViewControllerLoadStatusNormal才会触发needLoadMoreBlock
@property (nonatomic, assign) JCPageViewControllerIndexExStatus loadingStatus;
///如果在needLoadMoreBlock返回YES，则会触发此回调，在数据加载完成时应该把loadingStatus设置为相应的Normal或者HJBasePageViewControllerLoadStatusNoMore
@property (nonatomic, copy, nullable) JCPageViewControllerIndexExLoaddMoreBlock loadMoreBlock;
///停止加载更多，就是将loadingStatus改为HJBasePageViewControllerLoadStatusNormal
- (void)endRefreshing;
///重新加载当前的ViewController
- (void)reloadSelectedViewController;
#pragma mark - callbacks
///PageViewController获取ViewController的回调，必须设置
@property (nonatomic, copy) JCPageViewControllerIndexExBlock viewControllerAtIndexBlock;
///PageViewController获取数据数量的回调, 必须设置
@property (nonatomic, copy) JCPageViewControllerIndexExCountBlock viewControllerCountBlock;

@end

@protocol JCPageViewControllerIndexExItemVC <JCPageViewControllerItemVC>
///当前的Index
@property (nonatomic, assign) NSInteger selectedIndexForPage;
@end

@interface UIViewController (JCPageViewControllerIndexExItemVC) <JCPageViewControllerIndexExItemVC>


@end

NS_ASSUME_NONNULL_END

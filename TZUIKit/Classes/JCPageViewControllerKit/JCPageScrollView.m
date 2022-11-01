//
//  JCPageScrollView.m
//  JCPageViewControllerDemo
//
//  Created by huajiao on 2018/4/11.
//  Copyright © 2018年 huajiao. All rights reserved.
//

#import "JCPageScrollView.h"
#import <objc/runtime.h>
#import <Masonry/Masonry.h>

@interface JCPageScrollContainerView : UIView
@property (strong, nonatomic) UIView *contentView;
@end
@implementation JCPageScrollContainerView
- (void)layoutSubviews{
    [super layoutSubviews];
    self.contentView.frame = self.bounds;
}
@end

@interface JCPageScrollViewOrientation : NSObject{
    @protected
    __weak JCPageScrollView *_scrollView;
}

- (instancetype)initWithScrollView:(JCPageScrollView *)scrollView;

@property (nonatomic, weak) JCPageScrollView *scrollView;
- (JCPageScrollViewNavigationOrientation)orientationType;
- (void)setAlwaysBounce;
- (void)setContainerViewsFrame:(UIView *)obj idx:(NSUInteger)idx;
- (CGSize)contentSize;
- (CGPoint)contentOffsetForSelectedView;
- (CGPoint)contentOffsetForBeforeView;
- (CGPoint)contentOffsetForAfterView;
- (BOOL)isShouldLoadBeforeView;
- (UIEdgeInsets)contentInsetForNoBeforeView;
- (BOOL)isShouldLoadAfterView;
- (UIEdgeInsets)contentInsetForNoAfterView;
- (UIEdgeInsets)contentInsetForNoBeforeAndAfterView;
- (BOOL)isShouldSetBeforeViewToSelectedView;
- (BOOL)isShouldSetAfterViewToSelectedView;
@end


@implementation JCPageScrollViewOrientation

- (instancetype)initWithScrollView:(JCPageScrollView *)scrollView{
    if (self = [super init]) {
        _scrollView = scrollView;
    }
    return self;
}

- (JCPageScrollViewNavigationOrientation)orientationType{
    return JCPageScrollViewNavigationOrientationHorizontal;
}
- (void)setAlwaysBounce{
    
}
- (void)setContainerViewsFrame:(UIView *)obj idx:(NSUInteger)idx{
    
}
- (CGPoint)contentOffsetForSelectedView{
    return CGPointZero;
}
- (CGPoint)contentOffsetForBeforeView{
    return CGPointZero;
}
- (CGPoint)contentOffsetForAfterView{
    return CGPointZero;
}
- (BOOL)isShouldLoadBeforeView{
    return NO;
}
- (UIEdgeInsets)contentInsetForNoBeforeView{
    return UIEdgeInsetsZero;
}
- (BOOL)isShouldLoadAfterView{
    return NO;
}
- (UIEdgeInsets)contentInsetForNoAfterView{
    return UIEdgeInsetsZero;
}
- (UIEdgeInsets)contentInsetForNoBeforeAndAfterView{
    return UIEdgeInsetsZero;
}
- (BOOL)isShouldSetBeforeViewToSelectedView{
    return NO;
}
- (BOOL)isShouldSetAfterViewToSelectedView{
    return NO;
}
- (CGSize)contentSize{
    return CGSizeZero;
}

@end

@interface JCPageScrollViewOrientationVertical : JCPageScrollViewOrientation

@end

@interface JCPageScrollViewOrientationHorizontal : JCPageScrollViewOrientation

@end

@interface JCPageScrollView () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSArray <__kindof UIView *> *containerViews;//有三个视图容器，初始化ScrollView时就创建好

@property (nonatomic, readonly) JCPageScrollContainerView *selectedViewContainerView;//当中的View的ContainerView

@property (nonatomic, readonly) JCPageScrollContainerView *beforeViewContainerView;//最前面的容器

@property (nonatomic, readonly) JCPageScrollContainerView *afterViewContainerView;//最后面的容器

@property (nonatomic, weak) id<UIScrollViewDelegate> theDelegate;

@property (nonatomic, assign, getter = isNeedLoadAfterView) BOOL needLoadAfterView;//用来限制是否需要加载下一个View

@property (nonatomic, assign, getter = isNeedLoadBeforeView) BOOL needLoadBeforeView;//用来限制是否需要加载上一个View

@property (nonatomic, strong, nullable) UIView *beforeView;
@property (nonatomic, strong, nullable) UIView *afterView;

@property (nonatomic, weak, nullable) UIView *transitioningView;//当前正在切换的视图

@property (nonatomic, assign, getter = isTransitionComplete) BOOL transitionComplete;//当前切换是否完成了，给Controller使用的，controller需要重新调用划走的VC的appearmethods

#pragma mark 方向类
@property (nonatomic, strong) JCPageScrollViewOrientation *orientation;

#pragma mark 重用

@property (nonatomic, strong) NSMutableDictionary <NSString *, NSMutableSet <UIView *> *> * reusableViews;

@property (assign, nonatomic, getter=isNeedLoadBeforeViewOnce) BOOL needLoadBeforeViewOnce;
@property (assign, nonatomic, getter=isNeedLoadAfterViewOnce) BOOL needLoadAfterViewOnce;

@end

@implementation JCPageScrollView
- (instancetype)initWithFrame:(CGRect)frame
              orientationType:(JCPageScrollViewNavigationOrientation)orientationType {
    self = [super initWithFrame:frame];
    if (self) {
        self.navigationOrientationType = orientationType;
        self.maxCacheCountPerIdentifier = 1;
        [self setupContainerViews];
    }
    return self;
}

- (instancetype)initWithOrientationType:(JCPageScrollViewNavigationOrientation)orientationType{
  return [self initWithFrame:CGRectZero orientationType:orientationType];
}

- (instancetype)init{
  NSAssert(NO, @"not supported!");
  return nil;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    NSAssert(NO, @"not supported!");
    return nil;
}

- (void)setDelegate:(id<UIScrollViewDelegate>)delegate{
    _theDelegate = delegate;
}

- (void)dealloc {
    _theDelegate = nil;
    [super setDelegate:nil];
}

- (void)setupContainerViews{
//    self.pagingEnabled = YES;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    [self _resetData];
    [super setDelegate:self];
    [self.containerViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addSubview:obj];
    }];
    
    self.panGestureRecognizer.delegate = self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if(_canScrollBlock){
        return _canScrollBlock(self,self.selectedView, gestureRecognizer);
    }
    return YES;
}

- (void)setBounds:(CGRect)bounds{
    CGRect lastBounds = self.bounds;
    [super setBounds:bounds];
    if(!CGSizeEqualToSize(lastBounds.size, bounds.size)){
        [self _reSetContentSizeAndLayout];
    }
}

- (void)_reSetContentSizeAndLayout{
    CGSize lastContentSize = self.contentSize;
    CGSize contentSize = [self theContentSize];
    if(CGSizeEqualToSize(lastContentSize, contentSize)){
        return ;
    }
    
    [self.containerViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self setContainerViewsFrame:obj idx:idx];
    }];
    
    self.contentSize = contentSize;
    self.contentOffset = [self contentOffsetForSelectedView];
}

- (void)setCanLoadBeforeAndAfterView{
    
    if (!_beforeView) {
        _needLoadBeforeView = YES;
    }
    if (!_afterView) {
        _needLoadAfterView = YES;
    }
    self.contentInset = UIEdgeInsetsZero;
}

- (void)setNavigationOrientationType:(JCPageScrollViewNavigationOrientation)navigationOrientationType{
    switch (navigationOrientationType) {
        case JCPageScrollViewNavigationOrientationVertical:
            self.orientation = [[JCPageScrollViewOrientationVertical alloc] initWithScrollView:self];
            break;
        default:
            self.orientation = [[JCPageScrollViewOrientationHorizontal alloc] initWithScrollView:self];
            break;
    }
}

- (JCPageScrollViewNavigationOrientation)navigationOrientationType{
    return _orientation.orientationType;
}

- (void)setOrientation:(JCPageScrollViewOrientation *)orientation{
    if (_orientation == orientation) {
        return ;
    }
    _orientation = orientation;
    
    [_orientation setAlwaysBounce];
    [self _setContentInsetByBeforeAndAfterView];
    [self _reSetContentSizeAndLayout];
}

- (NSArray <UIView *> *)containerViews{
    if (!_containerViews) {
        _containerViews = @[[[JCPageScrollContainerView alloc] init],[[JCPageScrollContainerView alloc] init],[[JCPageScrollContainerView alloc] init]];
    }
    return _containerViews;
}


- (JCPageScrollContainerView *)beforeViewContainerView{
    return self.containerViews.firstObject;
}
static const NSInteger kSelectedIdx = 1;
- (JCPageScrollContainerView *)selectedViewContainerView{
    return [self containerViewAtIndex:kSelectedIdx];
}

- (JCPageScrollContainerView *)afterViewContainerView{
    return self.containerViews.lastObject;
}

- (UIView *)containerViewAtIndex:(NSInteger)index{
    return self.containerViews[index];
}

- (NSMutableDictionary<NSString *,NSMutableSet<UIView *> *> *)reusableViews{
    if (!_reusableViews) {
        _reusableViews = [NSMutableDictionary dictionary];
    }
    return _reusableViews;
}

- (UIView *)dequeueReusableViewWithIdentifier:(NSString *)identifier{
    NSMutableSet <UIView *> *views = _reusableViews[identifier];
    if (!views) {
        views = [NSMutableSet set];
        self.reusableViews[identifier] = views;
    }
    
    UIView *view = [views anyObject];
    if (view) {
        [views removeObject:view];
    }
    return view;
}


- (void)setBeforeView:(UIView *)beforeView{
    [_beforeView removeFromSuperview];
    _beforeView = beforeView;
    self.beforeViewContainerView.contentView = beforeView;
    [self.beforeViewContainerView addSubview:beforeView];
//    [beforeView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.beforeViewContainerView);
//    }];
}

- (void)setSelectedView:(UIView *)selectedView{
    [self setSelectedView:selectedView resetData:YES];
}

- (void)setSelectedView:(UIView *)selectedView resetData:(BOOL)resetData{
    [_selectedView removeFromSuperview];
    _selectedView = selectedView;
    self.selectedViewContainerView.contentView = selectedView;
    [self.selectedViewContainerView addSubview:selectedView];
//    [selectedView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.selectedViewContainerView);
//    }];
    
    self.contentOffset = [self contentOffsetForSelectedView];
    self.contentInset = UIEdgeInsetsZero;
    
    if (resetData) {
        [self _resetData];
    }
}

- (void)setTransitioningViewAndCallback:(UIView *)transitioningView{
    if (_transitioningView == transitioningView) {
        return ;
    }
    UIView *lastTransitionView = _transitioningView;
    _transitioningView = transitioningView;
    if (_transitionViewDidChangeBlock) {
        _transitionViewDidChangeBlock(self, lastTransitionView, transitioningView);
    }
    
}

- (void)_resetData{
    _needLoadAfterView = YES;
    _needLoadBeforeView = YES;
    _transitionComplete = YES;
    _transitioningView = nil;
    [self _cacheOrRemoveView:_beforeView];
    self.beforeView = nil;
    [self _cacheOrRemoveView:_afterView];
    self.afterView = nil;
}

- (void)_setContentInsetByBeforeAndAfterView{
    
    if (!_beforeView && !_afterView) {
        self.contentInset = [self contentInsetForNoBeforeAndAfterView];
        return;
    }
    
    if (!_beforeView) {
        self.contentInset = [self contentInsetForNoBeforeView];
        return;
    }
    
    if (!_afterView) {
        self.contentInset = [self contentInsetForNoAfterView];
        return;
    }
    
    self.contentInset = UIEdgeInsetsZero;
}

- (void)setAfterView:(UIView *)afterView{
    [_afterView removeFromSuperview];
    _afterView = afterView;
    self.afterViewContainerView.contentView = afterView;
    [self.afterViewContainerView addSubview:afterView];
//    [afterView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.afterViewContainerView);
//    }];
}

- (void)setContentOffsetToSelectView{
    self.contentOffset = [self contentOffsetForSelectedView];
}

- (void)setNeedReloadBeforeView{
    _needLoadBeforeView = YES;
    [self _cacheOrRemoveView:_beforeView];
    self.beforeView = nil;
}

- (void)setNeedReloadAfterView{
    _needLoadAfterView = YES;
    [self _cacheOrRemoveView:_afterView];
    self.afterView = nil;
}

#pragma mark - ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(!_needTriggerScrollCallbacks){//只有拖动手势开始时才需要触发这些回调
        return ;
    }
    if ([self isShouldLoadAfterView]){//加载下一个视图
        if (_needLoadAfterView) {
            _needLoadAfterView = NO;
            if (_viewAfterSelectedViewBlock) {
                self.afterView = _viewAfterSelectedViewBlock(self, _selectedView);
            }
            [self _setContentInsetByBeforeAndAfterView];
        }
        
        if (_afterView) {
            if (_transitionComplete) {//调用一次就不调了
                _transitionComplete = NO;
                _transitioningView = _afterView;
                if (_viewWillTransitionBlock) {
                    _viewWillTransitionBlock(self, _selectedView, _afterView);
                }
                return ;
            }
            
            [self setTransitioningViewAndCallback:_afterView];
        }
    }else if ([self isShouldLoadBeforeView]){//加载上一个视图
        
        if (_needLoadBeforeView) {
            _needLoadBeforeView = NO;
            if (_viewBeforeSelectedViewBlock) {
                self.beforeView = _viewBeforeSelectedViewBlock(self, _selectedView);
            }
            [self _setContentInsetByBeforeAndAfterView];
        }
        if (_beforeView) {
            if (_transitionComplete) {//调用一次就不调了
                _transitionComplete = NO;
                _transitioningView = _beforeView;
                if (_viewWillTransitionBlock) {
                    _viewWillTransitionBlock(self, _selectedView, _beforeView);
                }
                return ;
            }
            
            [self setTransitioningViewAndCallback:_beforeView];
        }
        
    }
    if ([self isShouldSetAfterViewToSelectedView]){//上滑出了下一个
        _needLoadAfterView = YES;
        _needLoadBeforeView = _needLoadBeforeViewOnce;//因为上一个还在视图中，所以不需要加载新的视图
        if (_needLoadBeforeViewOnce) {//只起一次作用
            _needLoadBeforeViewOnce = NO;
        }
        _transitionComplete = YES;
        [_afterView removeFromSuperview];
        [_beforeView removeFromSuperview];
        [_selectedView removeFromSuperview];
        
        [self _cacheOrRemoveView:_beforeView];//判断是否需要缓存，不需要则直接移除
        
        _beforeView = nil;
        UIView *beforView = _selectedView;
        if (!_needLoadBeforeView) {//如果不需要加载前一个视图，则将当期的视图做为前一个视图放好
            self.beforeView = beforView;
        }
        _selectedView = nil;
        [self setSelectedView:_afterView resetData:NO];
        
        if (_viewDidTransitionBlock) {
            _viewDidTransitionBlock(self, beforView, _selectedView);
        }
        _afterView = nil;
    }
    if ([self isShouldSetBeforeViewToSelectedView]) {//下拉出上一个
        _needLoadBeforeView = YES;
        _needLoadAfterView = _needLoadAfterViewOnce;//因为上一个还在视图中，所以不需要加载新的视图
        if (_needLoadAfterViewOnce) {//只起一次作用
            _needLoadAfterViewOnce = NO;
        }
        _transitionComplete = YES;
        [_beforeView removeFromSuperview];
        [_selectedView removeFromSuperview];
        [_afterView removeFromSuperview];
        
        [self _cacheOrRemoveView:_afterView];//判断是否需要缓存，不需要则直接移除
        
        _afterView = nil;
        UIView *afterView = _selectedView;
        if (!_needLoadAfterView) {
            self.afterView = afterView;
        }
        _selectedView = nil;
        [self setSelectedView:_beforeView resetData:NO];
        
        if (_viewDidTransitionBlock) {
            _viewDidTransitionBlock(self, afterView, _selectedView);
        }
        _beforeView = nil;
    }
    
    if ([_theDelegate respondsToSelector:_cmd]) {
        [_theDelegate scrollViewDidScroll:scrollView];
    }
}

- (BOOL)_cacheViewIfNeedForReuse:(UIView *)view{
    if (!view) {
        return NO;
    }
    NSString *identifier = view.jc_pageScrollViewReuseIdentifier;
    if (!identifier.length) {
        return NO;
    }
    NSMutableSet <UIView *>* views = _reusableViews[identifier];
    
    if (views.count >= _maxCacheCountPerIdentifier) {
        return NO;
    }
    if (!views) {
        views = [NSMutableSet set];
        self.reusableViews[identifier] = views;
    }
    
    [views addObject:view];
    return YES;
}

- (void)_cacheOrRemoveView:(UIView *)view{
    BOOL needCache = [self _cacheViewIfNeedForReuse:view];
    if (!needCache) {
        //AfterView不需要了，移除
        if (_viewDidRemoveFromSuperViewBlock) {
            _viewDidRemoveFromSuperViewBlock(self, view);
        }
    }
}

#pragma mark - orientation methods start
- (void)setContainerViewsFrame:(UIView *)obj idx:(NSUInteger)idx{
    [_orientation setContainerViewsFrame:obj idx:idx];
}
- (CGPoint)contentOffsetForSelectedView{
    return [_orientation contentOffsetForSelectedView];
}

- (CGPoint)contentOffsetForBeforeView{
    return [_orientation contentOffsetForBeforeView];
}

- (void)setSelectedViewToLeft:(UIView * _Nonnull)selectedView{
    _needLoadAfterViewOnce = YES;
    _needLoadBeforeView = NO;
    self.beforeView = selectedView;
    [self _setContentInsetByBeforeAndAfterView];
    [self setContentOffset:[self contentOffsetForBeforeView] animated:YES];
}

- (CGPoint)contentOffsetForAfterView{
    return [_orientation contentOffsetForAfterView];
}

- (void)setSelectedViewToRight:(UIView *)selectedView{
    _needLoadBeforeViewOnce = YES;
    _needLoadAfterView = NO;
    self.afterView = selectedView;
    [self _setContentInsetByBeforeAndAfterView];
    [self setContentOffset:[self contentOffsetForAfterView] animated:YES];
}

- (BOOL)isShouldLoadBeforeView{
    return [_orientation isShouldLoadBeforeView];
}
- (UIEdgeInsets)contentInsetForNoBeforeView{
    return [_orientation contentInsetForNoBeforeView];
}
- (BOOL)isShouldLoadAfterView{
    return [_orientation isShouldLoadAfterView];
}
- (UIEdgeInsets)contentInsetForNoAfterView{
    return [_orientation contentInsetForNoAfterView];
}

- (UIEdgeInsets)contentInsetForNoBeforeAndAfterView{
    return [_orientation contentInsetForNoBeforeAndAfterView];
}

- (BOOL)isShouldSetBeforeViewToSelectedView{
    return [_orientation isShouldSetBeforeViewToSelectedView];
}
- (BOOL)isShouldSetAfterViewToSelectedView{
    return [_orientation isShouldSetAfterViewToSelectedView];
}
- (CGSize)theContentSize{
    return [_orientation contentSize];
}

#pragma mark - orientation methods end

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (_scrollDidEndBlock) {
        _scrollDidEndBlock(self, _transitioningView, _selectedView, _transitionComplete);
    }
    _transitionComplete = YES;
    _transitioningView = nil;
    _needTriggerScrollCallbacks = NO;
    if ([_theDelegate respondsToSelector:_cmd]) {
        [_theDelegate scrollViewDidEndDecelerating:scrollView];
    }
    self.pagingEnabled = NO;
}

// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if ([_theDelegate respondsToSelector:_cmd]) {
        [_theDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    
    if ([_theDelegate respondsToSelector:_cmd]) {
        [_theDelegate scrollViewDidZoom:scrollView];
    }
    
}

// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _needTriggerScrollCallbacks = YES;
    self.pagingEnabled = YES;
    if ([_theDelegate respondsToSelector:_cmd]) {
        [_theDelegate scrollViewWillBeginDragging:scrollView];
    }
}
// called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    if ([_theDelegate respondsToSelector:_cmd]) {
        [_theDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}


- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    if ([_theDelegate respondsToSelector:_cmd]) {
        [_theDelegate scrollViewWillBeginDecelerating:scrollView];
    }
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    if ([_theDelegate respondsToSelector:_cmd]) {
        [_theDelegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    if ([_theDelegate respondsToSelector:_cmd]) {
        return [_theDelegate viewForZoomingInScrollView:scrollView];
    }
    return nil;
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view{
    if ([_theDelegate respondsToSelector:_cmd]) {
        [_theDelegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale{
    if ([_theDelegate respondsToSelector:_cmd]) {
        [_theDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
    if ([_theDelegate respondsToSelector:_cmd]) {
        return [_theDelegate scrollViewShouldScrollToTop:scrollView];
    }
    return NO;
}
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    if ([_theDelegate respondsToSelector:_cmd]) {
        [_theDelegate scrollViewDidScrollToTop:scrollView];
    }
}

- (void)scrollViewDidChangeAdjustedContentInset:(UIScrollView *)scrollView{
  if (@available(iOS 11.0, *)) {
    if ([_theDelegate respondsToSelector:_cmd]) {
        [_theDelegate scrollViewDidChangeAdjustedContentInset:scrollView];
    }
  }
}

@end

@implementation JCPageScrollViewOrientationVertical

- (JCPageScrollViewNavigationOrientation)orientationType{
    return JCPageScrollViewNavigationOrientationVertical;
}

- (void)setAlwaysBounce{
    _scrollView.alwaysBounceVertical = YES;
    _scrollView.alwaysBounceHorizontal = NO;
}

- (void)setContainerViewsFrame:(UIView *)obj idx:(NSUInteger)idx{
    obj.frame = CGRectMake(0, CGRectGetHeight(_scrollView.frame) * idx, CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame));
}

- (CGPoint)contentOffsetForSelectedView{
    return CGPointMake(0, CGRectGetHeight(_scrollView.frame));
}

- (CGPoint)contentOffsetForAfterView{
    return CGPointMake(0, CGRectGetHeight(_scrollView.frame) * 2);
}

- (BOOL)isShouldLoadBeforeView{
    return _scrollView.contentOffset.y < CGRectGetHeight(_scrollView.frame);
}

- (UIEdgeInsets)contentInsetForNoBeforeView{
    return UIEdgeInsetsMake(-CGRectGetHeight(_scrollView.frame), 0, 0, 0);
}

- (BOOL)isShouldLoadAfterView{
    return _scrollView.contentOffset.y > CGRectGetHeight(_scrollView.frame);
}

- (UIEdgeInsets)contentInsetForNoAfterView{
    return UIEdgeInsetsMake(0, 0,  -CGRectGetHeight(_scrollView.frame), 0);
}

- (UIEdgeInsets)contentInsetForNoBeforeAndAfterView{
    return UIEdgeInsetsMake(-CGRectGetHeight(_scrollView.frame), 0,  -CGRectGetHeight(_scrollView.frame), 0);
}

- (BOOL)isShouldSetBeforeViewToSelectedView{
    return _scrollView.contentOffset.y <= 0;
}
- (BOOL)isShouldSetAfterViewToSelectedView{
    return _scrollView.contentOffset.y >= CGRectGetHeight(_scrollView.frame) * 2;
}
- (CGSize)contentSize{
    return CGSizeMake(CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame) * _scrollView.containerViews.count);
}

@end

@implementation JCPageScrollViewOrientationHorizontal

- (JCPageScrollViewNavigationOrientation)orientationType{
    return JCPageScrollViewNavigationOrientationHorizontal;
}

- (void)setAlwaysBounce{
    _scrollView.alwaysBounceVertical = NO;
    _scrollView.alwaysBounceHorizontal = YES;
}

- (void)setContainerViewsFrame:(UIView *)obj idx:(NSUInteger)idx{
    obj.frame = CGRectMake(CGRectGetWidth(_scrollView.frame) * idx, 0, CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame));
}

- (CGPoint)contentOffsetForSelectedView{
    return CGPointMake(CGRectGetWidth(_scrollView.frame), 0);
}

- (CGPoint)contentOffsetForAfterView{
    return CGPointMake(CGRectGetWidth(_scrollView.frame) * 2, 0);
}

- (BOOL)isShouldLoadBeforeView{
    return _scrollView.contentOffset.x < CGRectGetWidth(_scrollView.frame);
}

- (UIEdgeInsets)contentInsetForNoBeforeView{
    return UIEdgeInsetsMake(0, -CGRectGetWidth(_scrollView.frame), 0, 0);
}

- (BOOL)isShouldLoadAfterView{
    return _scrollView.contentOffset.x > CGRectGetWidth(_scrollView.frame);
}

- (UIEdgeInsets)contentInsetForNoAfterView{
    return UIEdgeInsetsMake(0, 0, 0, -CGRectGetWidth(_scrollView.frame));
}
- (UIEdgeInsets)contentInsetForNoBeforeAndAfterView{
    return UIEdgeInsetsMake(0, -CGRectGetWidth(_scrollView.frame), 0, -CGRectGetWidth(_scrollView.frame));
}

- (BOOL)isShouldSetBeforeViewToSelectedView{
    return _scrollView.contentOffset.x <= 0;
}
- (BOOL)isShouldSetAfterViewToSelectedView{
    return _scrollView.contentOffset.x >= CGRectGetWidth(_scrollView.frame) * 2;
}
- (CGSize)contentSize{
    return CGSizeMake( CGRectGetWidth(_scrollView.frame) * _scrollView.containerViews.count, CGRectGetHeight(_scrollView.frame));
}

@end



@implementation UIView (JCPageScrollView)
- (void)setJc_pageScrollViewReuseIdentifier:(NSString *)jc_pageScrollViewReuseIdentifier{
    objc_setAssociatedObject(self, @selector(jc_pageScrollViewReuseIdentifier), jc_pageScrollViewReuseIdentifier, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)jc_pageScrollViewReuseIdentifier{
    return objc_getAssociatedObject(self, _cmd);
}

@end



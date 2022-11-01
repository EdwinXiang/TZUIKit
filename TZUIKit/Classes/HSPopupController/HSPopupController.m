//
//  HSPopupController.m
//  HSUIKit
//
//  Created by Edwin on 2022/8/2.
//

#import "HSPopupController.h"

#define CORNER_RADIUS 16.f

@interface HSPopupController ()<UIViewControllerAnimatedTransitioning>

@property (nonatomic, strong) UIView *dimmingView;
@property (nonatomic, strong) UIView *presentationWrappingView;

@end

@implementation HSPopupController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    
    if (self) {
        presentedViewController.modalPresentationStyle = UIModalPresentationCustom;
        self.tapDimmViewGestureEnable = YES;
        self.transitionDuration = 0.3;
        self.alpha = 0.5;
    }
    
    return self;
}

- (UIView*)presentedView {
    return self.presentationWrappingView;
}

- (void)presentationTransitionWillBegin {
    UIView *presentedViewControllerView = [super presentedView];
    
    UIView *presentationWrapperView = [[UIView alloc] initWithFrame:self.frameOfPresentedViewInContainerView];
    presentationWrapperView.layer.shadowOpacity = 0;
    presentationWrapperView.layer.shadowRadius = 13.f;
    presentationWrapperView.layer.shadowOffset = CGSizeMake(0, -6.f);
    self.presentationWrappingView = presentationWrapperView;
    
    // 圆角处理，iPhone 只有上圆角，iPad 是上下都有圆角
    CGRect presentationRoundedCornerViewFrame = presentationWrapperView.bounds;
//        if (!LBConst.isiPad) {
            presentationRoundedCornerViewFrame = UIEdgeInsetsInsetRect(presentationWrapperView.bounds, UIEdgeInsetsMake(0, 0, -CORNER_RADIUS, 0));
//        }
    UIView *presentationRoundedCornerView = [[UIView alloc] initWithFrame:presentationRoundedCornerViewFrame];
    presentationRoundedCornerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    presentationRoundedCornerView.layer.cornerRadius = CORNER_RADIUS;
    presentationRoundedCornerView.layer.masksToBounds = YES;
    
    CGRect presentedViewControllerWrapperViewFrame = presentationRoundedCornerView.bounds;
//        if (!LBConst.isiPad) {
            presentedViewControllerWrapperViewFrame = UIEdgeInsetsInsetRect(presentationRoundedCornerView.bounds, UIEdgeInsetsMake(0, 0, CORNER_RADIUS, 0));
//        }
    UIView *presentedViewControllerWrapperView = [[UIView alloc] initWithFrame:presentedViewControllerWrapperViewFrame];
    presentedViewControllerWrapperView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    presentedViewControllerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    presentedViewControllerView.frame = presentedViewControllerWrapperView.bounds;
    [presentedViewControllerWrapperView addSubview:presentedViewControllerView];
    [presentationRoundedCornerView addSubview:presentedViewControllerWrapperView];
    [presentationWrapperView addSubview:presentationRoundedCornerView];
    
    UIView *dimmingView = [[UIView alloc] initWithFrame:self.containerView.bounds];
    dimmingView.backgroundColor = [UIColor blackColor];
    dimmingView.opaque = NO;
    dimmingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [dimmingView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dimmingViewTapped:)]];
    dimmingView.userInteractionEnabled = self.tapDimmViewGestureEnable;
    self.dimmingView = dimmingView;
    [self.containerView addSubview:dimmingView];
    
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.presentingViewController.transitionCoordinator;
    
    self.dimmingView.alpha = 0.f;
    [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.dimmingView.alpha = self.alpha;
    } completion:NULL];
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    if (completed == NO) {
        self.presentationWrappingView = nil;
        self.dimmingView = nil;
    }
}

- (void)dismissalTransitionWillBegin {
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.presentingViewController.transitionCoordinator;
    
    [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.dimmingView.alpha = 0.f;
    } completion:NULL];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    if (completed == YES) {
        self.presentationWrappingView = nil;
        self.dimmingView = nil;
    }
}

#pragma mark Layout
- (void)preferredContentSizeDidChangeForChildContentContainer:(id<UIContentContainer>)container {
    [super preferredContentSizeDidChangeForChildContentContainer:container];
    
    if (container == self.presentedViewController) {
        [self.containerView setNeedsLayout];
    }
    [UIView animateWithDuration:self.transitionDuration animations:^{
        [self.containerView layoutIfNeeded];
    }];
}

- (CGSize)sizeForChildContentContainer:(id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
    if (container == self.presentedViewController) {
        return ((UIViewController *)container).preferredContentSize;
    } else {
        return [super sizeForChildContentContainer:container withParentContainerSize:parentSize];
    }
}

- (CGRect)frameOfPresentedViewInContainerView {
    CGRect containerViewBounds = self.containerView.bounds;
    CGSize presentedViewContentSize = [self sizeForChildContentContainer:self.presentedViewController withParentContainerSize:containerViewBounds.size];
    
    CGRect presentedViewControllerFrame = containerViewBounds;
    //    if (LBConst.isiPad) {
    //        CGFloat topBottomMargin = 50.0;
    //        presentedViewControllerFrame.size.height = MIN(presentedViewContentSize.height, containerViewBounds.size.height - topBottomMargin * 2.0);
    //        presentedViewControllerFrame.origin.y = CGRectGetMaxY(containerViewBounds) - presentedViewControllerFrame.size.height - topBottomMargin;
    //        presentedViewControllerFrame.size.width = MIN(presentedViewContentSize.width, 375.0);
    //        presentedViewControllerFrame.origin.x = (CGRectGetMaxX(containerViewBounds) - presentedViewControllerFrame.size.width) / 2.0;
    //    } else {
    presentedViewControllerFrame.size.height = presentedViewContentSize.height;
    presentedViewControllerFrame.origin.y = CGRectGetMaxY(containerViewBounds) - presentedViewControllerFrame.size.height;
    //    }
    return presentedViewControllerFrame;
}

- (void)containerViewWillLayoutSubviews {
    [super containerViewWillLayoutSubviews];
    
    self.dimmingView.frame = self.containerView.bounds;
    self.presentationWrappingView.frame = self.frameOfPresentedViewInContainerView;
}

#pragma mark Tap Gesture Recognizer

- (void)dimmingViewTapped:(UITapGestureRecognizer*)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return [transitionContext isAnimated] ? self.transitionDuration : 0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = transitionContext.containerView;
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    BOOL isPresenting = (fromViewController == self.presentingViewController);
    CGRect __unused fromViewInitialFrame = [transitionContext initialFrameForViewController:fromViewController];
    CGRect fromViewFinalFrame = [transitionContext finalFrameForViewController:fromViewController];
    CGRect toViewInitialFrame = [transitionContext initialFrameForViewController:toViewController];
    CGRect toViewFinalFrame = [transitionContext finalFrameForViewController:toViewController];
    
    [containerView addSubview:toView];
    
    if (isPresenting) {
        toViewInitialFrame.size = toViewFinalFrame.size;
        toViewInitialFrame.origin.x = (CGRectGetMaxX(containerView.bounds) - toViewInitialFrame.size.width) / 2.0;
        toViewInitialFrame.origin.y = CGRectGetMaxY(containerView.bounds);
        toView.frame = toViewInitialFrame;
    } else {
        fromViewFinalFrame = CGRectOffset(fromView.frame, 0, CGRectGetHeight(fromView.frame));
    }
    
    NSTimeInterval transitionDuration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:transitionDuration animations:^{
        if (isPresenting) {
            toView.frame = toViewFinalFrame;
        } else {
            fromView.frame = fromViewFinalFrame;
        }
    } completion:^(BOOL finished) {
        BOOL wasCancelled = [transitionContext transitionWasCancelled];
        [transitionContext completeTransition:!wasCancelled];
    }];
}

#pragma mark UIViewControllerTransitioningDelegate

- (UIPresentationController*)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    NSAssert(self.presentedViewController == presented, @"You didn't initialize %@ with the correct presentedViewController.  Expected %@, got %@.",
             self, presented, self.presentedViewController);
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}
@end

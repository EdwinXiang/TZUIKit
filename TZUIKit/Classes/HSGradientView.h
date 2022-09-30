//
//  HSGradientView.h
//  HSUIKit
//
//  Created by Edwin on 2022/8/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSGradientView : UIView
@property (strong, nonatomic, readonly) CAGradientLayer *gradientLayer;
@property (strong, nonatomic) NSArray <UIColor *> *colors;
@property (assign, nonatomic) CGPoint startPoint;
@property (assign, nonatomic) CGPoint endPoint;
@property (copy, nonatomic, nullable) NSArray<NSNumber *> *locations;
@end

NS_ASSUME_NONNULL_END

//
//  HSGradientView.m
//  HSUIKit
//
//  Created by Edwin on 2022/8/24.
//

#import "HSGradientView.h"

@implementation HSGradientView

+ (Class)layerClass{
    return CAGradientLayer.class;
}

- (CAGradientLayer *)gradientLayer{
    return (CAGradientLayer *)self.layer;
}

- (void)setColors:(NSArray<UIColor *> *)colors{
    NSMutableArray *colorsCG = [NSMutableArray arrayWithCapacity:colors.count];
    for (UIColor *color in colors) {
        [colorsCG addObject:(__bridge id)color.CGColor];
    }
    self.gradientLayer.colors = colorsCG;
}

- (NSArray<UIColor *> *)colors{
    NSMutableArray<UIColor *> *colors = [NSMutableArray arrayWithCapacity:self.gradientLayer.colors.count];
    for (int i = 0; i < self.gradientLayer.colors.count; i++) {
        [colors addObject:[UIColor colorWithCGColor:(__bridge CGColorRef _Nonnull)(self.gradientLayer.colors[i])]];
    }
    return colors;
}

- (CGPoint)startPoint{
    return self.gradientLayer.startPoint;
}

- (void)setStartPoint:(CGPoint)startPoint{
    self.gradientLayer.startPoint = startPoint;
}

- (CGPoint)endPoint{
    return self.gradientLayer.endPoint;
}

- (void)setEndPoint:(CGPoint)endPoint{
    self.gradientLayer.endPoint = endPoint;
}

- (void)setLocations:(NSArray<NSNumber *> *)locations{
    self.gradientLayer.locations = locations;
}

- (NSArray<NSNumber *> *)locations{
    return self.gradientLayer.locations;
}
@end

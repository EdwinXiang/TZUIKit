//
//  HSCollectionViewLeftAlignFlowLayout.m
//  HSUIKit
//
//  Created by Edwin on 2022/8/4.
//

#import "HSCollectionViewLeftAlignFlowLayout.h"

@interface HSCollectionViewLeftAlignFlowLayout () {
    CGFloat _sumCellWidth;
}
@end

@implementation HSCollectionViewLeftAlignFlowLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *layoutAttributes_t = [super layoutAttributesForElementsInRect:rect];
    NSArray *layoutAttributes = [[NSArray alloc] initWithArray:layoutAttributes_t copyItems:YES];
    //用来临时存放一行的Cell数组
    NSMutableArray *layoutAttributesTemp = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < layoutAttributes.count; index++) {

        UICollectionViewLayoutAttributes *currentAttr = layoutAttributes[index]; // 当前cell的位置信息
        UICollectionViewLayoutAttributes *previousAttr = index == 0 ? nil : layoutAttributes[index - 1]; // 上一个cell 的位置信
        UICollectionViewLayoutAttributes *nextAttr = index + 1 == layoutAttributes.count ?
                                                     nil : layoutAttributes[index + 1];//下一个cell 位置信息

        [layoutAttributesTemp addObject:currentAttr];
        _sumCellWidth += currentAttr.frame.size.width;

        CGFloat previousY = previousAttr == nil ? 0 : CGRectGetMaxY(previousAttr.frame);
        CGFloat currentY = CGRectGetMaxY(currentAttr.frame);
        CGFloat nextY = nextAttr == nil ? 0 : CGRectGetMaxY(nextAttr.frame);

        if (currentY != previousY && currentY != nextY) {
            if ([currentAttr.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
                [layoutAttributesTemp removeAllObjects];
                _sumCellWidth = 0.0;
            } else if ([currentAttr.representedElementKind isEqualToString:UICollectionElementKindSectionFooter]) {
                [layoutAttributesTemp removeAllObjects];
                _sumCellWidth = 0.0;
            } else {
                [self setCellFrameWith:layoutAttributesTemp];
            }
        } else if (currentY != nextY) {
            [self setCellFrameWith:layoutAttributesTemp];
        }
    }
    return layoutAttributes;
}

//调整属于同一行的cell的位置frame
- (void)setCellFrameWith:(NSMutableArray *)layoutAttributes {
    CGFloat nowWidth = self.sectionInset.left;
    for (UICollectionViewLayoutAttributes *attributes in layoutAttributes) {
        CGRect nowFrame = attributes.frame;
        nowFrame.origin.x = nowWidth;
        attributes.frame = nowFrame;
        nowWidth += nowFrame.size.width;

        CGFloat margin = self.scrollDirection == UICollectionViewScrollDirectionVertical ? self.minimumInteritemSpacing : self.minimumLineSpacing;
        nowWidth += margin;
    }
    _sumCellWidth = 0.0;
    [layoutAttributes removeAllObjects];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return true;
}

@end

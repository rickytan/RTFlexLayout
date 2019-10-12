//
//  UIView+RTFlexLayout.m
//  RTFlexLayout
//
//  Created by ricky on 2019/10/12.
//

#if __has_include(<YogaKit/UIView+Yoga.h>)
#import <YogaKit/UIView+Yoga.h>
#elif __has_include("UIView+Yoga.h")
#import "UIView+Yoga.h"
#endif
#import <objc/runtime.h>

#import "UIView+RTFlexLayout.h"

@interface __RTFlexView : UIView
@end

@implementation __RTFlexView

- (void)setNeedsLayout
{
    [super setNeedsLayout];
    [self.rt_layout markDirty];
}

- (void)invalidateIntrinsicContentSize
{
    [super invalidateIntrinsicContentSize];

    if (self.rt_automaticallyExcludeWhenIntrinsicSizeIsZero) {
        CGSize size = [self intrinsicContentSize];
        self.rt_layout.includedInLayout = size.width == 0 || size.height == 0;
    }

    [self rt_invalidateFlexLayout];
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];

    [self rt_configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        if (layout.isEnabled == hidden) {
            layout.enabled = !hidden;
            layout.includedInLayout = !hidden;
            [self rt_invalidateFlexLayout];
        }
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (self.rt_enableAutoLayoutGuide) {
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:NSClassFromString(@"_UILayoutGuide")]) {
                if (CGRectGetMinY(obj.frame) == 0) {
                    [obj rt_configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
                        layout.enabled = YES;
                        layout.height = YGPointValue(obj.bounds.size.height);
                        layout.width = YGPercentValue(100);
                    }];
                    [self sendSubviewToBack:obj];
                } else if (CGRectGetMaxY(obj.frame) == self.bounds.size.height) {
                    [obj rt_configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
                        layout.enabled = YES;
                        layout.height = YGPointValue(obj.bounds.size.height);
                        layout.width = YGPercentValue(100);
                    }];
                    [self bringSubviewToFront:obj];
                }
            }
        }];
    } else {
        
    }

    if (!self.superview.isYogaEnabled) {
        [self rt_applyFlexLayout];
    }
}

- (void)safeAreaInsetsDidChange
{
    [super safeAreaInsetsDidChange];

    if (!self.superview.isYogaEnabled) {
        UIEdgeInsets insets = self.safeAreaInsets;
        self.rt_layout.paddingTop = YGPointValue(insets.top);
        self.rt_layout.paddingBottom = YGPointValue(insets.bottom);
        self.rt_layout.paddingLeft = YGPointValue(insets.left);
        self.rt_layout.paddingRight = YGPointValue(insets.right);
    }
}

@end

@implementation UIView (RTFlexLayout)

- (YGLayout *)rt_layout
{
    if (!self.isYogaEnabled) {
        YGLayout *layout = self.yoga;
        layout.enabled = !self.isHidden;

        char name[128] = {};
        sprintf(name, "RTFlexNotify_%s", class_getName(self.class));
        Class flexClass = objc_lookUpClass(name);
        if (!flexClass) {
            flexClass = objc_allocateClassPair(self.class, name, 0);
            class_addMethod(flexClass, @selector(setNeedsLayout), class_getMethodImplementation([__RTFlexView class], @selector(setNeedsLayout)), "v@:");
            class_addMethod(flexClass, @selector(invalidateIntrinsicContentSize), class_getMethodImplementation([__RTFlexView class], @selector(invalidateIntrinsicContentSize)), "v@:");
            class_addMethod(flexClass, @selector(layoutSubviews), class_getMethodImplementation([__RTFlexView class], @selector(layoutSubviews)), "v@:");
            class_addMethod(flexClass, @selector(safeAreaInsetsDidChange), class_getMethodImplementation([__RTFlexView class], @selector(safeAreaInsetsDidChange)), "v@:");
            class_addMethod(flexClass, @selector(setHidden:), class_getMethodImplementation([__RTFlexView class], @selector(setHidden:)), "v@:b");
            objc_registerClassPair(flexClass);
        }
        object_setClass(self, flexClass);

        return layout;
    }
    return self.yoga;
}

- (void)setRt_automaticallyExcludeWhenIntrinsicSizeIsZero:(BOOL)rt_automaticallyExcludeWhenIntrinsicSizeIsZero
{
    objc_setAssociatedObject(self, @selector(rt_automaticallyExcludeWhenIntrinsicSizeIsZero), @(rt_automaticallyExcludeWhenIntrinsicSizeIsZero), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)rt_automaticallyExcludeWhenIntrinsicSizeIsZero
{
    return [objc_getAssociatedObject(self, @selector(rt_automaticallyExcludeWhenIntrinsicSizeIsZero)) boolValue];
}

- (void)setRt_enableAutoLayoutGuide:(BOOL)rt_enableAutoLayoutGuide
{
    if (rt_enableAutoLayoutGuide != self.rt_enableAutoLayoutGuide) {
        objc_setAssociatedObject(self, @selector(rt_enableAutoLayoutGuide), @(rt_enableAutoLayoutGuide), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self setNeedsLayout];
    }
}

- (BOOL)rt_enableAutoLayoutGuide
{
    return [objc_getAssociatedObject(self, @selector(rt_enableAutoLayoutGuide)) boolValue];
}

- (void)rt_invalidateFlexLayout
{
    [self setNeedsLayout];

    if (!self.isYogaEnabled) {
        return;
    }

    YGLayout *layout = self.rt_layout;
    [layout markDirty];

    UIView *superview = self.superview;
    UIView *lastFlexView = nil;
    while (superview && superview.isYogaEnabled) {
        lastFlexView = superview;
        superview = superview.superview;
    }
    [lastFlexView rt_invalidateFlexLayout];
}

- (void)rt_applyFlexLayout
{
    if (self.isYogaEnabled) {
        [self.rt_layout applyLayoutPreservingOrigin:YES];
    }
}

- (void)rt_configureLayoutWithBlock:(void (^)(YGLayout * _Nonnull))block
{
    block(self.rt_layout);
}

@end

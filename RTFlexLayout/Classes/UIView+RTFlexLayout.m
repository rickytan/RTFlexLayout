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

#define RTFLEXNOTIFYING_CLASS_PREFIX "RTFlexNotifying_"

@implementation UIView (RTFlexLayout)

+ (void)_rt_flex_addMethodsForClass:(Class)cls {
    const SEL selectors[] = {
        @selector(class),
        @selector(setNeedsLayout),
        @selector(invalidateIntrinsicContentSize),
        @selector(setHidden:),
        @selector(layoutSubviews),
        @selector(safeAreaInsetsDidChange),
    };

    const size_t length = sizeof(selectors) / sizeof(selectors[0]);
    char selName[128] = {};
    for (size_t i = 0; i < length; ++i) {
        const char *type = method_getTypeEncoding(class_getInstanceMethod(cls, selectors[i]));
        if (class_addMethod(cls, selectors[i], class_getMethodImplementation(cls, selectors[i]), type)) {
            sprintf(selName, "_rt_flex_%s", sel_getName(selectors[i]));
            SEL newSelector = sel_registerName(selName);
            class_addMethod(cls, newSelector, class_getMethodImplementation(self, newSelector), type);
            method_exchangeImplementations(class_getInstanceMethod(cls, selectors[i]),
                                           class_getInstanceMethod(cls, newSelector));
        }
    }
}

- (YGLayout *)rt_layout
{
    if (!self.isYogaEnabled) {
        YGLayout *layout = self.yoga;
        layout.enabled = !self.isHidden;

        Class superClass = object_getClass(self);
        const char *superClassName = class_getName(superClass);
        if (strncmp(superClassName, "NSKVONotifying_", 15) == 0) {
            [UIView _rt_flex_addMethodsForClass:superClass];
        }
        else {
            char name[128] = {};
            sprintf(name, RTFLEXNOTIFYING_CLASS_PREFIX "%s", class_getName(superClass));
            Class flexClass = objc_getClass(name);
            if (!flexClass) {
                flexClass = objc_allocateClassPair(superClass, name, 0);
                [UIView _rt_flex_addMethodsForClass:flexClass];
                objc_registerClassPair(flexClass);
            }
            object_setClass(self, flexClass);
        }

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



- (Class)_rt_flex_class
{
    Class cls = [self _rt_flex_class];
    return class_getSuperclass(cls);
}

- (void)_rt_flex_setNeedsLayout
{
    [self _rt_flex_setNeedsLayout];
    [self.rt_layout markDirty];
}

- (void)_rt_flex_invalidateIntrinsicContentSize
{
    [self _rt_flex_invalidateIntrinsicContentSize];

    if (self.rt_automaticallyExcludeWhenIntrinsicSizeIsZero) {
        CGSize size = [self intrinsicContentSize];
        self.rt_layout.includedInLayout = size.width == 0 || size.height == 0;
    }

    [self rt_invalidateFlexLayout];
}

- (void)_rt_flex_setHidden:(BOOL)hidden
{
    [self _rt_flex_setHidden:hidden];

    [self rt_configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        if (layout.isEnabled == hidden) {
            layout.enabled = !hidden;
            layout.includedInLayout = !hidden;
            [self rt_invalidateFlexLayout];
        }
    }];
}

- (void)_rt_flex_layoutSubviews
{
    [self _rt_flex_layoutSubviews];

    if (self.rt_enableAutoLayoutGuide) {
        YGLayout *layout = self.rt_layout;
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:NSClassFromString(@"_UILayoutGuide")]) {
                if (CGRectGetMinY(obj.frame) == 0) {
                    layout.paddingTop = YGPointValue(CGRectGetHeight(obj.bounds));
                } else if (CGRectGetMaxY(obj.frame) == self.bounds.size.height) {
                    layout.paddingBottom = YGPointValue(CGRectGetHeight(obj.bounds));
                }
            }
        }];
    }

    if (!self.superview.isYogaEnabled) {
        [self rt_applyFlexLayout];
    }
}

- (void)_rt_flex_safeAreaInsetsDidChange
{
    [self _rt_flex_safeAreaInsetsDidChange];

    if (!self.superview.isYogaEnabled) {
        if (@available(iOS 11.0, *)) {
            UIEdgeInsets insets = self.safeAreaInsets;
            self.rt_layout.paddingTop = YGPointValue(insets.top);
            self.rt_layout.paddingBottom = YGPointValue(insets.bottom);
            self.rt_layout.paddingLeft = YGPointValue(insets.left);
            self.rt_layout.paddingRight = YGPointValue(insets.right);
        } else {
            // Fallback on earlier versions
        }
    }
}

@end

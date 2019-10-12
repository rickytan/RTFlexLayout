//
//  UIView+RTFlexLayout.h
//  RTFlexLayout
//
//  Created by ricky on 2019/10/12.
//

#import <UIKit/UIKit.h>

#if __has_include(<YogaKit/YGLayout.h>)
#import <YogaKit/YGLayout.h>
#elif __has_include("YogaKit/YGLayout.h")
#import "YogaKit/YGLayout.h"
#else
#error "YogaKit required!"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface UIView (RTFlexLayout)
@property (nonatomic, readonly) YGLayout *rt_layout;
@property (nonatomic, assign) BOOL rt_automaticallyExcludeWhenIntrinsicSizeIsZero;
@property (nonatomic, assign) BOOL rt_enableAutoLayoutGuide;

- (void)rt_applyFlexLayout;
- (void)rt_invalidateFlexLayout;
- (void)rt_configureLayoutWithBlock:(void(^)(YGLayout *layout))block;

@end

NS_ASSUME_NONNULL_END

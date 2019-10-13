//
//  RTViewController.m
//  RTFlexLayout
//
//  Created by rickytan on 10/12/2019.
//  Copyright (c) 2019 rickytan. All rights reserved.
//

#import <RTFlexLayout/RTFlexLayout.h>

#import "RTViewController.h"

@interface RTViewController ()

@end

@implementation RTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.view rt_configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.padding = YGPointValue(10);
        layout.flexDirection = YGFlexDirectionRow;
        layout.flexWrap = YGWrapWrap;
        layout.alignItems = YGAlignFlexStart;
    }];
    
    {
        UILabel *label = [UILabel new];
        label.numberOfLines = 0;
        label.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
        [self.view addSubview:label];
        [label rt_configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.width = YGPercentValue(100);
            layout.marginBottom = YGPointValue(15);
        }];
    }

    for (int i = 0; i < 12; ++i)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];

        button.backgroundColor = [UIColor yellowColor];
        button.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
        button.layer.cornerRadius = 8;
        button.titleLabel.font = [UIFont systemFontOfSize:12];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:[NSString stringWithFormat:@"Tag %d", i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onAction:) forControlEvents:UIControlEventTouchUpInside];
        [button rt_configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.alignSelf = YGAlignCenter;
            layout.marginRight = YGPointValue(6);
            layout.padding = YGPointValue(4);
            layout.minWidth = YGPointValue(64);
            layout.marginBottom = YGPointValue(10);
        }];
        [button addObserver:self forKeyPath:NSStringFromSelector(@selector(frame)) options:NSKeyValueObservingOptionNew context:NULL];
        NSLog(@"%@", [button class]);
        [self.view addSubview:button];
    }

    {
        UILabel *label = [UILabel new];
        label.numberOfLines = 3;
        label.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
        [self.view addSubview:label];
        [label rt_configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.width = YGPercentValue(100);
            layout.marginBottom = YGPointValue(15);
        }];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    [self.view rt_applyFlexLayout];
}

- (void)onAction:(id)sender
{
    self.view.rt_enableAutoLayoutGuide = !self.view.rt_enableAutoLayoutGuide;
    [sender setHidden:![sender isHidden]];
//    UILabel *label = [self.view.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self isKindOfClass: %@", [UILabel class]]].firstObject;
//    [UIView animateWithDuration:0.3
//                     animations:^{
//        label.numberOfLines = label.numberOfLines == 0 ? 2 : 0;
//        [self.view bringSubviewToFront:sender];
////        [sender rt_invalidateFlexLayout];
//    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    
}

@end

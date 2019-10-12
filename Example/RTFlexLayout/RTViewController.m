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
        layout.alignItems = YGAlignCenter;
    }];
    self.view.rt_enableAutoLayoutGuide = YES;

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

    for (int i = 0; i < 10; ++i)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor blueColor];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [button setTitle:[NSString stringWithFormat:@"Tag %d", i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onAction:) forControlEvents:UIControlEventTouchUpInside];
        [button rt_configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.marginRight = YGPointValue(6);
            layout.paddingHorizontal = YGPointValue(4);
            layout.marginBottom = YGPointValue(10);
        }];
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

- (void)onAction:(id)sender
{
    UILabel *label = [self.view.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self isKindOfClass: %@", [UILabel class]]].firstObject;
    [UIView animateWithDuration:0.3
                     animations:^{
        label.numberOfLines = label.numberOfLines == 0 ? 2 : 0;
        [self.view bringSubviewToFront:sender];
//        [sender rt_invalidateFlexLayout];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

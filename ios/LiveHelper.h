//
//  LiveHelper.h
//  IJKPlayerSDKDemo
//
//  Created by zhaokai on 16/3/24.
//  Copyright © 2016年 zhaokai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LiveHelper : NSObject

+ (UIImage *)imageWithBezierPath:(UIBezierPath *)bezierPath fill:(BOOL)fill fillColor:(UIColor *)fillColor stroke:(BOOL)stroke strokeColor:(UIColor *)strokeColor;
+ (CGRect)frameForItemAtIndex:(NSUInteger)index contentArea:(CGRect)area rows:(NSUInteger)rows cols:(NSUInteger)cols itemHeight:(CGFloat)itemHeight itemWidth:(CGFloat)itemWidth;
+ (UIButton *)createButton:(NSString*)title target:(id)target action:(SEL)action;
+ (UILabel *)createLable:(NSString*)title;
+ (UISwitch *)createSwitch:(BOOL) on;
+ (void)arertMessage:(NSString *)message;
@end

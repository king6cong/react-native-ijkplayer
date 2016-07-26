//
//  LiveHelper.m
//  IJKPlayerSDKDemo
//
//  Created by zhaokai on 16/3/24.
//  Copyright © 2016年 zhaokai. All rights reserved.
//

#import "LiveHelper.h"

@implementation LiveHelper

//MARK: Utils 辅助功能
+ (UIImage *)imageWithBezierPath:(UIBezierPath *)bezierPath fill:(BOOL)fill fillColor:(UIColor *)fillColor stroke:(BOOL)stroke strokeColor:(UIColor *)strokeColor
{
    UIImage *image = nil;
    if (bezierPath) {
        UIGraphicsBeginImageContextWithOptions(bezierPath.bounds.size, NO, [[UIScreen mainScreen] scale]);
        if (fill) {
            if (fillColor) {
                [fillColor setFill];
            }
            [bezierPath fill];
        }
        
        if (stroke) {
            if (strokeColor) {
                [strokeColor setStroke];
            }
            [bezierPath stroke];
        }
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return image;
}

+ (CGRect)frameForItemAtIndex:(NSUInteger)index contentArea:(CGRect)area rows:(NSUInteger)rows cols:(NSUInteger)cols itemHeight:(CGFloat)itemHeight itemWidth:(CGFloat)itemWidth
{
    int midPadding = 0;
    int leftPadding = (area.size.width - itemWidth * cols) / (cols + 1 );
    NSUInteger inColumn = (index - 1) % cols + 1;//在第几列, 从一开始
    NSUInteger inRow = ceil(index / (double)cols);//在第几行, 从1 开始
    
    float originX = leftPadding + (itemWidth + leftPadding) * (inColumn - 1) + area.origin.x;
    float originY =  itemHeight * (inRow - 1)+ midPadding *(inRow -1) + area.origin.y;
    
    return CGRectMake(originX, originY, itemWidth, itemHeight);
}

+ (UIButton *)createButton:(NSString*)title target:(id)target action:(SEL)action
{
    UIButton * button;
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle: title forState: UIControlStateNormal];
//    button.titleLabel.font = [UIFont systemFontOfSize:10.];
    [button.titleLabel setMinimumScaleFactor:0.1f];
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.titleLabel.numberOfLines = 2;
    button.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    [button setTitleColor:[UIColor redColor] forState:UIControlStateDisabled];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    return button;
}

+ (UILabel *)createLable:(NSString*)title
{
    UILabel *  lbl = [[UILabel alloc] init];
    lbl.text = title;
    return lbl;
}

+ (UISwitch *)createSwitch:(BOOL) on
{
    UISwitch *sw = [[UISwitch alloc] init];
    sw.on = on;
    return sw;
}

+ (void)arertMessage:(NSString *)message
{
    UIAlertView * view  = [[UIAlertView alloc]initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [view show];
}
@end

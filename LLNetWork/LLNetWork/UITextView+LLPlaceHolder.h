//
//  UITextView+LLPlaceHolder.h
//  LLNetWork
//
//  Created by LLVK on 27/07/2017.
//  Copyright © 2017 devHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (LLPlaceHolder)
// placeHolderText
@property (nonatomic, copy) NSString *placeHolder;

//placeHolderTextColor
@property (nonatomic, strong) UIColor *placeHolderColor;

//placeHolderLabel
@property (nonatomic, readonly) UILabel *placeHolderLabel;
@end

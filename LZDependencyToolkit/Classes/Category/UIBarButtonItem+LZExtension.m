//
//  UIBarButtonItem+LZExtension.m
//  Pods
//
//  Created by Dear.Q on 16/8/18.
//
//

#import "UIBarButtonItem+LZExtension.h"
#import <CoreGraphics/CGGeometry.h>
#import <objc/runtime.h>
#import "UIColor+LZExtension.h"
#import "UIImage+LZClipping.h"

@implementation UIBarButtonItem (LZExtension)

//MARK: - runtime
+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originSelector = @selector(setTitleTextAttributes:forState:);
        SEL swizzleSelector = @selector(LZ_setTitleTextAttributes:forState:);
        Method originMethod = class_getInstanceMethod(class, originSelector);
        Method swizzleMethod = class_getInstanceMethod(class, swizzleSelector);
        BOOL exit = class_addMethod(class, swizzleSelector, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod));
        if (exit) {
            class_replaceMethod(self, originSelector, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod));
        } else {
            method_exchangeImplementations(originMethod, swizzleMethod);
        }
    });
}

- (void)LZ_setTitleTextAttributes:(NSDictionary<NSString *,id> *)attributes forState:(UIControlState)state {
    
    UIView *customView = self.customView;
    if (customView) {
        
        if ([customView isKindOfClass:[UIButton class]]) {
            UIButton *tempBtn = (UIButton *)customView;
            NSAttributedString *attributedStr = [[NSAttributedString alloc] initWithString:tempBtn.currentTitle
                                                                                attributes:attributes];
            [tempBtn setAttributedTitle:attributedStr forState:state];
        }
    } else {
        [self LZ_setTitleTextAttributes:attributes forState:state];
    }
}

//MARK: - Public
/** 创建一个自定义导航按钮(标题、默认状态图片、高亮状态图片、代理、点击事件) */
#pragma clang push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (UIBarButtonItem *)initWithTitle:(NSString *)title
                         normalImg:(NSString *)normalImg
                      highlightImg:(NSString *)highlightImg
                        disableImg:(NSString *)disableImg
                            target:(id)target
                            action:(SEL)action {
    
    if (self = [super init]) {
        
        if (!self.enabled) {
            self.enabled = YES;
        }
        
        UIButton *barButton = [UIButton buttonWithType:UIButtonTypeCustom];
        barButton.opaque = YES;
        barButton.backgroundColor = [UIColor clearColor];
        barButton.adjustsImageWhenDisabled = YES;
        barButton.adjustsImageWhenHighlighted = NO;
        barButton.imageView.contentMode = UIViewContentModeLeft;
        
        if (nil != title && title.length) {
            
            [barButton setTitle:title forState:UIControlStateNormal];
            [barButton setTitle:title forState:UIControlStateHighlighted];
            [barButton setTitle:title forState:UIControlStateDisabled];
            UIBarButtonItem *theme = [UIBarButtonItem appearance];
            NSDictionary *normalAttributes = [theme titleTextAttributesForState:UIControlStateNormal];
            NSDictionary *highlightAttributes = [theme titleTextAttributesForState:UIControlStateHighlighted];
            NSDictionary *disableAttributes = [theme titleTextAttributesForState:UIControlStateDisabled];
            if (nil != normalAttributes || normalAttributes.allKeys.count ? YES : NO) {
                
                NSAttributedString *normalAttributedString =
                [[NSAttributedString alloc] initWithString:title
                                                attributes:normalAttributes];
                [barButton setAttributedTitle:normalAttributedString
                                     forState:UIControlStateNormal];
            } else {
                
            }
            if (nil != highlightAttributes || highlightAttributes.allKeys.count ? YES : NO) {
                
                NSAttributedString *hightlightAttributedString =
                [[NSAttributedString alloc] initWithString:title
                                                attributes:highlightAttributes];
                [barButton setAttributedTitle:hightlightAttributedString
                                     forState:UIControlStateHighlighted];
            }
            if (nil != disableAttributes || highlightAttributes.allKeys.count ? YES : NO) {
                
                NSAttributedString *disableAttributedString =
                [[NSAttributedString alloc] initWithString:title
                                                attributes:disableAttributes];
                [barButton setAttributedTitle:disableAttributedString
                                     forState:UIControlStateDisabled];
            }
            if (nil == normalAttributes && nil == highlightAttributes && nil == disableAttributes) {
                
                barButton.titleLabel.font = [UIFont systemFontOfSize:16];
                [barButton setTitleColor:LZColorWithHexString(@"#333333")
                                forState:UIControlStateNormal];
                [barButton setTitleColor:LZColorWithHexString(@"#333333")
                                forState:UIControlStateHighlighted];
                [barButton setTitleColor:LZColorWithHexString(@"#A8A8A8")
                                forState:UIControlStateDisabled];
            }
            if (nil != normalImg && normalImg.length) {
                
                [barButton setImage:[self img:normalImg] forState:UIControlStateNormal];
                [barButton setImage:[self img:highlightImg] forState:UIControlStateHighlighted];
                [barButton setImage:[self img:disableImg] forState:UIControlStateDisabled];
            }
        } else {
            if (nil != normalImg && normalImg.length) {
                
                [barButton setBackgroundImage:[self img:normalImg] forState:UIControlStateNormal];
                [barButton setBackgroundImage:[self img:highlightImg] forState:UIControlStateHighlighted];
                [barButton setBackgroundImage:[self img:disableImg] forState:UIControlStateDisabled];
            }
        }
        if (nil != barButton.currentImage || nil != barButton.currentTitle) {
            
            barButton.frame = (CGRect){{0,0},barButton.currentImage.size};
            if (nil != barButton.currentTitle) {
                
                CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName:barButton.titleLabel.font}];
                CGRect oldFrame = barButton.frame;
                oldFrame.size.width = titleSize.width + barButton.currentImage.size.width;
                if (0 == oldFrame.size.height) oldFrame.size.height = titleSize.height;
                oldFrame.size.height = 28;
                barButton.frame = oldFrame;
            }
        }
        if (nil != barButton.currentBackgroundImage) {
            barButton.frame = (CGRect){{0,0},barButton.currentBackgroundImage.size};
        }
        [barButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        self.customView = barButton;
    }
    
    return self;
}
#pragma clang pop

/** 创建一个自定义导航按钮(标题、默认状态图片、高亮状态图片、代理、点击事件) */
+ (UIBarButtonItem *)itemWithTitle:(NSString *)title
                       normalImage:(NSString *)normalImage
                    highlightImage:(NSString *)highlightImage
                      disableImage:(NSString *)disableImage
                            target:(id)target
                            action:(SEL)action {
    
    return [[self alloc] initWithTitle:title
                             normalImg:normalImage
                          highlightImg:highlightImage
                            disableImg:disableImage
                                target:target
                                action:action];
}

/** 创建一个自定义导航按钮(标题、代理、点击事件) */
+ (UIBarButtonItem *)itemWithTitle:(NSString *)title
                            target:(id)target
                            action:(SEL)action {
    
    return [[self alloc] initWithTitle:title
                             normalImg:nil
                          highlightImg:nil
                            disableImg:nil
                                target:target
                                action:action];
}

//MARK: - Private
/**
 @author Lilei
 
 @brief 实例 Image
 
 @param imgNameOrPath 文件名或路径
 @return UIImage
 */
- (UIImage *)img:(NSString *)imgNameOrPath {
    
    if (nil == imgNameOrPath || !imgNameOrPath.length) {
        return nil;
    }
    UIImage *image = [UIImage imageNamed:imgNameOrPath];
    if (nil == image) {
        image = [UIImage imageWithContentsOfFile:imgNameOrPath];
    }
    if (image.size.width > 32) {
        image = [image scaledToSize:CGSizeMake(32, 32)];
    }
    
    return image;
}

@end

@implementation UINavigationItem (LZExtension)

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
- (void)setLeftBarButtonItem:(UIBarButtonItem *)_leftBarButtonItem {
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0 &&
        nil != _leftBarButtonItem.customView) {
        
        UIBarButtonItem *negativeSeperator =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                      target:nil
                                                      action:nil];
        negativeSeperator.width = -7;
        if (_leftBarButtonItem) {
            [self setLeftBarButtonItems:@[negativeSeperator, _leftBarButtonItem]];
        } else {
            [self setLeftBarButtonItems:@[negativeSeperator]];
        }
    } else {
        [self setLeftBarButtonItem:_leftBarButtonItem animated:NO];
    }
}

- (void)setRightBarButtonItem:(UIBarButtonItem *)_rightBarButtonItem {
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0 &&
        nil != _rightBarButtonItem.customView) {
        
        UIBarButtonItem *negativeSeperator =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                      target:nil
                                                      action:nil];
        negativeSeperator.width = -7;
        if (_rightBarButtonItem) {
            [self setRightBarButtonItems:@[negativeSeperator, _rightBarButtonItem]];
        } else {
            [self setRightBarButtonItems:@[negativeSeperator]];
        }
    } else {
        [self setRightBarButtonItem:_rightBarButtonItem animated:NO];
    }
}

- (void)setLeftBarButtonItems:(NSArray<UIBarButtonItem *> *)_leftBarButtonItems {
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0) {
        
        UIBarButtonItem *negativeSeperator =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                      target:nil
                                                      action:nil];
        negativeSeperator.width = -7;
        if (_leftBarButtonItems && 0 < _leftBarButtonItems.count) {
            
            UIBarButtonItem *tempBarBtnItem = [_leftBarButtonItems firstObject];
            if (tempBarBtnItem.customView) {
                
                NSMutableArray *tempArrM = [NSMutableArray arrayWithObject:negativeSeperator];
                [tempArrM addObjectsFromArray:_leftBarButtonItems];
                [self setLeftBarButtonItems:[tempArrM copy]];
            } else {
                [self setLeftBarButtonItems:_leftBarButtonItems animated:NO];
            }
        } else {
            [self setLeftBarButtonItems:@[negativeSeperator]];
        }
    } else {
        [self setLeftBarButtonItems:_leftBarButtonItems animated:NO];
    }
}

- (void)setRightBarButtonItems:(NSArray<UIBarButtonItem *> *)_rightBarButtonItems {
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0) {
        
        UIBarButtonItem *negativeSeperator =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                      target:nil
                                                      action:nil];
        negativeSeperator.width = -7;
        if (_rightBarButtonItems && 0 < _rightBarButtonItems.count) {
            
            UIBarButtonItem *tempBarBtnItem = [_rightBarButtonItems firstObject];
            if (tempBarBtnItem.customView) {
                
                NSMutableArray *tempArrM = [NSMutableArray arrayWithObject:negativeSeperator];
                [tempArrM addObjectsFromArray:_rightBarButtonItems];
                [self setRightBarButtonItems:[tempArrM copy]];
            } else {
                [self setRightBarButtonItems:_rightBarButtonItems animated:NO];
            }
        } else {
            [self setRightBarButtonItems:@[negativeSeperator]];
        }
    } else {
        [self setRightBarButtonItems:_rightBarButtonItems animated:NO];
    }
}
#endif

@end

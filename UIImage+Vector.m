//
//  UIImage+Vector.m
//  UIImage+Vector
//
//  Created by David Keegan on 8/7/13.
//  Copyright (c) 2013 David Keegan All rights reserved.
//

#import "UIImage+Vector.h"
#import <CoreText/CoreText.h>
#import "KGPixelBoundsClip.h"

@implementation UIImage(Vector)

+ (NSCache *)cache{
    static NSCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSCache alloc] init];
    });
    return cache;
}

+ (UIImage *)iconWithFont:(UIFont *)font named:(NSString *)iconNamed withTintColor:(UIColor *)tintColor clipToBounds:(BOOL)clipToBounds forSize:(CGFloat)fontSize{
    NSString *identifier = [NSString stringWithFormat:@"%@%@%@%d%f", font.fontName, tintColor, iconNamed, clipToBounds, fontSize];
    UIImage *image = [[self cache] objectForKey:identifier];
    if(image == nil){
        NSMutableAttributedString *ligature = [[NSMutableAttributedString alloc] initWithString:iconNamed];
        [ligature setAttributes:@{(NSString *)kCTForegroundColorAttributeName: tintColor ?: [UIColor blackColor],
                                  (NSString *)kCTLigatureAttributeName: @(2),
                                  (NSString *)kCTFontAttributeName: font}
                          range:NSMakeRange(0, [ligature length])];

        CGSize iconSize = [ligature size];
        iconSize.width = ceil(iconSize.width);
        iconSize.height = ceil(iconSize.height);
        if(!CGSizeEqualToSize(CGSizeZero, iconSize)){
            UIGraphicsBeginImageContextWithOptions(iconSize, NO, 0);
            [ligature drawAtPoint:CGPointZero];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            if(clipToBounds){
                image = [image imageClippedToPixelBounds];
            }

            [[self cache] setObject:image forKey:identifier];
        }
    }
    return image;
}

+ (UIImage *)imageWithPDFNamed:(NSString *)pdfNamed withTintColor:(UIColor *)tintColor forHeight:(CGFloat)height{
    NSString *identifier = BBlockImageIdentifier(@"%@%@%f", pdfNamed, tintColor, height);
    UIImage *image = [[self cache] objectForKey:identifier];
    if(image){
        return image;
    }

    NSURL *url = [[NSBundle mainBundle] URLForResource:pdfNamed withExtension:@"pdf"];
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((__bridge CFURLRef)url);
    if(!pdf){
        return nil;
    }

    CGPDFPageRef page1 = CGPDFDocumentGetPage(pdf, 1);
    CGRect mediaRect = CGPDFPageGetBoxRect(page1, kCGPDFCropBox);
    CGFloat scaleFactor = height/CGRectGetHeight(mediaRect);
    CGSize size = CGSizeMake(CGRectGetWidth(mediaRect)*scaleFactor, height);

    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGFloat scale = MIN(size.width / mediaRect.size.width, size.height / mediaRect.size.height);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -size.height);
    CGContextScaleCTM(context, scale, scale);
    CGContextDrawPDFPage(context, page1);
    CGPDFDocumentRelease(pdf);
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    if(tintColor){
        UIGraphicsBeginImageContextWithOptions(size, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(context, 1, -1);
        CGContextTranslateCTM(context, 0, -size.height);
        CGContextClipToMask(context, (CGRect){CGPointZero, size}, [pdfImage CGImage]);
        [tintColor set];
        CGContextFillRect(context, (CGRect){CGPointZero, size});
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
}

@end

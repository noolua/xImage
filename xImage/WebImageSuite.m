//
//  WebImageSuite.m
//  xImage
//
//  Created by rockee on 13-5-17.
//
//
#import <QuartzCore/QuartzCore.h>
#import "AppSetting.h"
#import "WebImageSuite.h"
#import "xImage.h"

#define _RGB(r, g, b)   r/255.0, g/255.0, b/255.0
#define _DGREE(d)       (d * M_PI/180.0)

UIImage* _gen_header_image(AppConfig *config, CGSize content_size);
//UIImage* _scaledImage(UIImage* image ,CGSize newSize);

@interface WebImageSuite()
+(UIImage*) genWaterMask:(CGSize) size config:(AppConfig *)config;
@end

@implementation WebImageSuite
+(void)GenWebImageWithImage:(UIImage*)content_image toFile:(NSString*) filepath completion:(void(^)(BOOL ok))completion{
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        BOOL ok = NO;
        @autoreleasepool {
            CGFloat height_offset = 0;
            AppConfig *config = [AppSetting config];
            UIView *background = [[UIView alloc]  initWithFrame:CGRectZero];
            background.backgroundColor = [UIColor whiteColor];
            if(config.headerFormat == 1){
                CGRect frame = CGRectMake(0, 0, content_image.size.width, 120);
                UIImage *header_image = [UIImage imageWithContentsOfFile:config.headerImagePath];
                if(header_image){
                    CGSize fixedSize = header_image.size;
                    
                    CGFloat xFactor = fixedSize.width / frame.size.width;
                    CGFloat yFactor = fixedSize.height / frame.size.height;
                    CGFloat factor = MAX(xFactor, yFactor);
                    
                    if(factor > 1){
                        fixedSize.width = fixedSize.width / factor;
                        fixedSize.height = fixedSize.height / factor;
                    }
                    CGFloat x = 0;
                    if(fixedSize.width < frame.size.width){
                        if(config.headerAlignment == 0)
                            x = 0;
                        else if (config.headerAlignment == 1)
                            x = (frame.size.width - fixedSize.width)/2;
                        else
                            x = (frame.size.width - fixedSize.width);
                    }
                    UIImageView *header_view = [[UIImageView alloc] initWithFrame:CGRectMake(x, 0, fixedSize.width, fixedSize.height)];
                    header_view.image = header_image;
                    [background addSubview:header_view];
                    [header_view release];
                    height_offset += fixedSize.height;
                }
            }
            else{
                UILabel *header_label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, content_image.size.width, 40)];
                if(config.headerAlignment == 0)
                    header_label.textAlignment = NSTextAlignmentLeft;
                else if (config.headerAlignment == 1)
                    header_label.textAlignment = NSTextAlignmentCenter;
                else
                    header_label.textAlignment = NSTextAlignmentRight;
                header_label.text = config.headerText;
                [background addSubview:header_label];
                [header_label release];
                height_offset += 40;
            }
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, height_offset, content_image.size.width, content_image.size.height)];
            imageView.image = content_image;
            [background addSubview:imageView];
            [imageView release];

            if(![config.waterMarkText isEqualToString:@""]){
                UIImage * watermask = [WebImageSuite genWaterMask:content_image.size config:config];
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, height_offset, content_image.size.width, content_image.size.height)];
                imageView.image = watermask;
                [background addSubview:imageView];
                [imageView release];
            }

            height_offset += content_image.size.height;
            
            if(![config.footerText isEqualToString:@""]){
                UILabel *footer_label = [[UILabel alloc] initWithFrame:CGRectMake(0, height_offset, content_image.size.width, 40)];
                if(config.footerTextAlignment == 0)
                    footer_label.textAlignment = NSTextAlignmentLeft;
                else if (config.footerTextAlignment == 1)
                    footer_label.textAlignment = NSTextAlignmentCenter;
                else
                    footer_label.textAlignment = NSTextAlignmentRight;
                footer_label.text = config.footerText;
                [background addSubview:footer_label];
                [footer_label release];
                height_offset += 40;
            }
            if(config.footerImagePath){
                CGRect frame = CGRectMake(0, 0, content_image.size.width, 200);
                UIImage *footer_image = [UIImage imageWithContentsOfFile:config.footerImagePath];
                if(footer_image){
                    CGSize fixedSize = footer_image.size;
                    
                    CGFloat xFactor = fixedSize.width / frame.size.width;
                    CGFloat yFactor = fixedSize.height / frame.size.height;
                    CGFloat factor = MAX(xFactor, yFactor);
                    
                    if(factor > 1){
                        fixedSize.width = fixedSize.width / factor;
                        fixedSize.height = fixedSize.height / factor;
                    }
                    CGFloat x = 0;
                    if(fixedSize.width < frame.size.width){
                        if(config.footerImageAlignment == 0)
                            x = 0;
                        else if (config.footerImageAlignment == 1)
                            x = (frame.size.width - fixedSize.width)/2;
                        else
                            x = (frame.size.width - fixedSize.width);
                    }
                    UIImageView *footer_view = [[UIImageView alloc] initWithFrame:CGRectMake(x, height_offset, fixedSize.width, fixedSize.height)];
                    footer_view.image = footer_image;
                    [background addSubview:footer_view];
                    [footer_view release];
                    height_offset += fixedSize.height;
                }
            }
            /**/
            background.frame = CGRectMake(0, 0, content_image.size.width, height_offset);
            UIImage *image = [WebImageSuite snapView:background];
            
            [background release];
            /*
            UIImage *footer_image, *header_image, *image;
            
            header_image = _gen_header_image(config, content_image.size);
            
            footer_image = nil;
            
            image = header_image;
            */
            if (config.imageFormat == 0) {
                NSData * data = UIImagePNGRepresentation(image);
                ok = [data writeToFile:filepath atomically:NO];
            }else{
                NSData * data = UIImageJPEGRepresentation(image, config.jpgQunalityLevel*0.2 + 0.4);
                ok = [data writeToFile:filepath atomically:NO];
            }
        }
        completion(ok);
    });
}
+(UIImage *) layerToImage:(UIView *)view{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+(UIImage*) genWaterMask:(CGSize) size config:(AppConfig *)config{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:72];
    NSString *text = config.waterMarkText;
    CGFloat minSize = 72;
    CGFloat actualSize = actualSize;
    
    CGSize text_size = [text sizeWithFont:font minFontSize:minSize actualFontSize:&actualSize
              forWidth:size.width - 20 lineBreakMode:NSLineBreakByTruncatingTail];

    
    CGPoint point = CGPointMake(0, 0);
    if(text_size.width < size.width)
        point.x = (size.width - text_size.width) / 2;
    
	CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, config.waterMarkAlpha);
    CGContextRotateCTM (context, _DGREE(-45.0));
    CGFloat dy = 0;
    CGFloat dx = (size.width * sinf(_DGREE(45.0))) / 2;
    
    for (; dy < size.height; dy += 256) {
        CGPoint pt = point;
        pt.x = cosf(_DGREE(45.0)) * pt.x;
        pt.y = sinf(_DGREE(45.0)) * pt.y;
        pt.x = pt.x - tanf(_DGREE(45.0)) * dy + dx;
        pt.y += dy;
        [text drawAtPoint:pt forWidth:size.width withFont:font minFontSize:12.0 actualFontSize:&actualSize lineBreakMode:NSLineBreakByTruncatingTail baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
    }
    
    CGContextRotateCTM (context, _DGREE(45.0));
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


+(UIImage*) snapView:(UIView*)view{
    UIImage *image = nil;
    [view isKindOfClass:[UIScrollView class]];
    if([view isKindOfClass:[UIWebView class]]){
        UIWebView *webView = (UIWebView*)view;
        UIScrollView *scroll = [webView scrollView];
        CGPoint offset = [scroll contentOffset];
        CGSize contentSize = [scroll contentSize];
        CGSize frameSize = webView.frame.size;
        CGRect rect = webView.frame;
        rect.origin.x = 0;
        rect.origin.y = 0;
        
        UIGraphicsBeginImageContext(contentSize);
        /*render in context*/
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0, contentSize.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        //	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
        
        for (CGFloat height = 0.0; height < contentSize.height;){
            [scroll setContentOffset:CGPointMake(0, height) animated:NO];
            rect.origin.y = contentSize.height - frameSize.height - height;
            CGContextDrawImage(context, rect, [[self layerToImage:webView] CGImage]);
            height += frameSize.height;
        }
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [scroll setContentOffset:offset animated:NO];
    }else if([view isKindOfClass:NSClassFromString(@"TabDocumentWebBrowserView")]){
        image = [SnapTool snapshotForActiveDocument];
    }else if([view isKindOfClass:[UIView class]]){
        UIGraphicsBeginImageContext(view.bounds.size);
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();    
    }
    return image;
}
@end

/*
 
-(void)drawInContext:(CGContextRef)context
{
	CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
	CGContextSetRGBStrokeColor(context, _RGB(128, 128, 128), 1.0);
    CGContextFillRect(context, self.bounds);
    CGPoint line[2] = {CGPointMake(5, 35), CGPointMake(315, 35)};
    CGContextStrokeLineSegments(context, line, 2);
	CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:17];
    NSString *text = @"摘自互联网, 版权归原作者";
    int alginment = 2;
    CGSize header_size = CGSizeMake(300, 80);
    CGFloat minSize = 17;
    CGFloat actualSize = actualSize;
    
    CGSize text_size = [text sizeWithFont:font
                              minFontSize:minSize actualFontSize:&actualSize
                                 forWidth:header_size.width - 20 lineBreakMode:NSLineBreakByTruncatingTail];
    
    CGPoint point = CGPointMake(0, 10);
    if(text_size.width < header_size.width){
        switch (alginment) {
            default:
            case 0:
                point.x = 0;
                break;
            case 1:
                point.x = (header_size.width - text_size.width)/2;
                break;
            case 2:
                point.x = (header_size.width - text_size.width);
                break;
        }
    }
    //    header_size.height = text_size.height + 20;
    [text drawAtPoint:point forWidth:header_size.width withFont:font minFontSize:12.0 actualFontSize:&actualSize lineBreakMode:NSLineBreakByTruncatingTail baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
}
 */

UIImage *_gen_header_image(AppConfig *config, CGSize content_size){
    UIImage *image = nil;
    CGFloat margin = 20;
    if(config.headerFormat == 0){
        CGRect header_rect = CGRectMake(0, 0, content_size.height, 60);
        UIFont *font = [UIFont fontWithName:@"Helvetica" size:17];
        CGFloat actualSize = 17.0;
        CGSize text_size = [config.headerText sizeWithFont:[UIFont systemFontOfSize:12]
                                               minFontSize:12 actualFontSize:&actualSize
                                                  forWidth:header_rect.size.width - margin lineBreakMode:NSLineBreakByTruncatingTail];
        CGPoint pt = CGPointMake(0, margin/2);
        if(text_size.width < header_rect.size.width){
            if(config.headerAlignment == 1){
                pt.x = (header_rect.size.width - text_size.width)/2;
            }else if(config.headerAlignment == 2){
                pt.x = (header_rect.size.width - text_size.width);
            }
        }

        UIGraphicsBeginImageContext(header_rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();

        CGContextSetRGBFillColor(context, _RGB(255, 255, 255), 1.0);
        CGContextSetRGBStrokeColor(context, _RGB(128, 128, 128), 1.0);
        CGContextFillRect(context, header_rect);
        CGPoint line[2] = {CGPointMake(5, header_rect.size.height - 5), CGPointMake(header_rect.size.width - 5, header_rect.size.height - 5)};
        CGContextStrokeLineSegments(context, line, 2);
        CGContextSetRGBFillColor(context, _RGB(0, 0, 0), 1.0);

        [config.headerText drawAtPoint:pt forWidth:header_rect.size.width withFont:font minFontSize:12.0 actualFontSize:&actualSize lineBreakMode:NSLineBreakByTruncatingTail baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    
    }else{
        CGRect header_rect = CGRectMake(0, 0, content_size.height, 130);
        UIImage *header_image = [UIImage imageWithContentsOfFile:config.headerImagePath];
        if(header_image){
            // scale header_image;
            CGSize  size = header_image.size;
            CGFloat scaleWidth = size.width / (content_size.width - margin);
            CGFloat scaleHight = size.height / 120;
            CGFloat scaled = MAX(scaleHight, scaleWidth);

            if(scaled > 1.0){
                size.width = size.width / scaled;
                size.height = size.height / scaled;
            }
            CGPoint pt = CGPointMake(0, 5);
            if(size.width < header_rect.size.width){
                if(config.headerAlignment == 1){
                    pt.x = (header_rect.size.width - size.width)/2;
                }else if(config.headerAlignment == 2){
                    pt.x = (header_rect.size.width - size.width);
                }
            }
            
            CGRect rect = CGRectMake(pt.x, pt.y, size.width, size.height);
            
            UIGraphicsBeginImageContext(header_rect.size);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGContextSetRGBFillColor(context, _RGB(255, 255, 255), 1.0);
            CGContextSetRGBStrokeColor(context, _RGB(128, 128, 128), 1.0);
            CGContextFillRect(context, header_rect);
            CGPoint line[2] = {CGPointMake(5, header_rect.size.height - 5), CGPointMake(header_rect.size.width - 5, header_rect.size.height - 5)};
            CGContextStrokeLineSegments(context, line, 2);
            
            [header_image drawInRect:rect];
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    }
    return image;
}

UIImage* _scaledImage(UIImage* image , CGSize scale){
    UIImage *sourceImage = image;
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = scale.width;
    CGFloat targetHeight = scale.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (!CGSizeEqualToSize(imageSize, scale)) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor < heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        
        if (widthFactor < heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor > heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    // this is actually the interesting part:
    UIGraphicsBeginImageContext(scale);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage ;
}





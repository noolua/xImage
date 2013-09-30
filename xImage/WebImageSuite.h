//
//  WebImageSuite.h
//  xImage
//
//  Created by rockee on 13-5-17.
//
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface WebImageSuite : NSObject
/*
 when completed, this method whill call completion with error, if sccuessful error is nil
 completion should not be NULL
*/
+(void)GenWebImageWithImage:(UIImage*)image toFile:(NSString*) filepath completion:(void(^)(BOOL ok))completion;
+(UIImage*) snapView:(UIView*)view;
@end
UIImage* _scaledImage(UIImage* image , CGSize scale);


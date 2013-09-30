//
//  xImage.h
//  xImage
//
//  Created by rockee on 13-5-10.
//
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifndef xImage_xImage_h
#define xImage_xImage_h

@interface SnapTool : NSObject
+(UIView*) activeView;
+(UIImage*) snapshotForActiveDocument;
+(NSString*) activeDocumentTitle;

@end

#endif

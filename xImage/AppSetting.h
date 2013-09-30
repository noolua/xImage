//
//  AppSetting.h
//  xImage
//
//  Created by rockee on 13-5-16.
//
//

#import <Foundation/Foundation.h>

@class AppConfig;
@interface AppSetting : NSObject
+(AppSetting*) instance;
+(AppConfig*) config;
-(BOOL) update;
-(BOOL) default_load;

@property(nonatomic, readonly) BOOL initilized;
@property(nonatomic, readonly) NSString *version, *plug_path, *main_script_path;
@property(nonatomic, readonly) NSURL *comment_url, *online_doc_url, *header_request_url, *footer_request_url, *stat_url, *about_url;
@end

@interface AppConfig : NSObject
@property(nonatomic, readwrite) int imageFormat;    // 0 = png, 1 = jpg
@property(nonatomic, readwrite) int jpgQunalityLevel;   // 0 =low, 1 = normal, 2= high
@property(nonatomic, readwrite) int headerFormat;   // 0 = text, 1 = image
@property(nonatomic, readwrite) int headerAlignment, footerTextAlignment, footerImageAlignment; // 0=left, 1=center, 2=right
@property(nonatomic, readwrite) float waterMarkAlpha; // default =0.3, range = [0.3, 1.0]
@property(nonatomic, copy) NSString* waterMarkText, *headerText, *footerText;
@property(nonatomic, copy) NSString *headerImagePath, *footerImagePath;
@property(nonatomic, copy) NSString *themeName;
@property(nonatomic, readonly, getter = _isDirty) BOOL isDirty;
@end


//
//  AppSetting.m
//  xImage
//
//  Created by rockee on 13-5-16.
//
//
/*
 控制面板地址：     http://cp.hichina.com/
 控制面板账号：     hmu166464
 密码：zaq1xsw2
 IP地址：121.198.253.210
 数据库信息(Mysql)
 数据库类型：     Mysql
 数据库地址：     hdm-087.hichina.com
 数据库名称：     hdm0870154_db
 数据库账号：     hdm0870154
 数据库密码：     q4y9t6r8r7
 */

#import <CommonCrypto/CommonDigest.h>
#import "AppSetting.h"

@interface AppSetting (){

}
@property(nonatomic, readonly) NSURL *update_url;
@end

@implementation AppSetting
@synthesize version, plug_path, main_script_path;
@synthesize comment_url, online_doc_url, update_url, header_request_url, footer_request_url, stat_url, about_url;
@synthesize initilized;

+(AppSetting*) instance{
    static AppSetting *__instance = nil;
    if(!__instance){
        __instance = [[AppSetting alloc] init];
    }
    return __instance;
}

+(AppConfig*) config{
    static AppConfig* __instance = nil;
    if(!__instance){
        __instance = [[AppConfig alloc] init];
    }
    return __instance;
}

-(id)init{
    self = [super init];
    if(self){
        version = @"1.0.0";
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//        plug_path = [[NSString alloc]initWithString:[paths objectAtIndex:0]];
        plug_path = @"/var/tmp";
        main_script_path = [[NSString alloc] initWithString:[plug_path stringByAppendingPathComponent:@"__core__.lua"]];
        comment_url = [[NSURL alloc] initWithString:@"http://www.fadai8.cn/mobilesafari/comment.php"];
        online_doc_url = [[NSURL alloc] initWithString:@"http://www.fadai8.cn/mobilesafari/help.htm"];
        update_url = [[NSURL alloc] initWithString:@"http://www.fadai8.cn/mobilesafari/update/__core__.lua"];
        header_request_url = [[NSURL alloc] initWithString:@"http://www.fadai8.cn/mobilesafari/request_images.php?type=header"];
        footer_request_url = [[NSURL alloc] initWithString:@"http://www.fadai8.cn/mobilesafari/request_images.php?type=footer"];
        stat_url = [[NSURL alloc] initWithString:@"http://www.fadai8.cn/mobilesafari/stat.php"];
        about_url = [[NSURL alloc] initWithString:@"http://www.fadai8.cn/mobilesafari/about.php"];
    }
    return self;
}

-(void)dealloc{
    [plug_path release];
    [main_script_path release];
    [comment_url release];
    [online_doc_url release];
    [update_url release];
    [header_request_url release];
    [footer_request_url release];
    [stat_url release];
    [about_url release];
    [super dealloc];
}

-(void)reload{
}

-(BOOL)default_load{
    BOOL isDir = NO;
    BOOL isOK = NO;
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if(![fm fileExistsAtPath:main_script_path isDirectory:&isDir]){
        isOK = [self update];
    }else{
        [self reload];
        isOK = YES;
    }
    initilized = isOK;
    return isOK;
}

-(BOOL) update{
    BOOL isOK = NO;
    NSData *data = [NSData dataWithContentsOfURL: update_url];
    
    if(data){
        isOK = [data writeToFile:main_script_path atomically:YES];
        if(isOK){
            [self reload];
        }
    }
    initilized = isOK;
    return isOK;
}
@end

@interface AppConfig(){
    unsigned char _md5_hash[CC_MD5_DIGEST_LENGTH];
}

@end

@implementation AppConfig
@synthesize imageFormat, jpgQunalityLevel, waterMarkAlpha;;
@synthesize headerText, footerText, headerImagePath, footerImagePath, waterMarkText;
@synthesize headerAlignment, footerImageAlignment, footerTextAlignment;
@synthesize headerFormat;
@synthesize themeName;
@synthesize isDirty;

-(id) init{
    self = [super init];
    if(self){
        waterMarkAlpha = 0.1;   // [0.1 - 0.7]
        jpgQunalityLevel = 1;   // 0 = low, 1 = normal, 2 = high
        imageFormat = 1; // 0 = PNG, 1 = JPG
        headerFormat = 1;
        headerText = @"本图由'@看图读报' 提供的工具生成";
        waterMarkText = @"";
        footerText = @"";
        themeName = @"default";
        headerImagePath = @"/var/tmp/header.png";
        headerAlignment = 1;
        footerTextAlignment = 1;
        footerImageAlignment = 1;
    }
    return self;
}

-(void) dealloc{
    [waterMarkText release];
    [headerText release];
    [footerText release];
    [headerImagePath release];
    [footerImagePath release];
    [themeName release];
    [super dealloc];
}

#define MD5_UP_STRING(ctx, name)        \
if(![name isEqualToString:@""]){\
    CC_MD5_Update(&ctx, [name UTF8String], [name lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);\
}


-(BOOL) _isDirty{
    BOOL dirty = NO;
    CC_MD5_CTX md5_ctx;
    CC_MD5_Init(&md5_ctx);
    
    CC_MD5_Update(&md5_ctx, &imageFormat, sizeof(int));
    CC_MD5_Update(&md5_ctx, &jpgQunalityLevel, sizeof(int));
    CC_MD5_Update(&md5_ctx, &headerFormat, sizeof(int));
    CC_MD5_Update(&md5_ctx, &headerAlignment, sizeof(int));
    CC_MD5_Update(&md5_ctx, &footerImageAlignment, sizeof(int));
    CC_MD5_Update(&md5_ctx, &footerTextAlignment, sizeof(int));

    CC_MD5_Update(&md5_ctx, &waterMarkAlpha, sizeof(float));
    
    MD5_UP_STRING(md5_ctx, waterMarkText);
    MD5_UP_STRING(md5_ctx, headerText);
    MD5_UP_STRING(md5_ctx, footerText);
    MD5_UP_STRING(md5_ctx, headerImagePath);
    MD5_UP_STRING(md5_ctx, footerImagePath);
    MD5_UP_STRING(md5_ctx, themeName);
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(result, &md5_ctx);
    
    if(memcmp(result, _md5_hash, CC_MD2_DIGEST_LENGTH) != 0){
        dirty = YES;
        memcpy(_md5_hash, result, CC_MD2_DIGEST_LENGTH);
    }else{
        dirty = NO;
    }
    
    return dirty;
}
@end

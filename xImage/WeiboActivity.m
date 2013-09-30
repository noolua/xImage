//
//  WeiboActivity.m
//  xImage
//
//  Created by rockee on 13-5-10.
//
//
#include <objc/runtime.h>
#include <objc/message.h>

#import <QuartzCore/QuartzCore.h>
#import "WeiboActivity.h"
#import "resource.h"
#import "xImage.h"
#import "SinaWeibo.h"

#import "WeiboPrepareViewController.h"

@interface AlertHoder : NSObject <UIAlertViewDelegate>
+(AlertHoder*) instance;
@end

@implementation AlertHoder
+(AlertHoder*)instance
{
    static AlertHoder* __holder = nil;
    if(!__holder){
        __holder = [[AlertHoder alloc]init];
    }
    return __holder;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex != alertView.cancelButtonIndex){
        NSURL* url = [NSURL URLWithString:@"http://www.fadai8.cn"];
        [[UIApplication sharedApplication] openURL:url];
        [alertView release];
    }
}

@end

@interface WeiboActivity(){
	NSURL *_URL;
}
-(void) delayPresent;
-(void) checkWeiboAccounts;
@end

@implementation WeiboActivity
-(void)dealloc{
    [_URL release];
    [super dealloc];
}
- (NSString *)activityType
{
	return NSStringFromClass([self class]);
}

- (NSString *)activityTitle
{
	return @"带图微博";
}

- (UIImage *)activityImage
{
    return resource_image(RIWeiboIcon);
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    BOOL bURL = NO;
    
	for (id activityItem in activityItems) {
		if ([activityItem isKindOfClass:[NSURL class]]) {
			bURL = YES;
		}
	}
	
	return bURL;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
	for (id activityItem in activityItems) {
		if ([activityItem isKindOfClass:[NSURL class]]) {
			_URL = [[NSURL alloc] initWithString:[activityItem absoluteString]];
		}
	}
}

-(void) performActivity{
    BOOL ok = YES;
    [self performSelector:@selector(checkWeiboAccounts) withObject:nil afterDelay:0.5];
    [self activityDidFinish:ok];
}

-(void)checkWeiboAccounts{
    [[SinaWeibo instance] isAvailableWithCompletion:^(BOOL isAvailable) {
        if(!isAvailable){
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"微博帐号"
                                                                message:@"请先绑定微博帐号, 系统设置->新浪微博->‘你的账号’"
                                                               delegate:[AlertHoder instance] cancelButtonTitle:@"确定" otherButtonTitles:@"帮助", nil];
                [alert show];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSelector:@selector(delayPresent)];
            });
        }
    }];
}

-(void) delayPresent{
    
    UINavigationController *nav = [[UINavigationController alloc] init];
    UIViewController *controller = [WeiboPrepareViewController createWithURL:_URL];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
	} else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
	}
    [nav pushViewController:controller animated:NO];
    
    UIApplication *app = [UIApplication sharedApplication];
    UIWindow *win = [app.windows objectAtIndex:0];
    
    [win.rootViewController presentViewController:nav animated:YES completion:nil];
    
    [controller release];
    [nav release];
}





@end

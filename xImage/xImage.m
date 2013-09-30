//
//  xImage.mm
//  xImage
//
//  Created by rockee on 13-5-8.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "CaptainHook/CaptainHook.h"
#include <notify.h> // not required; for examples only
#import "xImage.h"

#import "AppSetting.h"
#import "WeiboActivity.h"

// Objective-C runtime hooking using CaptainHook:
//   1. declare class using CHDeclareClass()
//   2. load class using CHLoadClass() or CHLoadLateClass() in CHConstructor
//   3. hook method using CHOptimizedMethod()
//   4. register hook using CHHook() in CHConstructor
//   5. (optionally) call old method using CHSuper()

//#define __xIMAGE_LOG__

@interface xImage : NSObject

@end

@implementation xImage

-(id)init{
	if ((self = [super init])){
	}
    return self;
}
@end

@class ActionPanelActivityItemsSource;
//@class AddBookmarkUIActivity;

CHDeclareClass(ActionPanelActivityItemsSource); // declare class

CHOptimizedMethod(0, self, id, ActionPanelActivityItemsSource, _customActivities) {
    NSArray *old_array = CHSuper(0, ActionPanelActivityItemsSource, _customActivities);
    NSMutableArray *array = [NSMutableArray arrayWithArray:old_array];
    id browser = objc_msgSend(objc_getClass("BrowserController"), NSSelectorFromString(@"sharedBrowserController"));
    if(browser){
        if(objc_msgSend(browser, NSSelectorFromString(@"isShowingReader"))){
            WeiboActivity *weibo = [[[WeiboActivity alloc] init] autorelease];
            [array insertObject:weibo atIndex:0];
        }
    }
    return array;
}


static void WillEnterForeground(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	// not required; for example only
}

static void ExternallyPostedNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	// not required; for example only
}

CHConstructor // code block that runs immediately upon load
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// listen for local notification (not required; for example only)
	CFNotificationCenterRef center = CFNotificationCenterGetLocalCenter();
	CFNotificationCenterAddObserver(center, NULL, WillEnterForeground, CFSTR("UIApplicationWillEnterForegroundNotification"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	
	// listen for system-side notification (not required; for example only)
	// this would be posted using: notify_post("com.gs-studio.xImage.eventname");
	CFNotificationCenterRef darwin = CFNotificationCenterGetDarwinNotifyCenter();
	CFNotificationCenterAddObserver(darwin, NULL, ExternallyPostedNotification, CFSTR("com.gs-studio.xImage.eventname"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	
	// CHLoadClass(ClassToHook); // load class (that is "available now")
	CHLoadLateClass(ActionPanelActivityItemsSource);  // load class (that will be "available later")
    CHHook(0, ActionPanelActivityItemsSource, _customActivities);
    [[AppSetting instance] default_load];
	[pool drain];
}


@interface SnapTool(){

}

@end

@implementation SnapTool
+(UIView*) activeView{
    UIView* active = nil;
    id browser = objc_msgSend(objc_getClass("BrowserController"), NSSelectorFromString(@"sharedBrowserController"));
    
    if(browser){
        if(objc_msgSend(browser, NSSelectorFromString(@"isShowingReader"))){
            id readerView = objc_msgSend(browser, NSSelectorFromString(@"readerView"));
            UIWebView *webView = objc_msgSend(readerView, NSSelectorFromString(@"webView"));
            active = webView;
        }else{
            id tabController = objc_msgSend(browser, NSSelectorFromString(@"tabController"));
            id doc = objc_msgSend(tabController, NSSelectorFromString(@"activeTabDocument"));
            UIView *frontView = objc_msgSend(doc, NSSelectorFromString(@"frontView"));
            active = frontView;
        }
    }
    return active;

}

+(UIImage*) snapshotForActiveDocument{
    UIImage *image = nil;
    id browser = objc_msgSend(objc_getClass("BrowserController"), NSSelectorFromString(@"sharedBrowserController"));
    id tabController = objc_msgSend(browser, NSSelectorFromString(@"tabController"));
    id doc = objc_msgSend(tabController, NSSelectorFromString(@"activeTabDocument"));
    id snap = objc_msgSend(browser, NSSelectorFromString(@"snapshotForTabDocument:"), doc);
    image = [UIImage imageWithCGImage:(CGImageRef)objc_msgSend(snap, NSSelectorFromString(@"image"))];
    return image;
}

+(NSString*) activeDocumentTitle{
    id browser = objc_msgSend(objc_getClass("BrowserController"), NSSelectorFromString(@"sharedBrowserController"));
    id tabController = objc_msgSend(browser, NSSelectorFromString(@"tabController"));
    id doc = objc_msgSend(tabController, NSSelectorFromString(@"activeTabDocument"));
    id title = objc_msgSend(doc, NSSelectorFromString(@"title"));
    return title;
}
@end;

/*
id snapit(){

}
*/

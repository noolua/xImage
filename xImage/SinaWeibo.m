//
//  SinaWeibo.m
//  xImage
//
//  Created by rockee on 13-5-16.
//
//
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "SinaWeibo.h"

@interface SinaWeibo(){
    ACAccountStore *store;
}
@property(nonatomic, copy) NSArray *accounts;
-(void) syncRequest:(SLRequest *)request withCompletion:(SBCompletion)completion;
@end

@implementation SinaWeibo
@synthesize accounts;
@synthesize selectedAccount;

+(SinaWeibo*) instance{
    static SinaWeibo* __instance = nil;
    if(!__instance){
        __instance = [[SinaWeibo alloc] init];
    }
    return __instance;
}

-(id) init{
    self = [super init];
    if(self){
        selectedAccount = -1;
    }
    
    return self;
}

-(void) dealloc{
    [accounts release];
    [store release];
    [super dealloc];
}

-(void) isAvailableWithCompletion:(void (^)(BOOL isAvailable))completion{
    store = [[ACAccountStore alloc] init];
    ACAccountType *accType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierSinaWeibo];
    [store requestAccessToAccountsWithType:accType options:nil completion:^(BOOL granted, NSError *error) {
        BOOL available = NO;
        if(granted){
            self.accounts = [store accountsWithAccountType:accType];
            if([accounts count] > 0){
                available = YES;
                selectedAccount = 0;
            }
        }
        if(completion)
            completion(available);
    }];
}

-(int) count{
    return (int)[accounts count];
}

-(NSString*) accountNameAtIndex:(int)index{
    NSString *name = nil;
    if([accounts count] > index){
        ACAccount *acc = [accounts objectAtIndex:index];
        name = acc.accountDescription;
    }
    return name;
}

-(NSArray*) names{
    NSMutableArray *names = [NSMutableArray arrayWithCapacity:[accounts count]];
    for(int i =0; i < [accounts count]; i++){
        ACAccount *acc = [accounts objectAtIndex:i];
        [names addObject:acc.accountDescription];
    }
    return names;
}

-(NSString*) selectedAccountName{
    NSString *name = nil;
    
    if(selectedAccount != -1){
        name = [self accountNameAtIndex:selectedAccount];
    }
    return name;
}

-(void) requestFollowAuthor:(SBCompletion) completion{
    if(selectedAccount != -1){
        NSURL *url = [NSURL URLWithString:@"https://api.weibo.com/2/friendships/create.json"];
        SLRequest *quest = [SLRequest requestForServiceType:SLServiceTypeSinaWeibo requestMethod:SLRequestMethodPOST URL:url parameters:@{@"uid": @"3082672355"}];
        quest.account = [accounts objectAtIndex:selectedAccount];
        [self syncRequest:quest withCompletion:completion];
    }
}

-(void) requestStatus:(NSString*) status completion:(SBCompletion)completion{
    if(selectedAccount != -1){
        NSURL *url = [NSURL URLWithString:@"https://api.weibo.com/2/statuses/update.json"];
        SLRequest *quest = [SLRequest requestForServiceType:SLServiceTypeSinaWeibo requestMethod:SLRequestMethodPOST URL:url parameters:@{@"status": status}];
        quest.account = [accounts objectAtIndex:selectedAccount];
        [self syncRequest:quest withCompletion:completion];
    }
}

-(void) requestStatus:(NSString*) status withImage:(NSString*) imagefile completion:(SBCompletion)completion{
    if(selectedAccount != -1){
        NSURL *url = [NSURL URLWithString:@"https://upload.api.weibo.com/2/statuses/upload.json"];
        SLRequest *quest = [SLRequest requestForServiceType:SLServiceTypeSinaWeibo requestMethod:SLRequestMethodPOST URL:url parameters:@{@"status": status}];
        NSData *data = [NSData dataWithContentsOfFile:imagefile];
        [quest addMultipartData:data withName:@"pic" type:@"multipart/form-data" filename:[imagefile lastPathComponent]];
        quest.account = [accounts objectAtIndex:selectedAccount];
        [self syncRequest:quest withCompletion:completion];
    }
}


-(void) syncRequest:(SLRequest *)request withCompletion:(SBCompletion)completion{
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            completion(responseData, urlResponse, error);
        });
    }];
}

-(NSString*) author{
    return @"看图读报";
}

@end

//
//  SinaWeibo.h
//  xImage
//
//  Created by rockee on 13-5-16.
//
//

#import <Foundation/Foundation.h>

typedef void(^SBCompletion)(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error);

@interface SinaWeibo : NSObject
@property(nonatomic, readwrite) int selectedAccount;

+(SinaWeibo*) instance;

-(void) isAvailableWithCompletion:(void (^)(BOOL isAvailable))completion;
-(int) count;
-(NSString*) accountNameAtIndex:(int)index;
-(NSArray*) names;
-(NSString*) selectedAccountName;
-(void) requestFollowAuthor:(SBCompletion) completion;
-(void) requestStatus:(NSString*) status completion:(SBCompletion)completion;
-(void) requestStatus:(NSString*) status withImage:(NSString*) imagefile completion:(SBCompletion)completion;
-(NSString*) author;
@end

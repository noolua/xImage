//
//  JsonResouceRequest.h
//  xImage
//
//  Created by rockee on 13-5-21.
//
//

#import <Foundation/Foundation.h>

@interface JsonResouceRequest : NSObject
/*
 request: http url request for resource
 localPath: save web resource to local
 response: when received data, extract json data to load resource urls, it must not be nil.
 comletion: when it completed, tell caller result.
*/
+(void) jsonResouceRequest:(NSURLRequest*)request toLocal:(NSString*) localPath overwrite:(BOOL) overwrite response:(NSArray *(^)(NSURLResponse *urlResponse, NSData *responseData, NSError *err))response completion:(void(^)(BOOL done))completion;
+(NSArray*) jsonResouceLoad:(NSArray *)urls local:(NSString*) localPath handler:(id (^)(NSData* data)) handler;
@end

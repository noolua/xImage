//
//  JsonResouceRequest.m
//  xImage
//
//  Created by rockee on 13-5-21.
//
//
#import "JsonResouceRequest.h"

@interface JsonResouceRequest(){
    int downloaded, count;
    NSArray *resource_urls;
    BOOL status, overwrite;
}
@property(nonatomic, copy) NSString *localPath;
@property(nonatomic, copy) void(^completion)(BOOL);
-(id)initWithRequest:(NSURLRequest*)request toLocal:(NSString*) localPath overwrite:(BOOL) overwrite response:(NSArray *(^)(NSURLResponse *urlResponse, NSData *responseData, NSError *err))responser completion:(void(^)(BOOL done))completion;
-(void) downloadResouce;
@end


@implementation JsonResouceRequest
+(void) jsonResouceRequest:(NSURLRequest*)request toLocal:(NSString*) localPath overwrite:(BOOL) overwrite response:(NSArray *(^)(NSURLResponse *urlResponse, NSData *responseData, NSError *err))responser completion:(void(^)(BOOL done))completion{
    
    [[JsonResouceRequest alloc] initWithRequest:request toLocal:localPath overwrite:overwrite response:responser completion:completion];
    
}

+(NSArray*) jsonResouceLoad:(NSArray *)urls local:(NSString*) localPath handler:(id (^)(NSData* data)) handler{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[urls count]];
    for (NSString *url_string in urls) {
        NSURL *url = [NSURL URLWithString:url_string];
        NSString *url_path = url.path;
        NSString *local_path = [localPath stringByAppendingString:url_path];
        NSData *data = [NSData dataWithContentsOfFile:local_path];
        [array addObject:handler(data)];
    }
    return array;
}

-(id)initWithRequest:(NSURLRequest*)request toLocal:(NSString*) localPath_ overwrite:(BOOL) overwrite_ response:(NSArray *(^)(NSURLResponse *urlResponse, NSData *responseData, NSError *err))responser completion:(void(^)(BOOL done))completion_{
    self = [super init];
    if(self){
        self.localPath = localPath_;
        self.completion = completion_;
        overwrite = overwrite_;
        downloaded = 0;
        count = 0;
        status = NO;
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
                                   NSArray *urls = responser(response, responseData, error);
                                   resource_urls = [[NSArray alloc] initWithArray:urls];
                                   downloaded = 0;
                                   count = (int)[resource_urls count];
                                   [self performSelector:@selector(downloadResouce)];
                               }];
    }
    return self;
}

-(void) downloadResouce{
    if(downloaded < count){
        // check local resource it exist
        // nor download form url
        NSURL *url = [NSURL URLWithString:[resource_urls objectAtIndex:downloaded]];
        NSString *url_path = url.path;
        NSString *local_path = [self.localPath stringByAppendingString:url_path];
        if(![[NSFileManager  defaultManager] fileExistsAtPath:local_path] || overwrite == YES){
            NSString *dir = [local_path stringByDeletingLastPathComponent];
            [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
            NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:10];
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                                       [responseData writeToFile:local_path atomically:YES];
                                       downloaded++;
                                       [self performSelector:@selector(downloadResouce)];
                                   }];
        }else{
            downloaded++;
            [self performSelector:@selector(downloadResouce)];
        }
    }else{
        status = YES;
        if(self.completion){
            self.completion(status);
        }
        JsonResouceRequest *this = self;
        [this release];
    }
}


-(void)dealloc{
    self.localPath = nil;
    self.completion = nil;
    [resource_urls release];
    [super dealloc];
}

@end

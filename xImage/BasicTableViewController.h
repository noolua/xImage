//
//  BasicTableViewController.h
//  xImage
//
//  Created by rockee on 13-5-14.
//
//

#import <UIKit/UIKit.h>
#import "TableSection.h"


@interface BasicTableViewController : UITableViewController
+(id) createController:(NSString* ) aClassname;
@property(nonatomic, retain) NSMutableArray *sections;
-(void) showStatus:(NSString* )status inSeconds:(CGFloat) duration withCompletion: (void (^)(void)) completion;
-(void) startWaiting;
-(void) stopWaiting;
-(UIImage*) genImageWithTitle:(NSString*) title;
-(void) alertMessage:(NSString*) msg;
-(void) statEventID:(NSString*) eventID label:(NSString*) label;
@end

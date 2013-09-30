//
//  SelectionsViewController.h
//  xImage
//
//  Created by rockee on 13-5-14.
//
//

#import "BasicTableViewController.h"

typedef void(^SelectionsViewControllerCompletionHandler)(int* selected_vec, int count);

@interface SelectionsViewController : BasicTableViewController
+(id) createWithItems:(NSArray*) items_ enableMultiSelect:(BOOL) enable completion:(SelectionsViewControllerCompletionHandler)completion;
-(void) selectedAtIndex:(int)index;
@end

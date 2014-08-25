//
//  SelectionsViewController.m
//  xImage
//
//  Created by rockee on 13-5-14.
//
//

#import "SelectionsViewController.h"

@interface SelectionsViewController (){
    int *_selected_vec;
    int items_count;
}
-(id) setupWithItems:(NSArray*) items_ enableMultiSelect:(BOOL) enable completion:(SelectionsViewControllerCompletionHandler)completion;
@property(nonatomic, copy) void(^completion)(int*, int);
@property(nonatomic, retain) NSArray *items;
@property(nonatomic, readwrite)BOOL enableMultiSelect;
@end

@implementation SelectionsViewController
@synthesize completion, enableMultiSelect, items;

+(id) createWithItems:(NSArray*) items_ enableMultiSelect:(BOOL) enable completion:(SelectionsViewControllerCompletionHandler)completion{
    id obj = [BasicTableViewController createController:@"SelectionsViewController"];
    obj = [obj setupWithItems:items_ enableMultiSelect:enable completion:completion];
    return obj;
}

-(id) setupWithItems:(NSArray*) items_ enableMultiSelect:(BOOL) enable completion:(SelectionsViewControllerCompletionHandler)completion_{
    self.items = items_;
    self.enableMultiSelect = enable;
    items_count = (int)[items_ count];
    NSMutableArray *sections = [[NSMutableArray alloc] initWithCapacity:4];
    TableSection *sec = [[TableSection alloc] initWithCapacity:8];
    
    for (int i = 0; i < items_count; i++) {
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
        NSObject *obj = [items_ objectAtIndex:i];
        if([obj isKindOfClass:[NSString class]]){
            NSString *text = (NSString*)obj;
            cell.textLabel.text = text;
        }else if([obj isKindOfClass:[UIImage class]]){
            UIImage *image = (UIImage*)obj;
            cell.imageView.image = image;
        }
        [sec addObject:cell];
        [cell release];
    }
    [sections addObject:sec];
    [sec release];
    
    self.sections = sections;
    [sections release];
    
    _selected_vec = malloc(sizeof(int) * items_count);
    for (int i = 0; i < items_count; i++) {
        _selected_vec[i] = 0;
    }
    self.completion = completion_;
//    completion(_selected_vec, 2);
    return self;
}

-(void) dealloc{
    if(self.completion){
        self.completion(_selected_vec, items_count);
    }
    [items release];
    free(_selected_vec);
    self.completion = nil;
    [super dealloc];
}

-(void) selectedAtIndex:(int)index{
    if(index < items_count){
        _selected_vec[index] = YES;
        UITableViewCell *cell = [[self.sections objectAtIndex:0] objectAtIndex:index];
        cell.accessoryType = (cell.accessoryType == UITableViewCellAccessoryCheckmark) ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL shouldSelected = NO;

    UITableViewCell *cell = [[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if(cell.accessoryType == UITableViewCellAccessoryNone){
        shouldSelected = YES;
    }else{
        shouldSelected = (enableMultiSelect == YES) ? NO : YES;
    }
    cell.accessoryType = (shouldSelected == NO) ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
    _selected_vec[indexPath.row] = (shouldSelected) ? YES: NO;

    if(shouldSelected){
        if(!enableMultiSelect){
            for (int i = 0; i < items_count; i++) {
                UITableViewCell *one = [[self.sections objectAtIndex:indexPath.section] objectAtIndex:i];
                if(one != cell){
                    one.accessoryType = UITableViewCellAccessoryNone;
                    _selected_vec[i] = NO;
                }
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else{
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


@end

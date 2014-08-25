//
//  HeaderFooterViewController.m
//  xImage
//
//  Created by rockee on 13-5-14.
//
//
#import <QuartzCore/QuartzCore.h>
#import "HeaderFooterViewController.h"
#import "AppSetting.h"

#import "resource.h"
#import "JsonResouceRequest.h"

#import "SelectionsViewController.h"

//#import "PickupImageViewController.h"

#define kTagHeaderText      (1000)
#define kTagFooterText      (1001)
#define kTagPickupHeaderImage   (1002)
#define kTagPickupFooterImage   (1003)

enum{
    HFVC_Header,
    HFVC_Footer,
    HFVC_Review,
    HFVC_End_Index,
};

@interface HeaderFooterViewController ()<UITextFieldDelegate>{
    UITableViewCell *_cell4headerText;
    UITableViewCell *_cell4headerImage;
    UITableViewCell *_cell4footerImage;
    UISwitch *_switchHeaderFormat;
}
-(void) switchFormatForHeader:(UISwitch*) headerSwitch;
-(void) headerAlignmentChanged:(UISegmentedControl*)segment;
-(void) footerTextAlignmentChanged:(UISegmentedControl*)segment;
-(void) footerImageAlignmentChanged:(UISegmentedControl*)segment;

@end

@implementation HeaderFooterViewController
-(void) dealloc{
    [_cell4headerText release];
    [_cell4headerImage release];
    
    [super dealloc];
}

-(void) setupSections{
    AppConfig *config = [AppSetting config];
    
    self.navigationItem.title = @"微博设置";
    NSMutableArray *sections = [[NSMutableArray alloc] initWithCapacity:HFVC_End_Index];
    {
        TableSection *sec = [[TableSection alloc] initWithCapacity:4];
        {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
            UISegmentedControl* segment = [[UISegmentedControl alloc] initWithItems:@[@"居左", @"居中", @"居右"]];
            segment.segmentedControlStyle = UISegmentedControlStyleBar;
            segment.frame = CGRectMake(0, 0, 140, 30);
            segment.selectedSegmentIndex = config.headerAlignment;
            [segment addTarget:self action:@selector(headerAlignmentChanged:) forControlEvents:UIControlEventValueChanged];
            cell.textLabel.text = @"页眉布局";
            cell.accessoryView = segment;
            [segment release];
            [sec addObject:cell];
            [cell release];
        }
        {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
            UISwitch* format = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 120, 27)];
            [format addTarget:self action:@selector(switchFormatForHeader:) forControlEvents:UIControlEventTouchUpInside];
            format.offImage = [self genImageWithTitle:@"文字"];
            format.onImage = [self genImageWithTitle:@"图片"];
            [format setOn:(config.headerFormat == 1 ? YES: NO)];
            _switchHeaderFormat = format;
            cell.textLabel.text = @"页眉格式";
            cell.accessoryView = format;
            [format release];
            [sec addObject:cell];
            [cell release];
        }

        [sections addObject:sec];
        [sec release];
    }
    {
        TableSection *sec = [[TableSection alloc] initWithCapacity:4];
        {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
            UISegmentedControl* segment = [[UISegmentedControl alloc] initWithItems:@[@"居左", @"居中", @"居右"]];
            segment.segmentedControlStyle = UISegmentedControlStyleBar;
            segment.frame = CGRectMake(0, 0, 140, 30);
            segment.selectedSegmentIndex = config.footerTextAlignment;
            [segment addTarget:self action:@selector(footerTextAlignmentChanged:) forControlEvents:UIControlEventValueChanged];
            cell.textLabel.text = @"页脚文字布局";
            cell.accessoryView = segment;
            [segment release];
            [sec addObject:cell];
            [cell release];
        }
        {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
            UITextField * text = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 140, 30)];
            text.borderStyle = UITextBorderStyleRoundedRect;
            cell.textLabel.text = @"页脚文字";
            cell.accessoryView = text;
            text.placeholder = @"文字内容";
            text.text = config.footerText;
            text.tag = kTagFooterText;
            text.delegate = self;
            [text release];
            [sec addObject:cell];
            [cell release];
        }
        {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
            UISegmentedControl* segment = [[UISegmentedControl alloc] initWithItems:@[@"居左", @"居中", @"居右"]];
            segment.segmentedControlStyle = UISegmentedControlStyleBar;
            segment.frame = CGRectMake(0, 0, 140, 30);
            segment.selectedSegmentIndex = config.footerImageAlignment;
            [segment addTarget:self action:@selector(footerImageAlignmentChanged:) forControlEvents:UIControlEventValueChanged];
            cell.textLabel.text = @"页脚图片布局";
            cell.accessoryView = segment;
            [segment release];
            [sec addObject:cell];
            [cell release];
        }
        {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"subtitle"];
            cell.frame = CGRectMake(0, 0, 320, 80);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.tag = kTagPickupFooterImage;
            UIImage *image = [UIImage imageWithContentsOfFile:[AppSetting config].footerImagePath];
            if(!image){
                image = resource_image(RIWeiboIcon);
                cell.detailTextLabel.text = @"选择页脚图片";
            }
            cell.imageView.image = image;
            _cell4footerImage = cell;
            [sec addObject:cell];
            [cell release];
        }
        [sections addObject:sec];
        [sec release];
    }
    /*
    {
        TableSection *sec = [[TableSection alloc] initWithCapacity:1];
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default_button"];
        cell.backgroundColor = [UIColor colorWithRed:82.0/255.0 green:80.0/255.0 blue:138.0/255.0 alpha:1.0];
        cell.textLabel.text = @"预览效果";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
        cell.textLabel.layer.shadowOpacity = 1;
        cell.textLabel.layer.shadowOffset = CGSizeMake(0, -1);
        [sec addObject:cell];
        [sections addObject:sec];
        [cell release];
        [sec release];
    }
    */
    /*cell4headerText*/
    {
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
        UITextField * text = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 140, 30)];
        text.borderStyle = UITextBorderStyleRoundedRect;
        cell.textLabel.text = @"页眉文字";
        cell.accessoryView = text;
        text.placeholder = @"文字内容";
        text.text = config.headerText;
        text.tag = kTagHeaderText;
        text.delegate = self;
        [text release];
        
        _cell4headerText = cell;
    }

    /*cell4headerImage*/
    {
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"subtitle"];
        cell.frame = CGRectMake(0, 0, 320, 80);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.tag = kTagPickupHeaderImage;
        UIImage *image = [UIImage imageWithContentsOfFile:[AppSetting config].headerImagePath];
        if(!image){
            image = resource_image(RIWeiboIcon);
            cell.detailTextLabel.text = @"选择页眉图片";
        }
        cell.imageView.image = image;
        _cell4headerImage = cell;
    }
    
    self.sections = sections;
    [sections release];
    
    TableSection *sec = [self.sections objectAtIndex:HFVC_Header];
    int row = 2;
    if(config.headerFormat == 1){
        /*image*/
        [sec insertObject:_cell4headerImage atIndex:row];
        [sec removeObject:_cell4headerText];
    }else{
        /*text*/
        [sec insertObject:_cell4headerText atIndex:row];
        [sec removeObject:_cell4headerImage];
    }
}

-(void) switchFormatForHeader:(UISwitch*) headerSwitch{
    [AppSetting config].headerFormat = headerSwitch.on ? 1 : 0;
    TableSection *sec = [self.sections objectAtIndex:HFVC_Header];
    int row = 2;
    if(headerSwitch.on){
        /*image*/
        [sec insertObject:_cell4headerImage atIndex:row];
        [sec removeObject:_cell4headerText];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:HFVC_Header]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else{
        /*text*/
        [sec insertObject:_cell4headerText atIndex:row];
        [sec removeObject:_cell4headerImage];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:HFVC_Header]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
-(void) headerAlignmentChanged:(UISegmentedControl*)segment{
    [AppSetting config].headerAlignment = (int)segment.selectedSegmentIndex;
}

-(void) footerTextAlignmentChanged:(UISegmentedControl*)segment{
    [AppSetting config].footerTextAlignment = (int)segment.selectedSegmentIndex;
}

-(void) footerImageAlignmentChanged:(UISegmentedControl*)segment{
    [AppSetting config].footerImageAlignment = (int)segment.selectedSegmentIndex;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if(textField.tag == kTagHeaderText){
        [AppSetting config].headerText = textField.text;
    }else if(textField.tag == kTagFooterText){
        [AppSetting config].footerText = textField.text;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if(cell.tag == kTagPickupHeaderImage || cell.tag == kTagPickupFooterImage){
        [self startWaiting];
        AppSetting *setting = [AppSetting instance];
        NSURL *url = (cell.tag == kTagPickupHeaderImage) ? setting.header_request_url :setting.footer_request_url;
        NSURLRequest *req = [NSURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:30];
        __block NSArray *urls = nil;
        [JsonResouceRequest jsonResouceRequest:req toLocal:[AppSetting instance].plug_path overwrite:YES response:^NSArray *(NSURLResponse *urlResponse, NSData *responseData, NSError *err) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData
                                                                options:NSJSONReadingAllowFragments error:&err];
            urls = [[NSArray alloc] initWithArray:[dic objectForKey:@"images"]];
            return urls;
        } completion:^(BOOL done) {
            [self stopWaiting];
            NSArray *images = [JsonResouceRequest jsonResouceLoad:urls local:[AppSetting instance].plug_path handler:^id(NSData *data) {
                id one = nil;
                if(data){
                    one = [UIImage imageWithData:data];
                }
                return one;
            }];
            NSMutableArray *fixedImages = [NSMutableArray arrayWithArray:images];
            [fixedImages insertObject:@"取消图片" atIndex:0];
            SelectionsViewController *controller = [SelectionsViewController createWithItems:fixedImages enableMultiSelect:NO completion:^(int *selected_vec, int count) {
                for(int i = 0; i < count; i++){
                    if(selected_vec[i] != 0){
                        int select = i;
                        if(select == 0){
                            [cell.imageView setImage:nil];
                            if(cell.tag == kTagPickupHeaderImage){
                                [AppSetting config].headerImagePath = @"";
                                cell.detailTextLabel.text = @"选择页眉图片";
                            }else{
                                [AppSetting config].footerImagePath = @"";
                                cell.detailTextLabel.text = @"选择页脚图片";
                            }
                            cell.imageView.image = resource_image(RIWeiboIcon);
                        }else{
                            select -= 1;
                            UIImage *image = [images objectAtIndex:select];
                            cell.imageView.image = image;
                            cell.detailTextLabel.text = @"";
                            NSURL *url = [NSURL URLWithString:[urls objectAtIndex:select]];
                            NSString *path = url.path;
                            NSString *local_path = [setting.plug_path stringByAppendingString:path];
                            if(cell.tag == kTagPickupHeaderImage){
                                [AppSetting config].headerImagePath = local_path;
                            }else{
                                [AppSetting config].footerImagePath = local_path;
                            }
                        }
                        break;
                    }
                }
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                [urls release];
            }];
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];
        }];

    }
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

@end

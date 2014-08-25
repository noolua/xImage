//
//  WeiboPrepareViewController.m
//  xImage
//
//  Created by rockee on 13-5-10.
//
//
#import <QuartzCore/QuartzCore.h>
#import "xImage.h"

#import "WeiboPrepareViewController.h"
#import "WeiboSettingViewController.h"
#import "SelectionsViewController.h"
#import "AppSetting.h"

#import "SinaWeibo.h"
#import "TableSection.h"
#import "resource.h"
#import "WebImageSuite.h"

#define TAG_SETTING     (0x12ad)
#define TAG_Review      (0x12dd)
#define SNAP_FILE      @"CF4F331A-C6FB-4D55-AB35-9073675F941B.snap"

enum
{
    WPS_Setting,
    WPS_WeiboPrepare,
    WPS_End_Index,
};

@interface WeiboPrepareViewController ()<UITextViewDelegate>{
    UIImageView *_thumbView;
    UITextView *_statusView;
    UILabel *_label;
    UISwitch   *_switchAddURL;
    unsigned long long  _image_file_size;
    BOOL _appeared;
}
@property(nonatomic, copy) NSURL *sourceURL;
-(void) setupSections;
-(void)close:(id)sender;
-(void)sendWeibo:(id)sender;
-(void)tapAtWhos:(id)sender;
-(void)tapTopics:(id)sender;
-(void)updateLabel;
-(void)genImage;
-(void)genSummary;
@end

@implementation WeiboPrepareViewController
+(id) createWithURL:(NSURL*) sourceURL_{
    WeiboPrepareViewController *demo = [BasicTableViewController createController:@"WeiboPrepareViewController"];
    demo.sourceURL = sourceURL_;
    return demo;
}

- (void)dealloc
{
    self.sourceURL = nil;
    [super dealloc];
}

-(void) viewDidAppear:(BOOL)animated{
    
    if(_appeared == NO){
        [self performSelector:@selector(genSummary) withObject:nil];
        [self performSelector:@selector(genImage) withObject:nil];
        _image_file_size = 0;
        _appeared = YES;
    }
    if([AppSetting config].isDirty){
        [self performSelector:@selector(genImage) withObject:nil];
    }
    [super viewDidAppear:animated];
}

-(void) setupSections{
    
    NSMutableArray *sections = nil;
    sections = [[NSMutableArray alloc] initWithCapacity:WPS_End_Index];
    UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleBordered target:self action:@selector(close:)];
    self.navigationItem.leftBarButtonItem = close;
    [close release];
    
    UIBarButtonItem *send = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStyleDone target:self action:@selector(sendWeibo:)];
    self.navigationItem.rightBarButtonItem = send;
    [send release];
    
    self.navigationItem.title = @"微博发布";
    {
        TableSection *sec = [[TableSection alloc] initWithCapacity:3];
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
        cell.textLabel.text = @"微博设置";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [sec addObject:cell];
        [cell release];
        [sections addObject:sec];
        [sec release];
    }
    {
        TableSection *sec = [[TableSection alloc] initWithCapacity:8];
        {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
            NSString *name = [[SinaWeibo instance] selectedAccountName];
            NSString *text = [NSString stringWithFormat:@"发布人: %@", name];
            cell.textLabel.text = text;
            if([[SinaWeibo instance] count] > 1){
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            [sec addObject:cell];
            [cell release];
        }
        {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
            CGRect frame = CGRectMake(20, 10, 280, 120);
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                frame = CGRectMake(40, 10, 240, 120);
            }
            UITextView *message = [[UITextView alloc] initWithFrame:frame];
            message.font = [UIFont systemFontOfSize:20];
            message.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            message.layer.cornerRadius = 8;
            message.layer.masksToBounds = YES;
            message.layer.borderWidth = 1;
            message.layer.borderColor = [[UIColor grayColor] CGColor];
            _statusView = message;
            _statusView.delegate = self;
            cell.frame = CGRectMake(0, 0, 320, 140);
            [cell addSubview:message];
            [message release];
            [sec addObject:cell];
            [cell release];
        }
        /*
        {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
            UIButton *buttonTopics = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            buttonTopics.frame = CGRectMake(40, 5, 40, 30);
            [buttonTopics setTitle:@"#" forState:UIControlStateNormal];
            [buttonTopics addTarget:self action:@selector(tapTopics:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:buttonTopics];
            UIButton *buttonAtWho = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            buttonAtWho.frame = CGRectMake(90, 5, 40, 30);
            [buttonAtWho setTitle:@"@" forState:UIControlStateNormal];
            [buttonAtWho addTarget:self action:@selector(tapAtWhos:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:buttonAtWho];
            [sec addObject:cell];
            [cell release];
        }
        */
        /*
        {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
            cell.textLabel.text = @"插入表情符号";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [sec addObject:cell];
            [cell release];
        }
        */
        {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"subtitle"];
            UISwitch* addURL = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 94, 27)];
            [addURL addTarget:self action:@selector(updateLabel) forControlEvents:UIControlEventTouchUpInside];
            [addURL setOn:YES];
            cell.accessoryView = addURL;
            cell.detailTextLabel.text = @"    ";
            _switchAddURL = addURL;
            _label = cell.detailTextLabel;
            [addURL release];
            [sec addObject:cell];
            [cell release];
        }
        /*
        {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
            cell.textLabel.text = @"@朋友们...";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [sec addObject:cell];
            [cell release];
        }
        */
        {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
            cell.frame = CGRectMake(0, 0, 320, 260);
            cell.tag = TAG_Review;
            CGRect frame = CGRectMake(20, 10, 280, 240);
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                frame = CGRectMake(40, 10, 240, 240);
            }
            UIImageView *imageview = [[UIImageView alloc] initWithFrame:frame];
            imageview.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            imageview.image = resource_image(RIWeiboIcon);
            [cell addSubview:imageview];
            _thumbView = imageview;
            [imageview release];
            [sec addObject:cell];
            [cell release];
        }
        [sections addObject:sec];
        [sec release];
    }

    self.sections = sections;
    [sections release];
}


-(void)close:(id)sender{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)sendWeibo:(id)sender{
    NSString *message = _statusView.text;
    NSString *filePath = [[AppSetting instance].plug_path stringByAppendingPathComponent:SNAP_FILE];
    NSUInteger length = [message length];
    if(length > 0  && length < 140){
        [self startWaiting];
        [_statusView resignFirstResponder];
        if(_switchAddURL.on){
            message = [message stringByAppendingString:@" "];
            message = [message stringByAppendingString:[self.sourceURL absoluteString]];
        }
        [[SinaWeibo instance] requestStatus:message withImage:filePath completion:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            BOOL bOK = NO;
            NSString *msg = nil;
            if ([urlResponse statusCode] >= 400) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData
                                                                    options:NSJSONReadingAllowFragments error:&error];
                NSString *error_msg = [dic objectForKey:@"error"];
                msg = [NSString stringWithFormat:@"发表失败: '%@'", error_msg];
            }else{
                bOK = YES;
                msg = @"发表成功";
            }
            [self stopWaiting];
            NSString *name = [[SinaWeibo instance] selectedAccountName];
            NSString *content_label = [NSString stringWithFormat:@"%@:%@", name, _statusView.text];
            [self statEventID:@"发表微博" label:content_label];
            [self showStatus:msg inSeconds:2.0 withCompletion:^{
                if(bOK){
                    [self dismissViewControllerAnimated:YES completion:NULL];
                }
            }];
        }];
    }else if(length >= 140){
        [self showStatus:@"微博文字不得超过140个字" inSeconds:2.0 withCompletion:NULL];
        
    }
    /*send wei bo*/
}

-(void)updateLabel{
    int  length = (int)[_statusView.text length];
    length = 140 - length;
    if(_image_file_size == 0){
        NSString *text = [[NSString alloc] initWithFormat:@"%@原文链接, 还剩(%d)个字", (_switchAddURL.on ? @"添加" :@"取消"), length];
        _label.text = text;
        [text release];
    }else{
        NSString *text = [[NSString alloc] initWithFormat:@"%@原文链接, 还剩(%d)个字, 图片大小 %lluK",
                          (_switchAddURL.on ? @"添加" :@"取消"), length, _image_file_size / 1024];
        _label.text = text;
        [text release];
    }
}

- (void)textViewDidChange:(UITextView *)textView{
    if(textView == _statusView){
        [self updateLabel];
    }
}

-(void)tapAtWhos:(id)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"HEHE" message:@"at who" delegate:nil
                                          cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
    
    [alert show];
    [alert release];
}

-(void)tapTopics:(id)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"HEHE" message:@"topics" delegate:nil
                                          cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
    
    [alert show];
    [alert release];
}

-(void)genImage{
    UIView *activeView = [SnapTool activeView];
    @autoreleasepool {
        [self startWaiting];
        _image_file_size = 0;
        UIImage *image = [WebImageSuite snapView:activeView];
        NSString *filePath = [[AppSetting instance].plug_path stringByAppendingPathComponent:SNAP_FILE];
        
        [WebImageSuite GenWebImageWithImage:image toFile:filePath completion:^(BOOL ok) {
            if(ok){
                NSDictionary *attribute = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
                if(attribute){
                    NSNumber *filesize = [attribute objectForKey:NSFileSize];
                    _image_file_size = [filesize unsignedLongLongValue];
                    [self updateLabel];
                }
                UIImage *load = [UIImage imageWithContentsOfFile:filePath];
                UIImage *scaled = _scaledImage(load, _thumbView.bounds.size);
                _thumbView.image = scaled;
                [self stopWaiting];
            }
        }];
    }
}

-(void)genSummary{
    NSString *rawTitle = [SnapTool activeDocumentTitle];
    NSArray *comps = [rawTitle componentsSeparatedByString:@"-"];
    NSString *title = [comps objectAtIndex:0];
    NSArray *comps2 =[title componentsSeparatedByString:@"|"];
    title = [comps2 objectAtIndex:0];
    NSArray *comps3 =[title componentsSeparatedByString:@"_"];
    title = [comps3 objectAtIndex:0];
    title = [NSString stringWithFormat:@"【%@】", title];
    _statusView.text = title;
}

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if(indexPath.section == WPS_Setting){
        WeiboSettingViewController *setting = [BasicTableViewController createController:@"WeiboSettingViewController"];
        [self.navigationController pushViewController:setting animated:YES];
        [setting release];
    }else if(indexPath.section == WPS_WeiboPrepare && indexPath.row == 0 && [[SinaWeibo instance] count] >= 2){
        NSArray *names = [[SinaWeibo instance] names];
        SelectionsViewController *controller = [SelectionsViewController createWithItems:names enableMultiSelect:NO completion:^(int *selected_vec, int count) {
            for(int i = 0; i < count; i++){
                if(selected_vec[i] != 0){
                    [SinaWeibo instance].selectedAccount = i;
                    NSString *name = [[SinaWeibo instance] selectedAccountName];
                    NSString *text = [NSString stringWithFormat:@"发布人: %@", name];
                    UITableViewCell *cell = [[self.sections objectAtIndex:WPS_WeiboPrepare] objectAtIndex:0];
                    cell.textLabel.text = text;
                    break;
                }
            }
        }];
        [controller selectedAtIndex:[SinaWeibo instance].selectedAccount];
        
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }else if(cell.tag == TAG_Review){
        NSString *filePath = [[AppSetting instance].plug_path stringByAppendingPathComponent:SNAP_FILE];
        UIImage *load = [UIImage imageWithContentsOfFile:filePath];
        if(load){
            UIViewController * controller = [[UIViewController alloc] init];
            controller.title = @"浏览原图";
            UIScrollView *scroller = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
            controller.view = scroller;
            UIImageView *imageview = [[UIImageView alloc] initWithImage:load];
            CGSize fixed = load.size;
            CGSize sc_size = scroller.bounds.size;
            CGFloat xFactor = fixed.width / sc_size.width;
            if(xFactor > 1.0){
                fixed.width /= xFactor;
                fixed.height /= xFactor;
            }
            imageview.frame = CGRectMake(0, 0, fixed.width, fixed.height);
            [scroller addSubview:imageview];
            [scroller setContentSize:fixed];
            [imageview release];
            [scroller release];
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];
        }
    }
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}




@end

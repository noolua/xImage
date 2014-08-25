//
//  AboutAppViewController.m
//  xImage
//
//  Created by rockee on 13-5-22.
//
//
#import <QuartzCore/QuartzCore.h>
#import "AboutAppViewController.h"
#import "resource.h"
#import "AppSetting.h"
#import "SinaWeibo.h"

#define kTagFollowMe        (10002)

enum
{
    AAVC_AboutMe,
    AAVC_MoreApps,
    AAVC_End_Index,
};

@interface AboutAppViewController (){
    BOOL _appeared;
    UITextView *_aboutme;
    NSDictionary *contents;
}

-(void) requestContent;
-(void) followAuthor;
-(void) reloadContents;
@end

@implementation AboutAppViewController
-(void)dealloc{
    if(contents)
        [contents release];
    [super dealloc];
}

-(void) viewDidAppear:(BOOL)animated{
    
    if(_appeared == NO){
        [self performSelector:@selector(requestContent)];
        _appeared = YES;
    }
    [super viewDidAppear:animated];
}

-(void) setupSections{
    self.navigationItem.title = @"关于";
    NSMutableArray *sections = [[NSMutableArray alloc] initWithCapacity:AAVC_End_Index];
    {
        TableSection *sec = [[TableSection alloc] initWithCapacity:2];
        {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
            CGRect frame = CGRectMake(20, 10, 280, 240);
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                frame = CGRectMake(40, 10, 240, 240);
            }
            UITextView *message = [[UITextView alloc] initWithFrame:frame];
            message.editable = NO;
            message.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
            message.font = [UIFont systemFontOfSize:20];
            message.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            message.layer.cornerRadius = 8;
            message.layer.masksToBounds = YES;
            message.layer.borderWidth = 1;
            message.layer.borderColor = [[UIColor grayColor] CGColor];
            _aboutme = message;
            cell.frame = CGRectMake(0, 0, 320, 260);
            [cell addSubview:message];
            [message release];
            [sec addObject:cell];
            [cell release];
        }
        {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
            cell.textLabel.text = [NSString stringWithFormat:@"版本：%@", [AppSetting instance].version];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [sec addObject:cell];
            [cell release];
        }
        {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default_button"];
            UIButton *addFollow = [UIButton buttonWithType:UIButtonTypeContactAdd];
            [addFollow addTarget:self action:@selector(followAuthor) forControlEvents:UIControlEventTouchUpInside];
            cell.textLabel.text = @"关注作者微博"; 
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.accessoryView = addFollow;
            cell.tag = kTagFollowMe;
            [sec addObject:cell];
            [cell release];
        }
        [sections addObject:sec];
        [sec release];
    }
    {
        TableSection *sec = [[TableSection alloc] initWithCapacity:8];
        /*
        sec.header = @"推荐应用";
        {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"subtitle"];
            cell.imageView.image = resource_image(RIWeiboIcon);
            cell.textLabel.text = @"饭局计划";
            cell.detailTextLabel.text = @"饭局规划x美食相机x开销激励，你的私人美食助理";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.frame = CGRectMake(0, 0, 320, 70);
            [sec addObject:cell];
            [cell release];
        }
        {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"subtitle"];
            cell.imageView.image = resource_image(RIWeiboIcon);
            cell.textLabel.text = @"iMoney";
            cell.detailTextLabel.text = @"苹果官方推荐的中文即时汇率换算应用";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.frame = CGRectMake(0, 0, 320, 70);
            [sec addObject:cell];
            [cell release];
        }
        {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"subtitle"];
            cell.imageView.image = resource_image(RIWeiboIcon);
            cell.textLabel.text = @"iCare 吃药提醒";
            cell.detailTextLabel.text = @"专门帮助你提醒自己和亲友准时服药的超有爱应用";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.frame = CGRectMake(0, 0, 320, 70);
            [sec addObject:cell];
            [cell release];
        }
        */
        [sections addObject:sec];
        [sec release];
    }
    
    self.sections = sections;
    [sections release];
    
}

-(void) followAuthor{
    [self startWaiting];
    [[SinaWeibo instance] requestFollowAuthor:^(NSData *responseData, NSHTTPURLResponse *httpResponse, NSError *error) {
        NSString *msg = nil;
        if ([httpResponse statusCode] >= 400) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData
                                                                options:NSJSONReadingAllowFragments error:&error];
            NSString *error_msg = [dic objectForKey:@"error"];
            msg = [NSString stringWithFormat:@"关注失败: '%@'", error_msg];
        }else{
            msg = @"关注成功";
        }
        [self stopWaiting];
        [self showStatus:msg inSeconds:2.0 withCompletion:NULL];
    }];
}

-(void) requestContent{
    [self startWaiting];
    
    NSURLRequest *request = [NSURLRequest requestWithURL: [AppSetting instance].about_url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:30];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse * response, NSData *responseData, NSError *error)
     {
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
         if ([httpResponse statusCode] >= 400 || error != nil){
             NSString *msg = [NSString stringWithFormat:@"访问失败, 代码(%d)，请稍候再试", (int)[httpResponse statusCode]];
             [self showStatus:msg inSeconds:2.0 withCompletion:NULL];
         }else{
             NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData
                                                                 options:NSJSONReadingAllowFragments error:&error];
             if(contents){
                 [contents release];
                 contents = nil;
             }
             contents = [[NSDictionary alloc] initWithDictionary:dic];
             [self performSelector:@selector(reloadContents)];
         }
         [self stopWaiting];
     }];
}

-(void) reloadContents{
    TableSection *sec = [self.sections objectAtIndex:AAVC_MoreApps];

    _aboutme.text = [contents objectForKey:@"content"];

    [sec removeAllObjects];
    NSArray *arrayApps = [contents objectForKey:@"apps"];
    int count = (int)[arrayApps count];
    sec.header = @"";
    if(count > 0){
        sec.header = @"推荐应用";
        for (NSDictionary *item in arrayApps) {
            NSString *name = [item objectForKey:@"name"];
            NSString *detail = [item objectForKey:@"detail"];
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"subtitle"];
            cell.imageView.image = resource_image(RIWeiboIcon);
            cell.textLabel.text = name;
            cell.detailTextLabel.text = detail;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.frame = CGRectMake(0, 0, 320, 70);
            [sec addObject:cell];
            [cell release];
        }
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:AAVC_MoreApps] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if(cell.tag == kTagFollowMe){
        [self followAuthor];
    }else if(indexPath.section == AAVC_MoreApps){
        /*click app*/
        NSString *app_url = nil;
        NSArray *apps = [contents objectForKey:@"apps"];
        NSDictionary *item = [apps objectAtIndex:indexPath.row];
        app_url = [item objectForKey:@"app_url"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:app_url]];
    }
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}


@end

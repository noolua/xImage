//
//  ReportViewController.m
//  xImage
//
//  Created by rockee on 13-5-14.
//
//
#import "sys/utsname.h"
#import <QuartzCore/QuartzCore.h>

#import "ReportViewController.h"
#import "AppSetting.h"
#import "SinaWeibo.h"

enum
{
    RVC_Report,
    RVC_Submit,
    RVC_End_Index,
};

@interface ReportViewController (){
    BOOL toWeibo;
    NSURLConnection *_cnn;
    UITextView *_comment;
    UILabel *_detail;
}
-(void) switchToWeibo:(UISwitch*) sw;
-(void) sendComments;
@end

@implementation ReportViewController

-(void)dealloc{
    [_cnn release];
    [super dealloc];
}

-(void) viewDidAppear:(BOOL)animated{
    [_comment performSelector:@selector(becomeFirstResponder) withObject:nil];
//    [_comment becomeFirstResponder];
    [super viewDidAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated{
    [_comment resignFirstResponder];
    [super viewWillDisappear:animated];
}

-(void) setupSections{
    self.navigationItem.title = @"意见反馈";
    NSMutableArray *sections = [[NSMutableArray alloc] initWithCapacity:RVC_End_Index];
    {
        TableSection *sec = [[TableSection alloc] initWithCapacity:4];
        {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"subtitle"];
            UISwitch* format = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 140, 27)];
            [format addTarget:self action:@selector(switchToWeibo:) forControlEvents:UIControlEventTouchUpInside];
            format.onImage = [self genImageWithTitle:@"发微博"];
            format.offImage = [self genImageWithTitle:@"发网站"];
            [format setOn:toWeibo];
            _detail = cell.detailTextLabel;
            cell.detailTextLabel.text = @"发表一条反馈到作者网站";
            cell.accessoryView = format;
            [format release];
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
            cell.frame = CGRectMake(0, 0, 320, 140);
            [cell addSubview:message];
            _comment = message;
            [message release];
            [sec addObject:cell];
            [cell release];
        }
        [sections addObject:sec];
        [sec release];
    }
    {
        TableSection *sec = [[TableSection alloc] initWithCapacity:1];
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default_button"];
        cell.backgroundColor = [UIColor colorWithRed:82.0/255.0 green:80.0/255.0 blue:138.0/255.0 alpha:1.0];
        cell.textLabel.text = @"发送报告";
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
    
    self.sections = sections;
    [sections release];
    
}

-(void) switchToWeibo:(UISwitch*) sw{
    toWeibo = sw.on;
    if(toWeibo){
        _detail.text = @"发表一条微博并@作者";
        
    }else{
        _detail.text = @"发表一条反馈到作者网站";
    }
}

-(void) sendComments{
    NSString *comment = _comment.text;
    NSString *user = [[SinaWeibo instance] selectedAccountName];
    if([comment isEqualToString:@""] || !user){
        [self showStatus:@"没有可提交的内容" inSeconds:1.5 withCompletion:^{
            self.view.userInteractionEnabled = YES;
        }];
        self.view.userInteractionEnabled = NO;
        return;
    }
    else{
        if(toWeibo){
            NSString *status = [NSString stringWithFormat:@"%@ @%@", comment, [[SinaWeibo instance] author]];
            [[SinaWeibo instance] requestStatus:status completion:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                NSString *msg = nil;
                if ([urlResponse statusCode] >= 400) {
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData
                                                                        options:NSJSONReadingAllowFragments error:&error];
                    NSString *error_msg = [dic objectForKey:@"error"];
                    msg = [NSString stringWithFormat:@"发表微博失败: '%@'", error_msg];
                }else{
                    msg = @"发表微博成功";
                }
                [self stopWaiting];
                [self showStatus:msg inSeconds:2.0 withCompletion:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }];
        }else{
            struct utsname systemInfo;
            uname(&systemInfo);
            NSString *device = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
            NSString *sysVerion = [[UIDevice currentDevice] systemVersion];
            NSString *hiddenInfo = [NSString stringWithFormat:@"verion: %@, device: %@, os: %@", [AppSetting instance].version, device, sysVerion];
            NSString *postfield = [[NSString alloc] initWithFormat:@"sysinfo=%@&comment=%@&user_name=%@", hiddenInfo, comment, user];
            NSData *data = [postfield dataUsingEncoding:NSUTF8StringEncoding];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[AppSetting instance].comment_url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:5.0];
            [request setHTTPMethod:@"POST"];
            NSString *postLength = [NSString stringWithFormat:@"%d", (int)[data length]];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            
            [request setHTTPBody:data];
            [postfield release];
            if(_cnn){
                [_cnn release];
                _cnn = nil;
            }
            _cnn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        }
        [self startWaiting];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [self stopWaiting];
    [self showStatus:@"提交失败，请稍候再试" inSeconds:2.0 withCompletion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSString *msg = @"提交成功";
    if ([httpResponse statusCode] >= 400) {
        msg = [NSString stringWithFormat:@"提交失败(%d)，请稍候再试", (int)[httpResponse statusCode]];
    }else{
//        _comment.text = @"";
    }
    [self stopWaiting];
    
    [self showStatus:msg inSeconds:2.0 withCompletion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == RVC_Submit){
        [self sendComments];
    }
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}


@end

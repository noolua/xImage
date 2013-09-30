//
//  WeiboSettingViewController.m
//  xImage
//
//  Created by rockee on 13-5-13.
//
//
#import <QuartzCore/QuartzCore.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

#import "WeiboSettingViewController.h"
#import "TableSection.h"
#import "AppSetting.h"
#import "SinaWeibo.h"

#import "HeaderFooterViewController.h"
#import "ThemesViewController.h"
#import "ReportViewController.h"

enum
{
    WSVC_Setting,
    WSVC_More,
    WSVC_End_Index,
};

#define kTagHeaderFooter        (1000)
#define kTagThemes              (1001)
#define kTagReportBugs          (1002)
#define kTagOnlineDoc           (1003)
#define kTagAboutApp            (1004)
#define kTagWaterMark           (1005)

@interface WeiboSettingViewController ()<UITextFieldDelegate>{
    UILabel* _waterMark;
    UITableViewCell *_cell4JPGQunality;
}
-(void) waterMaskValueChanged:(UISlider*)slider;
-(void) jpgQunalityValueChanged:(UISegmentedControl*)segment;
-(void) switchImageFormat:(UISwitch*)switchFormat;
@end

@implementation WeiboSettingViewController
- (void)dealloc
{
    [_cell4JPGQunality release];
    [super dealloc];
}

-(void) setupSections{
    AppConfig* config = [AppSetting config];
    
    self.navigationItem.title = @"微博设置";
    NSMutableArray *sections = [[NSMutableArray alloc] initWithCapacity:WSVC_End_Index];
    {
        TableSection *sec = [[TableSection alloc] initWithCapacity:4];
        {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
            UISwitch* format = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 100, 27)];
            [format addTarget:self action:@selector(switchImageFormat:) forControlEvents:UIControlEventTouchUpInside];
            format.offImage = [self genImageWithTitle:@"PNG"];
            format.onImage = [self genImageWithTitle:@"JPG"];
            [format setOn:(config.imageFormat == 1 ? YES : NO)];
            cell.textLabel.text = @"图片格式";
            cell.accessoryView = format;
            [format release];
            [sec addObject:cell];
            [cell release];
        }
        {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
            cell.textLabel.text = @"页眉与页脚";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.tag = kTagHeaderFooter;
            [sec addObject:cell];
            [cell release];
        }
        /*
        {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
            cell.textLabel.text = @"主题样式";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.tag = kTagThemes;
            [sec addObject:cell];
            [cell release];
        }
        */
        {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
            UITextField * text = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 140, 30)];
            text.borderStyle = UITextBorderStyleRoundedRect;
            cell.textLabel.text = @"水印设置";
            cell.accessoryView = text;
            text.text = config.waterMarkText;
            text.placeholder = @"水印文字";
            text.delegate = self;
            text.tag = kTagWaterMark;
            [text release];
            [sec addObject:cell];
            [cell release];
        }
        {
            NSString *text = [NSString stringWithFormat:@"水印透明度(%.1f)", config.waterMarkAlpha];
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
            UISlider* slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 140, 40)];
            slider.minimumValue = 0.1;
            slider.maximumValue = 0.7;
            slider.value = config.waterMarkAlpha;
            [slider addTarget:self action:@selector(waterMaskValueChanged:) forControlEvents:UIControlEventValueChanged];
            cell.textLabel.text = text;
            cell.accessoryView = slider;
            _waterMark = cell.textLabel;
            _waterMark.alpha = config.waterMarkAlpha;
            _waterMark.textColor = [UIColor redColor];
            [slider release];
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
            cell.textLabel.text = @"问题报告与建议";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.tag = kTagReportBugs;
            [sec addObject:cell];
            [cell release];
        }
        {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
            cell.textLabel.text = @"在线帮助文档";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.tag = kTagOnlineDoc;
            [sec addObject:cell];
            [cell release];
        }
        {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
            cell.textLabel.text = @"关于带图微博";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.tag = kTagAboutApp;
            [sec addObject:cell];
            [cell release];
        }
        [sections addObject:sec];
        [sec release];
    }
    
    /*cell4JPGQunality*/
    {
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
        UISegmentedControl* segment = [[UISegmentedControl alloc] initWithItems:@[@"低", @"中", @"高"]];
        segment.segmentedControlStyle = UISegmentedControlStyleBar;
        segment.frame = CGRectMake(0, 0, 140, 30);
        segment.selectedSegmentIndex = config.jpgQunalityLevel;

        [segment addTarget:self action:@selector(jpgQunalityValueChanged:) forControlEvents:UIControlEventValueChanged];
        cell.textLabel.text = @"JPG质量";
        cell.accessoryView = segment;
        [segment release];
        _cell4JPGQunality = cell;
    }
    self.sections = sections;
    [sections release];
    
    TableSection *sec = [self.sections objectAtIndex:WSVC_Setting];
    if(config.imageFormat == 1){
        [sec insertObject:_cell4JPGQunality atIndex:1];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:WSVC_Setting]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else{
        [sec removeObject:_cell4JPGQunality];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:WSVC_Setting]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

-(void) waterMaskValueChanged:(UISlider*)slider{
    NSString *format = [[NSString alloc]initWithFormat:@"水印透明度(%.1f)", slider.value];
    _waterMark.text = format;
    [format release];
    _waterMark.alpha = slider.value;
    [AppSetting config].waterMarkAlpha = slider.value;
}

-(void) jpgQunalityValueChanged:(UISegmentedControl*)segment{
    [AppSetting config].jpgQunalityLevel = segment.selectedSegmentIndex;
}

-(void) switchImageFormat:(UISwitch*)switchFormat{
    TableSection *sec = [self.sections objectAtIndex:WSVC_Setting];
    if(switchFormat.on){
        [AppSetting config].imageFormat = 1;
        [sec insertObject:_cell4JPGQunality atIndex:1];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:WSVC_Setting]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else{
        [AppSetting config].imageFormat = 0;
        [sec removeObject:_cell4JPGQunality];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:WSVC_Setting]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if(textField.tag == kTagWaterMark){
        [AppSetting config].waterMarkText = textField.text;
    }
}

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if(cell.tag == kTagHeaderFooter){
        HeaderFooterViewController *controller = [BasicTableViewController createController:@"HeaderFooterViewController"];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }else if(cell.tag == kTagThemes){
        ThemesViewController *controller = [BasicTableViewController createController:@"ThemesViewController"];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }else if(cell.tag == kTagReportBugs){
        ReportViewController *controller = [BasicTableViewController createController:@"ReportViewController"];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }else if(cell.tag == kTagOnlineDoc){
        UIViewController *controller = [[UIViewController alloc] init];
        UIWebView *webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 1000, 1000)];
        controller.view = webview;
        webview.scalesPageToFit = YES;
        NSURLRequest *request = [NSURLRequest requestWithURL:[AppSetting instance].online_doc_url
                                                 cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval: 60.0];
        [webview loadRequest:request];
        
        [self.navigationController pushViewController:controller animated:YES];
        [webview release];
        [controller release];
    }else if(cell.tag == kTagAboutApp){
        BasicTableViewController *controller = [BasicTableViewController createController:@"AboutAppViewController"];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
        /*
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
        */
    }
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

@end

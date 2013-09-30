//
//  BasicTableViewController.m
//  xImage
//
//  Created by rockee on 13-5-14.
//
//
#import "sys/utsname.h"

#import <QuartzCore/QuartzCore.h>
#import "BasicTableViewController.h"
#import "device.h"
#import "AppSetting.h"


@interface BasicTableViewController (){
    BOOL _viewLoaded;
    UILabel *statusLabel;
    UIView *waitingView;
}
-(void) setupSections;
@end

@implementation BasicTableViewController
@synthesize sections;

+(id) createController:(NSString* ) aClassname{
    id object = [[NSClassFromString(aClassname) alloc] init];
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 1000, 1000) style:UITableViewStyleGrouped];
    [object setTableView:table];
    return object;
}

-(void) viewWillAppear:(BOOL)animated{
    if (!_viewLoaded) {
        statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
        statusLabel.backgroundColor = [UIColor darkTextColor];
        statusLabel.alpha = 0.0;
        statusLabel.textAlignment = NSTextAlignmentCenter;
        statusLabel.layer.cornerRadius = 8;
        statusLabel.textColor = [UIColor whiteColor];
        statusLabel.font = [UIFont systemFontOfSize:17];
        statusLabel.frame = CGRectZero;
        statusLabel.hidden = YES;
        [self.view addSubview:statusLabel];
        
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.center = CGPointMake(40, 40);
        indicator.hidesWhenStopped = YES;
        [indicator stopAnimating];
        CGPoint center = self.view.center;
        waitingView = [[UIView alloc] initWithFrame:CGRectMake(center.x - 40, center.y/4, 80, 80)];
        waitingView.alpha = 0.7;
        waitingView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        waitingView.backgroundColor = [UIColor darkTextColor];
        waitingView.layer.cornerRadius = 8;
        [waitingView addSubview:indicator];
        waitingView.hidden = YES;
        [self.view addSubview:waitingView];
        [indicator release];
        
        [self setupSections];
        _viewLoaded = YES;
    }
    [super viewWillAppear:animated];
}

-(void) dealloc{
    [sections release];
    [statusLabel release];
    [waitingView release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setupSections{
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    TableSection *sec = [sections objectAtIndex:section];
    return [sec count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    TableSection *sec = [sections objectAtIndex:section];
    return sec.header;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    TableSection *sec = [sections objectAtIndex:section];
    return sec.footer;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    TableSection *sec = [sections objectAtIndex:indexPath.section];
    cell = [sec objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    TableSection *sec = [sections objectAtIndex:indexPath.section];
    cell = [sec objectAtIndex:indexPath.row];
    
    return cell.bounds.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void) showStatus:(NSString* )status inSeconds:(CGFloat) duration withCompletion: (void (^)(void)) completion{
    CGRect frame = statusLabel.frame;
    CGPoint center = self.view.center;
    CGSize expectedLabelSize = [status sizeWithFont:statusLabel.font
                                  constrainedToSize:CGSizeMake(280, 140)
                                      lineBreakMode:statusLabel.lineBreakMode];
    expectedLabelSize.width += 20;
    expectedLabelSize.height += 20;
    center.x = center.x - expectedLabelSize.width/2;
    center.y = center.y / 4;
    frame.size = expectedLabelSize;
    frame.origin = center;
    statusLabel.text = status;
    statusLabel.frame = frame;
    statusLabel.hidden = NO;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:duration];
    [CATransaction setCompletionBlock:^{
        statusLabel.hidden = YES;
        if(completion){
            completion();
        }
    }];
    
    CABasicAnimation *optical = [CABasicAnimation animationWithKeyPath:@"opacity"];
    optical.duration = duration*0.75;
    optical.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    optical.fromValue = [NSNumber numberWithFloat:1.0];
    optical.toValue = [NSNumber numberWithFloat:0.8];
    
    
    CABasicAnimation *optical2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    optical2.beginTime = duration*0.75;
    optical2.duration = duration*0.25;
    optical2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    optical2.fromValue = [NSNumber numberWithFloat:0.8];
    optical2.toValue = [NSNumber numberWithFloat:0.0];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = duration;
    group.animations = [NSArray arrayWithObjects:optical, optical2, nil];
    
    [statusLabel.layer addAnimation:group forKey:nil];
    
    [CATransaction commit];
    statusLabel.alpha = 0.0;
}

-(void) startWaiting{
    self.view.userInteractionEnabled = NO;
    waitingView.hidden = NO;
    [[[waitingView subviews] objectAtIndex:0] startAnimating];
}

-(void) stopWaiting{
    [[[waitingView subviews] objectAtIndex:0] stopAnimating];
    waitingView.hidden = YES;
    self.view.userInteractionEnabled = YES;
}

-(UIImage*) genImageWithTitle:(NSString*) title{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 27)];

    label.text = title;
    label.backgroundColor = [UIColor blueColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    
    UIGraphicsBeginImageContextWithOptions(label.bounds.size, label.opaque, 0.0);
    [label.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [label release];
    return img;
}

-(void) alertMessage:(NSString*) msg{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

-(void) statEventID:(NSString*) eventID label:(NSString*) label{
    [self startWaiting];
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *device = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    NSString *sysVerion = [[UIDevice currentDevice] systemVersion];
    NSString *hiddenInfo = [NSString stringWithFormat:@"verion: %@, device: %@, os: %@", [AppSetting instance].version, device, sysVerion];
    const char *uuid = device_uuid();
    if(!uuid)
        uuid = "null-uuid";
    NSString *postfield = [[NSString alloc] initWithFormat:@"sysinfo=%@&eventid=%@&label=%@&uuid=%s", hiddenInfo, eventID, label, uuid];
    NSData *data = [postfield dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[AppSetting instance].stat_url];
    [request setHTTPMethod:@"POST"];
    NSString *postLength = [NSString stringWithFormat:@"%d", [data length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:data];
    [postfield release];

    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    [self stopWaiting];
    /*
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *err) {
        [self stopWaiting];
    }];
    */
}


@end

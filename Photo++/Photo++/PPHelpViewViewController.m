//
//  PPHelpViewViewController.m
//  Photo++
//
//  Created by Mohtashim Khan on 3/6/15.
//  Copyright (c) 2015 XYZ. All rights reserved.
//

#import "PPHelpViewViewController.h"

@interface PPHelpViewViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation PPHelpViewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.webView.allowsInlineMediaPlayback = YES;
    self.webView.mediaPlaybackRequiresUserAction = NO;

    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"Vid" ofType:@"html"];
    NSString *htmlString =
        [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:htmlString baseURL:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)didTapCloseBtn:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before
navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

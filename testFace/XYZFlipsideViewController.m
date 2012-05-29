//
//  XYZFlipsideViewController.m
//  testFace
//
//  Created by Mingyi Yuan on 12-5-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "XYZFlipsideViewController.h"

@interface XYZFlipsideViewController ()

@end

@implementation XYZFlipsideViewController

@synthesize delegate = delegate_;
@synthesize processIndicator = processIndicator_;
@dynamic size;

- (CGSize)size {
    return CGSizeMake(120, 180);
}

- (void)awakeFromNib
{
    self.contentSizeForViewInPopover = CGSizeMake(120.0, 200.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setProcessIndicator:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
        (UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Actions

- (IBAction)saveImageTouchUp:(id)sender {
    [self.delegate workSaveImage];
}

- (IBAction)loadImageTouchUp:(id)sender {
    [self.delegate workLoadImage];
}

- (IBAction)detectFaceTouchUp:(id)sender {
    self.processIndicator.alpha = 1.0;
    [self.processIndicator startAnimating];
    [(UIButton*)sender setEnabled:NO];
    [self.delegate workDetectFace:YES completion:^{
        [self.processIndicator stopAnimating];
        self.processIndicator.alpha = 0.0;
        [(UIButton*)sender setEnabled:YES];
    }];
}

- (IBAction)clearMarkTouchUp:(id)sender {
    [self.delegate workDetectFace:NO completion:nil];
}

@end

//
//  XYZFlipsideViewController.m
//  testFace
//
//  Created by Mingyi Yuan on 12-5-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "XYZFlipsideViewController.h"

@interface XYZFlipsideViewController ()
- (void)detectFire:(id)param;
@end

@implementation XYZFlipsideViewController

@dynamic size;
@synthesize delegate = delegate_;
@synthesize processIndicator = processIndicator_;
@synthesize methodSwitch;
@synthesize accuracySwitch;
@synthesize faceCountLabel;

- (CGSize)size {
    return CGSizeMake(120, 400);
}

- (void)awakeFromNib
{
    self.contentSizeForViewInPopover = self.size;
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.processIndicator.hidesWhenStopped = YES;
    [self.processIndicator stopAnimating];
}

- (void)viewDidUnload
{
    [self setProcessIndicator:nil];
    [self setMethodSwitch:nil];
    [self setAccuracySwitch:nil];
    [self setFaceCountLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
        (UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

# pragma mark -- helper methods
- (void)updateSettings:(FaceDetector *)detector {
    if (detector) {
        self.methodSwitch.selectedSegmentIndex = 
        (detector.source == DetectorSourceOpenCV) ? 0 : 1;
        self.accuracySwitch.selectedSegmentIndex =
        (detector.accuracy == DetectorAccuracyLow) ? 0 : 1;
        self.faceCountLabel.text = 
        [[NSNumber numberWithInteger:detector.faceCount] stringValue];
    }
}
- (void)detectFire:(id)param {
    DetectorSource source = (self.methodSwitch.selectedSegmentIndex == 0)?
    DetectorSourceOpenCV : DetectorSourceCoreImage;
    DetectorAccuracy accuracy = (self.accuracySwitch.selectedSegmentIndex == 0)?
    DetectorAccuracyLow : DetectorAccuracyHigh;
    [self.delegate workDetectFace:self
                       WithSource:source
                         accuracy:accuracy];
    [self.processIndicator stopAnimating];
    [(UIButton*)param setEnabled:YES];
}

# pragma mark - Actions
- (IBAction)saveImageTouchUp:(id)sender {
    [self.delegate workSaveImage:self];
}

- (IBAction)loadImageTouchUp:(id)sender {
    [self.delegate workLoadImage:self];
}

- (IBAction)detectFaceTouchUp:(id)sender {
    [(UIButton*)sender setEnabled:NO];
    self.faceCountLabel.text = nil;
    [self.processIndicator startAnimating];
    NSThread *detectThread = [[NSThread alloc] initWithTarget:self
                                                     selector:@selector(detectFire:)
                                                       object:sender];
    [detectThread start];
}

- (IBAction)clearMarkTouchUp:(id)sender {
    [self.delegate workClearMark:self];
}

- (IBAction)deleteImageTouchUp:(id)sender {
    [self.delegate workDeleteImage:self];
}

@end

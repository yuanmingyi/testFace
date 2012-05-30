//
//  XYZFlipsideViewController.h
//  testFace
//
//  Created by Mingyi Yuan on 12-5-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceDetector.h"

@class XYZFlipsideViewController;

@protocol workDelegate
- (void)workDetectFace:(XYZFlipsideViewController*)controller
            WithSource:(DetectorSource)source
              accuracy:(DetectorAccuracy)accuracy;            
//- (id)workGetDetector:(XYZFlipsideViewController*)controller;
- (void)workClearMark:(XYZFlipsideViewController*)controller;
- (void)workSaveImage:(XYZFlipsideViewController*)controller;
- (void)workLoadImage:(XYZFlipsideViewController*)controller;
- (void)workDeleteImage:(XYZFlipsideViewController*)controller;
@end

@interface XYZFlipsideViewController : UIViewController

@property (assign, nonatomic, readonly) CGSize size;
@property (weak, nonatomic) id <workDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *processIndicator;

@property (weak, nonatomic) IBOutlet UISegmentedControl *methodSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *accuracySwitch;
@property (weak, nonatomic) IBOutlet UILabel *faceCountLabel;

- (IBAction)saveImageTouchUp:(id)sender;
- (IBAction)loadImageTouchUp:(id)sender;
- (IBAction)detectFaceTouchUp:(id)sender;
- (IBAction)clearMarkTouchUp:(id)sender;
- (IBAction)deleteImageTouchUp:(id)sender;

- (void)updateSettings:(FaceDetector *)detector;

@end

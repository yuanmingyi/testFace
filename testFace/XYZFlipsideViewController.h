//
//  XYZFlipsideViewController.h
//  testFace
//
//  Created by Mingyi Yuan on 12-5-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol workDelegate
- (void)workDetectFace:(BOOL)isDetect completion:(void (^)(void))completion;
- (void)workSaveImage;
- (void)workLoadImage;
@end

@interface XYZFlipsideViewController : UIViewController

@property (weak, nonatomic) id <workDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *processIndicator;
@property (assign, nonatomic, readonly) CGSize size;

- (IBAction)saveImageTouchUp:(id)sender;
- (IBAction)loadImageTouchUp:(id)sender;
- (IBAction)detectFaceTouchUp:(id)sender;
- (IBAction)clearMarkTouchUp:(id)sender;

@end

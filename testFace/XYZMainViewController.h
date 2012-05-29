//
//  XYZMainViewController.h
//  testFace
//
//  Created by Mingyi Yuan on 12-5-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "XYZFlipsideViewController.h"
@interface XYZMainViewController : UIViewController 
                                    <workDelegate, 
                                    UIImagePickerControllerDelegate,
                                    UINavigationControllerDelegate,
                                    UIPopoverControllerDelegate> 

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;
@property (strong, nonatomic) UIPopoverController *imagePickerPopoverController;


@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;

@property (strong, nonatomic) UIImage *originImage;;

- (IBAction)startCameraResponder:(id)sender;

@end

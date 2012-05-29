//
//  FaceDetector.h
//  testFace
//
//  Created by Mingyi Yuan on 12-5-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {DetectorSourceOpenCV, DetectorSourceCoreImage} DetectorSource;
typedef enum {DetectorAccuracyHigh, DetectorAccuracyLow} DetectorAccuracy;

@interface FaceDetector : NSObject 

@property (strong, nonatomic, readonly) UIImage * imageWithFaces;
@property (strong, nonatomic, readonly) NSArray * faceRegions;
@property (assign, nonatomic, readonly) NSInteger faceCount;

+ (id)detectorWithSource:(DetectorSource)source 
                accuracy:(DetectorAccuracy)accuracy
            detectInGray:(BOOL)detectInGray;
- (id)init;
- (void)detectInImage:(UIImage*)inImage;

@end

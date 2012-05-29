//
//  FaceDetector.m
//  testFace
//
//  Created by Mingyi Yuan on 12-5-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FaceDetector.h"

@interface FaceDetector ()
@property (assign, nonatomic) DetectorSource source;
@property (assign, nonatomic) DetectorAccuracy accuracy;
@property (strong, nonatomic) NSDictionary * detectorOptions;
@property (strong, nonatomic) NSDictionary * contextOptions;
@property (assign, nonatomic) BOOL detectInGray;
@end

@implementation FaceDetector

@synthesize imageWithFaces = imageWithFaces_;
@synthesize faceRegions = faceRegions_;
@synthesize faceCount = faceCount_;

@synthesize source;
@synthesize accuracy;
@synthesize detectorOptions, contextOptions;
@synthesize detectInGray;

+ (id)detectorWithSource:(DetectorSource)source 
                accuracy:(DetectorAccuracy)accuracy
            detectInGray:(BOOL)detectInGray {
    FaceDetector *detector = [[FaceDetector alloc] init];
    detector.source = source;
    detector.accuracy = accuracy;
    detector.detectorOptions = 
    [NSDictionary dictionaryWithObject:(accuracy == DetectorAccuracyLow)?
                                        CIDetectorAccuracyLow:
                                        CIDetectorAccuracyHigh
                                forKey:CIDetectorAccuracy];
    detector.contextOptions = 
    [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithBool:NO],
                    kCIContextUseSoftwareRenderer,
                    (__bridge_transfer id)(detectInGray?
                                           CGColorSpaceCreateDeviceGray():
                                           CGColorSpaceCreateDeviceRGB()),
                    kCIContextWorkingColorSpace,
                    nil];
    detector.detectInGray = detectInGray;
    return detector;
}

- (id)init {
    self = [super init];
    return self;
}
- (void)detectInImage:(UIImage *)inImage {
    if (inImage == nil 
        || inImage.size.width <= 0
        || inImage.size.height <= 0) {
        return;
    }
    if (self.detectInGray) {
        
    }
    if (self.source == DetectorSourceCoreImage) {
        [self detectFaceWithCoreImage:inImage];
    } else {
        
    }
}
- (void)detectFaceWithCoreImage:(UIImage*)inImage {
    CGImageRef cgImage = inImage.CGImage;    
    CIImage *ciImage = [CIImage imageWithCGImage:cgImage];    
    
    CIContext *ciContext = [CIContext contextWithOptions:self.contextOptions];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:ciContext
                                              options:self.detectorOptions];
    NSArray *featuresArray = [detector featuresInImage:ciImage];
    
    // prepare painting context
    size_t height = CGImageGetHeight(cgImage);
    size_t width = CGImageGetWidth(cgImage);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(cgImage);
    size_t bytesPerRow = 
                CGImageGetBitsPerPixel(cgImage) / bitsPerComponent * width;
    CGColorSpaceRef space = CGImageGetColorSpace(cgImage);
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(cgImage);
    
    CGContextRef cgContext = CGBitmapContextCreate(NULL, 
                                                   width, 
                                                   height, 
                                                   bitsPerComponent, 
                                                   bytesPerRow,
                                                   space, 
                                                   bitmapInfo);
    CGContextDrawImage(cgContext, CGRectMake(0, 0, width, height), cgImage);
    CGContextSetBlendMode(cgContext, kCGBlendModeXOR);
    
    // enumarate the detected features and draw them in the image
    NSMutableArray * faces = [[NSMutableArray alloc] init];
    for (CIFeature *feature in featuresArray) {
        CGRect bounds = feature.bounds;
        // draw face bounds in the image
        CGContextSetRGBFillColor(cgContext, 0.0, 0.0, 1.0, 1.0);
        CGContextStrokeRectWithWidth(cgContext, bounds, 1.0);
        // add bounds to array
        [faces addObject:[NSData dataWithBytes:&bounds length:sizeof(bounds)]];
        // if details in the face are avaliable, draw them in the image too
        /*if ([feature.type isEqualToString: CIDetectorTypeFace]) {
            CIFaceFeature *faceFeature = (CIFaceFeature*)feature;
            if (faceFeature.hasLeftEyePosition) {
                CGPoint eyePos = faceFeature.leftEyePosition;
                CGRect eyeRect = CGRectMake(eyePos.x-1, eyePos.y-1, 3, 3);
                CGContextSetRGBFillColor(cgContext, 1.0, 0.0, 0.0, 1.0);
                CGContextFillEllipseInRect(cgContext, eyeRect);
            }
            if (faceFeature.hasRightEyePosition) {
                CGPoint eyePos = faceFeature.rightEyePosition;
                CGRect eyeRect = CGRectMake(eyePos.x-1, eyePos.y-1, 3, 3);
                CGContextSetRGBFillColor(cgContext, 1.0, 1.0, 0.0, 1.0);
                CGContextFillEllipseInRect(cgContext, eyeRect);
            }
            if (faceFeature.hasMouthPosition) {
                CGPoint mousePos = faceFeature.mouthPosition;
                CGRect mouseRect = CGRectMake(mousePos.x-3, mousePos.y-1, 7, 3);
                CGContextSetRGBFillColor(cgContext, 0.0, 1.0, 0.0, 1.0);
                CGContextStrokeRectWithWidth(cgContext, mouseRect, 1.0);
            }
        }*/
    }
    CGImageRef markedImage = CGBitmapContextCreateImage(cgContext);
    UIImage *outImage = [UIImage imageWithCGImage:markedImage];
    imageWithFaces_ = outImage;
    faceRegions_ = faces;
    faceCount_ = [faces count];
    
    // clean up
    CGContextRelease(cgContext);
    CGImageRelease(markedImage);
    CGColorSpaceRelease(space);
}

@end

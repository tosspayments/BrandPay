//
//  OcrSdkVideoFrame.h
//  Fingram
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

/**
 * @brief   Camera Frame manager class
 * @details Save a camera frame and return to scaner
 * @author  Fingram
 * @date    2018.08.27
 * @version 2.0
 */
@interface OcrSdkVideoFrame : NSObject

/**
 * @details call from camera captureOutput callback.
 * @param sampleBuffer assign captureOutput param sampleBuffer
 */
- (id)initWithSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/**
 * @details get farme bytes count
 */
- (unsigned long)getBytesCount;
/**
 * @details get frame buffer to char* for input of card scanner
 */
- (char*)getBytes;
@end

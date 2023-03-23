//
//  OcrSdkCardScanner.h
//  Fingram
//

// A thin, objective-c wrapper about dmz's ScannerState object, for convenience.

#import "OcrSdkConfig.h"
#import "OcrSdkVideoFrame.h"

#define OCR_CARD_SCAN_STATE_NOT_DETECTED          0
#define OCR_CARD_SCAN_STATE_DETECT_CARD           1
#define OCR_CARD_SCAN_STATE_COMPLETE_CARD_NUMBER  2
#define OCR_CARD_SCAN_STATE_COMPLETE_CARD_SCAN    3
#define OCR_CARD_SCAN_STATE_CHECKING_CARD_SCAN    4

#define OCR_CARD_SCAN_STATE_TIME_OUT              10

//@property(nonatomic, assign, readwrite) NSUInteger scannerType;

@class OcrSdkIplImage;
@class OcrSdkReadCardInfo;

/**
 * @brief   Card Scanner
 * @details get camera preview frame. analyze and recognize card number & expiry date
 * @author  Fingram
 * @date    2018.08.27
 * @version 2.0
 */
@interface OcrSdkCardScanner : NSObject

/**
 * @details initialize & configure card scanner
 * @param config OcrSdkConfig object
 */
//- (int)configureScanner:(OcrSdkConfig*)config;
- (id)init:(int)scannerType;

- (int)changeGuideRect:(OcrSdkConfig*)config horizontal:(float)x vertical:(float)y scale:(float)scale orientation:(int)orientation;
- (int)changeGuideRectCard:(OcrSdkConfig*)config horizontal:(float)x vertical:(float)y scale:(float)scale orientation:(int)orientation;;
- (int)changeGuideRectPaper:(OcrSdkConfig*)config horizontal:(float)x vertical:(float)y scale:(float)scale orientation:(int)orientation;;

- (int)configureScanner:(int)scannerType config:(OcrSdkConfig*)config;

- (void)setScanOption:(OcrSdkConfig*)config scanExpiry:(BOOL)scanExpiry validateNumber:(BOOL)validateNumber validateExpiry:(BOOL)validateExpiry scanHolderName:(BOOL)scanHolderName;
- (void)setScanIDOption:(OcrSdkConfig*)config scanIssuingDate:(BOOL)scanIssuingDate scanIssuingRegion:(BOOL)scanIssuingRegion scanLicenseNumber:(BOOL)scanLicenseNumber scanLicenseType:(BOOL)scanLicenseType scanLisenseSerial:(BOOL)scanLisenseSerial;

/**
 * @details analyze & recognize each frame. if scanner complete recognize number & expiry then return that in OcrSdkConfig
 * @param frame a OcrVideoFrame
 * @param config the OcrSdkConfig
 * @return 0 there is no card input
 *         1 card detected but not recognize yet
 *         2 card number recognized but expiry date not recognize yet
 *         3 card number & expiry date recognized. complete
 */
- (int)scanFrame:(OcrSdkVideoFrame*)frame config:(OcrSdkConfig*)config;
- (int)scanKorIDFrame:(OcrSdkVideoFrame*)frame config:(OcrSdkConfig*)config;
- (int)scanAlienFrame:(OcrSdkVideoFrame*)frame config:(OcrSdkConfig*)config;
- (int)scanAlienBackFrame:(OcrSdkVideoFrame*)frame config:(OcrSdkConfig*)config;
- (int)scanPassportFrame:(OcrSdkVideoFrame*)frame config:(OcrSdkConfig*)config;
- (int)scanGiroFrame:(OcrSdkVideoFrame*)frame config:(OcrSdkConfig*)config;
- (int)scanCapturePaperFrame:(OcrSdkVideoFrame*)frame config:(OcrSdkConfig*)config;
- (int)scanBarcode:(OcrSdkVideoFrame*)frame config:(OcrSdkConfig*)config;

- (UIImage*)generateCapturePaperFrame:(UIImage *)image config:(OcrSdkConfig *)config;

- (void)resetScanner:(int)scannerType config:(OcrSdkConfig*)config;

/**
 * @details stop scanner & free memory
 */
//- (void)destroyScanner:(OcrSdkConfig*)config;
- (void)destroyScanner:(int)scannerType config:(OcrSdkConfig*)config;
/**
 * @details calculate guide position by camera preview
 */
- (void)getGuideFrameRect:(OcrSdkConfig*)config width:(int)previewWidth height:(int)previewHeight fitTo:(int)fit;
- (void)getGuideFrameRect:(OcrSdkConfig*)config width:(int)previewWidth height:(int)previewHeight;

//- (void)setScannerType:(int)type;

- (void)setScanComplete;

- (NSString*)getOcrVersion;

@end


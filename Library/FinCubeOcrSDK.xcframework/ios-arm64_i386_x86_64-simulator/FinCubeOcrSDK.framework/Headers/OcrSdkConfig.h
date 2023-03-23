//
//  OcrSdkConfig.h
//  Fingram
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define IDSCAN_DEFAULT_MODE       0
#define IDSCAN_SINGLE_TAKE_MODE   1

/**
 * @brief   card scanner setting & handle
 * @author  Fingram
 * @date    2018.08.27
 * @version 2.0
 */
@interface OcrSdkConfig : NSObject

//
// system info
//
@property(nonatomic, assign, readwrite) void* handle;
@property(nonatomic, assign, readwrite) int scannerType;
@property(nonatomic, assign, readwrite) CGRect guideRect;
@property(nonatomic, assign, readwrite) int previewWidth;
@property(nonatomic, assign, readwrite) int previewHeight;

//
// custom guide rect info
//
@property(nonatomic, assign, readwrite) int guide_x;
@property(nonatomic, assign, readwrite) int guide_y;
@property(nonatomic, assign, readwrite) int guide_w;
@property(nonatomic, assign, readwrite) int guide_h;

@property(nonatomic, assign, readwrite) int guideRectOrientation;

//
// credit card result info
//
@property(nonatomic, readwrite) NSMutableString* cardNumber;
@property(nonatomic, readwrite) int expiryYear;
@property(nonatomic, readwrite) int expiryMonth;
@property(nonatomic, readwrite) UIImage* cardImage;
@property(nonatomic, readwrite) NSMutableString* holderName;

//
// id
//
@property(nonatomic, readwrite) NSMutableString* name;
@property(nonatomic, readwrite) NSMutableString* kor_id_num;
@property(nonatomic, readwrite) NSMutableString* kor_id_num_masking;
@property(nonatomic, readwrite) UIImage* markedCardImage;
@property(nonatomic, readwrite) UIImage* markedFrameImage;
@property(nonatomic, readwrite) UIImage* frameImage;
@property(nonatomic, readwrite) UIImage* photoImage;
@property(nonatomic, readwrite) UIImage* photoImage_rect400;
@property(nonatomic, readwrite) bool colorTest;
@property(nonatomic, readwrite) float colorPoint;

//
// kor id
//
@property(nonatomic, readwrite) NSMutableString* license_type;
@property(nonatomic, readwrite) NSMutableString* license_no;
@property(nonatomic, readwrite) NSMutableString* license_no_masking;
@property(nonatomic, readwrite) NSMutableString* license_serial;
@property(nonatomic, readwrite) NSMutableString* issuing_date;
@property(nonatomic, readwrite) NSMutableString* issuing_region;
@property(nonatomic, readwrite) NSMutableString* aptitude_test_date_start;
@property(nonatomic, readwrite) NSMutableString* aptitude_test_date_end;

@property(nonatomic, readwrite) bool overseas_resident;

@property(nonatomic, readwrite) int id_card_type;

@property(nonatomic, readwrite) double face_score;
@property(nonatomic, readwrite) double specular_ratio;

@property(nonatomic, readwrite) CGRect mask_rect_id_number;
@property(nonatomic, readwrite) CGRect mask_rect_license_number;

@property(nonatomic, readwrite) CGRect rect_id_issue_date;
@property(nonatomic, readwrite) CGRect rect_id_overseas_residents;

//
// passport result info
//
//@property(nonatomic, readwrite) int numbers[16];
@property(nonatomic, readwrite) NSMutableString* passport_type;
@property(nonatomic, readwrite) NSMutableString* issuing_country;
@property(nonatomic, readwrite) NSMutableString* surName;
@property(nonatomic, readwrite) NSMutableString* givenName;
@property(nonatomic, readwrite) NSMutableString* name_kor;
@property(nonatomic, readwrite) NSMutableString* passport_no;
@property(nonatomic, readwrite) NSMutableString* passport_no_masking;
@property(nonatomic, readwrite) NSMutableString* nationality;
@property(nonatomic, readwrite) NSMutableString* date_of_birth;
@property(nonatomic, readwrite) NSMutableString* sex;
@property(nonatomic, readwrite) NSMutableString* date_of_issue;
@property(nonatomic, readwrite) NSMutableString* personal_no;
@property(nonatomic, readwrite) NSMutableString* mrz1;
@property(nonatomic, readwrite) NSMutableString* mrz2;
@property(nonatomic, readwrite) bool validate;

@property(nonatomic, readwrite) NSMutableArray* scanFrameList;

//
// giro result info
//
@property(nonatomic, readwrite) NSMutableString* giro;
@property(nonatomic, readwrite) NSMutableString* crn;
@property(nonatomic, readwrite) NSMutableString* amount;
@property(nonatomic, readwrite) NSMutableString* amountC;
@property(nonatomic, readwrite) NSMutableString* code;
@property(nonatomic, readwrite) NSMutableString* dueDate;
@property(nonatomic, readwrite) NSMutableString* amount2;
@property(nonatomic, readwrite) NSMutableString* amount2C;
@property(nonatomic, readwrite) NSMutableString* upperCode;
@property(nonatomic, readwrite) NSMutableString* lowerCode;
@property(nonatomic, readwrite) NSMutableString* ePaymentNumber;

@property(nonatomic, readwrite) int giro_type;


//
// alien
//
@property(nonatomic, readwrite) NSMutableString* visaType;

// alien back
@property(nonatomic, readwrite) NSMutableString* alienSerial;
@property(nonatomic, readwrite) NSMutableString* alienPermissionDate0;
@property(nonatomic, readwrite) NSMutableString* alienPermissionDate1;
@property(nonatomic, readwrite) NSMutableString* alienPermissionDate2;
@property(nonatomic, readwrite) NSMutableString* alienPermissionDate3;
@property(nonatomic, readwrite) NSMutableString* alienExpiryDate0;
@property(nonatomic, readwrite) NSMutableString* alienExpiryDate1;
@property(nonatomic, readwrite) NSMutableString* alienExpiryDate2;
@property(nonatomic, readwrite) NSMutableString* alienExpiryDate3;
@property(nonatomic, readwrite) NSMutableString* alienConfirmation0;
@property(nonatomic, readwrite) NSMutableString* alienConfirmation1;
@property(nonatomic, readwrite) NSMutableString* alienConfirmation2;
@property(nonatomic, readwrite) NSMutableString* alienConfirmation3;

//
// barcode result info
//
@property(nonatomic, readwrite) NSMutableString* barCode;

//
// faceDetectionXMLPath
//
@property(nonatomic, readwrite) NSString* faceDetectionXMLPath;


//
// for time-out
//
@property(nonatomic, readwrite) long timeOutIntervalSec;

@property(nonatomic, readwrite) long start_time;
@property(nonatomic, readwrite) long end_time;

// for hanacard, external assets path support
@property(nonatomic, readwrite) NSString* assetsPath;

// for single-take mode
@property(nonatomic, readwrite) int idScannerMode;

@property(nonatomic, readwrite, copy) NSString* licenseKeyFile;
@property(nonatomic, readwrite, copy) NSString* licenseKeyBuffer;

//
// fitDirection 0 : width full scaled preview
// fitDirection 1 : height full scaled preview
- (void)setGuideRectWithView:(int)x guide_y:(int)y guide_w:(int)w guide_h:(int)h preview_w:(int)preview_w preview_h:(int)preview_h fitTo:(int)fitDirection;

-(void)resetPersonalData;
@end

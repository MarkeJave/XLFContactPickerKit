//
//  FPHContact.h
//  upsi
//
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XLFContact : NSObject
@property (nonatomic, assign) NSInteger recordId;
@property (nonatomic, copy  ) NSString *firstName;
@property (nonatomic, copy  ) NSString *lastName;
@property (nonatomic, strong) NSArray *phoneNums;
@property (nonatomic, copy  ) NSString *email;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign, getter = isSelected) BOOL selected;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *dateUpdated;
- (NSString *)fullName;
@end

//
//  XLFContactPickerVC.h
//  ContactPicker
//
//

#import <UIKit/UIKit.h>

@class XLFContact;
@class XLFContactPickerVC;

@protocol XLFContactPickerVCDelegate <NSObject>
@optional
- (void)picker:(XLFContactPickerVC*)picker contact:(XLFContact *)contact;
- (void)picker:(XLFContactPickerVC*)picker contacts:(NSArray *)contacts;
@end
@interface XLFContactPickerVC : UITableViewController
@property (nonatomic , assign) BOOL evMutableSelect;
@property (nonatomic , assign) id<XLFContactPickerVCDelegate> evDelegate;
@end

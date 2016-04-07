//
//  XLFContactPickerCell.h
//  ContactPicker
//
//  Created by Mac on 3/27/14.
//  Copyright (c) 2014 Marike Jave. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface XLFContactPickerCell:UITableViewCell

+ (CGFloat)epTableView:(UITableView *)tableView heightWithModel:(id)model;

@property (nonatomic , strong) XLFContact* evModel;

@property (nonatomic , assign , getter=isEvCheck) BOOL evCheck;
@property (nonatomic , assign , getter=isEvEnableCheck) BOOL evEnableCheck;
@end

//
//  XLFContactPickerCell.m
//  ContactPicker
//
//  Created by Mac on 3/27/14.
//  Copyright (c) 2014 Marike Jave. All rights reserved.
//
#import "XLFContact.h"
#import "XLFContactPickerCell.h"

@interface XLFContactPickerCell()
@property (nonatomic , strong) XLFContact   *evContact;
@property (nonatomic , strong) UIImageView  *evimgvCheck;
@property (nonatomic , strong) UIImageView  *evimgvHead;
@property (nonatomic , strong) UILabel      *evlbName;
@property (nonatomic , strong) UILabel      *evlbPhone;
@end
@implementation XLFContactPickerCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    
        // Initialization code
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self setAccessoryType:UITableViewCellAccessoryDetailButton];
        
        [self epCreateSubViews];
        [self epConfigSubViewsDefault];
        
    }
    return self;
}

#pragma mark - getter and setter
- (void)setEvCheck:(BOOL)evCheck{

    _evCheck = evCheck;
    
    [[self evimgvCheck] setHighlighted:evCheck];
}

- (void)setEvEnableCheck:(BOOL)evEnableCheck{

    _evEnableCheck = evEnableCheck;
    
    if (evEnableCheck) {

        [self setEvimgvCheck:[[UIImageView alloc] initWithFrame:CGRectZero]];
        [self addSubview:[self evimgvCheck]];
        
        [self epConfigSubViews];
    }
    else{

        [[self evimgvCheck] removeFromSuperview];
        [self setEvimgvCheck:nil];
    }
}

- (void)setFrame:(CGRect)frame{
    
    [super setFrame:frame];
    
    [self epRelayoutSubViews:frame];
}

#pragma mark - FPHTableViewInterface
- (void)setEvModel:(id)evModel{

    [self setEvContact:evModel];
    
    [self epConfigSubViews];
}

- (id)evModel{

    return [self evContact];
}
+ (CGFloat)epTableView:(UITableView *)tableView heightWithModel:(id)model{

    return 70;
}

- (void)epCreateSubViews{

    // create
    [self setEvimgvHead:[[UIImageView alloc] initWithFrame:CGRectZero]];
    [self setEvlbName:[[UILabel alloc] initWithFrame:CGRectZero]];
    [self setEvlbPhone:[[UILabel alloc] initWithFrame:CGRectZero]];
    
    // add to content view
    [self addSubview:[self evimgvHead]];
    [self addSubview:[self evlbName]];
    [self addSubview:[self evlbPhone]];
    
}

- (void)epRelayoutSubViews:(CGRect)frame{

    if ([self isEvEnableCheck]) {

        [[self evimgvCheck] setFrame:CGRectMake(11, 21, 25, 25)];
        
        [[self evimgvHead] setFrame:CGRectMake(46, 14, 40, 40)];
        
        [[self evlbName] setFrame:CGRectMake(94, 12, 180, 21)];
        
        [[self evlbPhone] setFrame:CGRectMake(94, 35, 132, 21)];
    }
    else{

        [[self evimgvCheck] setFrame:CGRectMake(11, 21, 25, 25)];
        
        [[self evimgvHead] setFrame:CGRectMake(11, 14, 40, 40)];
        
        [[self evlbName] setFrame:CGRectMake(69, 12, 205, 21)];
        
        [[self evlbPhone] setFrame:CGRectMake(69, 35, 187, 21)];
    }
}

- (void)epConfigSubViewsDefault{

    [[self evimgvCheck] setImage:[UIImage imageNamed:@"icon-checkbox-unselected-25x25"]];
    [[self evimgvCheck] setHighlightedImage:[UIImage imageNamed:@"icon-checkbox-selected-green-25x25"]];
    
    [[self evimgvHead] setImage:[UIImage imageNamed:@"icon-avatar-60x60"]];
    [[[self evimgvHead] layer] setMasksToBounds:YES];
    [[[self evimgvHead] layer] setCornerRadius:20];
    
    [[self evlbName] setFont:[UIFont boldSystemFontOfSize:16]];
    [[self evlbName] setTextColor:[UIColor blackColor]];
    [[self evlbName] setTextAlignment:NSTextAlignmentLeft];
    
    [[self evlbPhone] setFont:[UIFont boldSystemFontOfSize:14]];
    [[self evlbPhone] setTextColor:[UIColor blackColor]];
    [[self evlbPhone] setTextAlignment:NSTextAlignmentLeft];
}

- (void)epConfigSubViews{

    [[self evimgvCheck] setImage:[UIImage imageNamed:@"icon_checkBox"]];
    [[self evimgvCheck] setHighlightedImage:[UIImage imageNamed:@"icon_checkBox_selected"]];
    
    [[self evimgvCheck] setHighlighted:[self isEvCheck]];
    
    [[self evimgvHead] setImage:[[self evContact] image] ? [[self evContact] image] : [UIImage imageNamed:@"icon_user_normal"]];
    
    [[self evlbName] setText:[[self evContact] fullName]];
    
    NSUInteger count = [[[self evContact] phoneNums] count];
    
    NSString *phone = [NSString stringWithFormat:@"%@ %@ %@", count ? [[[self evContact] phoneNums] objectAtIndex:0]:@"",count > 1 ? [[[self evContact] phoneNums] objectAtIndex:1]:@"", count > 2 ? @"...":@"" ];
    [[self evlbPhone] setText:phone];
    
    [self epRelayoutSubViews:[self frame]];
}
@end

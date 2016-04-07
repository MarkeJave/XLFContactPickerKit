

#import <UIKit/UIKit.h>

@interface ChineseToPinyinPrivate : NSObject {
    
}

+ (NSString *)pinyinFromChiniseString:(NSString *)string;
+ (char)sortSectionTitle:(NSString *)string;

@end

@interface NSString (ChineseToPinyin)

- (NSString *)pinyin;

@end
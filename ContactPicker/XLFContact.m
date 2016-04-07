//
//  XLFContact.m
//  upsi
//
//
#import "XLFContact.h"

@implementation XLFContact

- (NSString *)fullName {
    
    if(self.firstName != nil && self.lastName != nil) {
    
        return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
    }
    else if(self.firstName != nil) {
    
        return self.firstName;
    }
    else if(self.lastName != nil) {
    
        return self.lastName;
    }
        else {
    
        return @"";
    }
}
@end

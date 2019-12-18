

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ZWMessage : NSObject

+ (void)error:(NSString*)error title:(NSString *)title;
+ (void)message:(NSString*)msg title:(NSString *)title;
+ (void)success:(NSString*)msg title:(NSString *)title;
+ (void)Warning:(NSString*)msg title:(NSString *)title;
+ (void)setDefaultViewController:(BaseNavgationController *)myNav;
@end

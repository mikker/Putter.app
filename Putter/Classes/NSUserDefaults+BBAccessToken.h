#import <Foundation/Foundation.h>

@interface NSUserDefaults (BBAccessToken)

- (NSString *)accessToken;
- (void)setAccessToken:(NSString *)token;

@end

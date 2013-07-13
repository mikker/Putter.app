#import "NSUserDefaults+BBAccessToken.h"

static NSString * const kAccessTokenKey = @"kAccessTokenKey";

@implementation NSUserDefaults (BBAccessToken)

- (NSString *)accessToken
{
  return [self objectForKey:kAccessTokenKey];
}

- (void)setAccessToken:(NSString *)token
{
  [self setValue:token forKey:kAccessTokenKey];
  [self synchronize];
}

@end

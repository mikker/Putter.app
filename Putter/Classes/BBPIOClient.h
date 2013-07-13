#import "AFHTTPClient.h"


@interface BBPIOClient : AFHTTPClient

+ (instancetype)sharedClient;

- (NSURL *)authenticationURL;
- (void)authenticateWithCode:(NSString *)code succes:(void (^)(AFHTTPRequestOperation *operation))succes failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)addTransferWithURLString:(NSString *)URLString success:(void (^)(AFHTTPRequestOperation *operation, NSDictionary *transfer))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end

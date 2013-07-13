#import "BBPIOClient.h"
#import "AFJSONRequestOperation.h"
#import "NSUserDefaults+BBAccessToken.h"
#import "AppKeys.h"

static NSString * const kBaseURL = @"https://api.put.io";
static NSString * const kCallbackURL = @"putter://callback";


@implementation BBPIOClient

+ (instancetype)sharedClient
{
  static BBPIOClient *sharedClient = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kBaseURL]];
  });
  return sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url
{
  if (!(self = [super initWithBaseURL:url])) return nil;

  [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
  [self setParameterEncoding:AFFormURLParameterEncoding];
  [self setDefaultHeader:@"Accept" value:@"application/json"];

  return self;
}

#pragma mark - Public methods

- (NSURL *)authenticationURL
{
  NSString *path = [NSString stringWithFormat:@"%@/v2/oauth2/authenticate?client_id=%@&response_type=code&redirect_uri=%@", kBaseURL, kClientID, kCallbackURL];
  return [NSURL URLWithString:path];
}

- (void)authenticateWithCode:(NSString *)code succes:(void (^)(AFHTTPRequestOperation *))succes failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
  NSDictionary *parameters = @{
    @"client_id": kClientID,
    @"client_secret": kClientSecret,
    @"grant_type": @"authorization_code",
    @"redirect_uri": kCallbackURL,
    @"code": code
  };

  [self getPath:@"/oauth2/access_token" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

    NSString *accessToken = [responseObject objectForKey:@"access_token"];
    if (accessToken)
      NSUserDefaults.standardUserDefaults.accessToken = accessToken;

    succes(operation);
  } failure:failure];
}

#pragma mark Transfers

- (void)addTransferWithURLString:(NSString *)URLString success:(void (^)(AFHTTPRequestOperation *operation, NSDictionary *responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
  [self postPath:@"/transfers/add" parameters:@{@"url": URLString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
    success(operation, responseObject);
  } failure:failure];
}

#pragma mark - Overrides

- (NSString *)expandPath:(NSString *)path
{
  path = [@"/v2" stringByAppendingString:path];

  NSString *token = [NSUserDefaults standardUserDefaults].accessToken;
  if (token)
    path = [path stringByAppendingFormat:@"?oauth_token=%@", token];

  return path;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters
{
  path = [self expandPath:path];
  return [super requestWithMethod:method path:path parameters:parameters];
}

@end

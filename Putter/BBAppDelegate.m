#import "BBAppDelegate.h"
#import <RegexKitLite/RegexKitLite.h>
#import <AFNetworking/AFNetworking.h>
#import "BBPIOClient.h"
#import "NSUserDefaults+BBAccessToken.h"

@interface BBAppDelegate ()
{
  NSString *_magnetURL;
}
@end

@implementation BBAppDelegate

- (id)init
{
  self = [super init];

  [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];

  return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  if (!NSUserDefaults.standardUserDefaults.accessToken)
    [self authorizationAlert];
}

#pragma mark - IBAction

- (void)reauthorizeMenuItem:(id)sender
{
  NSUserDefaults.standardUserDefaults.accessToken = nil;
  [self authorizationAlert];
}

#pragma mark - Events

- (void)handleURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
  NSString *URLString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
  NSString *ownProtocolRegex = @"^putter:";
  NSString *magnetRegex = @"^magnet:";

  if ([URLString isMatchedByRegex:ownProtocolRegex]) {
    return [self authorizeWithURL:URLString];
  }

  else if ([URLString isMatchedByRegex:magnetRegex])
    _magnetURL = URLString;
  
    if (!NSUserDefaults.standardUserDefaults.accessToken) {
      return;
    }
  
    [self addTransferWithURLString:URLString];
}

#pragma mark - Private

- (void)authorizationAlert
{
  NSAlert *alert = [NSAlert alertWithMessageText:@"Authorization required" defaultButton:@"Authorize on Put.io" alternateButton:@"Quit" otherButton:nil informativeTextWithFormat:@"We need your permission to add transfers to your put.io account."];
  if ([alert runModal] == NSAlertDefaultReturn) {
    [[NSWorkspace sharedWorkspace] openURL:BBPIOClient.sharedClient.authenticationURL];
  } else {
    [NSApp terminate:self];
  }
}

- (void)addTransferWithURLString:(NSString *)URLString
{
  [[BBPIOClient sharedClient] addTransferWithURLString:URLString success:^(AFHTTPRequestOperation *operation, NSDictionary *transfer) {

    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://put.io/transfers"]];
    [NSApp terminate:self];

  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    [[NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Something went wrong with adding the transfer.\n%@", error] runModal];
  }];
}

- (void)authorizeWithURL:(NSString *)URLString
{
  NSString *codeRegex = @"^putter://callback\\?code=(.*)$";
  NSString *code = [URLString stringByMatching:codeRegex capture:1];
  if (!code) return;

  [[BBPIOClient sharedClient] authenticateWithCode:code succes:^(AFHTTPRequestOperation *operation) {

    if (_magnetURL) {
      [self addTransferWithURLString:_magnetURL];
      _magnetURL = nil;
    }

  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    [[NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Something went wrong with authorizing.\n%@", error] runModal];
  }];
}

@end

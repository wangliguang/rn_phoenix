//
//  LoadBundleViewController.m
//  rn_phoenix
//
//  Created by 王立广 on 2019/6/3.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "LoadBundleViewController.h"
#import <React/RCTBridge.h>
#import <React/RCTRootView.h>
#import "WHCFileManager.h"
#import "DiffMatchPatch.h"
#import <Foundation/NSObject.h>
@interface LoadBundleViewController ()

@property (weak, nonatomic) IBOutlet UILabel *bundleStatusText;

@end

#define CURRENT_BUNDLE_VERSION @"current_bundle_version"

@implementation LoadBundleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
  NSURLSession *session = [NSURLSession sharedSession];
  NSString* currentBundleVersion = [[NSUserDefaults standardUserDefaults] valueForKey:CURRENT_BUNDLE_VERSION];
  if (!currentBundleVersion) {
    currentBundleVersion = @"0";
  }
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://10.36.36.31:3000/users/getPatch?currentBundleVersion=%@", currentBundleVersion]];
  [[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    if (error) {
      NSLog(@"getPatch_error=%@", error);
      return;
    }
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"jsonDict %@", jsonDict);
    if(jsonDict[@"bundleUrl"]) {
      [self downLoadBundle:jsonDict[@"bundleUrl"] version:jsonDict[@"version"]];
    };
    
    if(jsonDict[@"patchUrl"]) {
      [self downLoadPatch:jsonDict[@"patchUrl"] version:jsonDict[@"version"]];
    };
  }] resume];
  
}

- (void)downLoadPatch:(NSString *)urlStr version: (NSString *)currentBundleVersion {
  NSURL *url = [NSURL URLWithString:urlStr];
  NSURLSession *session = [NSURLSession sharedSession];
  [[session downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *patchFilePath = [documentsPath stringByAppendingPathComponent:@"diff.pat"];
    [WHCFileManager moveItemAtPath:location.path toPath:patchFilePath overwrite:true];
    [self benginPatch:patchFilePath version:currentBundleVersion];
  }] resume];
}

- (void)benginPatch:(NSString *)patchesPath version: (NSString *)currentBundleVersion {
  NSString *path01 = [self getBundlePath];
  NSLog(@"path %@", [self getBundlePath]);
  NSData *data01 = [NSData dataWithContentsOfFile:path01];
  NSString *str01 = [[NSString alloc] initWithData:data01 encoding:NSUTF8StringEncoding];
  DiffMatchPatch *patch = [[DiffMatchPatch alloc]init];
  NSData *patchesData = [NSData dataWithContentsOfFile:patchesPath];
  NSLog(@"bundleFilePath====%@", [self getBundlePath] );
  NSString *patchesStr = [[NSString alloc]initWithData:patchesData encoding:NSUTF8StringEncoding];
  NSMutableArray *patchesArr = [patch patch_fromText:patchesStr error:nil];
  NSArray *newArray = [patch patch_apply:patchesArr toString:str01];
  BOOL isTrue = [newArray[0] writeToFile:[self getBundlePath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
  if (!isTrue) {
    NSLog(@"写入失败");
    return;
  }
  [self mainQueueUpdateUI:currentBundleVersion];
}

- (void)downLoadBundle:(NSString *)urlStr version:(NSString *)currentBundleVersion {
  NSURL *url = [NSURL URLWithString:urlStr];
  NSURLSession *session = [NSURLSession sharedSession];
  [[session downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
    [WHCFileManager moveItemAtPath:location.path toPath:[self getBundlePath] overwrite:true];
    [self mainQueueUpdateUI:currentBundleVersion];
  }] resume];
}

- (void) mainQueueUpdateUI: (NSString *)currentBundleVersion {
  dispatch_async(dispatch_get_main_queue(), ^{
    NSURL *jsCodeLocation = [NSURL URLWithString:[self getBundlePath]];
    RCTBridge *bridge = [[RCTBridge alloc] initWithBundleURL:jsCodeLocation moduleProvider:nil launchOptions:nil];
    RCTRootView* view = [[RCTRootView alloc] initWithBridge:bridge moduleName:@"rn_phoenix" initialProperties:nil];
    [[NSUserDefaults standardUserDefaults] setObject:currentBundleVersion forKey:CURRENT_BUNDLE_VERSION];
    self.view = view;
  });
}

- (NSString *)getBundlePath {
  NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
  NSString *bundleFilePath = [documentsPath stringByAppendingPathComponent:@"index.bundle"];
  return bundleFilePath;
}


@end

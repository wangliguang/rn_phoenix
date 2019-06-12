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
@property (nonatomic, assign) NSTimeInterval currentTime;
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
  NSLog(@"✅✅✅开始获取最新版本信息");
  self.currentTime = [self currentTimeStr];
  
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://47.94.81.19:3000/users/getPatch?currentBundleVersion=%@", currentBundleVersion]];
  [[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    if (error) {
      NSLog(@"❌❌❌获取最新版本信息失败 =%@", error);
      return;
    }
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    if(jsonDict[@"bundleUrl"]) {
      NSLog(@"✅✅✅本地没有bundle，开始下载整个bundle包，%@", jsonDict);
      [self downLoadBundle:jsonDict[@"bundleUrl"] version:jsonDict[@"version"]];
    };
    
    if(jsonDict[@"patchUrl"]) {
      NSLog(@"✅✅✅本地已有bundle，开始下载差分包，%@", jsonDict);
      [self downLoadPatch:jsonDict[@"patchUrl"] version:jsonDict[@"version"]];
    };
  }] resume];
  
}

- (void)downLoadPatch:(NSString *)urlStr version: (NSString *)currentBundleVersion {
  NSURL *url = [NSURL URLWithString:urlStr];
  NSURLSession *session = [NSURLSession sharedSession];
  [[session downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
    if (error) {
      NSLog(@"❌❌❌差分包下载失败 =%@", error);
      return;
    }
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *patchFilePath = [documentsPath stringByAppendingPathComponent:@"diff.pat"];
    [WHCFileManager moveItemAtPath:location.path toPath:patchFilePath overwrite:true];
    NSLog(@"✅✅✅差分包下载完成，开始合并，path=%@", [self getBundlePath]);
    [self benginPatch:patchFilePath version:currentBundleVersion];
  }] resume];
}

- (void)benginPatch:(NSString *)patchesPath version: (NSString *)currentBundleVersion {
  NSString *path01 = [self getBundlePath];
  NSData *data01 = [NSData dataWithContentsOfFile:path01];
  NSString *str01 = [[NSString alloc] initWithData:data01 encoding:NSUTF8StringEncoding];
  DiffMatchPatch *patch = [[DiffMatchPatch alloc]init];
  NSData *patchesData = [NSData dataWithContentsOfFile:patchesPath];
  NSString *patchesStr = [[NSString alloc]initWithData:patchesData encoding:NSUTF8StringEncoding];
  NSMutableArray *patchesArr = [patch patch_fromText:patchesStr error:nil];
  NSArray *newArray = [patch patch_apply:patchesArr toString:str01];
  NSError *error = nil;
  BOOL isTrue = [newArray[0] writeToFile:[self getBundlePath] atomically:YES encoding:NSUTF8StringEncoding error:&error];
  if (!isTrue) {
    NSLog(@"❌❌❌差分包合并失败=%@", error);
    return;
  }
  NSLog(@"✅✅✅差分包合并完成");
  [self mainQueueUpdateUI:currentBundleVersion];
}

- (void)downLoadBundle:(NSString *)urlStr version:(NSString *)currentBundleVersion {
  NSURL *url = [NSURL URLWithString:urlStr];
  NSURLSession *session = [NSURLSession sharedSession];
  [[session downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
    if (error) {
      NSLog(@"❌❌❌bundle下载失败=%@", error);
      return;
    }
    [WHCFileManager moveItemAtPath:location.path toPath:[self getBundlePath] overwrite:true];
    NSLog(@"✅✅✅bundle下载完毕 path=%@", [self getBundlePath]);
    [self mainQueueUpdateUI:currentBundleVersion];
  }] resume];
}

- (void) mainQueueUpdateUI: (NSString *)currentBundleVersion {
  dispatch_async(dispatch_get_main_queue(), ^{
    NSURL *jsCodeLocation = [NSURL URLWithString:[self getBundlePath]];
    RCTBridge *bridge = [[RCTBridge alloc] initWithBundleURL:jsCodeLocation moduleProvider:nil launchOptions:nil];
    RCTRootView* view = [[RCTRootView alloc] initWithBridge:bridge moduleName:@"rn_phoenix" initialProperties:nil];
    [[NSUserDefaults standardUserDefaults] setObject:currentBundleVersion forKey:CURRENT_BUNDLE_VERSION];
    NSLog(@"✅✅✅bundle加载完毕，消耗的总时间为=%f", [self currentTimeStr] - self.currentTime);
    
    self.view = view;
  });
}

- (NSString *)getBundlePath {
  NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
  NSString *bundleFilePath = [documentsPath stringByAppendingPathComponent:@"index.bundle"];
  
  [self currentTimeStr];
  return bundleFilePath;
}

- (NSTimeInterval)currentTimeStr{
  NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
  NSTimeInterval time=[date timeIntervalSince1970]*1000;// *1000 是精确到毫秒，不乘就是精确到秒
  return time;
}



@end

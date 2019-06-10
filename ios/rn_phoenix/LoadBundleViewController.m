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

@interface LoadBundleViewController ()

@property (weak, nonatomic) IBOutlet UILabel *bundleStatusText;
@property (nonatomic, copy) NSString *bundleFilePath;

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
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://47.94.81.19:3000/users/getPatch?currentBundleVersion=%@", currentBundleVersion]];
  [[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    if (error) {
      NSLog(@"getPatch_error=%@", error);
      return;
    }
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"jsonDict %@", jsonDict);
    if(jsonDict[@"bundleUrl"]) {
      [self downLoadBundle:jsonDict[@"bundleUrl"]];
    };
    
    if(jsonDict[@"patchUrl"]) {
      [self downLoadPatch:jsonDict[@"patchUrl"]];
    };
  }] resume];
  
}

- (void)downLoadPatch:(NSString *)urlStr {
  
}

- (void)downLoadBundle:(NSString *)urlStr {
  NSURL *url = [NSURL URLWithString:urlStr];
//  NSURL *url = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"bundle"];
  NSURLSession *session = [NSURLSession sharedSession];
  NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    self.bundleFilePath = [documentsPath stringByAppendingPathComponent:response.suggestedFilename];
    NSLog(@"bundleFilePath====%@", self.bundleFilePath );
    [WHCFileManager moveItemAtPath:location.path toPath:self.bundleFilePath overwrite:true];
  
    dispatch_async(dispatch_get_main_queue(), ^{
      NSURL *jsCodeLocation = [NSURL URLWithString:self.bundleFilePath];
      RCTBridge *bridge = [[RCTBridge alloc] initWithBundleURL:jsCodeLocation moduleProvider:nil launchOptions:nil];
      
      RCTRootView* view = [[RCTRootView alloc] initWithBridge:bridge moduleName:@"rn_phoenix" initialProperties:nil];
      NSString *currentBundleVersion = [[urlStr lastPathComponent] componentsSeparatedByString:@"."][0];
      [[NSUserDefaults standardUserDefaults] setObject:currentBundleVersion forKey:CURRENT_BUNDLE_VERSION];
      self.view = view;
    });
  }];
  
  // 开始下载任务
  [downloadTask resume];
}


@end

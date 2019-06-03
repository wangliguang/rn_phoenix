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

@interface LoadBundleViewController ()

@property (weak, nonatomic) IBOutlet UILabel *bundleStatusText;
@property (nonatomic, copy) NSString *bundleFilePath;

@end

@implementation LoadBundleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  [self downLoadBundle];
  
}

- (void)downLoadBundle {
  NSURL *url = [NSURL URLWithString:@"http://10.36.36.31:8080/job/phoenix/job/master/lastSuccessfulBuild/artifact/index.bundle"];
//  NSURL *url = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"bundle"];
  NSURLSession *session = [NSURLSession sharedSession];
  NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    self.bundleFilePath = [documentsPath stringByAppendingPathComponent:response.suggestedFilename];
    NSLog(@"bundleFilePath====%@", self.bundleFilePath );
    [[NSFileManager defaultManager] moveItemAtPath:location.path toPath:self.bundleFilePath error:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      NSURL *jsCodeLocation = [NSURL URLWithString:self.bundleFilePath];
      RCTBridge *bridge = [[RCTBridge alloc] initWithBundleURL:jsCodeLocation moduleProvider:nil launchOptions:nil];
      
      RCTRootView* view = [[RCTRootView alloc] initWithBridge:bridge moduleName:@"rn_phoenix" initialProperties:nil];
      
      self.view = view;
    });
  }];
  
  // 开始下载任务
  [downloadTask resume];
}

@end

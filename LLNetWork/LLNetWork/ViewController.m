//
//  ViewController.m
//  LLNetWork
//
//  Created by LLVK on 27/07/2017.
//  Copyright © 2017 devHuang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)testGetRequest{
    
    [ApiMethod getBlogData:@{} isCache:YES result:^(id response) {
        DLog(@"%@",response);
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

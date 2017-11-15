//
//  ViewController.m
//  FDDUserPage
//
//  Created by 方冬冬 on 2017/11/14.
//  Copyright © 2017年 方冬冬. All rights reserved.
//

#import "ViewController.h"
#import "FDDUserPage.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:BOOLFORKEY]) {
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:BOOLFORKEY];
//        // 静态引导页
        [self setStaticGuidePage];
//
//        // 动态引导页
//         [self setDynamicGuidePage];
//
//        // 视频引导页
//        // [self setVideoGuidePage];
//    }
//
    // 设置该控制器背景图片
    UIImageView *bg_imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [bg_imageView setImage:[UIImage imageNamed:@"view_bg_image"]];
    [self.view addSubview:bg_imageView];
    [self setTitle:@"Come On 2017"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 设置APP静态图片引导页
- (void)setStaticGuidePage {
    NSArray *imageNameArray = @[@"guideImage1.jpg",@"guideImage2.jpg",@"guideImage3.jpg",@"guideImage4.jpg",@"guideImage5.jpg"];
    FDDUserPage *guidePage = [[FDDUserPage alloc] initWithFrame:self.view.frame imageNameArray:imageNameArray buttonIsHidden:NO userPageType:FDDUserPageNormal];
    guidePage.slideInto = YES;
//    guidePage.pageIndicatorTintColor = [UIColor grayColor];
    guidePage.isautoScrolling = YES;
    [self.navigationController.view addSubview:guidePage];
}

#pragma mark - 设置APP动态图片引导页
- (void)setDynamicGuidePage {
    NSArray *imageNameArray = @[@"guideImage6.gif",@"guideImage7.gif",@"guideImage8.gif"];
    FDDUserPage *guidePage = [[FDDUserPage alloc] initWithFrame:self.view.frame imageNameArray:imageNameArray buttonIsHidden:YES userPageType:FDDUserPageGif];
    guidePage.slideInto = YES;
    [self.navigationController.view addSubview:guidePage];
}

#pragma mark - 设置APP视频引导页
- (void)setVideoGuidePage {
    NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"guideMovie1" ofType:@"mov"]];
    FDDUserPage *guidePage = [[FDDUserPage alloc] initWithFrame:self.view.bounds videoURL:videoURL];
    [self.navigationController.view addSubview:guidePage];
}


@end

//
//  FDDUserPage.m
//  FDDUserPage
//
//  Created by 方冬冬 on 2017/11/14.
//  Copyright © 2017年 方冬冬. All rights reserved.
//

#import "FDDUserPage.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import "FDDGifImageTool.h"
#define DDHidden_TIME   3.0
#define DDScreenW   [UIScreen mainScreen].bounds.size.width
#define DDScreenH   [UIScreen mainScreen].bounds.size.height
@interface FDDUserPage ()<UIScrollViewDelegate>
@property (nonatomic, strong) NSArray                 *imageArray;
@property (nonatomic, strong) UIPageControl           *imagePageControl;
@property (nonatomic, assign) NSInteger               slideIntoNumber;
@property (nonatomic, strong) MPMoviePlayerController *playerController;
@property(nonatomic,strong)UIButton *skipButton;
@property(nonatomic,strong)UIScrollView *guidePageView;

@property(nonatomic,strong)NSTimer *timer;
@end
@implementation FDDUserPage

- (instancetype)initWithFrame:(CGRect)frame imageNameArray:(NSArray<NSString *> *)imageNameArray buttonIsHidden:(BOOL)isHidden userPageType:(FDDUserPageType)userPageType {
    if ([super initWithFrame:frame]) {
        self.slideInto = NO;
        self.isautoScrolling = NO;
        
        if (isHidden == YES) {
            self.imageArray = imageNameArray;
        }
        
        // 设置引导视图的scrollview
        self.guidePageView = [[UIScrollView alloc]initWithFrame:frame];
        [ self.guidePageView setBackgroundColor:[UIColor lightGrayColor]];
        [ self.guidePageView setContentSize:CGSizeMake(DDScreenW*imageNameArray.count, DDScreenH)];
        [ self.guidePageView setBounces:NO];
        [ self.guidePageView setPagingEnabled:YES];
        [ self.guidePageView setShowsHorizontalScrollIndicator:NO];
        [ self.guidePageView setDelegate:self];
        [self addSubview: self.guidePageView];
        // 设置引导页上的跳过按钮
        [self addSubview:self.skipButton];
        // 添加在引导视图上的多张引导图片
        for (int i=0; i<imageNameArray.count; i++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(DDScreenW*i, 0, DDScreenW, DDScreenH)];
            if (userPageType == FDDUserPageGif) {
                NSData *localData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageNameArray[i] ofType:nil]];
                imageView = (UIImageView *)[[FDDGifImageTool alloc] initWithFrame:imageView.frame gifImageData:localData];
                [self.guidePageView addSubview:imageView];
            } else if(userPageType == FDDUserPageNormal){
                imageView.image = [UIImage imageNamed:imageNameArray[i]];
                [self.guidePageView addSubview:imageView];
            }
            // 设置在最后一张图片上显示进入体验按钮
            if (i == imageNameArray.count-1 && isHidden == NO) {
                [imageView setUserInteractionEnabled:YES];
                UIButton *startButton = [[UIButton alloc]initWithFrame:CGRectMake(DDScreenW*0.3, DDScreenH*0.8, DDScreenW*0.4, DDScreenH*0.08)];
                [startButton setTitle:@"开始体验" forState:UIControlStateNormal];
                [startButton setTitleColor:[UIColor colorWithRed:164/255.0 green:201/255.0 blue:67/255.0 alpha:1.0] forState:UIControlStateNormal];
                [startButton.titleLabel setFont:[UIFont systemFontOfSize:21]];
                [startButton setBackgroundImage:[UIImage imageNamed:@"guideImage_button_backgound"] forState:UIControlStateNormal];
                [startButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
                [imageView addSubview:startButton];
            }
        }
        
        // 设置引导页上的页面控制器
        self.imagePageControl.numberOfPages = imageNameArray.count;
        [self addSubview:self.imagePageControl];
        
        [self startTimer];
    }
    return self;
}

- (void)setIsautoScrolling:(BOOL)isautoScrolling{
    _isautoScrolling = isautoScrolling;
    if (!_timer && _isautoScrolling) {
        [self startTimer];
    }
}

- (void)startTimer{
    if (!_isautoScrolling) {
        return;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(scrollingOnTimer) userInfo:nil repeats:YES];
}

- (void)scrollingOnTimer{
    CGRect frame = self.imagePageControl.frame;
    frame.origin.x = frame.size.width * (_imagePageControl.currentPage + 1);
    frame.origin.y = 0;
    if(frame.origin.x >=self.guidePageView.contentSize.width){
        frame.origin.x = 0;
    }
    [self.guidePageView scrollRectToVisible:frame animated:YES];
    
}

- (void)stopTimer{
    [_timer invalidate];
    _timer = nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    int page = scrollView.contentOffset.x / scrollView.frame.size.width;
    [self.imagePageControl setCurrentPage:page];
    if (self.imageArray && page == self.imageArray.count-1 && self.slideInto == NO) {
        [self buttonClick:nil];
    }
    if (self.imageArray && page < self.imageArray.count-1 && self.slideInto == YES) {
        self.slideIntoNumber = 1;
    }
    if (self.imageArray && page == self.imageArray.count-1 && self.slideInto == YES) {
        UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:nil action:nil];
        if (swipeGestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight){
            self.slideIntoNumber++;
            if (self.slideIntoNumber == 3) {
                [self buttonClick:nil];
            }
        }
    }
    if (scrollView.isTracking) {
        [self stopTimer];
    }else{
        if (!_timer) {
            [self startTimer];
        }
    }
}

- (void)buttonClick:(UIButton *)button {
    [UIView animateWithDuration:DDHidden_TIME animations:^{
        self.alpha = 0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DDHidden_TIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self performSelector:@selector(removeGuidePageHUD) withObject:nil afterDelay:1];
        });
    }];
}

- (void)removeGuidePageHUD {
    [self removeFromSuperview];
}

/**< APP视频新特性页面(新增测试模块内容) */
- (instancetype)initWithFrame:(CGRect)frame videoURL:(NSURL *)videoURL {
    if ([super initWithFrame:frame]) {
        self.playerController = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
        [self.playerController.view setFrame:frame];
        [self.playerController.view setAlpha:1.0];
        [self.playerController setControlStyle:MPMovieControlStyleNone];
        [self.playerController setRepeatMode:MPMovieRepeatModeOne];
        [self.playerController setShouldAutoplay:YES];
        [self.playerController prepareToPlay];
        [self addSubview:self.playerController.view];
        
        // 视频引导页进入按钮
        UIButton *movieStartButton = [[UIButton alloc] initWithFrame:CGRectMake(20, DDScreenH-30-40, DDScreenW-40, 40)];
        [movieStartButton.layer setBorderWidth:1.0];
        [movieStartButton.layer setCornerRadius:20.0];
        [movieStartButton.layer setBorderColor:[UIColor whiteColor].CGColor];
        [movieStartButton setTitle:@"开始体验" forState:UIControlStateNormal];
        [movieStartButton setAlpha:0.0];
        [self.playerController.view addSubview:movieStartButton];
        [movieStartButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [UIView animateWithDuration:DDHidden_TIME animations:^{
            [movieStartButton setAlpha:1.0];
        }];
    }
    return self;
}
#pragma mark---- LAZY init

- (UIPageControl *)imagePageControl{
    if (!_imagePageControl) {
        _imagePageControl =[[UIPageControl alloc]initWithFrame:CGRectMake(DDScreenW*0.0, DDScreenH*0.9, DDScreenW*1.0, DDScreenH*0.1)];
        _imagePageControl.currentPage = 0;
    }
    return _imagePageControl;
}

- (UIButton *)skipButton{
    if (!_skipButton) {
        _skipButton = [[UIButton alloc]initWithFrame:CGRectMake(DDScreenW*0.8, DDScreenW*0.1, 50, 25)];
        [_skipButton setTitle:@"跳过" forState:UIControlStateNormal];
        [_skipButton.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
        [_skipButton setBackgroundColor:[UIColor grayColor]];
        // [skipButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        // [skipButton.layer setCornerRadius:5.0];
        [_skipButton.layer setCornerRadius:(_skipButton.frame.size.height * 0.5)];
        [_skipButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _skipButton;
}

- (void)setCurrentPageControlColor:(UIColor *)currentPageControlColor{
    if (!currentPageControlColor) {
        return;
    }
    self.imagePageControl.currentPageIndicatorTintColor = currentPageControlColor;
}
- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor{
    if (!pageIndicatorTintColor) {
        return;
    }
    self.imagePageControl.pageIndicatorTintColor = pageIndicatorTintColor;
}

- (void)dealloc{
    [self stopTimer];
}
@end

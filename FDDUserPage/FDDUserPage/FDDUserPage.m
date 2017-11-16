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
#define DDHidden_TIME   1.0
#define DDScreenW   [UIScreen mainScreen].bounds.size.width
#define DDScreenH   [UIScreen mainScreen].bounds.size.height
#define DDScreenBounds [UIScreen mainScreen].bounds

@interface FDDUserPage ()<UIScrollViewDelegate>
@property (nonatomic, strong) NSArray                 *imageArray;
@property (nonatomic, strong) UIPageControl           *imagePageControl;
@property (nonatomic, assign) NSInteger               slideIntoNumber;
@property (nonatomic, strong) MPMoviePlayerController *playerController;
@property(nonatomic,strong)UIButton *skipButton;
@property(nonatomic,strong)UIScrollView *guidePageView;

@property(nonatomic,strong)NSTimer *timer;

/**
 广告图片
 */
@property(nonatomic,strong)UIImageView *adImageView;

/**
 开始体验按钮
 */
@property(nonatomic,strong) UIButton *startButton;
@end
@implementation FDDUserPage

- (instancetype)initWithFrame:(CGRect)frame imageNameArray:(NSArray<NSString *> *)imageNameArray buttonIsHidden:(BOOL)isHidden userPageType:(FDDUserPageType)userPageType {
    if ([super initWithFrame:frame]) {
        self.slideInto = NO;
        self.isShowSkipButton = YES;
        self.isautoScrolling = NO;
        if (isHidden == YES) {
            self.imageArray = imageNameArray;
        }
        // 设置引导视图的scrollview
        self.guidePageView.frame = frame;
        [ self.guidePageView setContentSize:CGSizeMake(DDScreenW*imageNameArray.count, DDScreenH)];
        self.imagePageControl.numberOfPages = imageNameArray.count;
        [self createImageWithImageArray:imageNameArray andImageType:userPageType buttonIsHidden:isHidden];

    }
    return self;
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

- (void)addSubViewToBackView{
    // 设置引导页上的跳过按钮
    [self addSubview: self.guidePageView];
    [self addSubview:self.imagePageControl];
    [self addSubview:self.skipButton];

    [self startTimer];
    
}
- (void)createImageWithImageArray:(NSArray<NSString *> *)imageNameArray andImageType:(FDDUserPageType)userPageType buttonIsHidden:(BOOL)isHidden{
    if (userPageType == FDDUserPageGif) {
        [self addSubViewToBackView];
        // 添加在引导视图上的多张引导图片
        for (int i=0; i<imageNameArray.count; i++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(DDScreenW*i, 0, DDScreenW, DDScreenH)];
                NSData *localData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageNameArray[i] ofType:nil]];
                imageView = (UIImageView *)[[FDDGifImageTool alloc] initWithFrame:imageView.frame gifImageData:localData];
                [self.guidePageView addSubview:imageView];
            // 设置在最后一张图片上显示进入体验按钮
            if (i == imageNameArray.count-1 && isHidden == NO) {
                [imageView setUserInteractionEnabled:YES];
                [imageView addSubview:self.startButton];
            }
        }
    }else if (userPageType == FDDUserPageNormal){
        [self addSubViewToBackView];
        // 添加在引导视图上的多张引导图片
        for (int i=0; i<imageNameArray.count; i++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(DDScreenW*i, 0, DDScreenW, DDScreenH)];
            imageView.image = [UIImage imageNamed:imageNameArray[i]];
            [self.guidePageView addSubview:imageView];
            // 设置在最后一张图片上显示进入体验按钮
            if (i == imageNameArray.count-1 && isHidden == NO) {
                [imageView setUserInteractionEnabled:YES];
                [imageView addSubview:self.startButton];
            }
        }
    }else if (userPageType == FDDADPage){
        [self layoutADImgView];
        [self layoutTimerLabel];
    }
}

/**
 排布广告页
 */
- (void)layoutADImgView{
    self.adImageView.userInteractionEnabled = YES;
    [self addSubview:self.adImageView];
}

/**
 排布倒计时label
 */
- (void)layoutTimerLabel{
    if(self.isShowSkipButton){
        self.countDownTimerLabel.text = [NSString stringWithFormat:@"跳过 %ld",(long)self.adDuration];
        
    }else{
        self.countDownTimerLabel.text = [NSString stringWithFormat:@"剩余 %ld",(long)self.adDuration];
    }
    [self addSubview:self.countDownTimerLabel];
    
    if(self.isShowSkipButton){
        self.skipLabelTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(skipTap)];
        [self.countDownTimerLabel addGestureRecognizer:self.skipLabelTap];
    }
    
    if(self.isCloseTimer == YES){
        
    }else{
        self.adTimer = [NSTimer scheduledTimerWithTimeInterval:1.00 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
        
    }
    
}

/**
 广告倒计时时间
 */
- (void)timerAction{
    self.adDuration --;
    if(self.adDuration <=0){
        [self.adTimer invalidate];
        [self remoVeTheUserGuidePageView];

    }
    if(self.isShowSkipButton){
        self.countDownTimerLabel.text = [NSString stringWithFormat:@"跳过 %ld",(long)self.adDuration];
    }else{
        self.countDownTimerLabel.text = [NSString stringWithFormat:@"剩余 %ld",(long)self.adDuration];
    }
}
/**
 设置是否自动滚动引导页面

 @param isautoScrolling isautoScrolling
 */
- (void)setIsautoScrolling:(BOOL)isautoScrolling{
    _isautoScrolling = isautoScrolling;
    if (!_timer && _isautoScrolling) {
        [self startTimer];
    }
}

/**
 自动滚动的定时器
 */
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
    [self remoVeTheUserGuidePageView];
}

- (void)remoVeTheUserGuidePageView{
    [UIView animateWithDuration:DDHidden_TIME animations:^{
        self.alpha = 0;
        [self removeGuidePageHUD];
    }];
}


- (void)removeGuidePageHUD {
    
    [self removeFromSuperview];
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
        [_skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_skipButton.layer setCornerRadius:(_skipButton.frame.size.height * 0.5)];
        [_skipButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _skipButton;
}

/**
 广告imageView

 @return 返回一个
 */
- (UIScrollView *)guidePageView{
    if (!_guidePageView) {
        _guidePageView = [[UIScrollView alloc] init];
        [_guidePageView setBackgroundColor:[UIColor lightGrayColor]];
        _guidePageView.bounces = NO;
        _guidePageView.pagingEnabled = YES;
        _guidePageView.showsHorizontalScrollIndicator = NO;
        _guidePageView.delegate = self;
    }
    
    return _guidePageView;
}
- (UIImageView *)adImageView{
    if (!_adImageView) {
        _adImageView = [[UIImageView alloc] initWithFrame:DDScreenBounds];
    }
    return _adImageView;
}
- (UILabel *)countDownTimerLabel{
    if (!_countDownTimerLabel) {
        _countDownTimerLabel  = [[UILabel alloc]initWithFrame:CGRectMake(DDScreenBounds.size.width - 90, 20, 80, 30)];
        _countDownTimerLabel.backgroundColor = [UIColor colorWithRed:125/256.0 green:125/256.0  blue:125/256.0  alpha:0.5];
        _countDownTimerLabel.textColor = [UIColor whiteColor];
        _countDownTimerLabel.textAlignment = NSTextAlignmentCenter;
        _countDownTimerLabel.layer.masksToBounds = YES;
        _countDownTimerLabel.layer.cornerRadius = 5;
        _countDownTimerLabel.userInteractionEnabled = YES;
    }
    return _countDownTimerLabel;
}
//开始体验按钮
- (UIButton *)startButton{
    if (!_startButton) {
       _startButton =  [[UIButton alloc]initWithFrame:CGRectMake(DDScreenW*0.3, DDScreenH*0.8, DDScreenW*0.4, DDScreenH*0.08)];
        [_startButton setTitle:@"开始体验" forState:UIControlStateNormal];
        [_startButton setTitleColor:[UIColor colorWithRed:164/255.0 green:201/255.0 blue:67/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_startButton.titleLabel setFont:[UIFont systemFontOfSize:21]];
        [_startButton setBackgroundImage:[UIImage imageNamed:@"guideImage_button_backgound"] forState:UIControlStateNormal];
        [_startButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _startButton;
    
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


/**
 设置本地广告图片
 */
-(void)setAdLocalImgName:(NSString *)adLocalImgName{
    adLocalImgName = adLocalImgName;
    __weak typeof (self)selfWeak = self;
    [self.adImageView setImage:[UIImage imageNamed:adLocalImgName]];
    if(selfWeak.adTimer){
        [selfWeak.adTimer fire];
    }
}


- (void)dealloc{
    [self releaseAll];
}

/**
 倒计时上面的调过按钮
 */
- (void)skipTap{
    [self releaseAll];
}

/**
 释放广告的定时器
 */
- (void)releaseAll{
    if(self.adTimer !=nil){
        [self.adTimer invalidate];
        self.adTimer = nil;
    }
    if(self.timer != nil){
        [self.timer invalidate];
        self.timer = nil;
    }
    //去掉广告页面
    [self remoVeTheUserGuidePageView];
}
- (void)stopTimer{
    [_timer invalidate];
    _timer = nil;
}

@end

//
//  FDDUserPage.h
//  FDDUserPage
//
//  Created by 方冬冬 on 2017/11/14.
//  Copyright © 2017年 方冬冬. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum : NSUInteger {
    FDDUserPageNormal,//默认启动图
    FDDUserPageGif,//gif启动图
    FDDADPage,//广告图
} FDDUserPageType;


@interface FDDUserPage : UIView
//当前选中的颜色
@property(nonatomic,strong)UIColor *currentPageControlColor;


//是否自动滚动
@property(nonatomic,assign)BOOL   isAutoScrolling;
//是否可以自动播放视频
@property(nonatomic,assign)BOOL   isLoopPlayback;
//倒数时间label
@property (nonatomic,strong)UILabel * countDownTimerLabel;

@property (nonatomic,assign)BOOL       isShowSkipButton;//是否显示跳过按钮

@property (nonatomic,strong)UITapGestureRecognizer * skipLabelTap;//跳过手势

@property (nonatomic,assign)NSInteger  adDuration;//显示时间
@property (nonatomic,assign)BOOL      isCloseTimer;//是否关不启动定时器

@property (nonatomic,strong)NSTimer * adTimer;//广告定时器


@property (nonatomic,strong)NSString * adImgUrl;//广告网络图片
@property (nonatomic,strong)NSString * adLocalImgName;//广告本地图片
/**
 没有选中的颜色
 */
@property(nonatomic,strong)UIColor *pageIndicatorTintColor;
/**
 *  是否支持滑动进入APP(默认为NO-不支持滑动进入APP | 只有在buttonIsHidden为YES-隐藏状态下可用; buttonIsHidden为NO-显示状态下直接点击按钮进入)
 *  新增视频引导页同样不支持滑动进入APP
 */
@property (nonatomic, assign) BOOL slideInto;
/**
 *  FDDUserPage(图片引导页 | 可自动识别动态图片和静态图片)
 *
 *  @param frame      位置大小
 *  @param imageNameArray 引导页图片数组(NSString)
 *  @param isHidden   开始体验按钮是否隐藏(YES:隐藏-引导页完成自动进入APP首页; NO:不隐藏-引导页完成点击开始体验按钮进入APP主页)
 *
 *  @return FDDUserPage对象
 */
- (instancetype)initWithFrame:(CGRect)frame imageNameArray:(NSArray<NSString *> *)imageNameArray buttonIsHidden:(BOOL)isHidden userPageType:(FDDUserPageType)userPageType;
/**
 *  FDDUserPage(视频引导页)
 *
 *  @param frame    位置大小
 *  @param videoURL 引导页视频地址
 *
 *  @return FDDUserPage对象
 */
- (instancetype)initWithFrame:(CGRect)frame videoURL:(NSURL *)videoURL;




@end

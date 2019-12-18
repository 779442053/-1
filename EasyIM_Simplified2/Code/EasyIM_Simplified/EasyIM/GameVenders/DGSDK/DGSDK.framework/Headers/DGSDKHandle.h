//
//  DGSDKHandle.h
//  DG
//
//  Created by Marco on 12/11/18.
//  Copyright © 2018 Samnang. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

///消息通知 -- 回调
//即将进入SDK
#define DGSDKWILLENTERGAME @"DGSDKWILLENTERGAME"
//进入SDK成功 -- token登录成功
#define DGSDKENTEREDGAME @"DGSDKENTEREDGAME"
//已经退出SDK
#define DGSDKEXITEDGAME @"DGSDKEXITEDGAME"

//进入SDK失败
#define DGSDKENTEREDGAMEFAIL @"DGSDKENTEREDGAMEFAIL"
/*
    key:DGError
 
    数据加载失败的回调，i 有三个类型
        SocketNetError = 0;    socket链接失败
        MemberInitError = 1;   会员初始化失败
        MemberStop = 2;        会员账号暂停

 
 
 */







//SDK
#define DGSDKHANDLE [DGSDKHandle sharedInstance]

@interface DGSDKHandle : NSObject

+(instancetype)sharedInstance;

// ----- API部分
//使用token登录DG Game, 状态使用通知监听
/*
 token:需要登录用户token
 VC:当前的ViewController
 gameID:传游戏ID    ID表详见DGGameId.h文案
 isLoadDGGame: 显示SDK加载Toast    YES显示， False不显示
 minBet:最小下注额度，0不限制
 
 */
- (void)DGSDKLoginWithToken:(NSString *)token withViewController:(UIViewController *)VC withGameID:(int)gameID withLoadDGGameLoading:(BOOL)isShowHUD withMinBet:(int)minBet;

//!!!!!  对接平台退出SDK，账号踢出，谨慎调用  !!!!!
- (void)DGSDKAccountLogout;
@end

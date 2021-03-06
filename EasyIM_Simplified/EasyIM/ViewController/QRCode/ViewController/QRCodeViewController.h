//
//  QRCodeViewController.h
//  EasyIM
//
//  Created by apple on 2019/7/23.
//  Copyright © 2019 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/**
 * 个人/群二维码
 */
@interface QRCodeViewController : MMBaseViewController

/**
 二维码视图初始化
 @param type 二维码类型 0个人、1群聊、2会议室
 @param fid 个人或群或会议室编号
 @param fname 个人或群或会议室名称
 @param fpic 个人或群或会议室图片
 @return QRCodeViewController
 */
- (instancetype)initWithType:(NSInteger)type
                   AndFromId:(NSString *_Nonnull)fid
                 AndFromName:(NSString *_Nonnull)fname
                 WithFromPic:(NSString  *)fpic;

@end

NS_ASSUME_NONNULL_END

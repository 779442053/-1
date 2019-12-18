//
//  ContactsTableViewCell.h
//  EasyIM
//
//  Created by apple on 2019/8/24.
//  Copyright © 2019 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/**
 * 通讯录自定义列
 */
@interface ContactsTableViewCell : UITableViewCell

+(CGFloat)getCellHeight;
+(NSString *)getCellIdentify;

-(void)cellInitDataForName:(NSString *_Nullable)strName
                    AndPic:(NSString *_Nullable)strPicurl;

//设置角标
-(void)setRightBadgeForNO:(NSInteger)intNO;

@end

NS_ASSUME_NONNULL_END

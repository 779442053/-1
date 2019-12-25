//
//  MMChatSystemCell.h
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMChatSystemCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
                       reusableId:(NSString *)ID;

@property (nonatomic, strong) MMMessageFrame *messageF;
- (void)updateSendStatus:(MessageDeliveryState)status;
@end

NS_ASSUME_NONNULL_END

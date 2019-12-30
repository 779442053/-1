//
//  ContactTableViewCell.h
//  WeChatContacts-demo
//
//  Created by shen_gh on 16/3/12.
//  Copyright © 2016年 com.joinup(Beijing). All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ContactsModel.h"
#import "SearchFriendModel.h"
#import "MMGroupModel.h"

#import "MMRecentContactsModel.h"
//群组
#import "ZWGroupModel.h"
//通知
#import "ZWNotionModel.h"

@protocol MMFriendCellDelegate <NSObject>

- (void)longPress:(UILongPressGestureRecognizer *)longRecognizer;

@end


@interface ContactTableViewCell : UITableViewCell

@property (nonatomic,strong) UIImageView *headImageView;//头像
@property (nonatomic,strong) UILabel *nameLabel;        //姓名
@property (nonatomic,strong) UILabel *detailLabel;      //详情
@property (nonatomic,strong) UIView *lineView;          //底线
@property (nonatomic,strong) UILabel *timeLabel;        //消息时间
@property (nonatomic,strong) UILabel *unReadLabel;      //消息未读数



@property (nonatomic, strong) MMRecentContactsModel *recentContacts;
@property (nonatomic, strong) ContactsModel *contactsModel;
@property (nonatomic, strong) MMGroupModel *groupModel;
@property (nonatomic, strong) ZWGroupModel *ZWgroupModel;
@property (nonatomic, weak) id<MMFriendCellDelegate> delegate;

- (void)recentContactsWithModel: (MMRecentContactsModel *)model;

- (void)searchWithModel:(SearchFriendModel *)model;


- (void)updateUnreadCount:(NSInteger)messageUnCount;
//展示通知消息的cell
-(void)updateNotifionModel:(ZWNotionModel *)Model;

@end

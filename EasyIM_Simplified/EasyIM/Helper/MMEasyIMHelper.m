//
//  MMEasyIMHelper.m
//  EasyIM
//
//  Created by momo on 2019/5/11.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMEasyIMHelper.h"
#import "MMRecentContactsModel.h"
//Helper
#import "MMConversationHelper.h"

//Model
#import "MMChatViewController.h"

#import "ZWGroupModel.h"
static MMEasyIMHelper *helper = nil;
@implementation MMEasyIMHelper

+ (instancetype)shareHelper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[MMEasyIMHelper alloc] init];
    });
    return helper;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initHelper];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - init

- (void)initHelper
{
    //通知,代理管理
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePushChatController:) name:CHAT_PUSHVIEWCONTROLLER object:nil];
}


#pragma mark - NSNotification

- (void)handlePushChatController:(NSNotification *)aNotif
{
    ZWWLog(@"如群组,会议室等 共同跳转同一个类 如加对方为好友跳转到相对应的界面并传值")
    id object = aNotif.object;
    MMConversationModel *model = nil;
    if ([object isKindOfClass:[ContactsModel class]]) {
        ContactsModel *contact = (ContactsModel *)object;
        contact.cmd = @"sendMsg";
        model = [MMConversationHelper modelFromContact:contact];
    }else if ([object isKindOfClass:[MMGroupModel class]] || [object isKindOfClass:[ZWGroupModel class]]){
        if ([object isKindOfClass:[ZWGroupModel class]]) {
            ZWGroupModel *zwgroup = (ZWGroupModel *)object;
            MMGroupModel *group = [[MMGroupModel alloc]init];
            group.cmd = @"groupMsg";
            group.name = zwgroup.name;
            group.groupID = zwgroup.ID;
            model = [MMConversationHelper modelFromGroup:group];
        }else{
            MMGroupModel *group = (MMGroupModel *)object;
            group.cmd = @"groupMsg";
            model = [MMConversationHelper modelFromGroup:group];
        }
        
    }else if ([object isKindOfClass:[MMRecentContactsModel class]]){
        ZWWLog(@"从首页进到聊天界面,需要转换的数据模型")
        MMRecentContactsModel *recentModel = (MMRecentContactsModel *)object;
        if ([recentModel.targetType isEqualToString:@"chat"]) {
           ZWWLog(@"单聊")
            ContactsModel *contact = [[ContactsModel alloc]init];
            contact.cmd = @"sendMsg";
            contact.userId = recentModel.userId;
            contact.userName = recentModel.latestnickname;
            contact.photoUrl = recentModel.latestHeadImage;
            model = [MMConversationHelper modelFromContact:contact];
        }else if ([recentModel.targetType isEqualToString:@"groupchat"]){
            ZWWLog(@"群聊")
            model = [MMConversationHelper modelFromRecentContacts:recentModel];
        }else{
            ZWWLog(@"暂时不知道什么类型从首页进来的聊天")
        }
        
    }

    
    if (model) {
        MMChatViewController *controller = [[MMChatViewController alloc] initWithCoversationModel:model];
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        UIViewController *rootViewController = window.rootViewController;
        if ([rootViewController isKindOfClass:[BaseNavgationController class]]) {
            BaseNavgationController *nav = (BaseNavgationController *)rootViewController;
            [nav pushViewController:controller animated:YES];
        }
    }
    
}
@end

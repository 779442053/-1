//
//  MMConversationHelp.m
//  EasyIM
//
//  Created by momo on 2019/5/11.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMConversationHelper.h"

@implementation MMConversationModel

- (instancetype)initWithToUid:(NSString *)toUid
                   toUserName:(NSString *)toUserName
                     nickName:(NSString *)nickName
                   remarkName:(NSString *)remarkName
                     photoUrl:(NSString *)photoUrl
                          cmd:(NSString *)cmd
{
    self = [super init];
    if (self) {
        
        //公共部分
        self.toUserName = toUserName;
        self.toUid = toUid;
        self.cmd = cmd;
        self.nickName = nickName;
        self.isGroup = NO;
        
        self.photoUrl = photoUrl;
        self.remarkName = remarkName;
    }
    return self;
}

- (instancetype)initWithGroupId:(NSString *)groupId
                      groupName:(NSString *)groupName
                      creatorId:(NSString *)creatorId
                           mode:(NSString *)mode
                           time:(NSString *)time
                         notify:(NSString *)notify
                            cmd:(NSString *)cmd
{
    self = [super init];
    if (self) {
        
        //公共部分
        self.toUserName = groupName;
        self.toUid = groupId;
        self.cmd = cmd;
        self.isGroup = YES;
        
        self.creatorId = creatorId;
        self.mode = mode;
        self.time = time;//(时间戳可能在这转换,之后再修改)
        self.notify = notify;
    }
    return self;
}

- (NSString *)getTitle
{
    if (self.remarkName.length) {
        return self.remarkName;
    }
    if (self.nickName.length) {
        return self.nickName;
    }
    return self.toUserName;
}


@end



static MMConversationHelper *shared = nil;

@implementation MMConversationHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

+ (instancetype)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[MMConversationHelper alloc] init];
    });
    
    return shared;
}


+ (MMConversationModel *)modelFromContact:(ContactsModel *)aContact
{
    
    MMConversationModel *model = [[MMConversationModel alloc]
                                  initWithToUid:aContact.userId
                                  toUserName:aContact.userName
                                  nickName:aContact.nickName
                                  remarkName:aContact.remarkName
                                  photoUrl:aContact.photoUrl
                                  cmd:aContact.cmd];
    return model;
}

+ (MMConversationModel *)modelFromGroup:(MMGroupModel *)aGroup
{
    MMConversationModel *model = [[MMConversationModel alloc]
                                  initWithGroupId:aGroup.groupID
                                  groupName:aGroup.name
                                  creatorId:aGroup.creatorID
                                  mode:aGroup.mode
                                  time:aGroup.time
                                  notify:aGroup.notify
                                  cmd:aGroup.cmd];
    return model;
}

+ (MMConversationModel *)modelFromRecentContacts:(MMRecentContactsModel *)aRecenContact{
    
    //MARK:联系人
    MMConversationModel *model;
    if (!aRecenContact.targetId.checkTextEmpty) {
         model = [[MMConversationModel alloc] initWithToUid:aRecenContact.userId
                                                 toUserName:aRecenContact.latestnickname
                                                   nickName:aRecenContact.targetNick
                                                 remarkName:@""
                                                   photoUrl:aRecenContact.targetPhoto
                                                        cmd:@"sendMsg"];
    }
    //MARK:联系群
    else{
        model = [[MMConversationModel alloc] initWithGroupId:aRecenContact.targetId
                                                   groupName:aRecenContact.targetName
                                                   creatorId:aRecenContact.targetType
                                                        mode:@"0"
                                                        time:aRecenContact.lastTime
                                                      notify:@""
                                                         cmd:@"groupMsg"];
    }
    
    return model;
}

@end

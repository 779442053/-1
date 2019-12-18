//
//  MMChatBoxMoreView.h
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMChatBoxMoreViewItem.h"

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, MMChatBoxItem){
    MMChatBoxItemCamera = 0,      //Camera
    MMChatBoxItemAlbum ,          //Album
    MMChatBoxItemVedio,           //视频
    MMChatBoxItemVoice,           //语音
    MMChatBoxItemDoc,             //pdf
    MMChatBoxItemCon,             //联系人
    MMChatBoxItemLocation,        //位置
    
    
    
    MMChatBoxItemVideo,       // Video 暂时不用
};

@class MMChatBoxMoreView;
@protocol MMChatBoxMoreViewDelegate <NSObject>
/**
 *  点击更多的类型
 *
 *  @param chatBoxMoreView ICChatBoxMoreView
 *  @param itemType        类型
 */
- (void)chatBoxMoreView:(MMChatBoxMoreView *)chatBoxMoreView didSelectItem:(MMChatBoxItem)itemType;

@end


@interface MMChatBoxMoreView : UIView


@property (nonatomic, weak) id<MMChatBoxMoreViewDelegate>delegate;
@property (nonatomic, strong) NSMutableArray *items;


@end

NS_ASSUME_NONNULL_END

//
//  MMChatMessageImageCell.m
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMChatMessageImageCell.h"

#import "MMMediaManager.h"
#import "MMFileTool.h"
#import "MMMessageHelper.h"
#import <UIButton+WebCache.h>

@interface MMChatMessageImageCell ()

@property (nonatomic, strong) UIButton *imageBtn;

@end


@implementation MMChatMessageImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.imageBtn];
    }
    return self;
}


#pragma mark - Private Method

- (void)setModelFrame:(MMMessageFrame *)modelFrame
{
    
    [super setModelFrame:modelFrame];
    
    MMMediaManager *manager = [MMMediaManager sharedManager];
    UIImage *image = [manager imageWithLocalPath:[manager imagePathWithName:modelFrame.aMessage.slice.filePath.lastPathComponent]];
    self.imageBtn.frame = modelFrame.picViewF;
    self.bubbleView.userInteractionEnabled = _imageBtn.imageView.image != nil;
    self.bubbleView.image = nil;
    if (modelFrame.aMessage.isSender&&image) {    // 发送者
        UIImage *arrowImage = [manager arrowMeImage:image size:modelFrame.picViewF.size mediaPath:modelFrame.aMessage.slice.filePath isSender:modelFrame.aMessage.isSender];
        [self.imageBtn setBackgroundImage:arrowImage forState:UIControlStateNormal];
    } else {
        [self.imageBtn setBackgroundImage:[UIImage imageNamed:@"workgroup_img_defaultPhoto"] forState:UIControlStateNormal];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.imageBtn sd_setImageWithURL:[NSURL URLWithString:modelFrame.aMessage.slice.content] forState:UIControlStateNormal];
             });
        });
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//
//            UIImage *image;
//            if (messageBody.fileName.length) { // 从本地读取图片
//
//                NSFileManager *fileManager = [NSFileManager defaultManager];
//                NSData *imageData = [fileManager contentsAtPath:[[NSString getFielSavePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"s_%@", messageBody.fileName]]];
//                image = [UIImage imageWithData:imageData];
//
//            };
//            dispatch_async(dispatch_get_main_queue(), ^{
//
//                if (image) { // 本地有图片
//
//                    FLLog(@"本地有图片");
//                    [self.messageImage setImage:image];
//                }
//                else { // 网络加载图片
//
//                    FLLog(@"网络加载图片");
//                    [self.messageImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", BaseUrl, messageBody.thumbnailRemotePath]]];
//                }
//            });
//        });

        
//        NSString *orgImgPath = [manager originImgPath:modelFrame];
//        if ([MMFileTool fileExistsAtPath:orgImgPath]) {
//            UIImage *orgImg = [manager imageWithLocalPath:orgImgPath];
//            UIImage *arrowImage = [manager arrowMeImage:orgImg size:modelFrame.picViewF.size mediaPath:orgImgPath isSender:modelFrame.model.isSender];
//            [self.imageBtn setBackgroundImage:arrowImage forState:UIControlStateNormal];
//        } else {
//            [manager arrowMeImage:self.imageBtn.curre.ntBackgroundImage size:modelFrame.picViewF.size mediaPath:modelFrame.model.message.slice.content isSender:modelFrame.model.isSender];
//            [self.imageBtn setBackgroundImage:imageView.image forState:UIControlStateNormal];
//        }
    }
}

- (void)imageBtnClick:(UIButton *)btn
{
    if (btn.currentBackgroundImage == nil) {
        return;
    }
    CGRect smallRect = [MMMessageHelper photoFramInWindow:btn];
    CGRect bigRect   = [MMMessageHelper photoLargerInWindow:btn];
    NSValue *smallValue = [NSValue valueWithCGRect:smallRect];
    NSValue *bigValue   = [NSValue valueWithCGRect:bigRect];
    [self routerEventWithName:GXRouterEventImageTapEventName
                     userInfo:@{MessageKey   : self.modelFrame,
                                @"smallRect" : smallValue,
                                @"bigRect"   : bigValue
                                }];
}



#pragma mark - Getter

- (UIButton *)imageBtn
{
    if (nil == _imageBtn) {
        _imageBtn = [[UIButton alloc] init];
        [_imageBtn addTarget:self action:@selector(imageBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _imageBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        _imageBtn.layer.masksToBounds = YES;
        _imageBtn.layer.cornerRadius = 5;
        _imageBtn.clipsToBounds = YES;
    }
    return _imageBtn;
}


@end

//
//  MMMessageFrame.m
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMMessageFrame.h"

#import "NSString+Extension.h"
#import "UIImage+Extension.h"

#import "MMMediaManager.h"
#import "MMVideoManager.h"

#import "MMMessageConst.h"
#import "MMMessageHelper.h"

#import "MMFaceManager.h"

#define APP_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define APP_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface MMMessageFrame ()

@property (nonatomic, strong) UILabel *chatLabel;
@property (nonatomic, strong) NSAttributedString *attrText;

@end


@implementation MMMessageFrame

- (UILabel *)chatLabel
{
    if (!_chatLabel) {
        _chatLabel = [[UILabel alloc] init];
        _chatLabel.numberOfLines = 0;
        _chatLabel.font = [UIFont systemFontOfSize:16];
        _chatLabel.textColor = ICRGB(0x282724);
    }
    
    return _chatLabel;
}

- (NSAttributedString *)attrText
{
    if (_attrText == nil) {
        _attrText = [[NSAttributedString alloc] init];
    }
    return _attrText;
}



- (void)setAMessage:(MMMessage *)aMessage
{
    _aMessage = aMessage;
    
    CGFloat headToView    = 10;
    CGFloat headToBubble  = 3;
    CGFloat headWidth     = 45;
    CGFloat cellMargin    = 10;
    CGFloat bubblePadding = 10;
    CGFloat chatLabelMax  = APP_WIDTH - headWidth - 100;
    CGFloat arrowWidth    = 7;      // 气泡箭头
    CGFloat topViewH      = 15;
    CGFloat cellMinW      = 60;     // cell的最小宽度值,针对文本
    
    CGSize timeSize  = CGSizeMake(0, 0);
    if (aMessage.isSender) {
        
        cellMinW = timeSize.width + arrowWidth + bubblePadding*2;
        CGFloat headX = APP_WIDTH - headToView - headWidth;
        _headImageViewF = CGRectMake(headX, cellMargin, headWidth, headWidth);
        _nameLabelF = CGRectMake(headX-110, 2, 100, 20);
        
        if ([aMessage.slice.type isEqualToString:TypeText]) { // 文字
            
            //解决表情计算长度不正确
            self.attrText = [MMFaceManager transferMessageString:aMessage.slice.content font:self.chatLabel.font lineHeight:self.chatLabel.font.lineHeight];
            [self.chatLabel setAttributedText:self.attrText];
            CGSize chateLabelSize = [self.chatLabel sizeThatFits:CGSizeMake(chatLabelMax, MAXFLOAT)];
            
            CGSize bubbleSize     = CGSizeMake(chateLabelSize.width + bubblePadding * 2 + arrowWidth, chateLabelSize.height + bubblePadding * 2);
            CGSize topViewSize    = CGSizeMake(cellMinW+bubblePadding*2, topViewH);
            _bubbleViewF          = CGRectMake(CGRectGetMinX(_headImageViewF) - headToBubble - bubbleSize.width, cellMargin+topViewH, bubbleSize.width, bubbleSize.height);
            CGFloat x             = CGRectGetMinX(_bubbleViewF)+bubblePadding;
            _topViewF             = CGRectMake(CGRectGetMinX(_headImageViewF) - headToBubble - topViewSize.width-headToBubble-5, cellMargin,topViewSize.width,topViewSize.height);
            _chatLabelF           = CGRectMake(x, topViewH + cellMargin + bubblePadding, chateLabelSize.width, chateLabelSize.height);
        } else if ([aMessage.slice.type isEqualToString:TypePic]) { // 图片
            
            CGSize imageSize = CGSizeMake(40, 40);
            UIImage *image   = [UIImage imageWithContentsOfFile:[[MMMediaManager sharedManager] imagePathWithName:aMessage.slice.filePath.lastPathComponent]];
            if (image) {
                imageSize          = [self handleImage:image.size];
            }
            imageSize.width        = imageSize.width > timeSize.width ? imageSize.width : timeSize.width;
            CGSize topViewSize     = CGSizeMake(imageSize.width-arrowWidth, topViewH);
            CGSize bubbleSize      = CGSizeMake(imageSize.width, imageSize.height);
            CGFloat bubbleX        = CGRectGetMinX(_headImageViewF)-headToBubble-bubbleSize.width;
            _bubbleViewF           = CGRectMake(bubbleX, cellMargin+topViewH, bubbleSize.width, bubbleSize.height);
            CGFloat x              = CGRectGetMinX(_bubbleViewF);
            _topViewF             = CGRectMake(x, cellMargin,topViewSize.width,topViewSize.height);
            _picViewF              = CGRectMake(x, cellMargin+topViewH, imageSize.width, imageSize.height);
            
        } else if ([aMessage.slice.type isEqualToString:TypeVoice]) { // 语音消息
            
            CGFloat bubbleViewW     = 100;
            _bubbleViewF = CGRectMake(CGRectGetMinX(_headImageViewF) - headToBubble - bubbleViewW, cellMargin+topViewH, bubbleViewW, 40);
            _topViewF               = CGRectMake(CGRectGetMinX(_bubbleViewF), cellMargin, bubbleViewW - arrowWidth, topViewH);
            _durationLabelF         = CGRectMake(CGRectGetMinX(_bubbleViewF)+ bubblePadding , cellMargin + 10+topViewH, 50, 20);
            _voiceIconF = CGRectMake(CGRectGetMaxX(_bubbleViewF) - 22, cellMargin + 10 + topViewH, 11, 16.5);// - 20
            
        }  else if ([aMessage.slice.type isEqualToString:TypeVideo]) { // 视频信息
            
            CGSize imageSize       = CGSizeMake(150, 150);
            UIImage *videoImage = [[MMMediaManager sharedManager] videoImageWithFileName:aMessage.slice.content.lastPathComponent];
            if (!videoImage) {
                NSString *path          = [[MMVideoManager shareManager] receiveVideoPathWithFileKey:[aMessage.slice.content.lastPathComponent stringByDeletingPathExtension]];
                videoImage    = [UIImage videoFramerateWithPath:path];
            }
            if (videoImage) {
                float scale        = videoImage.size.height/videoImage.size.width;
                imageSize = CGSizeMake(150, 140*scale);
            }
            CGSize bubbleSize = CGSizeMake(imageSize.width, imageSize.height);
            _bubbleViewF = CGRectMake(CGRectGetMinX(_headImageViewF)-headToBubble-bubbleSize.width, cellMargin+topViewH, bubbleSize.width, bubbleSize.height);
            CGSize topViewSize     = CGSizeMake(imageSize.width-arrowWidth, topViewH);
            CGFloat x              = CGRectGetMinX(_bubbleViewF);
            _topViewF              = CGRectMake(x, cellMargin, topViewSize.width, topViewSize.height);
            _picViewF              = CGRectMake(x, cellMargin+topViewH, imageSize.width, imageSize.height);
            
        } else if ([aMessage.slice.type isEqualToString:TypeFile]) {
            
            CGSize bubbleSize = CGSizeMake(253, 95.0);
            _bubbleViewF = CGRectMake(CGRectGetMinX(_headImageViewF)-headToBubble-bubbleSize.width, cellMargin+topViewH, bubbleSize.width, bubbleSize.height);
            CGSize topViewSize     = CGSizeMake(bubbleSize.width-arrowWidth, topViewH);
            CGFloat x              = CGRectGetMinX(_bubbleViewF);
            _topViewF              = CGRectMake(x, cellMargin, topViewSize.width, topViewSize.height);
            _picViewF              = CGRectMake(x, cellMargin+topViewH, bubbleSize.width, bubbleSize.height);
        } else if ([aMessage.slice.type isEqualToString:TypePicText]) {
            CGSize bubbleSize = CGSizeMake(253, 120.0);
            _bubbleViewF = CGRectMake(CGRectGetMinX(_headImageViewF)-headToBubble-bubbleSize.width, cellMargin+topViewH, bubbleSize.width, bubbleSize.height);
            CGSize topViewSize     = CGSizeMake(bubbleSize.width-arrowWidth, topViewH);
            CGFloat x              = CGRectGetMinX(_bubbleViewF);
            _topViewF              = CGRectMake(x, cellMargin, topViewSize.width, topViewSize.height);
            _picViewF              = CGRectMake(x, cellMargin+topViewH, bubbleSize.width, bubbleSize.height);
        } else if([aMessage.slice.type isEqualToString:TypeLinkMan]){//联系人(名片)
            CGSize bubbleSize = CGSizeMake(230, 107);
            _bubbleViewF = CGRectMake(CGRectGetMinX(_headImageViewF)-headToBubble-bubbleSize.width, cellMargin+topViewH, bubbleSize.width, bubbleSize.height);
            CGSize topViewSize     = CGSizeMake(bubbleSize.width-arrowWidth, topViewH);
            CGFloat x              = CGRectGetMinX(_bubbleViewF);
            _topViewF              = CGRectMake(x, cellMargin, topViewSize.width, topViewSize.height);
            _picViewF              = CGRectMake(x, cellMargin+topViewH, bubbleSize.width, bubbleSize.height);
        }
        
        
        CGFloat activityX = _bubbleViewF.origin.x-40;
        CGFloat activityY = (_bubbleViewF.origin.y + _bubbleViewF.size.height)/2 - 5;
        CGFloat activityW = 40;
        CGFloat activityH = 40;
        _activityF        = CGRectMake(activityX, activityY, activityW, activityH);
        _retryButtonF     = _activityF;
        
    }
    else {
        // 接收者
        _headImageViewF   = CGRectMake(headToView, cellMargin, headWidth, headWidth);
        CGSize nameSize   = CGSizeMake(0, 0);
        cellMinW = nameSize.width + 6 + timeSize.width; // 最小宽度
        _nameLabelF = CGRectMake(CGRectGetMaxX(_headImageViewF), 2, 100, 20);
        
        if ([aMessage.slice.type isEqualToString:TypeText]) {
            
            //解决表情计算长度不正确
            self.attrText = [MMFaceManager transferMessageString:aMessage.slice.content font:self.chatLabel.font lineHeight:self.chatLabel.font.lineHeight];
            [self.chatLabel setAttributedText:self.attrText];
            CGSize chateLabelSize = [self.chatLabel sizeThatFits:CGSizeMake(chatLabelMax, MAXFLOAT)];

            CGSize topViewSize    = CGSizeMake(cellMinW+bubblePadding*2, topViewH);
            CGSize bubbleSize = CGSizeMake(chateLabelSize.width + bubblePadding * 2 + arrowWidth, chateLabelSize.height + bubblePadding * 2);
            
            _bubbleViewF  = CGRectMake(CGRectGetMaxX(_headImageViewF) + headToBubble, cellMargin+topViewH, bubbleSize.width, bubbleSize.height);
            CGFloat x     = CGRectGetMinX(_bubbleViewF) + bubblePadding + arrowWidth;
            _topViewF     = CGRectMake(CGRectGetMinX(_bubbleViewF)+arrowWidth, cellMargin, topViewSize.width, topViewSize.height);
            _chatLabelF   = CGRectMake(x, cellMargin + bubblePadding + topViewH, chateLabelSize.width, chateLabelSize.height);
        } else if ([aMessage.slice.type isEqualToString:TypePic]) {
            CGSize imageSize = CGSizeMake(40, 40);
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:aMessage.slice.content]];
            UIImage *showimage = [UIImage imageWithData:data];
            imageSize = [self handleImage:showimage.size];
            
            imageSize.width        = imageSize.width > cellMinW ? imageSize.width : cellMinW;
            CGSize topViewSize     = CGSizeMake(imageSize.width-arrowWidth, topViewH);
            CGSize bubbleSize      = CGSizeMake(imageSize.width, imageSize.height);
            CGFloat bubbleX        = CGRectGetMaxX(_headImageViewF)+headToBubble;
            _bubbleViewF           = CGRectMake(bubbleX, cellMargin+topViewH, bubbleSize.width, bubbleSize.height);
            CGFloat x              = CGRectGetMinX(_bubbleViewF);
            _topViewF              = CGRectMake(x+arrowWidth, cellMargin, topViewSize.width, topViewSize.height);
            _picViewF              = CGRectMake(x, cellMargin+topViewH, imageSize.width, imageSize.height);
            
        } else if ([aMessage.slice.type isEqualToString:TypeVoice]) {   // 语音
            CGFloat bubbleViewW = 100; // 加上一个红点的宽度
            CGFloat voiceToBull = 15;
            
            _bubbleViewF = CGRectMake(CGRectGetMaxX(_headImageViewF) + headToBubble, cellMargin+topViewH, bubbleViewW, 40);
            _topViewF    = CGRectMake(CGRectGetMinX(_bubbleViewF)+arrowWidth, cellMargin, bubbleViewW-arrowWidth, topViewH);
            _voiceIconF = CGRectMake(CGRectGetMinX(_bubbleViewF)+arrowWidth+bubblePadding, cellMargin + 10 + topViewH, 11, 16.5);
            
            //设定为3位数
            //            NSString *duraStr = @(aMessage.slice.duration).description;
            NSString *duraStr = @"100";
            CGSize durSize = [duraStr sizeWithMaxWidth:chatLabelMax andFont:[UIFont systemFontOfSize:14]];
            _durationLabelF = CGRectMake(CGRectGetMaxX(_bubbleViewF) - voiceToBull - durSize.width, cellMargin + 10 + topViewH, durSize.width+bubblePadding, durSize.height);
            _redViewF = CGRectMake(CGRectGetMaxX(_bubbleViewF) + 6, CGRectGetMinY(_bubbleViewF) + _bubbleViewF.size.height*0.5-4, 8, 8);
        } else if ([aMessage.slice.type isEqualToString:TypeVideo]) {   // 视频
            CGSize imageSize       = CGSizeMake(150, 150);
            UIImage *videoImage = [[MMMediaManager sharedManager] videoImageWithFileName:aMessage.slice.content];
            if (!videoImage) {
                NSString *path          = [[MMVideoManager shareManager] receiveVideoPathWithFileKey:aMessage.slice.content];
                videoImage    = [UIImage videoFramerateWithPath:path];
            }
            if (videoImage) {
                float scale        = videoImage.size.height/videoImage.size.width;
                imageSize = CGSizeMake(150, 140*scale);
            }
            CGSize bubbleSize = CGSizeMake(imageSize.width, imageSize.height+topViewH);
            _bubbleViewF = CGRectMake(CGRectGetMaxX(_headImageViewF)+headToBubble, cellMargin+topViewH, bubbleSize.width, bubbleSize.height);
            CGSize topViewSize     = CGSizeMake(imageSize.width-arrowWidth, topViewH);
            CGFloat x              = CGRectGetMinX(_bubbleViewF);
            _topViewF              = CGRectMake(x+arrowWidth, cellMargin, topViewSize.width, topViewSize.height);
            _picViewF              = CGRectMake(x, cellMargin+topViewH, imageSize.width, imageSize.height);
        } else if ([aMessage.slice.type isEqualToString:TypeSystem]) {
            CGSize size           = [aMessage.slice.content sizeWithMaxWidth:APP_WIDTH-40 andFont:[UIFont systemFontOfSize:11.0]];
            _bubbleViewF = CGRectMake(0, 0, 0, size.height+10);// 只需要高度就行
        } else if ([aMessage.slice.type isEqualToString:TypeFile]) {
            CGSize bubbleSize = CGSizeMake(253, 95.0);
            _bubbleViewF = CGRectMake(CGRectGetMaxX(_headImageViewF)+headToBubble, cellMargin+topViewH, bubbleSize.width, bubbleSize.height);
            CGSize topViewSize     = CGSizeMake(bubbleSize.width-arrowWidth, topViewH);
            CGFloat x              = CGRectGetMinX(_bubbleViewF);
            _topViewF              = CGRectMake(x+arrowWidth, cellMargin, topViewSize.width, topViewSize.height);
            _picViewF              = CGRectMake(x, cellMargin+topViewH, bubbleSize.width, bubbleSize.height);
        } else if ([aMessage.slice.type isEqualToString:TypePicText]) {
            CGSize bubbleSize = CGSizeMake(253, 120.0);
            _bubbleViewF = CGRectMake(CGRectGetMaxX(_headImageViewF)+headToBubble, cellMargin+topViewH, bubbleSize.width, bubbleSize.height);
            CGSize topViewSize     = CGSizeMake(bubbleSize.width-arrowWidth, topViewH);
            CGFloat x              = CGRectGetMinX(_bubbleViewF);
            _topViewF              = CGRectMake(x+arrowWidth, cellMargin, topViewSize.width, topViewSize.height);
            _picViewF              = CGRectMake(x, cellMargin+topViewH, bubbleSize.width, bubbleSize.height);
        }
        else if([aMessage.slice.type isEqualToString:TypeLinkMan]){//联系人(名片)
            CGSize bubbleSize = CGSizeMake(230, 107);
            _bubbleViewF = CGRectMake(CGRectGetMaxX(_headImageViewF)+headToBubble, cellMargin+topViewH, bubbleSize.width, bubbleSize.height);
            CGSize topViewSize     = CGSizeMake(bubbleSize.width-arrowWidth, topViewH);
            CGFloat x              = CGRectGetMinX(_bubbleViewF);
            _topViewF              = CGRectMake(x+arrowWidth, cellMargin, topViewSize.width, topViewSize.height);
            _picViewF              = CGRectMake(x, cellMargin+topViewH, bubbleSize.width, bubbleSize.height);
        }
        
    }
    _cellHight = MAX(CGRectGetMaxY(_bubbleViewF), CGRectGetMaxY(_headImageViewF)) + cellMargin;
    
    if ([aMessage.slice.type isEqualToString:TypeSystem]) {
        CGSize size           = [aMessage.slice.content sizeWithMaxWidth:[UIScreen mainScreen].bounds.size.width-40 andFont:[UIFont systemFontOfSize:11.0]];
        _cellHight = size.height+10;
    }
}




// 缩放，临时的方法
- (CGSize)handleImage:(CGSize)retSize
{
    CGFloat scaleH = 0.22;
    CGFloat scaleW = 0.38;
    CGFloat height = 0;
    CGFloat width = 0;
    if (retSize.height / APP_HEIGHT + 0.16 > retSize.width / APP_WIDTH) {
        height = APP_HEIGHT * scaleH;
        width = retSize.width / retSize.height * height;
    } else {
        width = APP_WIDTH * scaleW;
        height = retSize.height / retSize.width * width;
    }
    return CGSizeMake(width, height);
}



-(NSString *)getFinalStringLength:(NSString*)inputString
{
    
    __block NSString *textString = @"";
    
    [inputString enumerateSubstringsInRange:NSMakeRange(0, inputString.length)
                                    options:NSStringEnumerationByComposedCharacterSequences
                                 usingBlock:^(NSString *substring,NSRange substringRange,NSRange enclosingRange,BOOL *stop){
                                     
                                     if (strlen([substring UTF8String]) < 3) {
                                         
                                     }else{
                                         MMLog(@"%zd",@"[流汗]".length);
                                         MMLog(@"%zd",@"]".length);
                                         MMLog(@"%zd",@"汗".length);
                                         textString = [textString stringByAppendingString:substring];
                                     }
                                     
                                 }];
    return textString;
}
@end

//
//  MMChatMessageFileCell.m
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMChatMessageFileCell.h"

#import "MMFileButton.h"
#import "MMFileTool.h"

@interface MMChatMessageFileCell ()

@property (nonatomic, strong) MMFileButton *fileButton;

@end


@implementation MMChatMessageFileCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.fileButton];
    }
    return self;
}


- (void)setModelFrame:(MMMessageFrame *)modelFrame
{
    [super setModelFrame:modelFrame];
    
    self.fileButton.frame = modelFrame.picViewF;
    self.fileButton.messageModel = modelFrame.aMessage;
    
    NSString *localPath = [[MMFileTool fileMainPath] stringByAppendingString:[NSString stringWithFormat:@"/%@",self.modelFrame.aMessage.slice.fileName]];
    
    BOOL isExists = [MMFileTool fileExistsAtPath:localPath];


    if (isExists) {
        if (modelFrame.aMessage.isSender) {
            if (modelFrame.aMessage.deliveryState == MMMessageDeliveryState_Delivered) {
                self.fileButton.identLabel.text = @"已发送";
            } else {
                self.fileButton.identLabel.text = @"未发送";
            }
        } else {
            self.fileButton.identLabel.text = @"已下载";
        }
    } else {
        if (modelFrame.aMessage.isSender) {
            if (modelFrame.aMessage.deliveryState == MMMessageDeliveryState_Delivered) {
                self.fileButton.identLabel.text = @"已发送";
            } else {
                self.fileButton.identLabel.text = @"未发送";
            }
        } else {
            self.fileButton.identLabel.text = @"未下载";
        }
    }
    
}


#pragma mark - Event

- (void)fileBtnClicked:(UIButton *)fileBtn
{
    
    NSString *localPath = [[MMFileTool fileMainPath] stringByAppendingString:[NSString stringWithFormat:@"/%@",self.modelFrame.aMessage.slice.fileName]];
    
    BOOL isExists = [MMFileTool fileExistsAtPath:localPath];
    
    //如果文件不存在,则去下载
    if (!isExists) {
        self.fileButton.progressView.hidden = NO;
        [[MMApiClient sharedClient] DOWNLOAD:self.modelFrame.aMessage.slice.content fileDir:@"Chat/File" progress:^(NSProgress * _Nonnull progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.fileButton.progressView.progress = (double)progress.completedUnitCount/(double)progress.totalUnitCount;
            });
            
        } success:^(NSString * _Nonnull filePath) {
            // 获取文件 如视频.MP4
           NSString * lastPathComponent  = [filePath lastPathComponent];
            
            //用传过来的路径创建新路径 首先去除文件名
            NSString *pathNew = [filePath stringByReplacingOccurrencesOfString:lastPathComponent withString:@""];
            
            //然后拼接新文件名：新文件名
            NSString *moveToPath = [NSString stringWithFormat:@"%@%@",pathNew,self.modelFrame.aMessage.slice.fileName];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            //通过移动该文件对文件重命名
            BOOL isSuccess = [fileManager moveItemAtPath:filePath toPath:moveToPath error:nil];
            if (isSuccess) {
                self.modelFrame.aMessage.slice.filePath = moveToPath;
                self.modelFrame = self.modelFrame;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self localFilePath:moveToPath];
                });
            }else{
                //失败
                MMLog(@"失败!");
            }
            self.fileButton.progressView.hidden = YES;
            
        } failure:^(NSError * _Nonnull error) {
            [MMProgressHUD showHUD:@"下载失败"];
        }];
        
    }
    else{
        
        [self localFilePath:localPath];
    }
    
}


- (void)localFilePath:(NSString *)filePath
{
    
    // 如果文件存在就直接打开，否者下载
    [self routerEventWithName:GXRouterEventScanFile
                     userInfo:@{
                                MessageKey   : self.modelFrame,
                                @"filePath"  : filePath,
                                }
     ];
    
}



#pragma mark - Getter

- (MMFileButton *)fileButton
{
    if (!_fileButton) {
        _fileButton = [MMFileButton buttonWithType:UIButtonTypeCustom];
        [_fileButton addTarget:self action:@selector(fileBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fileButton;
}


@end

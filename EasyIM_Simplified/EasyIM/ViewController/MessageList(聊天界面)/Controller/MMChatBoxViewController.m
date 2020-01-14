//
//  MMChatBoxViewController.m
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMChatBoxViewController.h"
#import "MMChatBoxMoreView.h"
#import "MMChatBoxFaceView.h"
#import "MMMediaManager.h"
#import "MMVideoView.h"
#import "MMMessageConst.h"
#import "MMVideoManager.h"
#import "MMVedioCallManager.h"
#import "UIImage+Extension.h"
#import "MMDocumentViewController.h"
#import "MMTools.h"


#import "MMVedioCallEnum.h"
//邀请好友
#import "MMAddMemberViewController.h"
//位置
#import "ZWLocationViewController.h"

#import "ZWChartViewModel.h"
@interface MMChatBoxViewController ()<MMChatBoxDelegate,MMChatBoxMoreViewDelegate, UIImagePickerControllerDelegate,MMDocumentDelegate,UINavigationControllerDelegate,MMAddMemberViewControllerDelegate,LocationViewControllerDelegate>

@property (nonatomic, assign) CGRect keyboardFrame;
@property (strong, nonatomic, readonly) UIViewController *rootViewController;
/** chatBar more view */
@property (nonatomic, strong) MMChatBoxMoreView *chatBoxMoreView;
/** emoji face */
@property (nonatomic, strong) MMChatBoxFaceView *chatBoxFaceView;
/** 录音文件名 */
@property (nonatomic, copy) NSString *recordName;
@property (nonatomic, strong) UIImagePickerController *imagePicker;

@property (nonatomic, weak) MMVideoView *videoView;
@property (nonatomic, weak) ZWChartViewModel *ViewMOdel;
@property(nonatomic,strong)MMVedioCallManager *vedioCallManager;
@end
@implementation MMChatBoxViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.chatBox];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    self.vedioCallManager = [MMVedioCallManager sharedManager];
}

- (BOOL)resignFirstResponder
{
    if (self.chatBox.status == MMChatBoxStatusShowVideo) { // 录制视频状态
        if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
            [UIView animateWithDuration:0.3 animations:^{
                [_delegate chatBoxViewController:self didChangeChatBoxHeight:HEIGHT_TABBAR];
            } completion:^(BOOL finished) {
                [self.videoView removeFromSuperview]; // 移除video视图
                self.chatBox.status = MMChatBoxStatusNothing;//同时改变状态
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[MMVideoManager shareManager] exit];  // 防止内存泄露
                });
            }];
        }
        return [super resignFirstResponder];
    }
    if (self.chatBox.status != MMChatBoxStatusNothing && self.chatBox.status != MMChatBoxStatusShowVoice) {
        [self.chatBox resignFirstResponder];
        if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
            [UIView animateWithDuration:0.3 animations:^{
                [_delegate chatBoxViewController:self didChangeChatBoxHeight:HEIGHT_TABBAR];
            } completion:^(BOOL finished) {
                [self.chatBoxFaceView removeFromSuperview];
                [self.chatBoxMoreView removeFromSuperview];
                // 状态改变
                self.chatBox.status = MMChatBoxStatusNothing;
            }];
        }
        
    }
    return [super resignFirstResponder];
}
- (BOOL)becomeFirstResponder
{
    return [super becomeFirstResponder];
}
- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    if ([eventName isEqualToString:GXRouterEventVideoRecordExit]) {
        [self resignFirstResponder];
    } else if ([eventName isEqualToString:GXRouterEventVideoRecordFinish]) {
        NSString *videoPath = userInfo[VideoPathKey];
        [self resignFirstResponder];
        if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:sendVideoMessage:)]) {
            [_delegate chatBoxViewController:self sendVideoMessage:videoPath];
        }
    } else if ([eventName isEqualToString:GXRouterEventVideoRecordCancel]) {
        NSLog(@"record cancel");
    }
}
#pragma mark - Private Methods
- (NSString *)currentRecordFileName
{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%ld",(long)timeInterval];
    return fileName;
}
- (void)keyboardWillHide:(NSNotification *)notification
{
    self.keyboardFrame = CGRectZero;
    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
        [_delegate chatBoxViewController:self didChangeChatBoxHeight:HEIGHT_TABBAR];
        _chatBox.status = MMChatBoxStatusNothing;
    }
}
- (void)keyboardFrameWillChange:(NSNotification *)notification
{
    self.keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (_chatBox.status == MMChatBoxStatusShowKeyboard && self.keyboardFrame.size.height <= HEIGHT_CHATBOXVIEW) {
        return;
    }
    else if ((_chatBox.status == MMChatBoxStatusShowFace || _chatBox.status == MMChatBoxStatusShowMore) && self.keyboardFrame.size.height <= HEIGHT_CHATBOXVIEW) {
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
        [_delegate chatBoxViewController:self didChangeChatBoxHeight: self.keyboardFrame.size.height + HEIGHT_TABBAR];
        _chatBox.status = MMChatBoxStatusShowKeyboard; // 状态改变
    }
}
// 将要弹出视频视图
- (void)videoViewWillAppear
{
    MMVideoView *videoView = [[MMVideoView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, videwViewH)];
    [self.view insertSubview:videoView aboveSubview:self.chatBox];
    self.videoView = videoView;
    videoView.hidden = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didVideoViewAppeared:)]) {
        [_delegate chatBoxViewController:self didVideoViewAppeared:videoView];
    }
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Getter and Setter

- (MMChatBox *) chatBox
{
    if (_chatBox == nil) {
        _chatBox = [[MMChatBox alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, HEIGHT_TABBAR)];
        _chatBox.delegate = self;
    }
    return _chatBox;
}

- (MMChatBoxFaceView *)chatBoxFaceView
{
    if (nil == _chatBoxFaceView) {
        _chatBoxFaceView = [[MMChatBoxFaceView alloc] initWithFrame:CGRectMake(0, HEIGHT_TABBAR, KScreenWidth, HEIGHT_CHATBOXVIEW)];
    }
    return _chatBoxFaceView;
}

- (MMChatBoxMoreView *)chatBoxMoreView
{
    if (nil == _chatBoxMoreView) {
        _chatBoxMoreView = [[MMChatBoxMoreView alloc] initWithFrame:CGRectMake(0, HEIGHT_TABBAR, KScreenWidth, HEIGHT_CHATBOXVIEW)];
        _chatBoxMoreView.delegate = self;
        // 创建Item
        MMChatBoxMoreViewItem *takePictureItem = [MMChatBoxMoreViewItem createChatBoxMoreItemWithTitle:@"拍摄"
                                                                                             imageName:@"chat_takePhoto_icon"];
        MMChatBoxMoreViewItem *photosItem = [MMChatBoxMoreViewItem createChatBoxMoreItemWithTitle:@"照片"
                                                                                        imageName:@"chat_photo_icon"];
        MMChatBoxMoreViewItem *videoItem   = [MMChatBoxMoreViewItem createChatBoxMoreItemWithTitle:@"视频通话" imageName:@"chat_vodeo_icon"];
        MMChatBoxMoreViewItem *voiceItem   = [MMChatBoxMoreViewItem createChatBoxMoreItemWithTitle:@"语音通话" imageName:@"chat_voice_icon"];
        MMChatBoxMoreViewItem *docItem   = [MMChatBoxMoreViewItem createChatBoxMoreItemWithTitle:@"文件" imageName:@"chat_file_icon"];
        MMChatBoxMoreViewItem *connItem   = [MMChatBoxMoreViewItem createChatBoxMoreItemWithTitle:@"联系人" imageName:@"chat_connection_icon"];
        MMChatBoxMoreViewItem *locationItem   = [MMChatBoxMoreViewItem createChatBoxMoreItemWithTitle:@"位置" imageName:@"chat_location_icon"];
        
        [_chatBoxMoreView setItems:[[NSMutableArray alloc] initWithObjects:takePictureItem, photosItem,videoItem,voiceItem,docItem,connItem,locationItem, nil]];
    }
    return _chatBoxMoreView;
}
- (UIImagePickerController *)imagePicker
{
    if (nil == _imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
        _imagePicker.modalPresentationStyle = UIModalPresentationCustom;
        _imagePicker.view.backgroundColor = [UIColor grayColor];
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
        _imagePicker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor]};
        _imagePicker.navigationBar.translucent = NO;
        [_imagePicker.navigationBar setBarTintColor:[UIColor colorWithHexString:@"#333237"]];
    }
    return _imagePicker;
}
#pragma mark - TLChatBoxMoreViewDelegate
- (void) chatBoxMoreView:(MMChatBoxMoreView *)chatBoxMoreView
didSelectItem:(MMChatBoxItem)itemType
{
    switch (itemType) {
        case MMChatBoxItemAlbum:
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentViewController:self.imagePicker animated:YES completion:^{}];
            } else {
                NSLog(@"photLibrary is not available!");
            }
        }
            break;
        //MARK:拍摄
        case MMChatBoxItemCamera:
        {
            if (![MMTools hasPermissionToGetCamera]) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请在iPhone的“设置-隐私”选项中，允许乐聊访问你的相机。" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                }];
                [alertController addAction:OKAction];
                [self  presentViewController:alertController animated:YES completion:nil];
            } else {
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    [self presentViewController:self.imagePicker animated:YES completion:nil];
                } else {
                    NSLog(@"camera is no available!");
                }
            }
        }
            break;
        case MMChatBoxItemVedio://视频通话
        {
            //MARK:群聊视频
            if (self.conversationType == MMConversationType_Group) {
                [self groupInvitation:YES];
            }
            //MARK:单聊视频
            else{
                ZWWLog(@"张威威应该想后台获取通信地址,本地唤醒webrtc,视频")
                NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
                parma[CALL_CHATTER] = [MMManagerGlobeUntil sharedManager].toUid;
                parma[CALL_TYPE] = @(MMCallTypeVideo);
                parma[CALL_CALLPARTY] = @(MMCallParty_Calling);
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_Vedio1V1 object:parma];
            }
            
        }
            break;
        case MMChatBoxItemVoice://音频通话
        {
            //MARK:群聊语音
            if (self.conversationType == MMConversationType_Group) {
                [self groupInvitation:NO];
            }
            //MARK:单聊语音
            else{
                ZWWLog(@"张威威应该想后台获取通信地址,本地唤醒webrtc,进行呼叫")
                NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
                parma[CALL_CHATTER] = [MMManagerGlobeUntil sharedManager].toUid;
                parma[CALL_TYPE] = @(MMCallTypeVoice);
                parma[CALL_CALLPARTY] = @(MMCallParty_Calling);
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_Vedio1V1 object:parma];
            }
        }
            break;
        //MARK:文件
        case MMChatBoxItemDoc:
        {
            MMDocumentViewController *docVC = [[MMDocumentViewController alloc] init];
            docVC.delegate = self;
            BaseNavgationController *nav = [[BaseNavgationController alloc] initWithRootViewController:docVC];
            nav.navigationBar.hidden = YES;
            nav.modalPresentationStyle = 0;
            [self presentViewController:nav animated:YES completion:nil];
        }
            break;
        //MARK:联系人
        case MMChatBoxItemCon:{
            MMAddMemberViewController *addMember = [[MMAddMemberViewController alloc] init];
            addMember.isGroupVideo = NO;
            addMember.isGroupAudio = NO;
            addMember.isLinkman = YES;
            addMember.groupId = self.groupId;
            addMember.creatorId = self.creatorId;
            addMember.delegate = (id<MMAddMemberViewControllerDelegate>)self;
            [self.navigationController pushViewController:addMember animated:YES];
        }
            break;
        //MARK:位置
        case MMChatBoxItemLocation:
        {
            ZWLocationViewController *addressVC = [[ZWLocationViewController alloc]init];
            addressVC.delegate = self;
            BaseNavgationController *nav = [[BaseNavgationController alloc] initWithRootViewController:addressVC];
            //nav.navigationBar.hidden = NO;
            nav.modalPresentationStyle = 0;
            [self presentViewController:nav animated:YES completion:nil];
        }
            break;
        case MMChatBoxItemVideo:
        {
            [self resignFirstResponder];
            if (![[MMVideoManager shareManager] canRecordViedo]) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请在iPhone的“设置-隐私”选项中，允许乐聊访问你的相机。" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                }];
                [alertController addAction:OKAction];
                [self  presentViewController:alertController animated:YES completion:nil];
            } else {
                [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(videoViewWillAppear) userInfo:nil repeats:NO]; // 待动画完成
            }
        }
            break;
        default:
            break;
    }
}

-(void)groupInvitation:(BOOL)isVideo{
    __weak typeof(self) weakSelf = self;
    //先获取群内部成员
    [[self.ViewMOdel.getGroupPeopleListCommand execute:self.groupId] subscribeNext:^(id  _Nullable x) {
        if ([x[@"code"] intValue]) {
            NSArray<MemberList *> *memberList = [MemberList mj_objectArrayWithKeyValuesArray:x[@"res"]];
           if ([[x allValues] containsObject:@"cid"]) {
               self.creatorId = x[@"cid"];
           }
            if (memberList.count > 1) {
                MMAddMemberViewController *addMember = [[MMAddMemberViewController alloc] init];
                addMember.memberData = memberList;
                addMember.isGroupVideo = isVideo;
                addMember.isGroupAudio = !isVideo;
                addMember.groupId = self.groupId;
                addMember.creatorId = self.creatorId;
                addMember.delegate = (id<MMAddMemberViewControllerDelegate>)self;
                [weakSelf.navigationController pushViewController:addMember animated:YES];
            }else{
                NSString *strinfo = [NSString stringWithFormat:@"请先邀请好友入群再发起%@",isVideo?@"视频":@"语音"];
                [MMProgressHUD showHUD:strinfo];
            }
        }
    }];
}
//MARK: - MMAddMemberViewControllerDelegate(群音视频)
-(void)mmInvitationMemberFinish:(NSArray *)arrMembersId
                     andGroupId:(NSString *)strGroupId
                 andDetailsData:(NSArray *)arrDetails
                     andIsVideo:(BOOL)isVideo{
    //一个人，1v1
    if ([arrMembersId count] <= 1) {
        NSDictionary *dicObject = @{
                                    CALL_CHATTER:arrMembersId.firstObject,
                                    CALL_TYPE:isVideo?@(MMCallTypeVideo):@(MMCallTypeVoice),
                                    CALL_CALLPARTY:@(MMCallParty_Calling),
                                    CALL_USER_DETAILS:arrDetails
                                    };
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CALL_Vedio1V1
                                                            object:dicObject];
    }
    //两个人以上，1vM
    else{
        NSDictionary *dicObject = @{
                                    CALL_CHATTER:arrMembersId,
                                    CALL_TYPE:isVideo?@(MMCallTypeVideo):@(MMCallTypeVoice),
                                    CALL_CALLPARTY:@(MMCallParty_Calling),
                                    CALL_GROUPID:strGroupId,
                                    CALL_USER_DETAILS:arrDetails
                                    };
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CALL_Vedio1VM
                                                            object:dicObject];
    }
}
//MARK:联系人
-(void)mmDidSelectForLinkmanId:(NSString *)strUserId
                   andUserName:(NSString *)strUserName
                   andNickName:(NSString *)strNickname
                      andPhoto:(NSString *)strPhoto{
    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:sendLinkmanMessage:AndUserName:AndNickname:AndPhoto:)]) {
        [_delegate chatBoxViewController:self
                      sendLinkmanMessage:strUserId
                             AndUserName:strUserName
                             AndNickname:strNickname
                                AndPhoto:strPhoto];
    }
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    // 图片压缩后再上传服务器
    // 保存路径
    UIImage *simpleImg = [UIImage simpleImage:orgImage];
    NSString *filePath = [[MMMediaManager sharedManager] saveImage:simpleImg];
    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:sendImageMessage:imagePath:)]) {
        [_delegate chatBoxViewController:self sendImageMessage:simpleImg imagePath:filePath];
    }
}


#pragma mark - MMChatBoxDelegate

/**
 *  输入框状态改变
 *
 *  @param chatBox    chatBox
 *  @param fromStatus 起始状态
 *  @param toStatus   目的状态
 */
- (void)chatBox:(MMChatBox *)chatBox changeStatusForm:(MMChatBoxStatus)fromStatus to:(MMChatBoxStatus)toStatus
{
    if (toStatus == MMChatBoxStatusShowKeyboard) {  // 显示键盘
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.chatBoxFaceView removeFromSuperview];
            [self.chatBoxMoreView removeFromSuperview];
        });
        return;
    } else if (toStatus == MMChatBoxStatusShowVoice) {    // 语音输入按钮
        [UIView animateWithDuration:0.3 animations:^{
            if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
                [_delegate chatBoxViewController:self didChangeChatBoxHeight:HEIGHT_TABBAR];
            }
        } completion:^(BOOL finished) {
            [self.chatBoxFaceView removeFromSuperview];
            [self.chatBoxMoreView removeFromSuperview];
        }];
    } else if (toStatus == MMChatBoxStatusShowFace) {     // 表情面板
        if (fromStatus == MMChatBoxStatusShowVoice || fromStatus == MMChatBoxStatusNothing) {
            self.chatBoxFaceView.y = HEIGHT_TABBAR;
            [self.view addSubview:self.chatBoxFaceView];
            [UIView animateWithDuration:0.3 animations:^{
                if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
                    [_delegate chatBoxViewController:self didChangeChatBoxHeight:HEIGHT_TABBAR + HEIGHT_CHATBOXVIEW];
                }
            }];
        } else {  // 表情高度变化
            self.chatBoxFaceView.y = HEIGHT_TABBAR + HEIGHT_CHATBOXVIEW;
            [self.view addSubview:self.chatBoxFaceView];
            [UIView animateWithDuration:0.3 animations:^{
                self.chatBoxFaceView.y = HEIGHT_TABBAR;
            } completion:^(BOOL finished) {
                [self.chatBoxMoreView removeFromSuperview];
            }];
            if (fromStatus != MMChatBoxStatusShowMore) {
                [UIView animateWithDuration:0.2 animations:^{
                    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
                        [_delegate chatBoxViewController:self didChangeChatBoxHeight:HEIGHT_TABBAR + HEIGHT_CHATBOXVIEW];
                    }
                }];
            }
        }
    } else if (toStatus == MMChatBoxStatusShowMore) {
        if (fromStatus == MMChatBoxStatusShowVoice || fromStatus == MMChatBoxStatusNothing) {
            self.chatBoxMoreView.y = HEIGHT_TABBAR;
            [self.view addSubview:self.chatBoxMoreView];
            [UIView animateWithDuration:0.3 animations:^{
                if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
                    [_delegate chatBoxViewController:self didChangeChatBoxHeight:HEIGHT_TABBAR + HEIGHT_CHATBOXVIEW];
                }
            }];
        } else {
            self.chatBoxMoreView.y = HEIGHT_TABBAR + HEIGHT_CHATBOXVIEW;
            [self.view addSubview:self.chatBoxMoreView];
            [UIView animateWithDuration:0.3 animations:^{
                self.chatBoxMoreView.y = HEIGHT_TABBAR;
            } completion:^(BOOL finished) {
                [self.chatBoxFaceView removeFromSuperview];
            }];
            
            [UIView animateWithDuration:0.2 animations:^{
                if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
                    [_delegate chatBoxViewController:self didChangeChatBoxHeight:HEIGHT_TABBAR + HEIGHT_CHATBOXVIEW];
                }
            }];
        }
    }
    
}
- (void)chatBox:(MMChatBox *)chatBox sendTextMessage:(NSString *)textMessage
{
    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:sendTextMessage:)]) {
        [_delegate chatBoxViewController:self sendTextMessage:textMessage];
    }
}
/**
 *  输入框高度改变
 *
 *  @param chatBox chatBox
 *  @param height  height
 */
- (void)chatBox:(MMChatBox *)chatBox changeChatBoxHeight:(CGFloat)height
{
    self.chatBoxFaceView.y = height;
    self.chatBoxMoreView.y = height;
    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
        float h = (self.chatBox.status == MMChatBoxStatusShowFace ? HEIGHT_CHATBOXVIEW : self.keyboardFrame.size.height ) + height;
        [_delegate chatBoxViewController:self didChangeChatBoxHeight: h];
    }
    
}
- (void)chatBoxDidStartRecordingVoice:(MMChatBox *)chatBox
{
    self.recordName = [self currentRecordFileName];
    [[MMRecordManager shareManager] startRecordingWithFileName:self.recordName completion:^(NSError *error) {
        if (error) {   // 加了录音权限的判断
        } else {
            if ([_delegate respondsToSelector:@selector(voiceDidStartRecording)]) {
                [_delegate voiceDidStartRecording];
            }
        }
    }];
}
- (void)chatBoxDidStopRecordingVoice:(MMChatBox *)chatBox
{
    __weak typeof(self) weakSelf = self;
    [[MMRecordManager shareManager] stopRecordingWithCompletion:^(NSString *recordPath) {
        if ([recordPath isEqualToString:shortRecord]) {
            if ([_delegate respondsToSelector:@selector(voiceRecordSoShort)]) {
                [_delegate voiceRecordSoShort];
            }
            [[MMRecordManager shareManager] removeCurrentRecordFile:weakSelf.recordName];
        } else {    // send voice message
            if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:sendVoiceMessage:)]) {
                [_delegate chatBoxViewController:weakSelf sendVoiceMessage:recordPath];
            }
        }
    }];
}
- (void)chatBoxDidCancelRecordingVoice:(MMChatBox *)chatBox
{
    if ([_delegate respondsToSelector:@selector(voiceDidCancelRecording)]) {
        [_delegate voiceDidCancelRecording];
    }
    [[MMRecordManager shareManager] removeCurrentRecordFile:self.recordName];
}
- (void)chatBoxDidDrag:(BOOL)inside
{
    if ([_delegate respondsToSelector:@selector(voiceWillDragout:)]) {
        [_delegate voiceWillDragout:inside];
    }
}
#pragma mark - MMDocumentDelegate
- (void)selectedFileName:(NSString *)fileName
{
    if ([self.delegate respondsToSelector:@selector(chatBoxViewController:sendFileMessage:)]) {
        [self.delegate chatBoxViewController:self sendFileMessage:fileName];
    }
}
- (NSString*)parseRoom:(NSString*)room {
    if (!room.length) {
        [MMProgressHUD showHUD:@"Missing room name."];
        return nil;
    }
    // Trim whitespaces.
    NSCharacterSet* whitespaceSet = [NSCharacterSet whitespaceCharacterSet];
    NSString* trimmedRoom =
    [room stringByTrimmingCharactersInSet:whitespaceSet];
    
    // Check that room name is valid.
    NSError* error = nil;
    NSRegularExpressionOptions options = NSRegularExpressionCaseInsensitive;
    NSRegularExpression* regex =
    [NSRegularExpression regularExpressionWithPattern:@"\\w+"
                                              options:options
                                                error:&error];
    if (error) {
        [MMProgressHUD showHUD:error.localizedDescription];
        return nil;
    }
    NSRange matchRange =
    [regex rangeOfFirstMatchInString:trimmedRoom
                             options:0
                               range:NSMakeRange(0, trimmedRoom.length)];
    if (matchRange.location == NSNotFound ||
        matchRange.length != trimmedRoom.length) {
        [MMProgressHUD showHUD:@"Invalid room name."];
        return nil;
    }
    return trimmedRoom;
}
#pragma mark - XMLocationViewControllerDelegate
- (UIViewController *)rootViewController
{
    return [[UIApplication sharedApplication] keyWindow].rootViewController;
}
- (void)cancelLocation
{
    [self.rootViewController dismissViewControllerAnimated:YES completion:nil];
}
/**发送文职*/
- (void)sendLocation:(CLPlacemark *)placemark
{
    [self cancelLocation];
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBoxViewController:sendLocation:locationText:)])
    {
        [self.delegate chatBoxViewController:self sendLocation:placemark.location.coordinate locationText:placemark.name];
    }
}
-(ZWChartViewModel *)ViewMOdel{
    if (_ViewMOdel == nil) {
        _ViewMOdel = [[ZWChartViewModel alloc]init];
    }
    return _ViewMOdel;
}
@end

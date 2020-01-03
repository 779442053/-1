//
//  MMChatViewController.m
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMChatViewController.h"
#import "MMChatHearder.h"
#import "GlobalVariable.h"
#import <AVFoundation/AVFoundation.h> // 基于AVFoundation,通过实例化的控制器来设置player属性
#import <AVKit/AVKit.h>  // 1. 导入头文件  iOS 9 新增
//ViewController
#import "FriendInfoViewController.h"
#import "MMGroupDetailViewController.h"
#import "MMFileScanController.h"
//个人资料
#import "MMProfileViewController.h"
#import "BaseUIView.h"
//转发
#import "MMForwardViewController.h"
#import "MMContactsViewController.h"
#import "ZWMapLocationViewController.h"

#import "ZWChartViewModel.h"
static const CGFloat section_header_h = 60;

@interface MMChatViewController ()<MMChatBoxViewControllerDelegate,UITableViewDelegate,UITableViewDataSource,MMRecordManagerDelegate,BaseCellDelegate,MMChatManager,MMGroupDetailViewControllerDelegate,MMFAnyDataDelegate>
{
    CGRect _smallRect;
    CGRect _bigRect;
    UIMenuItem * _copyMenuItem;
    UIMenuItem * _deleteMenuItem;
    UIMenuItem * _forwardMenuItem;
    UIMenuItem * _recallMenuItem;
    UIMenuItem * _moreMenuItem;
    NSIndexPath *_longIndexPath;
}
@property (nonatomic, strong) MMChatBoxViewController *chatBoxVC;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITextView *textView;
/** 数据源 */
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger netCurrentPage;
@property (nonatomic, assign) BOOL loadAllMessage;
@property (nonatomic, strong) ZWChartViewModel *ViewModel;
/** 是否第一个加载*/
@property (nonatomic, assign) BOOL isFirstLoad;
@property (nonatomic, assign) BOOL isServer;
@property (nonatomic, assign) BOOL isAlreadyLoad;

/** voice path */
@property (nonatomic, copy) NSString *voicePath;

@property (nonatomic, strong) UIImageView *currentVoiceIcon;
@property (nonatomic, strong) UIImageView *presentImageView;

/** 是否model出控制器*/
@property (nonatomic, assign)  BOOL presentFlag;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) MMVoiceHud *voiceHud;

/** 是否是群聊*/
@property (nonatomic, assign) BOOL isGroup;

/** (群聊)背景 */
@property (nonatomic, strong) UIImageView *conversationBg;

/////////////////////////////////////////////////////////
@property (nonatomic, strong) UIView *sectionHeader;
@property (nonatomic, strong) UILabel *labSectionTime;

@end


@implementation MMChatViewController
- (instancetype)initWithCoversationModel:(MMConversationModel *)aConversationModel
{
    self = [super init];
    if (self) {
        _conversationModel = aConversationModel;
        _currentPage = 0;
        _netCurrentPage = 1;//第一页1
        _isFirstLoad = YES;
        _isAlreadyLoad = YES;
        self.isGroup = aConversationModel.isGroup;
    }
    return self;
}
- (void)setIsGroup:(BOOL)isGroup
{
    _isGroup = isGroup;
    ZWWLog(@"是不是群聊==%d",isGroup)
    //[self setTitle:[_conversationModel getTitle]];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [MMClient sharedClient].chattingConversation = self;
    [[MMClient sharedClient] addDelegate:self];
    [self setupUI];
    [self registerCell];
    [self.tableView.mj_header beginRefreshing];
    [self updateUnreadMessageRedIconForListAndDB];
    [self registerNotific];
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"chat_info_icon"] forState:UIControlStateNormal];
    rightBtn.frame = CGRectMake(KScreenWidth - 20 - 20, ZWStatusBarHeight + 10, 20, 20);
    [self.navigationView addSubview:rightBtn];
    [[rightBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [self rightBarButtonClicked];
    }];
    //进到当前界面,先获取当前用户是否给我发送了消息.获取离线用户消息.或者群消息
}
// 更新消息列表未读消息数量, 更新数据库
- (void)updateUnreadMessageRedIconForListAndDB
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[MMClient sharedClient].chatListViewC updateRedPointForUnreadWithConveration:_conversationModel.toUid];
        [[MMChatDBManager shareManager] updateUnreadCountOfConversation:_conversationModel.toUid unreadCount:0];
    });
}
- (void)setupUI
{
    NSString *title = [_conversationModel getTitle];
    [self setTitle:title];
    [self showLeftBackButton];
    [MMManagerGlobeUntil sharedManager].toUid = _conversationModel.toUid;
    [MMManagerGlobeUntil sharedManager].userName = [_conversationModel getTitle];
    self.view.backgroundColor = MMColor(240, 237, 237);
    // 注意添加顺序
    [self addChildViewController:self.chatBoxVC];
    [self.view addSubview:self.conversationBg];
    [self.view addSubview:self.chatBoxVC.view];
    [self.view addSubview:self.tableView];
    //MARK:下拉刷新
    WEAKSELF
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadDataSource];
    }];
}
//注册cell
- (void)registerCell
{
    [self.tableView registerClass:[MMChatMessageTextCell class] forCellReuseIdentifier:TypeText];
    [self.tableView registerClass:[MMChatMessageImageCell class] forCellReuseIdentifier:TypePic];
    [self.tableView registerClass:[MMChatMessageVideoCell class] forCellReuseIdentifier:TypeVideo];
    [self.tableView registerClass:[MMChatMessageVoiceCell class] forCellReuseIdentifier:TypeVoice];
    [self.tableView registerClass:[MMChatMessageFileCell class] forCellReuseIdentifier:TypeFile];
    /** 联系人 */
    [self.tableView registerClass:[MMChatLinkManCell class] forCellReuseIdentifier:TypeLinkMan];
    //系统消息, 文字 在中间展示.文字,撤回消息等等
    [self.tableView registerClass:[MMChatSystemCell class] forCellReuseIdentifier:TypeSystem];
    //定位
    [self.tableView registerClass:[ZWChatLocationMessageCell class] forCellReuseIdentifier:TypeLocation];
    
}
// 加载数据
- (void)loadDataSource
{
    MMLog(@"开始加载数据");
    if (self.loadAllMessage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView.mj_header endRefreshing];
        });
        return;
    }
    //1.限制为10条先去本地数据库取数据
    NSInteger limit = 10;
    __block NSArray *dataArray;
    if (!_isServer) {
        MMLog(@"在本地数据里取");
        dataArray = [[MMChatDBManager shareManager]
                     queryMessagesWithUser:_conversationModel.toUid
                     limit:limit
                     page:_currentPage];
        
        _isAlreadyLoad = NO;
    }
    //1.1如果本地没有则去从历史记录取
    if (!dataArray.count && !_isAlreadyLoad) {
        MMLog(@"在服务器上取");
        _isServer = YES;
        [self loadHisMessage:limit];
    }
    else{
        _currentPage ++;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView.mj_header endRefreshing];
    });
    [self.dataSource insertObjects:dataArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, dataArray.count)]];
    [self.tableView reloadData];
    if (_isFirstLoad && self.dataSource.count) {
        //tableView还没刷新完就开始调用滚到到底部的方法，所以可以利用伪延迟来进行处理
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if ([self.dataSource count] > 1){
                // 动画之前先滚动到倒数第二个消息
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.dataSource count] - 2 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }
            
            NSIndexPath* path = [NSIndexPath indexPathForRow:[self.dataSource count] - 1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
        _isFirstLoad = NO;
    }
    
}

//在网上取历史数据
- (void)loadHisMessage:(NSInteger)limit
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *startDateStr = @"";
    NSString *endDateStr = @"";
    if (self.dataSource.count) {
        MMMessageFrame *modelFrame = [self.dataSource firstObject];
        NSDate *date = [MMDateHelper dateWithTimeIntervalInMilliSecondSince1970:modelFrame.aMessage.timestamp];
        endDateStr = [dateFormatter stringFromDate:date];
        startDateStr = [MMDateHelper getExpectTimestamp:-1 month:0 day:0 date:date];
    }
    else{
        NSDate *date = [NSDate date];
        endDateStr = [dateFormatter stringFromDate:date];
        startDateStr = [MMDateHelper getExpectTimestamp:-1 month:0 day:0 date:date];//取过去一年的时间
    }
    
    MMLog(@"startDateStr:%@,endDateStr:%@",startDateStr,endDateStr);
    
    if (self.isGroup) {
        NSMutableDictionary *dicParams = [NSMutableDictionary
        dictionaryWithDictionary:@{
                                   @"groupid":_conversationModel.toUid,
                                   @"startime":startDateStr,
                                   @"endtime":endDateStr,
                                   @"page":@(_netCurrentPage).description,
                                   @"perpage":@(limit).description
                                   }];
        [[self.ViewModel.GetGroupChartLishDataCommand execute:dicParams] subscribeNext:^(id  _Nullable x) {
            if ([x[@"code"] intValue] == 0) {
                NSArray *arr = x[@"res"];
                if (arr.count < limit) {
                    self.loadAllMessage = YES;
                    MMLog(@"我没有数据不再加载了");
                    return ;
                }
                _netCurrentPage += limit;
                MMLog(@"继续加载数据");
            }
        }];
    }
    else{
        NSMutableDictionary *dicParams = [NSMutableDictionary
        dictionaryWithDictionary:@{
                                   @"toid":_conversationModel.toUid,
                                   @"startime":startDateStr,
                                   @"endtime":endDateStr,
                                   @"page":@(_netCurrentPage).description,
                                   @"perpage":@(limit).description,
                                   @"userid":[ZWUserModel currentUser].userId
                                   }];
        [[self.ViewModel.GetChartLishDataCommand execute:dicParams] subscribeNext:^(id  _Nullable x) {
            if ([x[@"code"] intValue]) {
                ZWWLog(@"=%@",x)
                NSArray *arr = x[@"res"];
                if (arr.count+1 < limit) {
                  self.loadAllMessage = YES;
                  MMLog(@"我没有数据不再加载了");
                  return ;
                }else{
                    _netCurrentPage += limit;
                }
                
            }
        }];
    }
}
//MARK: - 右上角菜单
- (void)rightBarButtonClicked
{
    //MARK:个人信息
    if ([_conversationModel.cmd isEqualToString:@"sendMsg"]) {
        FriendInfoViewController *friend = [[FriendInfoViewController alloc] init];
        friend.userId = _conversationModel.toUid;
        friend.isFriend = NO;
        //存在于通讯录即为好友
        NSArray *arrTemp = [MMContactsViewController shareInstance].arrData;
        if(arrTemp){
            for (id tempMode in arrTemp) {
                if (![tempMode isKindOfClass:[ContactsModel class]]) {
                    continue;
                }
                ContactsModel *model = (ContactsModel *)tempMode;
                if ([model.userId isEqualToString:_conversationModel.toUid]) {
                    friend.isFriend = YES;
                    break;
                }
            }
        }
        [self.navigationController pushViewController:friend animated:YES];
    }
    //MARK:群信息
    else{
        MMGroupDetailViewController *detail = [[MMGroupDetailViewController alloc]init];
        detail.mode = _conversationModel.mode;
        detail.time = _conversationModel.time;
        detail.creatorId = _conversationModel.creatorId;
        detail.groupId = _conversationModel.toUid;
        detail.name = _conversationModel.toUserName;
        detail.notify = _conversationModel.notify;
        detail.delegate = (id<MMGroupDetailViewControllerDelegate>)self;
        [self.navigationController pushViewController:detail animated:YES];
    }
}
//MARK: - 设置日期时间
-(void)updateTimeAndDate:(MMMessageFrame *_Nullable)modelFrame{
    if (modelFrame && modelFrame.aMessage) {
        long long dateTime = modelFrame.aMessage.timestamp;
        if (!dateTime) {
            dateTime = modelFrame.aMessage.localtime;
        }
        self.labSectionTime.text = [YHUtils formatDateToString:dateTime
                                                    WithFormat:@"MM月dd日"];
    }
}
//MARK: - MMGroupDetailViewControllerDelegate(群聊背景设置成功回调)
-(void)mmGroupDetailsSetBackgroundSuccess:(NSString *)strUrl
                                 andImage:(UIImage *)img{
    self.conversationBg.image = img;
    self.tableView.backgroundColor = [UIColor clearColor];
}
//MARK: - 通知注册
- (void)registerNotific
{
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondsToNotification:) name:@"MESSAGEFETCH" object:nil];
}

- (void)respondsToNotification:(NSNotification *)noti
{
    id obj = noti.object;
    NSDictionary *dic = noti.userInfo;
    NSLog(@"\n- self:%@ \n- obj:%@ \n- notificationInfo:%@", self, obj, dic);
    
}
- (void)dealloc
{
    [[MMClient sharedClient] removeDelegate:self];
    // 关闭时向消息列表添加当前会话(更新会话列表UI)
    [self addCurrentConversationToChatList];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - UITableViewDelegate&UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataSource && [self.dataSource count] > 0)
        return self.dataSource.count;
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.dataSource && [self.dataSource count] > 0)
       return section_header_h;
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.dataSource && [self.dataSource count] > 0)
         return self.sectionHeader;
    return nil;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MMChatMessageBaseCell *cell;
    if (self.dataSource && [self.dataSource count] > indexPath.row) {
        id obj = self.dataSource[indexPath.row];
        MMMessageFrame *modelFrame     = (MMMessageFrame *)obj;
        NSString *strType              = modelFrame.aMessage.slice.type;
        [self updateTimeAndDate:modelFrame];
        //这里做系统提示:如,xx进群,加xx为好友 可以聊天
        if ([strType isEqualToString:TypeSystem]) {
            MMChatSystemCell *cell = [MMChatSystemCell cellWithTableView:tableView reusableId:strType];
            cell.messageF = modelFrame;
            return cell;
        }
        cell = [tableView dequeueReusableCellWithIdentifier:strType];
        if ([cell isKindOfClass:[MMChatLinkManCell class]]) {
            WEAKSELF
            ((MMChatLinkManCell *)cell).cellUserClick = ^(NSString * _Nonnull strUserId) {
                [weakSelf headImageClicked:strUserId];
            };
        }else if ([cell isKindOfClass:[ZWChatLocationMessageCell class]]){
            WEAKSELF
            ((ZWChatLocationMessageCell *)cell).AddeesscellUserClick = ^(NSString * _Nonnull address, float jingdu, float weidu) {
                [weakSelf clickLocationCellWithJingdu:jingdu Weidu:weidu Address:address];
            };
        }
        cell.longPressDelegate         = self;
        cell.modelFrame                = modelFrame;
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MMMessageFrame *messageF = [self.dataSource objectAtIndex:indexPath.row];
    return messageF.cellHight;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.chatBoxVC resignFirstResponder];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.chatBoxVC resignFirstResponder];
}
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([cell isKindOfClass:[MMChatMessageVideoCell class]] && self) {
        MMChatMessageVideoCell *videoCell = (MMChatMessageVideoCell *)cell;
        [videoCell stopVideo];
    }
}
//MARK: - MMChatBoxViewControllerDelegate
- (void) chatBoxViewController:(MMChatBoxViewController *)chatboxViewController
        didChangeChatBoxHeight:(CGFloat)height
{
    ZWWLog(@"键盘发生了变化===%f",height)// 上升了427   下降了49
    self.tableView.height = HEIGHT_SCREEN - height - ZWTabbarSafeBottomMargin - ZWStatusAndNavHeight;
    self.chatBoxVC.view.top = self.tableView.bottom;
    if (height == HEIGHT_TABBAR) {
        ZWWLog(@"键盘回复原样状态")
        [self.tableView reloadData];
        [self scrollToBottom];
        //_isKeyBoardAppear  = NO;
    } else {
         ZWWLog(@"键盘弹出")
        [self scrollToBottom];
        //_isKeyBoardAppear  = YES;
    }
    if (self.textView == nil) {
        self.textView = chatboxViewController.chatBox.textView;
    }
}
- (void)chatBoxViewController:(MMChatBoxViewController *)chatboxViewController didVideoViewAppeared:(MMVideoView *)videoView
{
    [_chatBoxVC.view setFrame:CGRectMake(0,HEIGHT_SCREEN - ZWTabbarSafeBottomMargin - HEIGHT_TABBAR - ZWTabbarHeight,WIDTH_SCREEN, HEIGHT_SCREEN)];
    videoView.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.tableView.height = HEIGHT_SCREEN - videwViewH - 0;
        self.chatBoxVC.view.frame = CGRectMake(0, videwViewX, KScreenWidth, videwViewH);
        [self scrollToBottom];
    } completion:^(BOOL finished) { // 状态改变
        self.chatBoxVC.chatBox.status = MMChatBoxStatusShowVideo;
        // 在这里创建视频设配
        UIView *videoLayerView = [videoView viewWithTag:1000];
        UIView *placeholderView = [videoView viewWithTag:1001];
        [[MMVideoManager shareManager] setVideoPreviewLayer:videoLayerView];
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(videoPreviewLayerWillAppear:) userInfo:placeholderView repeats:NO];
    }];
    
}
//MARK: - 发送联系人=======
- (void) chatBoxViewController:(MMChatBoxViewController *_Nullable)chatboxViewController
            sendLinkmanMessage:(NSString *_Nonnull)strUserId
                   AndUserName:(NSString *_Nonnull)uName
                   AndNickname:(NSString *_Nullable)nName
                      AndPhoto:(NSString *_Nullable)strPurl{
    
    //1.对内容模型赋值
    ZWWLog(@"选择的联系人的用户id = %@",strUserId)
    MMChatContentModel *messageBody = [[MMChatContentModel alloc] init];
    messageBody.type = TypeLinkMan;
    messageBody.userID = strUserId;
    messageBody.userName = uName;
    messageBody.nickName = nName;
    messageBody.photo = strPurl;
    WEAKSELF
    MMMessage *message = [[MMChatHandler shareInstance]
                          sendLinkmanMessageModel:messageBody
                                           toUser:_conversationModel.toUid
                                       toUserName:[_conversationModel getTitle]
                                   toUserPhotoUrl:_conversationModel.photoUrl
                                              cmd:_conversationModel.cmd
                                       completion:^(MMMessage * _Nonnull message) {
                                             //刷新当前发送状态 这里显示的是发送失败或者发送完成状态
                                             [weakSelf updateSendStatusUIWithMessage:message];
                                     }];
    
    //这里先用返回回来的状态 也就是Loading...
    [self clientManager:nil didReceivedMessage:message];
}
- (void) chatBoxViewController:(MMChatBoxViewController *)chatboxViewController
               sendTextMessage:(NSString *)messageStr
{
    if (messageStr && messageStr.length > 0) {
        [self sendTextMessageWithContent:messageStr];
    }
}
- (void)sendTextMessageWithContent:(NSString *)messageStr
{
    WEAKSELF
    MMMessage *message = [[MMChatHandler shareInstance]
                          sendTextMessage:messageStr
                          toUser:_conversationModel.toUid
                          toUserName:[_conversationModel getTitle]
                          toUserPhotoUrl:_conversationModel.photoUrl
                          cmd:_conversationModel.cmd
                          completion:^(MMMessage * _Nonnull message) {
        [weakSelf updateSendStatusUIWithMessage:message];
    }];
    [self clientManager:nil didReceivedMessage:message];
}
-(void)chatBoxViewController:(MMChatBoxViewController *)chatboxViewController sendLocation:(CLLocationCoordinate2D)locationCoordinate locationText:(NSString *)locationText{
    ZWWLog(@"将要发送的位置信息=%f, %f  locationText = %@",locationCoordinate.latitude,locationCoordinate.longitude,locationText)
    if (locationCoordinate.longitude && locationCoordinate.latitude && locationText) {
        //交给MMChatHandler进行s消息处理.
        //封装成消息之后,开始插入本地界面展示发送中的消息
        WEAKSELF
        MMMessage *message = [[MMChatHandler shareInstance]
                              sendLocationMessage:locationCoordinate Address:locationText
                              toUser:_conversationModel.toUid
                              toUserName:[_conversationModel getTitle]
                              toUserPhotoUrl:_conversationModel.photoUrl
                              cmd:_conversationModel.cmd
                              completion:^(MMMessage * _Nonnull message) {
            [weakSelf updateSendStatusUIWithMessage:message];
        }];
        [self clientManager:nil didReceivedMessage:message];
    }
}

//MARK: - 发送图片信息
- (void)chatBoxViewController:(MMChatBoxViewController *)chatboxViewController
             sendImageMessage:(UIImage *)image
                    imagePath:(NSString *)imgPath
{
    if (image && imgPath) {
        [self sendImageMessageWithImgPath:imgPath andImage:image];
    }
}
- (void)sendImageMessageWithImgPath:(NSString *)imgPath andImage:(UIImage *)image
{
    WEAKSELF
    MMMessage *message = [[MMChatHandler shareInstance]
                          sendImgMessage:imgPath
                          imageSize:image.size
                          toUser:_conversationModel.toUid
                          toUserName:[_conversationModel getTitle]
                          toUserPhotoUrl:_conversationModel.photoUrl
                          cmd:_conversationModel.cmd
                          completion:^(MMMessage * _Nonnull message) {
                              [weakSelf updateSendStatusUIWithMessage:message];
                          }];
    
    //这里先用返回回来的状态 也就是Loading...
    [self clientManager:nil didReceivedMessage:message];
}

//MARK: - 发送文件消息
- (void) chatBoxViewController:(MMChatBoxViewController *)chatboxViewController sendFileMessage:(NSString *)fileName
{
    WEAKSELF
    MMMessage *message = [[MMChatHandler shareInstance]
                          sendFileMessage:fileName
                                   toUser:_conversationModel.toUid
                               toUserName:[_conversationModel getTitle]
                          toUserPhotoUrl:_conversationModel.photoUrl
                                      cmd:_conversationModel.cmd
                               completion:^(MMMessage * _Nonnull message) {
                                  //刷新当前发送状态 这里显示的是发送失败或者发送完成状态
                                  [weakSelf updateSendStatusUIWithMessage:message];
                          }];
    
    //这里先用返回回来的状态 也就是Loading...
    [self clientManager:nil didReceivedMessage:message];
}

//MARK: - 发送语音消息
- (void) chatBoxViewController:(MMChatBoxViewController *)chatboxViewController sendVoiceMessage:(NSString *)voicePath
{
    
    [self voiceDidCancelRecording];
    
    //如果voicePath没有内容则返回
    if (!voicePath) {
        return;
    }
    
    WEAKSELF
    MMMessage *message = [[MMChatHandler shareInstance]
                          sendVoiceMessageWithVoicePath:voicePath
                          toUser:_conversationModel.toUid
                          toUserName:[_conversationModel getTitle]
                          toUserPhotoUrl:_conversationModel.photoUrl
                          cmd:_conversationModel.cmd
                          completion:^(MMMessage * _Nonnull message) {
                              message.slice.filePath = voicePath;
                              //刷新当前发送状态 这里显示的是发送失败或者发送完成状态
                              [weakSelf updateSendStatusUIWithMessage:message];
                          }];
    message.slice.filePath = voicePath;
    [self clientManager:nil didReceivedMessage:message];
}


#pragma mark - BaseCellDelegate

- (void)longPress:(UILongPressGestureRecognizer *)longRecognizer
{
    if (longRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint location       = [longRecognizer locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
        _longIndexPath         = indexPath;
        
        if (!self.dataSource || [self.dataSource count] <= indexPath.row) {
            return;
        }
        
        id object              = [self.dataSource objectAtIndex:indexPath.row];
        if (![object isKindOfClass:[MMMessageFrame class]]) return;
        MMChatMessageBaseCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [self showMenuViewController:cell.bubbleView
                        andIndexPath:indexPath
                             message:cell.modelFrame.aMessage];

    }
}
-(void)clickLocationCellWithJingdu:(float)jingdu Weidu:(float)weidu Address:(NSString *)address{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:weidu longitude:jingdu];
    ZWMapLocationViewController *mapView = [[ZWMapLocationViewController alloc]init];
    mapView.location = location;
    [self.navigationController pushViewController:mapView animated:YES];
}

//MARK: - 头像点击
- (void)headImageClicked:(NSString *)eId
{
    NSString *userid = [NSString stringWithFormat:@"%@",[ZWUserModel currentUser].userId];
    if ([ZWUserModel currentUser] && [userid isEqualToString:eId]) {
        MMProfileViewController *profile = [[MMProfileViewController alloc] init];
        [self.navigationController pushViewController:profile animated:YES];
    }
    //MARK:好友
    else{
        FriendInfoViewController *friend = [[FriendInfoViewController alloc] init];
        friend.userId = eId;
        friend.isFriend = NO;
        
        //存在于通讯录即为好友
        NSArray *arrTemp = [MMContactsViewController shareInstance].arrData;
        if(arrTemp){
            for (id tempMode in arrTemp) {
                if (![tempMode isKindOfClass:[ContactsModel class]]) {
                    continue;
                }
                
                ContactsModel *model = (ContactsModel *)tempMode;
                if ([model.userId isEqualToString:eId]) {
                    friend.isFriend = YES;
                    break;
                }
            }
        }
        
        [self.navigationController pushViewController:friend animated:YES];
    }
}
#pragma mark - public method

// 路由响应
- (void)routerEventWithName:(NSString *)eventName
                   userInfo:(NSDictionary *)userInfo
{
    
    MMMessageFrame *modelFrame = [userInfo objectForKey:MessageKey];
    if ([eventName isEqualToString:GXRouterEventTextUrlTapEventName]) {
        
    } else if ([eventName isEqualToString:GXRouterEventImageTapEventName]) {
        
        //点击图片处理
        NSString *imgPath      = modelFrame.aMessage.slice.content;
        if (![imgPath containsString:@"http"]) {
            [[MMImageBrowser sharedBrowser] showImages:@[[NSURL fileURLWithPath:imgPath]] fromController:self];
        }else{
            [[MMImageBrowser sharedBrowser] showImages:@[[NSURL URLWithString:imgPath]] fromController:self];
        }
        
    } else if ([eventName isEqualToString:GXRouterEventVoiceTapEventName]) {
        //点击音频处理
        UIImageView *imageView = (UIImageView *)userInfo[VoiceIcon];
        UIView *redView        = (UIView *)userInfo[RedView];
        [self chatVoiceTaped:modelFrame voiceIcon:imageView redView:redView];
        //文件预览
    } else if ([eventName isEqualToString:GXRouterEventScanFile]){
        NSString *path = (NSString *)userInfo[@"filePath"];
        NSString *pathE = [path pathExtension];
        if ([pathE isEqualToString:@"mp4"]) {
            [self playLocalFilePath:path];
        }else{
            MMFileScanController *scanVC = [[MMFileScanController alloc] init];
            scanVC.filePath              = path;
            scanVC.orgName               = [[path lastPathComponent] stringByDeletingPathExtension];
            [self.navigationController pushViewController:scanVC animated:NO];
        }
    }
}
- (BOOL)canBecomeFirstResponder
{
    return YES;
}
#pragma mark - Video
- (void)playLocalFilePath:(NSString *)filePath
{
    // 1. 创建视频播放控制器
    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
    // 2. 设置视频播放器 (这里为了简便,使用了URL方式,同样支持playerWithPlayerItem:的方式)
    playerViewController.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:filePath]];
    // 3. modal展示
    [self presentViewController:playerViewController animated:YES completion:nil];
    // 4. 开始播放 : 默认不会自动播放
    [playerViewController.player play];
}
#pragma mark - Voice
- (void)voiceDidCancelRecording
{
    [self timerInvalue];
    self.voiceHud.hidden = YES;
}
- (void)voiceDidStartRecording
{
    [self timerInvalue];
    self.voiceHud.hidden = NO;
    [self timer];
}
// 向外或向里移动
- (void)voiceWillDragout:(BOOL)inside
{
    if (inside) {
        [_timer setFireDate:[NSDate distantPast]];
        _voiceHud.image  = [UIImage imageNamed:@"voice_1"];
    } else {
        [_timer setFireDate:[NSDate distantFuture]];
        self.voiceHud.animationImages  = nil;
        self.voiceHud.image = [UIImage imageNamed:@"cancelVoice"];
    }
}

- (void)progressChange
{
    AVAudioRecorder *recorder = [[MMRecordManager shareManager] recorder] ;
    [recorder updateMeters];
    float power= [recorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0,声音越大power绝对值越小
    CGFloat progress = (1.0/160)*(power + 160);
    self.voiceHud.progress = progress;
}

#pragma mark - 音频录音太短取消

- (void)voiceRecordSoShort
{
    [self timerInvalue];
    self.voiceHud.animationImages = nil;
    self.voiceHud.image = [UIImage imageNamed:@"voiceShort"];
    self.voiceHud.hidden = YES;
}
#pragma mark - 语音单机播放
- (void)chatVoiceTaped:(MMMessageFrame *)messageFrame
             voiceIcon:(UIImageView *)voiceIcon
               redView:(UIView *)redView
{
    WEAKSELF
    __block NSString *voicePath;
    // 文件路径
    NSString *tempFilePath = messageFrame.aMessage.slice.filePath;
    NSString *filePath;
    if (tempFilePath.length) {
        filePath = [self mediaPath:messageFrame.aMessage.slice.filePath];
    }
    BOOL isDirExist = [MMFileTool fileExistsAtPath:filePath];
    if (isDirExist) {
        voicePath = filePath;//wav
        [self playFilePath:voicePath andVoiceIcon:voiceIcon];
    }else{
        [[MMApiClient sharedClient] DOWNLOAD:messageFrame.aMessage.slice.content fileDir:kChatRecoderPath progress:nil success:^(NSString * _Nonnull filePath) {
            //删除之前的后缀名并改写成wav格式
            voicePath = [[filePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"wav"];
            if ([VoiceConverter ConvertAmrToWav:filePath wavSavePath:voicePath]) {
                messageFrame.aMessage.slice.filePath = voicePath;
                [[MMChatDBManager shareManager] updateMessage:messageFrame.aMessage];
                [weakSelf playFilePath:voicePath andVoiceIcon:voiceIcon];
            }
            [MMFileTool removeFileAtPath:filePath];
        } failure:^(NSError * _Nonnull error) {
            [MMProgressHUD showHUD:@"播放失败"];
        }];
    }
    if (messageFrame.aMessage.status == 0){
        messageFrame.aMessage.status = 1;
        redView.hidden = YES;
    }
}
- (void)playFilePath:(NSString *)voicePath andVoiceIcon:(UIImageView *)voiceIcon
{
    MMRecordManager *recordManager = [MMRecordManager shareManager];
    recordManager.playDelegate = self;
    if (self.voicePath) {
        if ([self.voicePath isEqualToString:voicePath]) { // the same recoder
            self.voicePath = nil;
            [[MMRecordManager shareManager] stopPlayRecorder:voicePath];
            [voiceIcon stopAnimating];
            self.currentVoiceIcon = nil;
            return;
        } else {
            [self.currentVoiceIcon stopAnimating];
            self.currentVoiceIcon = nil;
        }
    }
    [[MMRecordManager shareManager] startPlayRecorder:voicePath];
    [voiceIcon startAnimating];
    self.voicePath = voicePath;
    self.currentVoiceIcon = voiceIcon;
}
// 移除录视频时的占位图片
- (void)videoPreviewLayerWillAppear:(NSTimer *)timer
{
    UIView *placeholderView = (UIView *)[timer userInfo];
    [placeholderView removeFromSuperview];
}
#pragma mark - MMRecordManagerDelegate
- (void)voiceDidPlayFinished
{
    self.voicePath = nil;
    MMRecordManager *manager = [MMRecordManager shareManager];
    manager.playDelegate = nil;
    [self.currentVoiceIcon stopAnimating];
    self.currentVoiceIcon = nil;
}
#pragma mark - Private
- (void) scrollToBottom
{
    if (self.dataSource.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataSource.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}
- (void)timerInvalue
{
    [_timer invalidate];
    _timer  = nil;
}
// 文件路径
- (NSString *)mediaPath:(NSString *)originPath
{
    // 这里文件路径重新给，根据文件名字来拼接
    NSString *name = [[originPath lastPathComponent] stringByDeletingPathExtension];
    return [[MMRecordManager shareManager] receiveVoicePathWithFileKey:name];
}
//MARK: - 复制删除转发多选
- (void)showMenuViewController:(UIView *)showInView andIndexPath:(NSIndexPath *)indexPath message:(MMMessage *)message
{
    if (_copyMenuItem == nil) {
        _copyMenuItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyMessage:)];
    }
    if (_deleteMenuItem == nil) {
        _deleteMenuItem = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteMessage:)];
    }
    if (_forwardMenuItem == nil) {
        _forwardMenuItem = [[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(forwardMessage:)];
    }
    if (_moreMenuItem == nil) {
        _moreMenuItem = [[UIMenuItem alloc] initWithTitle:@"多选" action:@selector(moreMessage:)];
    }
    NSMutableArray<UIMenuItem *> *_arrMenu = [NSMutableArray arrayWithObjects:_copyMenuItem,_forwardMenuItem,_deleteMenuItem, _moreMenuItem,nil];
    if (message.isSender) {
        NSInteger currentTime = [MMMessageHelper currentMessageTime];
        NSInteger interval    = currentTime - message.localtime;
        //三分钟内可撤回
        if ((interval/1000) <= 3*60 && message.deliveryState == MMMessageDeliveryState_Delivered) {
            if (_recallMenuItem == nil) {
                _recallMenuItem = [[UIMenuItem alloc] initWithTitle:@"撤回" action:@selector(recallMessage:)];
            }
            [_arrMenu addObject:_recallMenuItem];
        }
    }
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuItems:_arrMenu];
    menu.arrowDirection = UIMenuControllerArrowDefault;
    [menu setTargetRect:showInView.frame inView:showInView.superview];
    [menu setMenuVisible:YES animated:YES];
}


//MARK: - 复制
- (void)copyMessage:(UIMenuItem *)copyMenuItem
{
    if (self.dataSource && _longIndexPath && [self.dataSource count] > _longIndexPath.row) {
        UIPasteboard *pasteboard  = [UIPasteboard generalPasteboard];
        MMMessageFrame * messageF = [self.dataSource objectAtIndex:_longIndexPath.row];
        pasteboard.string         = messageF.aMessage.slice.content;
        MMLog(@"消息复制成功");
    }
    else{
        MMLog(@"复制失败");
    }
}
- (void)deleteMessage:(UIMenuItem *)deleteMenuItem
{
    if (self.dataSource && _longIndexPath && [self.dataSource count] > _longIndexPath.row) {
        // 这里还应该把本地的消息附件删除
        MMMessageFrame *messageF = [self.dataSource objectAtIndex:_longIndexPath.row];
        NSDictionary *dicParams = @{
                                    @"cmd":@"delMsgHis",
                                    @"sessionId":[ZWUserModel currentUser] ? [ZWUserModel currentUser].sessionID:@"",
                                    @"msgid":messageF.aMessage.msgID,
                                    @"userid":[ZWUserModel currentUser] ? [ZWUserModel currentUser].userId:@""
                                };
        
        __weak typeof(self) weakSelf = self;
        [[MMApiClient sharedClient] GET:K_APP_REQUEST_API
                             parameters:dicParams
                                success:^(id  _Nonnull responseObject) {
                                    if (responseObject && K_APP_REQUEST_OK(responseObject[K_APP_REQUEST_CODE])) {
                                        
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [weakSelf statusChanged:messageF];
                                            MMLog(@"消息删除成功");
                                        });
                                    }
                                    else{
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [MMProgressHUD showError:responseObject[K_APP_REQUEST_MSG]];
                                        });
                                    }
                                }
                                failure:^(NSError * _Nonnull error) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        MMLog(@"消息删除失败");
                                    });
                                }];
    }
}
// - 消息撤回
- (void)recallMessage:(UIMenuItem *)recallMenuItem
{
    if (self.dataSource && [self.dataSource count] > _longIndexPath.row) {
        MMMessageFrame * messageF = [self.dataSource objectAtIndex:_longIndexPath.row];
        //拿到当前消息id.走tcp 进行消息撤回操作.成功之后.刷新UI即可
        WEAKSELF
        NSString *cmd = @"groupRevokeMsg";
        if (messageF.aMessage.cType != MMConversationType_Group) {
            cmd = @"revokeMsg";
        }
        MMMessage *message = [[MMChatHandler shareInstance] WithdrawMessageWithMessageID:messageF.aMessage cmd:cmd completion:^(MMMessage * _Nonnull message) {
            //此时,已经撤回成功啦.可以展示在界面上面啦
            //保存在本地数据库.
            //服务器成功之后删除本地数据库呗撤回的消息
            //被删除的message
            //MMMessage *delemessage = messageF.aMessage;
            //存储,实在handle 里面
            [weakSelf updateSendStatusUIWithMessage:message];
        }];
        [weakSelf clientManager:nil didReceivedMessage:message];
        //删除本地
        [self.dataSource removeObject:messageF];
        self.textView.text = messageF.aMessage.slice.content;
        //更新UI
        [self.tableView reloadData];
    }
}
- (void)statusChanged:(MMMessageFrame *)messageF
{
    [self.dataSource removeObject:messageF];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[_longIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}
- (void)forwardMessage:(UIMenuItem *)forwardItem
{
    MMForwardViewController *forward = [[MMForwardViewController alloc] init];
    forward.delegate = (id <MMFAnyDataDelegate>) self;
    BaseNavgationController *nav = [[BaseNavgationController alloc] initWithRootViewController:forward];
    [self presentViewController:nav animated:YES completion:nil];
}
- (void)moreMessage:(UIMenuItem *)moreItem
{
    MMLog(@"更多");
    [MMProgressHUD showHUD:@"作为一个预留"];
}


#pragma mark - Getter and Setter

- (MMChatBoxViewController *) chatBoxVC
{
    if (_chatBoxVC == nil) {
        _chatBoxVC = [[MMChatBoxViewController alloc] init];
        [_chatBoxVC.view setFrame:CGRectMake(0,HEIGHT_SCREEN - ZWTabbarSafeBottomMargin - HEIGHT_TABBAR,WIDTH_SCREEN, HEIGHT_SCREEN)];
        _chatBoxVC.delegate = self;
        _chatBoxVC.conversationType = _conversationModel.isGroup?MMConversationType_Group: MMConversationType_Chat;
        if (_conversationModel.mode.checkTextEmpty) {
            NSInteger _model = _conversationModel.mode.integerValue;
            if (_model == 0)
                _chatBoxVC.conversationType = MMConversationType_Group;//群聊
            else if(_model == 10)
                _chatBoxVC.conversationType = MMConversationType_Meet;//会议室
        }
        _chatBoxVC.groupId = _conversationModel.toUid;
        _chatBoxVC.mode = _conversationModel.mode;
        _chatBoxVC.creatorId = _conversationModel.creatorId;
    }
    return _chatBoxVC;
}
#pragma mark - Getter
-(UITableView *)tableView
{
    if (! _tableView) {
        _tableView = [[UITableView alloc]
                      initWithFrame:CGRectMake(0, ZWStatusAndNavHeight, WIDTH_SCREEN, HEIGHT_SCREEN - ZWStatusAndNavHeight  - ZWTabbarHeight)
                      style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = MMColor(240, 237, 237);
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.firstReload = YES;
    }
    return _tableView;
}

-(UIImageView *)conversationBg
{
    if (!_conversationBg) {
        _conversationBg = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _conversationBg.backgroundColor = [UIColor clearColor];
        //图片不变形处理
        [YHUtils imgNoTransformation:_conversationBg];
    }
    return _conversationBg;
}

-(UIView *)sectionHeader
{
    if (!_sectionHeader) {
        _sectionHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, section_header_h)];
        _sectionHeader.backgroundColor = [UIColor clearColor];
        _sectionHeader.alpha = 0.3;
        [_sectionHeader addSubview:self.labSectionTime];
    }
    return _sectionHeader;
}

-(UILabel *)labSectionTime
{
    if (!_labSectionTime) {
        CGFloat h = 22;
        CGFloat w = 80;
        CGFloat y = (section_header_h - h) * 0.5;
        CGFloat x = (SCREEN_WIDTH - w) * 0.5;
        _labSectionTime = [BaseUIView createLable:CGRectMake(x, y, w, h)
                                          AndText:@""
                                     AndTextColor:[UIColor whiteColor]
                                       AndTxtFont:FONT(13)
                               AndBackgroundColor:[UIColor colorWithHexString:@"#A1BDC7"]];
        _labSectionTime.textAlignment = NSTextAlignmentCenter;
        //圆角
        _labSectionTime.layer.cornerRadius = h * 0.5;
        _labSectionTime.layer.masksToBounds = YES;
    }
    return _labSectionTime;
}
- (NSMutableArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
- (UIImageView *)presentImageView
{
    if (!_presentImageView) {
        _presentImageView = [[UIImageView alloc] init];
    }
    return _presentImageView;
}
- (MMVoiceHud *)voiceHud
{
    if (!_voiceHud) {
        _voiceHud = [[MMVoiceHud alloc] initWithFrame:CGRectMake(0, 0, 155, 155)];
        _voiceHud.hidden = YES;
        [self.view addSubview:_voiceHud];
        _voiceHud.center = CGPointMake(KScreenWidth/2, KScreenHeight/2);
    }
    return _voiceHud;
}
- (NSTimer *)timer
{
    if (!_timer) {
        _timer =[NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(progressChange) userInfo:nil repeats:YES];
    }
    return _timer;
}
#pragma mark - MMChatManagerDelegate(收到消息)
- (void)clientManager:(MMClient *)manager didReceivedMessage:(MMMessage *)message
{
    ZWWLog(@"受到一条消息========\n %@",message);
    // 接收的消息
    if (manager) {
        if ([message.fromID isEqualToString:message.toID]) { // 自己发送给自己的消息
            ZWWLog(@"自己跟自己发送消息")
            // 不展示UI
            return;
        }
    }
    NSString * fromID = [NSString stringWithFormat:@"%@",message.fromID];
    NSString * userid = [NSString stringWithFormat:@"%@",[ZWUserModel currentUser].userId];
    NSString * toID = [NSString stringWithFormat:@"%@",message.toID];;
    NSString * toUid = [NSString stringWithFormat:@"%@",self.conversationModel.toUid];
    ZWWLog(@"idididid = fromid = %@  userid= %@ toID= %@  toUid = %@",fromID,userid,toID,toUid)
    if (![fromID isEqualToString:toUid] && ![toID isEqualToString:toUid]) {
        // 不展示UI
        ZWWLog(@"我收到一条不属于当前聊天的消息")
        return;
    }
    MMMessageFrame *mf = [[MMMessageFrame alloc] init];
    mf.aMessage = message;
    ZWWLog(@"是否是历史记录:%d",message.isInsert);
    if (message.isInsert) {
        [self.dataSource insertObject:mf atIndex:0];
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }else{
        [self.dataSource addObject:mf];
        [self.tableView reloadData];
        [self scrollToBottom];
    }
}
#pragma mark - Private
/**
 刷新发送状态
 @param aMessage 消息体
 */
- (void)updateSendStatusUIWithMessage:(MMMessage *)aMessage
{
    //谓词搜索当前message所在的位置
    NSPredicate *pr = [NSPredicate predicateWithFormat:@"aMessage == %@",aMessage];
    NSArray *arrTemp = [_dataSource  filteredArrayUsingPredicate:pr];
    if (!arrTemp.count) {
        return;
    }
    //获取元素的位置
    NSInteger index = [_dataSource indexOfObject:[arrTemp firstObject]];
    if (index >= 0) {
        //根据当前的位置获取Cell
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        MMChatMessageBaseCell *cell =  [_tableView cellForRowAtIndexPath:indexPath];
        [cell updateSendStatus:aMessage.deliveryState];
        if ([aMessage.slice.type isEqualToString:@"file"]) {
            cell.modelFrame = self.dataSource[index];
        }
    }
}
/**
 将当前会话添加到消息列表中
 */
- (void)addCurrentConversationToChatList
{
    if (self.dataSource.count) {
        MMMessageFrame *messageF = [self.dataSource lastObject];
        if (!self.isGroup) {
            messageF.aMessage.toUserName = [_conversationModel getTitle];
            messageF.aMessage.toUserPhoto = _conversationModel.photoUrl;
            messageF.aMessage.type = @"chat";
            messageF.aMessage.conversation = _conversationModel.toUid;
            [[MMChatDBManager shareManager] addOrUpdateConversationWithMessage:messageF.aMessage isChatting:YES];
        }
        NSString * userId = [NSString stringWithFormat:@"%@",[ZWUserModel currentUser].userId];
        NSString * fromID = [NSString stringWithFormat:@"%@",messageF.aMessage.fromID];
        if ([fromID isEqualToString:userId] && !messageF.aMessage.isInsert) {
            // 消息是自己发送的，则更新消息列表最新消息UI
            [[MMClient sharedClient].chatListViewC addOrUpdateConversation:messageF.aMessage.toID latestMessage:messageF isRead:YES];
        }
    }
}

#pragma mark - MMFAnyDataDelegate
- (void)forwardMessageData:(NSMutableArray *)selectData
{
    MMLog(@"转发数据已回传");
}
-(ZWChartViewModel *)ViewModel{
    if (_ViewModel == nil) {
        _ViewModel = [[ZWChartViewModel alloc]init];
    }
    return _ViewModel;
}
@end

/*
 *  Copyright 2016 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "ARDSettingsStore.h"

static NSString *const kVideoResolutionKey = @"rtc_video_resolution_key";
static NSString *const kVideoCodecKey = @"rtc_video_codec_info_key";
static NSString *const kBitrateKey = @"rtc_max_bitrate_key";
static NSString *const kUidKey = @"rtc_uid_key";
static NSString *const kRoomUrlKey = @"rtc_room_url_key";
static NSString *const kRidKey = @"rtc_rid_key";

NS_ASSUME_NONNULL_BEGIN
@interface ARDSettingsStore () {
    NSUserDefaults *_storage;
}
@property(nonatomic, strong, readonly) NSUserDefaults *storage;
@end

@implementation ARDSettingsStore

+ (void)setDefaultsForVideoResolution:(NSString*)videoResolution
                           videoCodec:(NSData*)videoCodec
                              bitrate:(nullable NSNumber*)bitrate
                                  uid:(NSString*)uid
                              roomUrl:(NSString*)roomUrl {
    NSMutableDictionary<NSString *, id> *defaultsDictionary = [@{
                                                                 } mutableCopy];
    
    if (videoResolution) {
        defaultsDictionary[kVideoResolutionKey] = videoResolution;
    }
    if (videoCodec) {
        defaultsDictionary[kVideoCodecKey] = videoCodec;
    }
    if (bitrate) {
        defaultsDictionary[kBitrateKey] = bitrate;
    }
    if (uid) {
        defaultsDictionary[kUidKey] = uid;
    }
    if (roomUrl) {
        defaultsDictionary[kRoomUrlKey] = roomUrl;
    }
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsDictionary];
}

- (NSUserDefaults *)storage {
    if (!_storage) {
        _storage = [NSUserDefaults standardUserDefaults];
    }
    return _storage;
}

- (NSString *)videoResolution {
    return [self.storage objectForKey:kVideoResolutionKey];
}

- (void)setVideoResolution:(NSString *)resolution {
    [self.storage setObject:resolution forKey:kVideoResolutionKey];
    [self.storage synchronize];
}

- (NSData *)videoCodec {
    return [self.storage objectForKey:kVideoCodecKey];
}

- (void)setVideoCodec:(NSData *)videoCodec {
    [self.storage setObject:videoCodec forKey:kVideoCodecKey];
    [self.storage synchronize];
}

- (nullable NSNumber *)maxBitrate {
    return [self.storage objectForKey:kBitrateKey];
}

- (void)setMaxBitrate:(nullable NSNumber *)value {
    [self.storage setObject:value forKey:kBitrateKey];
    [self.storage synchronize];
}

- (NSString*)uid {
    return [self.storage objectForKey:kUidKey];
}

- (void)setUid:(NSString*)uid {
    [self.storage setObject:uid forKey:kUidKey];
    [self.storage synchronize];
}

- (NSString*)roomUrl {
    return [self.storage objectForKey:kRoomUrlKey];
}

- (void)setRoomUrl:(NSString*)roomUrl {
    [self.storage setObject:roomUrl forKey:kRoomUrlKey];
    [self.storage synchronize];
}

- (int)rid {
    return [[self.storage objectForKey:kRidKey] intValue];
}

- (void)setRid:(int)rid {
    [self.storage setObject:@(rid) forKey:kRidKey];
    [self.storage synchronize];
}

@end
NS_ASSUME_NONNULL_END
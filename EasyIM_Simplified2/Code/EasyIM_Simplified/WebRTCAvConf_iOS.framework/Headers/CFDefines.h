//
/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2018 Piasy
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
//


#ifndef CFDefines_h
#define CFDefines_h

#import "ConfConfig.h"
#import "ConfEvents.h"

typedef NS_ENUM(NSInteger, ConfMode) {
    MODE_APPRTC = CFConfConfig_MODE_APPRTC,
    MODE_JANUS_VIDEO_ROOM = CFConfConfig_MODE_JANUS_VIDEO_ROOM,
};

typedef NS_ENUM(NSInteger, ConfError) {
    ERR_INIT_FAIL = CFConfEventsBase_ERR_INIT_FAIL,
    ERR_RS_FAIL = CFConfEventsBase_ERR_RS_FAIL,
    ERR_PC_FAIL = CFConfEventsBase_ERR_PC_FAIL,
    ERR_UNAUTHORIZED = CFConfEventsBase_ERR_UNAUTHORIZED,
    ERR_ROOM_DESTROYED = CFConfEventsBase_ERR_ROOM_DESTROYED,
    ERR_VIDEO_CAPTURER_FAIL = CFConfEventsBase_ERR_VIDEO_CAPTURER_FAIL,
    ERR_DISABLE_BOTH_AUDIO_AND_VIDEO =
        CFConfEventsBase_ERR_DISABLE_BOTH_AUDIO_AND_VIDEO,
    ERR_RETRYING = CFConfEventsBase_ERR_RETRYING,
};

typedef NS_ENUM(NSInteger, VideoRenderScaleType) {
    SCALE_TYPE_CENTER_CROP = CFConfConfig_SCALE_TYPE_CENTER_CROP,
    SCALE_TYPE_CENTER_INSIDE = CFConfConfig_SCALE_TYPE_CENTER_INSIDE,
};

#endif /* CFDefines_h */

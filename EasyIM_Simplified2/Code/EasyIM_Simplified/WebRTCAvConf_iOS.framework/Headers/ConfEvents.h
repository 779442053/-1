//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: jar:file:libs/WebRTCAvConf-sources.jar!com/piasy/avconf/ConfEvents.java
//

#include "J2ObjC_header.h"

#pragma push_macro("INCLUDE_ALL_ConfEvents")
#ifdef RESTRICT_ConfEvents
#define INCLUDE_ALL_ConfEvents 0
#else
#define INCLUDE_ALL_ConfEvents 1
#endif
#undef RESTRICT_ConfEvents

#if !defined (CFConfEvents_) && (INCLUDE_ALL_ConfEvents || defined(INCLUDE_CFConfEvents))
#define CFConfEvents_

#define RESTRICT_ConfEventsBase 1
#define INCLUDE_CFConfEventsBase 1
#include "ConfEventsBase.h"

@interface CFConfEvents : CFConfEventsBase

#pragma mark Public

- (instancetype)init;

- (void)onDestroyed;

- (void)onErrorWithInt:(jint)code
          withNSString:(NSString *)data;

- (void)onPeerJoinedWithNSString:(NSString *)uid;

- (void)onPeerLeftWithNSString:(NSString *)uid;

- (void)onPeerMutedWithNSString:(NSString *)uid
                    withBoolean:(jboolean)muted;

- (void)onPreloadFinished;

- (void)onStreamStartedWithNSString:(NSString *)uid;

@end

J2OBJC_EMPTY_STATIC_INIT(CFConfEvents)

FOUNDATION_EXPORT void CFConfEvents_init(CFConfEvents *self);

J2OBJC_TYPE_LITERAL_HEADER(CFConfEvents)

@compatibility_alias ComPiasyAvconfConfEvents CFConfEvents;

#endif

#pragma pop_macro("INCLUDE_ALL_ConfEvents")

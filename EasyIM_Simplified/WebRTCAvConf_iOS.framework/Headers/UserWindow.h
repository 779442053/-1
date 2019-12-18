//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: jar:file:libs/WebRTCAvConf-sources.jar!com/piasy/avconf/UserWindow.java
//

#include "J2ObjC_header.h"

#pragma push_macro("INCLUDE_ALL_UserWindow")
#ifdef RESTRICT_UserWindow
#define INCLUDE_ALL_UserWindow 0
#else
#define INCLUDE_ALL_UserWindow 1
#endif
#undef RESTRICT_UserWindow

#if !defined (CFUserWindow_) && (INCLUDE_ALL_UserWindow || defined(INCLUDE_CFUserWindow))
#define CFUserWindow_

@interface CFUserWindow : NSObject

#pragma mark Public

- (instancetype)initWithTop:(jint)top
                   withLeft:(jint)left
                  withWidth:(jint)width
                 withHeight:(jint)height
                 withZIndex:(jint)z;

- (instancetype)initWithTop:(jint)top
                   withLeft:(jint)left
                  withWidth:(jint)width
                 withHeight:(jint)height
                 withZIndex:(jint)z
                    withUid:(NSString *)uid;

- (instancetype)initWithTop:(jint)top
                   withLeft:(jint)left
                  withWidth:(jint)width
                 withHeight:(jint)height
                 withZIndex:(jint)z
                    WithRid:(NSString *)rid
                    withUid:(NSString *)uid;

- (void)assignZIndex:(jint)z;

- (void)bindWithRid:(NSString *)rid
             andUid:(NSString *)uid;

- (CFUserWindow *)copy__ OBJC_METHOD_FAMILY_NONE;

- (jint)height;

- (jboolean)isBoundTo:(NSString *)uid;

- (jboolean)isSame:(CFUserWindow *)that;

- (jint)left;

- (NSString *)rid;

- (void)swap:(CFUserWindow *)that;

- (jint)top;

- (NSString *)description;

- (NSString *)uid;

- (void)unbind;

- (void)updateWithTop:(jint)top
             withLeft:(jint)left
            withWidth:(jint)width
           withHeight:(jint)height;

- (jboolean)userPresent;

- (jint)width;

- (jint)zIndex;

#pragma mark Package-Private

- (void)moveWithTop:(jint)top
           withLeft:(jint)left;

// Disallowed inherited constructors, do not use.

- (instancetype)init NS_UNAVAILABLE;

@end

J2OBJC_EMPTY_STATIC_INIT(CFUserWindow)

inline jint CFUserWindow_get_MATCH_PARENT(void);
#define CFUserWindow_MATCH_PARENT -1
J2OBJC_STATIC_FIELD_CONSTANT(CFUserWindow, MATCH_PARENT, jint)

FOUNDATION_EXPORT void CFUserWindow_initWithTop_withLeft_withWidth_withHeight_withZIndex_(CFUserWindow *self, jint top, jint left, jint width, jint height, jint z);

FOUNDATION_EXPORT CFUserWindow *new_CFUserWindow_initWithTop_withLeft_withWidth_withHeight_withZIndex_(jint top, jint left, jint width, jint height, jint z) NS_RETURNS_RETAINED;

FOUNDATION_EXPORT CFUserWindow *create_CFUserWindow_initWithTop_withLeft_withWidth_withHeight_withZIndex_(jint top, jint left, jint width, jint height, jint z);

FOUNDATION_EXPORT void CFUserWindow_initWithTop_withLeft_withWidth_withHeight_withZIndex_withUid_(CFUserWindow *self, jint top, jint left, jint width, jint height, jint z, NSString *uid);

FOUNDATION_EXPORT CFUserWindow *new_CFUserWindow_initWithTop_withLeft_withWidth_withHeight_withZIndex_withUid_(jint top, jint left, jint width, jint height, jint z, NSString *uid) NS_RETURNS_RETAINED;

FOUNDATION_EXPORT CFUserWindow *create_CFUserWindow_initWithTop_withLeft_withWidth_withHeight_withZIndex_withUid_(jint top, jint left, jint width, jint height, jint z, NSString *uid);

FOUNDATION_EXPORT void CFUserWindow_initWithTop_withLeft_withWidth_withHeight_withZIndex_WithRid_withUid_(CFUserWindow *self, jint top, jint left, jint width, jint height, jint z, NSString *rid, NSString *uid);

FOUNDATION_EXPORT CFUserWindow *new_CFUserWindow_initWithTop_withLeft_withWidth_withHeight_withZIndex_WithRid_withUid_(jint top, jint left, jint width, jint height, jint z, NSString *rid, NSString *uid) NS_RETURNS_RETAINED;

FOUNDATION_EXPORT CFUserWindow *create_CFUserWindow_initWithTop_withLeft_withWidth_withHeight_withZIndex_WithRid_withUid_(jint top, jint left, jint width, jint height, jint z, NSString *rid, NSString *uid);

J2OBJC_TYPE_LITERAL_HEADER(CFUserWindow)

@compatibility_alias ComPiasyAvconfUserWindow CFUserWindow;

#endif

#pragma pop_macro("INCLUDE_ALL_UserWindow")
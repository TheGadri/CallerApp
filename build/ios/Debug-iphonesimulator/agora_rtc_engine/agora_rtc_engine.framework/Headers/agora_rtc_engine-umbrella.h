#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AgoraRtcEnginePlugin.h"
#import "AgoraRtcEngineKit.h"

FOUNDATION_EXPORT double agora_rtc_engineVersionNumber;
FOUNDATION_EXPORT const unsigned char agora_rtc_engineVersionString[];


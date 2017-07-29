
//
//  HttpHeader.h
//  LLNetWork
//
//  Created by LLVK on 29/07/2017.
//  Copyright © 2017 devHuang. All rights reserved.
//

#ifndef HttpHeader_h
#define HttpHeader_h

/**
 *  Server
 *
 */
#define SERVER_1

#ifdef SERVER_1
#define BASEURL @"http://apis.baidu.com/tianyiweather/"
#endif

#ifdef SERVER_2
#define BASEURL @""
#endif

#ifdef SSERVER_3
#define BASEURL @""
#endif

/**
 *  AppVersion
 *
 */
#define AppVersion @"1.0"

/**
 *  Source
 *
 */
#define Source @"iOS"

/**
 *  Token
 *
 */
#define Token @"..........."

/**
 *  IMAGEURL
 *
 */
#define IMAGEURL @"http://......"

/**
 *  Handle
 *
 */
#define SHOWNOMOREDATA [MBProgressHUD showInfoMessage:@"已经全部加载完毕"];
#define SHOWERROR [MBProgressHUD showErrorMessage:@"数据请求失败"];

/**
 *  Method
 */

#define AUDIO_WAV     @"audio/wav"
#define IMAGE_JPEG    @"image/png"

/**
 *  CacheName
 */
#define CacheName @"RequestCache"

/**
 *  Debug
 *
 */
#ifdef DEBUG
#   define DLog(fmt, ...) {NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);}
#   define ELog(err) {if(err) DLog(@"%@", err)}
#else
#   define DLog(...)
#   define ELog(err)
#endif

/**
 *  Empty
 *
 */
//字符串是否为空
#define kStringIsEmpty(str) ([str isKindOfClass:[NSNull class]] || str == nil || [str length] < 1 ? YES : NO )
//数组是否为空
#define kArrayIsEmpty(array) (array == nil || [array isKindOfClass:[NSNull class]] || array.count == 0)
//字典是否为空
#define kDictIsEmpty(dic) (dic == nil || [dic isKindOfClass:[NSNull class]] || dic.allKeys == 0)
//是否是空对象
#define kObjectIsEmpty(_object) (_object == nil \
|| [_object isKindOfClass:[NSNull class]] \
|| ([_object respondsToSelector:@selector(length)] && [(NSData *)_object length] == 0) \
|| ([_object respondsToSelector:@selector(count)] && [(NSArray *)_object count] == 0))

#endif /* HttpHeader_h */

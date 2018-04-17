//
//  AMECategoryMaker.h
//  CategoryMaker
//
//  Created by ame on 2018/4/16.
//  Copyright © 2018年 ame017. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XcodeKit/XcodeKit.h>

#define NSLog(FORMAT, ...)                                                        \
fprintf(stderr, "(%s %s)<runClock:%ld> ->\n<%s : %d行> %s方法\n  %s\n -------\n",  \
__DATE__,                                                                         \
__TIME__,                                                                         \
clock(),                                                                          \
[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],        \
__LINE__,                                                                         \
__func__,                                                                         \
[[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String])                   \

typedef NS_ENUM(NSInteger, AMECategoryMakerType) {
    AMECategoryMakerTypeObjc,
    AMECategoryMakerTypeSwift,
    AMECategoryMakerTypeOther
};

@interface AMECategoryMaker : NSObject


@property (nonatomic, strong)XCSourceEditorCommandInvocation *invocation;

+ (instancetype)shardMaker;
- (void)makeCategory:(XCSourceEditorCommandInvocation *)invocation;

@end

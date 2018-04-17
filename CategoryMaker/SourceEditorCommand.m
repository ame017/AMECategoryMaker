//
//  SourceEditorCommand.m
//  CategoryMaker
//
//  Created by ame on 2018/4/16.
//  Copyright © 2018年 ame017. All rights reserved.
//

#import "SourceEditorCommand.h"
#import "AMECategoryMaker.h"

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
    if ([invocation.commandIdentifier hasSuffix:@"SourceEditorCommand"]){
        [[AMECategoryMaker shardMaker]makeCategory:invocation];
    }
    completionHandler(nil);
}

@end

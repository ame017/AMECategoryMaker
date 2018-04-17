//
//  AMECategoryMaker.m
//  CategoryMaker
//
//  Created by ame on 2018/4/16.
//  Copyright © 2018年 ame017. All rights reserved.
//

#import "AMECategoryMaker.h"
#import "NSString+AMECategoryMaker.h"

static AMECategoryMaker * _ame_category_maker;
@implementation AMECategoryMaker

+ (instancetype)shardMaker{
    @synchronized (self) {
        if (!_ame_category_maker) {
            _ame_category_maker = [AMECategoryMaker new];
        }
    }
    return _ame_category_maker;
}
//入口
- (void)makeCategory:(XCSourceEditorCommandInvocation *)invocation{
    self.invocation = invocation;
    [self make];
}

- (NSMutableArray<NSString *> *)selectLinesWithStart:(NSInteger)startLine endLine:(NSInteger)endLine{
    NSMutableArray * selectLines = [NSMutableArray arrayWithCapacity:endLine-startLine];
    for (NSInteger i = startLine; i<=endLine ; i++) {
        [selectLines addObject:self.invocation.buffer.lines[i]];
    }
    return selectLines;
}

- (AMECategoryMakerType)typeJudgeWithString:(NSString *)string{
    //注释 或者Xib 或者不带var property的注释夹层
    if ([string hasSubString:@"//"] || [string hasSubString:@"/*"]|| [string hasSubString:@"*/"] || ([string hasSubString:@"IBOutlet"] && [string hasSubString:@"@"]) || (![string hasSubString:@"@property"] && ![string hasSubString:@"var"])) {
        return AMECategoryMakerTypeOther;
    }
    if ([string hasSubString:@"@property"]) {
        return AMECategoryMakerTypeObjc;
    }
    if([string hasSubString:@"var"]){
        //swift
        return AMECategoryMakerTypeSwift;
    }
    return AMECategoryMakerTypeOther;
}

- (void)make{
    for (XCSourceTextRange *range in self.invocation.buffer.selections) {
        //选中的起始行
        NSInteger startLine = range.start.line;
        //选中的起始列
        NSInteger endLine   = range.end.line;
        
        //遍历获取选中区域 获得选中区域的字符串数组
        NSMutableArray<NSString *> * selectLines = [self selectLinesWithStart:startLine endLine:endLine];
        
        //用一个变量记录空行数
        NSInteger blankLine = 0;
        //按行处理
        for (int i = 0 ; i < selectLines.count ; i++) {
            NSString * string = selectLines[i];
            //排除空字符串
            if(string == nil||[string isEqualToString:@""]){
                continue;
            }
            AMECategoryMakerType type = [self typeJudgeWithString:string];
            //排除注释和xib
            if (type == AMECategoryMakerTypeOther) {
                blankLine++;
                continue;
            }
            
            NSString * key = @"";
            NSString * mothod = @"";
            //objc
            key = [self objc_formatKey:string];
            mothod = [self objc_formatGetterAndSetter:string];

            //找end并写入
            NSInteger implementationEndLine = [self findEndLine:self.invocation.buffer.lines selectionEndLine:endLine];
            if (implementationEndLine <= 1) {
                continue;
            }
            [self.invocation.buffer.lines insertObject:mothod atIndex:implementationEndLine];
            //找key位置并写入
            NSInteger keyLine = [self findKeyLine:self.invocation.buffer.lines selectionEndLine:endLine]+1+i-blankLine;
            if (keyLine <= 1) {
                continue;
            }
            [self.invocation.buffer.lines insertObject:key atIndex:keyLine];
            for (int j = 0; j < self.invocation.buffer.lines.count; j++) {
                if ([self.invocation.buffer.lines[j] isEqualToString:string]) {
                    self.invocation.buffer.lines[j] = [NSString stringWithFormat:@"//%@",string];
                }
            }
        }
    }
}

//输出的字符串_objc
//格式化key
- (NSString *)objc_formatKey:(NSString *)sourceStr{
    NSString *myResult;
    //@property (nonatomic, strong) NSArray<TJSDestinationModel *> * dataArray
    //类名
    NSString * className = [[sourceStr getStringWithOutSpaceBetweenString1:@")" options1:0 string2:@" " options2:NSBackwardsSearch]stringByReplacingOccurrencesOfString:@"*" withString:@""];
    NSLog(@"className--->%@",className);
    if ([className isEqualToString:@""]) {
        return @"";
    }
    //属性名
    NSString * uName = [[sourceStr getStringWithOutSpaceBetweenString1:className options1:NSBackwardsSearch string2:@";" options2:NSBackwardsSearch]stringByReplacingOccurrencesOfString:@"*" withString:@""];
    if ([uName isEqualToString:@""]) {
        return @"";
    }
    NSLog(@"uName--->%@",uName);
    //static char *view_versionKey = "view_versionKey";
    NSString * line1 = [NSString stringWithFormat:@"static char * %@Key = \"%@Key\";",uName,uName];
    myResult = line1;
    return myResult;
}

- (NSString *)objc_formatGetterAndSetter:(NSString*)sourceStr{
    NSString *myResult;
    //@property (nonatomic, strong) NSArray<TJSDestinationModel *> * dataArray
    //类名
    NSString * className = [[sourceStr getStringWithOutSpaceBetweenString1:@")" options1:0 string2:@" " options2:NSBackwardsSearch]stringByReplacingOccurrencesOfString:@"*" withString:@""];
    NSLog(@"className--->%@",className);
    if ([className isEqualToString:@""]) {
        return @"";
    }
    NSString * childClass = @"";
    if ([className hasSubString:@"<"] && [className hasSubString:@">"]) {
        childClass = [NSString stringWithFormat:@"<%@>",[className getStringWithOutSpaceBetweenString1:@"<" options1:0 string2:@">" options2:NSBackwardsSearch]];
        className = [className stringByReplacingOccurrencesOfString:childClass withString:@""];
        childClass = [childClass stringByReplacingOccurrencesOfString:@"*" withString:@" *"];
    }
    NSLog(@"childClass---->%@",childClass);
    NSLog(@"resetClassName--->%@",className);
    //属性名
    NSString * uName = [[sourceStr getStringWithOutSpaceBetweenString1:className options1:NSBackwardsSearch string2:@";" options2:NSBackwardsSearch]stringByReplacingOccurrencesOfString:@"*" withString:@""];
    if ([uName isEqualToString:@""]) {
        return @"";
    }
    NSLog(@"uName--->%@",uName);
    NSString * upUname = [NSString stringWithFormat:@"%@%@",[[uName substringToIndex:1]uppercaseString],[uName substringFromIndex:1]];
    //_属性名
//    NSString *underLineName=[NSString stringWithFormat:@"_%@",uName];
    NSString *type = @"";
    BOOL isReadOnly = NO;
    
    if ([sourceStr hasSubString:@"nonatomic"] && ([sourceStr hasSubString:@"strong"] || [sourceStr hasSubString:@"retain"])) {
        type = @"OBJC_ASSOCIATION_RETAIN_NONATOMIC";
    }
    if (![sourceStr hasSubString:@"nonatomic"] && ([sourceStr hasSubString:@"strong"] || [sourceStr hasSubString:@"retain"])) {
        type = @"OBJC_ASSOCIATION_RETAIN";
    }
    if ([sourceStr hasSubString:@"nonatomic"] && ([sourceStr hasSubString:@"copy"])) {
        type = @"OBJC_ASSOCIATION_COPY_NONATOMIC";
    }
    if (![sourceStr hasSubString:@"nonatomic"] && ([sourceStr hasSubString:@"copy"])) {
        type = @"OBJC_ASSOCIATION_COPY_NONATOMIC";
    }
    if ([sourceStr hasSubString:@"assign"] || [sourceStr hasSubString:@"weak"]) {
        type = @"OBJC_ASSOCIATION_ASSIGN";
    }
    if ([sourceStr hasSubString:@"readonly"]) {
        isReadOnly = YES;
    }
    
    NSString * line0 = [NSString stringWithFormat:@"\n- (void)set%@:(%@%@%@)%@{",upUname,className,childClass,[type isEqualToString:@"OBJC_ASSOCIATION_ASSIGN"]?@"":@" *",uName];
    NSString * line1 = @"";
    if ([type isEqualToString:@"OBJC_ASSOCIATION_ASSIGN"]) {
        line1 = [NSString stringWithFormat:@"\n    objc_setAssociatedObject(self, %@Key, @(%@), %@);",uName,uName,type];
    }else{
        line1 = [NSString stringWithFormat:@"\n    objc_setAssociatedObject(self, %@Key, %@, %@);",uName,uName,type];
    }
    NSString * line2 = [NSString stringWithFormat:@"\n}\n"];

    NSString * line3 = [NSString stringWithFormat:@"\n- (%@%@%@)%@{",className,childClass,[type isEqualToString:@"OBJC_ASSOCIATION_ASSIGN"]?@"":@" *",uName];
    
    if ([type isEqualToString:@"OBJC_ASSOCIATION_ASSIGN"]) {
        NSString * subMothod = @"";
        if ([className hasSubString:@"int"]||[className hasSubString:@"Integer"]||[className hasSubString:@"long"]||[className hasSubString:@"short"]) {
            subMothod = @"integerValue";
        }
        if ([className hasSubString:@"float"]||[className hasSubString:@"Float"]||[className hasSubString:@"double"]) {
            subMothod = @"doubleValue";
        }
        if ([className hasSubString:@"bool"]||[className hasSubString:@"BOOL"]) {
            subMothod = @"boolValue";
        }
        NSString * line4 = [NSString stringWithFormat:@"\n    return [objc_getAssociatedObject(self, %@Key)%@];",uName,subMothod];
        NSString * line5 = [NSString stringWithFormat:@"\n}"];
        if (isReadOnly) {
            myResult = [NSString stringWithFormat:@"%@%@%@",line3,line4,line5];
        }else{
            myResult = [NSString stringWithFormat:@"%@%@%@%@%@%@",line0,line1,line2,line3,line4,line5];
        }
    }else{
        NSString * line4 = [NSString stringWithFormat:@"\n    if(!objc_getAssociatedObject(self, %@Key)){",uName];
        NSString * line5 = [NSString stringWithFormat:@"\n        %@ *object = [[%@ alloc]init];",className,className];
        NSString * line6 = [NSString stringWithFormat:@"\n        objc_setAssociatedObject(self, %@Key, object, %@);",uName,type];
        NSString * line7 = [NSString stringWithFormat:@"\n    }"];
        NSString * line8 = [NSString stringWithFormat:@"\n    return objc_getAssociatedObject(self, %@Key);",uName];
        NSString * line9 = [NSString stringWithFormat:@"\n}"];
        if (isReadOnly) {
            myResult = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",line3,line4,line5,line6,line7,line8,line9];
        }else{
            myResult = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@",line0,line1,line2,line3,line4,line5,line6,line7,line8,line9];
        }
    }
    NSLog(@"%@",myResult);
    return myResult;
}

- (NSInteger)findEndLine:(NSArray<NSString *> *)lines selectionEndLine:(NSInteger)endLine{
    //找interface确认类名
    NSString * line = @"";
    for (NSInteger i = endLine; i >= 1; i--) {
        if ([lines[i] hasSubString:@"@implementation"]|| [lines[i] hasSubString:@"@interface"]) {
            line = lines[i];
            break;
        }
    }
    NSString * categoryWithSpace = @"";
    categoryWithSpace = [line getStringWithOutSpaceBetweenString1:@"(" string2:@")"];
    NSLog(@"%@",categoryWithSpace);
    //分类名
    NSString * categoryStr = [categoryWithSpace stringByReplacingOccurrencesOfString:@" " withString:@""];
    //根据类名找implementation
    BOOL findMark = NO;
    for (NSInteger i = endLine; i < lines.count; i++) {
        if ([lines[i] hasSubString:@"@implementation"] &&
            [lines[i] hasSubString:categoryStr]) {
            findMark = YES;
            continue;
        }
        if (findMark && [lines[i] hasSubString:@"@end"]) {
            return i;
        }
    }
    if (findMark == NO) {
        for (NSInteger i = endLine; i < lines.count; i++) {
            if ([lines[i] hasSubString:@"@end"]) {
                return i;
            }
        }
    }
    return 0;
}

- (NSInteger)findKeyLine:(NSArray<NSString *> *)lines selectionEndLine:(NSInteger)endLine{
    //找interface确认类名
    for (NSInteger i = endLine; i >= 1; i--) {
        if ([lines[i] hasSubString:@"@implementation"]) {
            return i;
        }else if ([lines[i] hasSubString:@"@interface"]) {
            //如果是interface就获取下分类名 然后向下找implementation 如果找到就返回implementation 否则返回interface
            NSString * categoryWithSpace = @"";
            categoryWithSpace = [lines[i] getStringWithOutSpaceBetweenString1:@"(" string2:@")"];
            NSLog(@"%@",categoryWithSpace);
            //分类名
            NSString * categoryStr = [categoryWithSpace stringByReplacingOccurrencesOfString:@" " withString:@""];
            BOOL findMark = NO;
            for (NSInteger j = endLine; j < lines.count; j++) {
                if ([lines[j] hasSubString:@"@implementation"] &&
                    [lines[j] hasSubString:categoryStr]) {
                    findMark = YES;
                    return j;
                }
            }
            if (findMark == NO) {
                return i;
            }
        }
    }
    return 0;
}

@end

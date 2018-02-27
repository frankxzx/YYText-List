//
//  NSString+list.m
//  YYText+List
//
//  Created by Xuzixiang on 2018/2/27.
//  Copyright © 2018年 frankxzx. All rights reserved.
//

#import "NSString+list.h"

@implementation NSString (list)

-(NSArray <NSValue *>*)paragraphRanges {
    NSMutableArray *ranges = [NSMutableArray array];
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByParagraphs usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        [ranges addObject:[NSValue valueWithRange:substringRange]];
    }];
    return  ranges;
}

@end

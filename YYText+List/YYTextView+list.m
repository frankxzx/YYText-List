//
//  YYTextView+list.m
//  YYText+List
//
//  Created by Xuzixiang on 2018/2/26.
//  Copyright © 2018年 frankxzx. All rights reserved.
//

#import "YYTextView+list.h"
#import <objc/runtime.h>

CGFloat const kNumerListIndent = 15.0f;
CGFloat const kBulletListIndent = 10.0f;
NSString *const YYTextListAttributedName = @"YYTextListAttributed";
NSString *const kBulletString = @"\u2022 ";

@implementation YYTextView (list)

-(void)insertPrefix:(YYTextListType)type {
    if (self.selectedRange.location == NSNotFound) { return; }
    //光标所在的当前段落
    NSRange paragraphRange = [self.attributedText.string paragraphRangeForRange:self.selectedRange];
    NSInteger headOfParagraph = paragraphRange.location;
    NSInteger lastParagrahPrefix = [self lastParagraphPrefix];
    YYTextListPrefixItem *prefixItem = [YYTextListPrefixItem listWithPrefixType:type range:NSMakeRange(headOfParagraph, 0) prefixCount:lastParagrahPrefix+1];
    NSMutableAttributedString *paragraphString = [[NSMutableAttributedString alloc]initWithAttributedString:[self.attributedText attributedSubstringFromRange:paragraphRange]];
    
    //替换前缀
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc]initWithAttributedString:self.attributedText];
    YYTextListPrefixItem *oldPrefixItem = paragraphString.yy_attributes[YYTextListAttributedName];
    if (oldPrefixItem) {
        if (oldPrefixItem.type == type) { return; }
        [text replaceCharactersInRange:NSMakeRange(headOfParagraph, oldPrefixItem.prefix.length) withString:prefixItem.prefix];
    } else {
    //添加前缀
        [text yy_insertString:prefixItem.prefix atIndex:headOfParagraph];
//        [self setSelectedRange:NSMakeRange(headOfParagraph, 0)];
        //记录光标位置
        __block NSInteger lastCurPosition = self.selectedRange.location;
        dispatch_async(dispatch_get_main_queue(), ^{
            lastCurPosition += self.selectedRange.length;
            self.selectedTextRange = [YYTextRange rangeWithRange:NSMakeRange(lastCurPosition, 0)];
//            [self scrollRangeToVisible:selectRange];
        });
    }
    
    text.yy_headIndent = prefixItem.indent;
    self.attributedText = text;
    NSRange newParagraphRange = [self.attributedText.string paragraphRangeForRange:NSMakeRange(headOfParagraph, 0)];
    [text yy_setAttribute:YYTextListAttributedName value:prefixItem range:newParagraphRange];
    self.attributedText = text;
}

-(void)inheritedFormLastParagraph {
    YYTextListType listType = [self lastParagraphListType];
    if (listType != YYTextListNone) {
        [self insertPrefix:listType];
    }
}

-(NSInteger)lastParagraphPrefix {
    //光标所在的当前段落
    NSRange paragraphRange = [self.attributedText.string paragraphRangeForRange:self.selectedRange];
    NSInteger headOfParagraph = paragraphRange.location;
    if (headOfParagraph == 0) { return 0; }
    NSRange lastParagraphRange = [self.attributedText.string paragraphRangeForRange:NSMakeRange(headOfParagraph-1, 0)];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[0-9]+" options:kNilOptions error:nil];
    
    __block NSInteger n = 0;
    [regex enumerateMatchesInString:self.attributedText.string options:kNilOptions range:lastParagraphRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
         NSRange r = result.range;
        if (r.location == lastParagraphRange.location) {
            NSString *prefix = [self.attributedText.string substringWithRange:r];
            if ([prefix integerValue] > 0) {
                n = [prefix integerValue] ;
                * stop = YES;
            }
        }
    }];
    return n;
}

-(YYTextListType)lastParagraphListType {
    //光标所在的当前段落
    NSRange paragraphRange = [self.attributedText.string paragraphRangeForRange:self.selectedRange];
    YYTextListPrefixItem *prefixItem = [self.attributedText yy_attribute:YYTextListAttributedName atIndex:paragraphRange.location+1];
    if (prefixItem) {
        return prefixItem.type;
    }
    return YYTextListNone;
}

@end

@implementation YYTextListPrefixItem

+ (instancetype)listWithPrefixType:(YYTextListType)type range:(NSRange)range prefixCount:(NSInteger)prefixCount {
    YYTextListPrefixItem *one = [self new];
    one.type = type;
    switch (type) {
        case YYTextListBullet:
            return [YYTextListPrefixItem listWithPrefix:kBulletString indent:kBulletListIndent range:range prefixCount:prefixCount];

        case YYTextListNumber:
            return [YYTextListPrefixItem listWithPrefix:[NSString stringWithFormat:@"%ld ", (long)prefixCount] indent:kBulletListIndent range:range prefixCount:prefixCount];
       
        case YYTextListNone:
            return [YYTextListPrefixItem listWithPrefix:@"" indent:0 range:NSMakeRange(NSNotFound, NSNotFound) prefixCount:NSNotFound];
    }
    return one;
}

+ (instancetype)listWithPrefix:(NSString *)prefix indent:(CGFloat)indent range:(NSRange)range prefixCount:(NSInteger)prefixCount {
    YYTextListPrefixItem *one = [self new];
    one.indent = indent;
    one.range = range;
    one.prefix = prefix;
    one.prefixCount = prefixCount;
    return one;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.indent) forKey:@"indent"];
    [aCoder encodeObject:self.prefix forKey:@"prefix"];
    [aCoder encodeObject:[NSValue valueWithRange:self.range] forKey:@"range"];
    [aCoder encodeInteger:self.type forKey:@"type"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    self.indent = ((NSNumber *)[aDecoder decodeObjectForKey:@"indent"]).floatValue;
    self.prefix = [aDecoder decodeObjectForKey:@"prefix"];
    self.range = ((NSValue *)[aDecoder decodeObjectForKey:@"range"]).rangeValue;
    self.type = (YYTextListType)[aDecoder decodeIntegerForKey:@"type"];
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) one = [self.class new];
    one.indent = self.indent;
    one.prefix = self.prefix.copy;
    one.range = self.range;
    one.type = self.type;
    return one;
}

@end

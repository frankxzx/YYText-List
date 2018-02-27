//
//  YYTextView+list.m
//  YYText+List
//
//  Created by Xuzixiang on 2018/2/26.
//  Copyright © 2018年 frankxzx. All rights reserved.
//

#import "YYTextView+list.h"
#import "NSString+list.h"

CGFloat const kNumerListIndent = 15.0f;
CGFloat const kBulletListIndent = 10.0f;
NSString *const YYTextListAttributedName = @"YYTextListAttributed";
NSString *const kBulletString = @"\u2022";

@implementation YYTextView (list)

-(void)insertPrefix:(YYTextListType)type isNewParagraph:(BOOL)isNewParagraph {
    if (self.selectedRange.location == NSNotFound) { return; }
    //光标所在的当前段落
    NSRange paragraphRange = [self.attributedText.string paragraphRangeForRange:self.selectedRange];
    NSInteger headOfParagraph = paragraphRange.location;
    NSInteger lastParagrahPrefix = [self lastParagraphPrefix];
    YYTextListPrefixItem *prefixItem = [YYTextListPrefixItem listWithPrefixType:type range:NSMakeRange(headOfParagraph, 0) prefixCount:lastParagrahPrefix+1];
    NSMutableAttributedString *paragraphString = [[NSMutableAttributedString alloc]initWithAttributedString:[self.attributedText attributedSubstringFromRange:paragraphRange]];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc]initWithAttributedString:self.attributedText];
    YYTextListPrefixItem *oldPrefixItem = paragraphString.yy_attributes[YYTextListAttributedName];
    
    if (isNewParagraph) {
        //换行添加前缀
        [text yy_insertString:prefixItem.prefix atIndex:headOfParagraph];
    } else {
        //替换前缀
        if (oldPrefixItem) {
            if (oldPrefixItem.type == prefixItem.type  &&  prefixItem.type == YYTextListNone ) { return; }
            [text replaceCharactersInRange:NSMakeRange(headOfParagraph, oldPrefixItem.prefix.length) withString:prefixItem.prefix];
        } else {
        //添加前缀
            if (type == YYTextListNone) { return; }
            [text yy_insertString:prefixItem.prefix atIndex:headOfParagraph];
        }
    }
    
    text.yy_headIndent = prefixItem.indent;
    self.attributedText = text;
    NSRange newParagraphRange = [self.attributedText.string paragraphRangeForRange:NSMakeRange(headOfParagraph, 0)];
    [text yy_setAttribute:YYTextListAttributedName value:prefixItem range:newParagraphRange];
    self.attributedText = text;
    //记录光标位置
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger location = newParagraphRange.location + newParagraphRange.length - 1;
        self.selectedTextRange = [YYTextRange rangeWithRange:NSMakeRange(location, 0)];
    });
}

-(void)inheritedFormLastParagraph {
    YYTextListType listType = [self lastParagraphListType];
    if (listType != YYTextListNone) {
        [self insertPrefix:listType isNewParagraph:YES];
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

NS_INLINE BOOL NSContainRange(NSRange range1, NSRange range2) {
    BOOL isInside = NSLocationInRange(range1.location, range2) && NSLocationInRange(NSMaxRange(range1), range2);
    BOOL isEqual = NSEqualRanges(range1, range2);
    return isInside || isEqual;
}

-(YYTextListType)lastParagraphListType {
    
    NSArray *paragraphRanges = [self.attributedText.string paragraphRanges];
    __block NSInteger lastParagraphIdx = 0;
    
    if (NSMaxRange(self.attributedText.yy_rangeOfAll) == NSMaxRange(self.selectedRange)) {
        lastParagraphIdx = paragraphRanges.count - 1;
    } else {
        [paragraphRanges enumerateObjectsUsingBlock:^(NSValue *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange paragraphRange = obj.rangeValue;
            if (paragraphRange.location != NSNotFound) {
                if (NSContainRange(self.selectedRange, paragraphRange)) {
                    lastParagraphIdx = idx-1;
                    *stop = YES;
                }
            }
        }];
    }
    
    //NSInteger idx = lastParagraphIdx - 1 >= 0 ?: 0;
    NSRange lastParagraphRange = [[self.attributedText.string paragraphRanges]objectAtIndex:lastParagraphIdx].rangeValue;
    YYTextListPrefixItem *prefixItem = [self.attributedText yy_attribute:YYTextListAttributedName atIndex:lastParagraphRange.location];
    if (prefixItem) {
        return prefixItem.type;
    }
    return YYTextListNone;
}

@end

@implementation YYTextListPrefixItem

+ (instancetype)listWithPrefixType:(YYTextListType)type range:(NSRange)range prefixCount:(NSInteger)prefixCount {
    YYTextListPrefixItem *one;
    switch (type) {
        case YYTextListBullet:
            one = [YYTextListPrefixItem listWithPrefix:[NSString stringWithFormat:@"%@ ", kBulletString] indent:kBulletListIndent range:range prefixCount:prefixCount];
            break;

        case YYTextListNumber:
            one = [YYTextListPrefixItem listWithPrefix:[NSString stringWithFormat:@"%ld. ", (long)prefixCount] indent:kBulletListIndent range:range prefixCount:prefixCount];
            break;
       
        case YYTextListNone:
            one = [YYTextListPrefixItem listWithPrefix:@"" indent:0 range:NSMakeRange(NSNotFound, NSNotFound) prefixCount:NSNotFound];
            break;
    }
    one.type = type;
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

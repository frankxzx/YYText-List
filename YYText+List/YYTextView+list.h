//
//  YYTextView+list.h
//  YYText+List
//
//  Created by Xuzixiang on 2018/2/26.
//  Copyright © 2018年 frankxzx. All rights reserved.
//

#import <YYText/YYText.h>

extern NSString *const YYTextListAttributedName;

typedef NS_ENUM(NSUInteger, YYTextListType) {
    YYTextListNumber,
    YYTextListBullet,
    YYTextListNone
};

@interface YYTextView (list)

-(void)insertPrefix:(YYTextListType)type isNewParagraph:(BOOL)isNewParagraph;
-(void)inheritedFormLastParagraph;

@end

@interface YYTextListPrefixItem: NSObject <NSCoding, NSCopying>
+ (instancetype)listWithPrefix:(NSString *)prefix indent:(CGFloat)indent range:(NSRange)range prefixCount:(NSInteger)prefixCount;
+ (instancetype)listWithPrefixType:(YYTextListType)type range:(NSRange)range prefixCount:(NSInteger)prefixCount;

@property (nonatomic) YYTextListType type;
@property (nonatomic, copy) NSString *prefix;
@property (nonatomic) NSRange range;
@property (nonatomic) CGFloat indent;
@property (nonatomic) NSInteger prefixCount;

@end

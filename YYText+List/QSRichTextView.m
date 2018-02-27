//
//  QSRichTextView.m
//  YYText+List
//
//  Created by Xuzixiang on 2018/2/27.
//  Copyright © 2018年 frankxzx. All rights reserved.
//

#import "QSRichTextView.h"

@implementation QSRichTextView

-(void)insertText:(NSString *)text {
    [super insertText:text];
    if ([text isEqualToString:@"\n"]) {
        if (self.qs_delegate && [self.qs_delegate respondsToSelector:@selector(qsRichTextViewDidEnterNewLine)]) {
            [self.qs_delegate qsRichTextViewDidEnterNewLine];
        }
    }
}

@end

//
//  QSRichTextView.h
//  YYText+List
//
//  Created by Xuzixiang on 2018/2/27.
//  Copyright © 2018年 frankxzx. All rights reserved.
//

#import <YYText/YYText.h>

@protocol QSRichTextViewDelegate <YYTextViewDelegate>

-(void)qsRichTextViewDidEnterNewLine;

@end

@interface QSRichTextView : YYTextView

@property(nonatomic, weak) id <QSRichTextViewDelegate> qs_delegate;

@end

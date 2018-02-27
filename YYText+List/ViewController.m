//
//  ViewController.m
//  YYText+List
//
//  Created by Xuzixiang on 2018/2/16.
//  Copyright © 2018年 frankxzx. All rights reserved.
//

#import "ViewController.h"
#import "QSRichTextView.h"
#import "YYTextView+list.h"

@interface ViewController () <QSRichTextViewDelegate> {
    QSRichTextView *textView;
    UIButton *dismissButton;
    UIButton *numberButton;
    UIButton *bulletButton;
    UIButton *cancelListButton;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    textView = [QSRichTextView new];
    textView.qs_delegate = self;
    dismissButton = [[UIButton alloc]init];
    [dismissButton setTitle:@"dismiss" forState:UIControlStateNormal];
    [dismissButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [dismissButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    [textView addSubview:dismissButton];
    [self.view addSubview:textView];
    numberButton = [[UIButton alloc]init];
    [numberButton setTitle:@"number" forState:UIControlStateNormal];
    [numberButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [numberButton addTarget:self action:@selector(listNumberAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:numberButton];
    bulletButton = [[UIButton alloc]init];
    [bulletButton setTitle:@"bullet" forState:UIControlStateNormal];
    [bulletButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [bulletButton addTarget:self action:@selector(listBulletAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bulletButton];
    cancelListButton = [[UIButton alloc]init];
    [cancelListButton setTitle:@"cancel" forState:UIControlStateNormal];
    [cancelListButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelListButton addTarget:self action:@selector(listCancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelListButton];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGSize size = [UIScreen mainScreen].bounds.size;
    textView.frame = CGRectMake(0, 20, size.width, size.height - 100);
    bulletButton.frame = CGRectMake(0, size.height - 80, 80, 80);
    numberButton.frame = CGRectMake(80, size.height - 80, 80, 80);
    cancelListButton.frame = CGRectMake(160, size.height - 80, 80, 80);
    dismissButton.frame = CGRectMake(200, 60, 50, 44);
}

- (void)listNumberAction:(id)sender {
    [textView insertPrefix:YYTextListNumber isNewParagraph:NO];
}

- (void)listBulletAction:(id)sender {
    [textView insertPrefix:YYTextListBullet isNewParagraph:NO];
}

- (void)listCancelAction:(id)sender {
    [textView insertPrefix:YYTextListNone isNewParagraph:NO];
}

- (void)dismiss:(id)sender {
    [textView endEditing:YES];
}

-(void)qsRichTextViewDidEnterNewLine {
    [textView inheritedFormLastParagraph];
}

@end

//
//  ViewController.m
//  ChatPerfDemo
//
//  Created by 山谷 明洋 on 2013/02/08.
//  Copyright (c) 2013年 SHIFT INC. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[ChatPerf chatPerf] setDelegate:self];
}
- (void)printLog:(NSObject*)object {
    NSString* origText = [NSString stringWithFormat:@"%@", _textView.text];
    _textView.text = [NSString stringWithFormat:@"%@\n---------------------------------------------\n%@", origText, object];
    NSRange range = NSMakeRange(_textView.text.length - 1, 1);
    [_textView scrollRangeToVisible:range];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)tankIdButton:(id)sender {
    [[ChatPerf chatPerf] requestTankId];
}
- (IBAction)perfButton:(id)sender {
    [[ChatPerf chatPerf] doPerf];
}
- (IBAction)clearButton:(id)sender {
    _textView.text = @"START..";
}
- (void)didPerf {
    [self printLog:@"パフしました。"];
}
- (void)receivedTankId:(NSString *)tankId {
    [self printLog:[NSString stringWithFormat:@"タンクIDは%@です。", tankId]];
}
- (void)accessoryDidConnect {
    [self printLog:@"接続されました。"];
}
- (void)accessoryDidDisconnect {
    [self printLog:@"切断されました。"];
}
@end

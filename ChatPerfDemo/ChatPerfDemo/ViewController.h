//
//  ViewController.h
//  ChatPerfDemo
//
//  Created by 山谷 明洋 on 2013/02/08.
//  Copyright (c) 2013年 SHIFT INC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ChatPerf/ChatPerf.h>

@interface ViewController : UIViewController <ChatPerfDelegate>
- (IBAction)tankIdButton:(id)sender;
- (IBAction)perfButton:(id)sender;
- (IBAction)clearButton:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@end
//
//  ChatPerf.h
//  Sample
//
//  Created by Akihiro Yamaya on 2013/02/08.
//  Copyright 2013 ChatPerf Holdings PTE. LTD.
//  Released under the 3-clause BSD License.
// 

#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>

@protocol ChatPerfDelegate;

extern NSString *ChatPerfSessionDataReceivedNotification;

@interface ChatPerf : NSObject <NSStreamDelegate> {
    NSString *protocolString;
    NSString *tankId;
    EAAccessory *accessory;
    EASession *session;
    NSMutableData *writeData;
    NSMutableData *readData;
}

@property (nonatomic, assign) id<ChatPerfDelegate> delegate;

+ (ChatPerf*)chatPerf;
- (void)requestTankId;
- (void)doPerf;

@end

@protocol ChatPerfDelegate <NSObject>
@optional
-(void)didPerf;
-(void)receivedTankId:(NSString*)tankId;
-(void)accessoryDidConnect;
-(void)accessoryDidDisconnect;
@end
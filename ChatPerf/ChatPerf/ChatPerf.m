//
//  ChatPerf.m
//  Sample
//
//  Created by Akihiro Yamaya on 2013/02/08.
//  Copyright 2013 ChatPerf Holdings PTE. LTD.
//  Released under the 3-clause BSD License.
// 

#import "ChatPerf.h"

#define CHAT_PERF_INPUT_BUFFER_SIZE 128

NSString *ChatPerfSessionDataReceivedNotification = @"ChatPerfSessionDataReceivedNotification";

static ChatPerf *chatPerf = nil;

@implementation ChatPerf

@synthesize delegate;

+ (ChatPerf*)chatPerf {
    if (chatPerf == nil) {
        chatPerf = [[super allocWithZone:NULL] init];
    }
    return chatPerf;
}

- (id)init {
    self = [super init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDidConnect:)
                                                 name:EAAccessoryDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDidDisconnect:)
                                                 name:EAAccessoryDidDisconnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionDataReceived:)
                                                 name:ChatPerfSessionDataReceivedNotification object:nil];
    [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
    NSMutableArray *accessoryList = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
    NSInteger len = [accessoryList count];
    if (len > 0) {
        EAAccessory *connectedAccessory = [accessoryList objectAtIndex:0];
        [self _accessoryDidConnect:connectedAccessory];
    }
    return self;
}
- (void)doPerf {
    [self sendHexWith:@"ff01e8"];
    [self closeSession];
    [delegate didPerf];
    [self openSession];
}
- (void)requestTankId {
    if (tankId == nil) {
        [self sendHexWith:@"ff02"];
    }
    else {
        [delegate receivedTankId:tankId];
        [self closeSession];
        [self openSession];
    }
}
- (void)accessoryDidConnect:(NSNotification *)notification {
    EAAccessory *connectedAccessory = [[notification userInfo] objectForKey:EAAccessoryKey];
    [self _accessoryDidConnect:connectedAccessory];
}
- (void)_accessoryDidConnect:(EAAccessory *)connectedAccessory {
    NSInteger len = [[connectedAccessory protocolStrings] count];
    if (len > 0) {
        protocolString = [[connectedAccessory protocolStrings] objectAtIndex:0];
        tankId = nil;
        accessory = connectedAccessory;
        [self openSession];
        [delegate accessoryDidConnect];
    }
}
- (void)accessoryDidDisconnect:(NSNotification *)notification {
    EAAccessory *disconnectedAccessory = [[notification userInfo] objectForKey:EAAccessoryKey];
    NSInteger len = [[disconnectedAccessory protocolStrings] count];
    if (len > 0) {
        protocolString = nil;
        tankId = nil;
        [self closeSession];
        [delegate accessoryDidDisconnect];
    }
}
- (void)sessionDataReceived:(NSNotification *)notification {
    uint32_t bytesAvailable = 0;
    NSData *data;
    if ((bytesAvailable = [self readBytesAvailable]) > 0) {
        data = [self readData:bytesAvailable];
    }
    NSUInteger len = [data length];
    Byte *byteData = (Byte*)malloc(len);
    memcpy(byteData, [data bytes], len);
    NSString *_tankId = [NSString stringWithFormat:@"%c%c%c", byteData[2], byteData[3], byteData[4]];
    if (tankId == nil) {
        tankId = _tankId;
        [delegate receivedTankId:tankId];
    }
}
- (BOOL)openSession {
    session = [[EASession alloc] initWithAccessory:accessory forProtocol:protocolString];
    if (session) {
        [[session inputStream] setDelegate:self];
        [[session inputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [[session inputStream] open];
        [[session outputStream] setDelegate:self];
        [[session outputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [[session outputStream] open];
    }
    return (session != nil);
}
- (void)closeSession {
    [[session inputStream] close];
    [[session inputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[session inputStream] setDelegate:nil];
    [[session outputStream] close];
    [[session outputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[session outputStream] setDelegate:nil];
    session = nil;
    writeData = nil;
    readData = nil;
}
- (void)writeData:(NSData *)data {
    if (writeData == nil) {
        writeData = [[NSMutableData alloc] init];
    }
    [writeData appendData:data];
    [self _writeData];
}
- (void)_writeData {
    while (([[session outputStream] hasSpaceAvailable]) && ([writeData length] > 0)) {
        NSInteger bytesWritten = [[session outputStream] write:[writeData bytes] maxLength:[writeData length]];
        if (bytesWritten == -1) {
            break;
        }
        else if (bytesWritten > 0) {
            [writeData replaceBytesInRange:NSMakeRange(0, bytesWritten) withBytes:NULL length:0];
        }
    }
}
- (NSUInteger)readBytesAvailable {
    return [readData length];
}
- (NSData *)readData:(NSUInteger)bytesToRead {
    NSData *data = nil;
    if ([readData length] >= bytesToRead) {
        NSRange range = NSMakeRange(0, bytesToRead);
        data = [readData subdataWithRange:range];
        [readData replaceBytesInRange:range withBytes:NULL length:0];
    }
    return data;
}
- (void)_readData {
    uint8_t buf[CHAT_PERF_INPUT_BUFFER_SIZE];
    while ([[session inputStream] hasBytesAvailable]) {
        NSInteger bytesRead = [[session inputStream] read:buf maxLength:CHAT_PERF_INPUT_BUFFER_SIZE];
        if (readData == nil) {
            readData = [[NSMutableData alloc] init];
        }
        [readData appendBytes:(void *)buf length:bytesRead];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:ChatPerfSessionDataReceivedNotification object:self userInfo:nil];
}

- (void)sendHexWith:(NSString*)text {
    const char *buf = [text UTF8String];
    NSMutableData *data = [NSMutableData data];
    if (buf) {
        uint32_t len = strlen(buf);
        char singleNumberString[3] = {'\0', '\0', '\0'};
        uint32_t singleNumber = 0;
        for(uint32_t i = 0 ; i < len; i+=2) {
            if ( ((i+1) < len) && isxdigit(buf[i]) && (isxdigit(buf[i+1])) ) {
                singleNumberString[0] = buf[i];
                singleNumberString[1] = buf[i + 1];
                sscanf(singleNumberString, "%x", &singleNumber);
                uint8_t tmp = (uint8_t)(singleNumber & 0x000000FF);
                [data appendBytes:(void *)(&tmp) length:1];
            }
            else {
                break;
            }
        }
        [self writeData:data];
    }
}
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventNone:
            break;
        case NSStreamEventOpenCompleted:
            break;
        case NSStreamEventHasBytesAvailable:
            [self _readData];
            break;
        case NSStreamEventHasSpaceAvailable:
            [self _writeData];
            break;
        case NSStreamEventErrorOccurred:
            break;
        case NSStreamEventEndEncountered:
            break;
        default:
            break;
    }
}

@end
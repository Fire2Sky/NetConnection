//
//  ViewController.m
//  TCPClient
//
//  Created by 田野 on 14/11/26.
//  Copyright (c) 2014年 Fire2Sky. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//初始化网络的方法
- (void)initNetworkCommunication
{
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"192.168.1.103",PORT, &readStream, &writeStream);
    _inputStream = (_bridge_transfer NSInputStream *)readStream;
    _outputStream = (_bridge_transfer NSOutputStream *)writeStream;
    [_inputStream setDelegate:self];
    [_outputStream setDelegate:self];
    
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [_inputStream open];
    [_outputStream open];
    
}

//单击"发送"按钮
- (IBAction)sendData:(id)sender
{
    flag = 0;
    [self initNetworkCommunication];
    
}


//单击"接受"按钮
- (IBAction)receiveData:(id)sender
{
    flag = 1;
    [self initNetworkCommunication];
    
}

-(void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent
{
    NSString *event;
    switch (streamEvent)
    {
        case NSStreamEventNone: event = @"NSStreamEventNone";
            break;
        case NSStreamEventOpenCompleted: event = @"NSSteamEventOpenCompleted";
            break;
        case NSStreamEventHasBytesAvailable: event = @"NSStreamEventHasBytesAvailable";
            if (flag == 1 && theStream == _inputStream)
            {
                NSMutableData *input = [[NSMutableData alloc] init];
                uint8_t buffer[1024];
                long len;
                while([_inputStream hasBytesAvailable])
                {
                    len = [_inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0)
                    {
                        [input appendBytes:buffer length:len];
                        
                    }
                    
                }
                NSString * resultstring = [[NSString alloc] initWithData: input encoding: NSUTF8StringEncoding];
                NSLog(@"接受: %@", resultstring);
                _message.text = resultstring;
            }
            break;
        case NSStreamEventHasSpaceAvailable: event = @"NSStreamEventHasSpaceAvailable";
            if (flag == 0 && theStream == _outputStream)
            {
                //输出
                UInt8 buff[] = "Hello Server!";
                
                
            }
}

@end

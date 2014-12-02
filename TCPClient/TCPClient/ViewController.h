//
//  ViewController.h
//  TCPClient
//
//  Created by 田野 on 14/11/26.
//  Copyright (c) 2014年 Fire2Sky. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>
#include <sys/socket.h>
#include <netinet/in.h>

#define PORT 9000

@interface ViewController : UIViewController
{
    //操作标志  0 为发送,1 为接受
    int flag;
}
//定义属性输入流,与CFReadStreamRef相对应
@property (nonatomic, retain) NSInputStream * inputStream;
//定义属性输出流,与CFWriteStreamRef相对应
@property (nonatomic, retain) NSOutputStream * outputStream;

@property (weak, nonatomic) IBOutlet UILabel * message;
-(IBAction)sendData:(id)sender;
-(IBAction)receiveData:(id)sender;



@end


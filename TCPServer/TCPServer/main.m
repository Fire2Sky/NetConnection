//
//  main.m
//  TCPServer
//
//  Created by 田野 on 14/11/25.
//  Copyright (c) 2014年 Fire2Sky. All rights reserved.
//
//#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>


#include <sys/socket.h>
#include <netinet/in.h>

#define PORT 9000
//接收客户端请求后回调
void AcceptCallBack (CFSocketRef, CFSocketCallBackType, CFDataRef,const void *, void *);

//客户端读取数据时调用(服务端写入)
void WriteStreamClientCallBack (CFWriteStreamRef stream, CFStreamEventType eventType, void *);

//客户端写入数据时调用(服务端读取)
void ReadStreamClientCallBack (CFReadStreamRef stream, CFStreamEventType eventType, void *);

/*typedef void (* CFSocketCallBack)(
	CFSocketRef s,			//Socket对象
	CFSocketCallBackType,	//Socket回调类型
	CFDataRef address,		//Socket地址
	const void * data,		//如果socket回调类型是kCFSocketAcceptCallBack类型,则data是CFSocketNativeHandle类型的指针
	void *info				//用户传递任何数据的指针
	)
 
 typedef void ()
 */

int main(int argc, const char * argv[]){
    //定义一个Server socket引用
    CFSocketRef sserver;
    
    //创建socket context
    CFSocketContext CTX = {0, NULL, NULL, NULL, NULL};
    
    //创建server socket TCP IPv4设置回调函数
    sserver = CFSocketCreate (NULL, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, (CFSocketCallBack)AcceptCallBack, &CTX);
    if (sserver == NULL)
        return -1;
    
    //设置是否重新绑定标志
    int yes = 1;
    //设置scoket属性 SOL_SOCKET是设置 tcp SO_REUSEADDR重新绑定,yes是否重新绑定
    setsockopt(CFSocketGetNative(sserver), SOL_SOCKET, SO_REUSEADDR, (void *)&yes, sizeof(yes));
    /*设置端口和地址*/
    struct sockaddr_in addr;
    memset(&addr, 0 , sizeof(addr));			//memset函数对指定的地址进行内存复制
    addr.sin_len = sizeof(addr);
    addr.sin_family = AF_INET;					//AF_INET是设置IPV4
    addr.sin_port = htons(PORT);				//honst函数是 无符号短整型转换成"网络字节序"
    addr.sin_addr.s_addr = htonl(INADDR_ANY);	//INADDR_ANY有内核分配. htonl 函数 无符号长整型数转换成"网络字节序"
    
    /*从指定字节缓冲区复制,一个不可变的CFData对象*/
    CFDataRef address = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&addr, sizeof(addr));
    
    //绑定socket
    if (CFSocketSetAddress(sserver, (CFDataRef)address)!= kCFSocketSuccess){
        fprintf(stderr, "Socket 绑定失败\n");
        CFRelease(sserver);
        return -1;
    }
    
    //创建一个Run Loop Socket源
    CFRunLoopSourceRef sourceRef = CFSocketCreateRunLoopSource(kCFAllocatorDefault, sserver, 0);
    
    //socket源添加到Run Loop中
    CFRunLoopAddSource(CFRunLoopGetCurrent(), sourceRef, kCFRunLoopCommonModes);
    CFRelease(sourceRef);
    
    printf("Socket listening on port %d\n", PORT);
    
    //运行Loop
    CFRunLoopRun();
}



//接收客户端的请求后,回调函数
void AcceptCallBack(
                    CFSocketRef socket,
                    CFSocketCallBackType type,
                    CFDataRef address,
                    const void * data,
                    void * info)
{
    CFReadStreamRef readStream = NULL;
    CFWriteStreamRef writeStream = NULL;
    
    //data 参数含义是,如果回调类型是kCFSocketAcceptCallBack,data就是CFSocketNativeHandle类型的指针
    CFSocketNativeHandle sock = *(CFSocketNativeHandle *) data;
    
    //创建读写的socket流
    CFStreamCreatePairWithSocket(kCFAllocatorDefault, sock, &readStream, &writeStream);
    
    if (!readStream || !writeStream) {
        close(sock);
        fprintf(stderr, "CFStreamCreatePairWithSocket() 失败\n");
        return;
    
    }
    
    CFStreamClientContext streamCtxt = {0, NULL, NULL, NULL, NULL};
    //注册两种回调函数
    CFReadStreamSetClient(readStream, kCFStreamEventHasBytesAvailable, ReadStreamClientCallBack, &streamCtxt);
    CFWriteStreamSetClient(writeStream, kCFStreamEventCanAcceptBytes, WriteStreamClientCallBack, &streamCtxt);
    //加入两种循环中
    CFReadStreamScheduleWithRunLoop(readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    CFWriteStreamScheduleWithRunLoop(writeStream, CFRunLoopGetCurrent(),kCFRunLoopCommonModes);
    
    CFReadStreamOpen(readStream);
    CFWriteStreamOpen(writeStream);
    
    
}


//读取流操作 客户端有数据过来时候调用
void ReadStreamClientCallBack(CFReadStreamRef stream, CFStreamEventType eventType, void* clientCallBackInfo){
    UInt8 buff[255];
    CFReadStreamRef inputStream = stream;
    if (NULL != inputStream)
    {
        CFReadStreamRead(stream, buff, 255);
        printf("接受数据:%s\n",buff);
        CFReadStreamClose(inputStream);
        CFReadStreamUnscheduleFromRunLoop(inputStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        inputStream = NULL;
    }
    
}


//写入流操作 客户端在读取数据时调用

void WriteStreamClientCallBack(CFWriteStreamRef stream, CFStreamEventType eventType, void * clientCallBack)
{
    CFWriteStreamRef outputStream = stream;
    //输出
    UInt8 buff[] = "Hello Client!";
    if(NULL != outputStream)
    {
        CFWriteStreamWrite(outputStream, buff, strlen((const char*)buff)+1);
        //关闭输出流
        CFWriteStreamClose(outputStream);
        CFWriteStreamUnscheduleFromRunLoop(outputStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        outputStream = NULL;
        
    }
    
}

//int main(int argc, const char * argv[]) {
//    @autoreleasepool {
//        // insert code here...
//        NSLog(@"Hello, World!");
//    }
//    return 0;
//}
    


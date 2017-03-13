//
//  ViewController.m
//  FMTCPSocketServer
//
//  Created by fm on 2017/3/8.
//  Copyright © 2017年 wangjiuyin. All rights reserved.
//

#import "ViewController.h"
#import "AsyncSocket.h"

@interface ViewController ()<AsyncSocketDelegate>

@property (nonatomic, weak) IBOutlet UILabel *localHostLabel;
@property (nonatomic, weak) IBOutlet UITextField *portTF;
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UITextField *responseTF;

@property (nonatomic, strong) AsyncSocket *tcpSocket;
@property (nonatomic, strong) NSMutableArray *clientSocketArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.portTF.text = @"8888";
}

#pragma mark - Private methods
-(void)addMessage:(NSString *)str
{
    self.textView.text = [self.textView.text stringByAppendingFormat:@"%@\n\n\n",str];
    [self.textView scrollRangeToVisible:[self.textView.text rangeOfString:str options:NSBackwardsSearch]];
}

#pragma mark - Actions
- (IBAction)doMonitor:(UIButton *)sender
{
    NSError *error;
    [self.tcpSocket acceptOnPort:[self.portTF.text intValue] error:&error];
    [self addMessage:@"已监听！。。。。。"];
}

- (IBAction)doResponse:(UIButton *)sender
{
    NSData *data = [self.responseTF.text dataUsingEncoding:NSUTF8StringEncoding];
    [self.tcpSocket writeData:data withTimeout:-1 tag:10];
    for (AsyncSocket *soc in self.clientSocketArr) {
        [soc writeData:data withTimeout:-1 tag:10];
    }
    [self addMessage:[NSString stringWithFormat:@"回复的数据：%@", self.responseTF.text]];
    [self.view endEditing:YES];
}

#pragma mark - AsyncSocketDelegate
- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket {
    
    [self.clientSocketArr addObject:newSocket];
    [newSocket readDataWithTimeout:-1 tag:0];
}
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *readStr = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding];
    NSLog(@"读到的数据：%@",readStr);
    [self addMessage:[NSString stringWithFormat:@"读到的数据：%@ \nhost:%@", readStr, sock.connectedHost]];
//    [sock writeData:[readStr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:101];
    [sock readDataWithTimeout:-1 tag:0];
    
}
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    [self addMessage:[NSString stringWithFormat:@"已连接%@",host]];
    self.localHostLabel.text = [self.localHostLabel.text stringByAppendingString:[sock localHost]];
}
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
    [self addMessage:[NSString stringWithFormat:@"willDisc:%@",sock]];
}
- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
    [self addMessage:[NSString stringWithFormat:@"已断开:%@",sock]];
}
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"sock:%@  %ld",sock,tag);
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - getter & setter
- (AsyncSocket *)tcpSocket
{
    if (!_tcpSocket) {
        _tcpSocket = [[AsyncSocket alloc] initWithDelegate:self];
    }
    return _tcpSocket;
}

- (NSMutableArray *)clientSocketArr
{
    if (!_clientSocketArr) {
        _clientSocketArr = [[NSMutableArray alloc] init];
    }
    return _clientSocketArr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

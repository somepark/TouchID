//
//  TDTouchID.m
//  TDTouchID
//
//  Created by imtudou on 2016/11/19.
//  Copyright © 2016年 TuDou. All rights reserved.
//

#import "TDTouchID.h"
#import "NSString+QDTouchID.h"

@implementation TDTouchID
+ (instancetype)sharedInstance {
    static TDTouchID *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TDTouchID alloc] init];
    });
    return instance;
}

-(void)td_showTouchIDWithDescribe:(NSString *)desc BlockState:(StateBlock)block{
    
    if ([NSString judueIPhonePlatformSupportTouchID])
    {
        [self startTouchIDWithPolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics locaizeFallbackTitle:desc BlockState:block];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"您的设置硬件暂时不支持指纹识别");
            block(TDTouchIDStateNotSupport,nil);
        });
    }
    
}
- (void)startTouchIDWithPolicy:(LAPolicy )policy locaizeFallbackTitle:(NSString *)desc BlockState:(StateBlock)block{
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"系统版本不支持TouchID (必须高于iOS 8.0才能使用)");
            block(TDTouchIDStateVersionNotSupport,nil);
        });
        
        return;
    }
    LAContext *context = [[LAContext alloc]init];
    
    context.localizedFallbackTitle = desc.length>0?desc:@"";
    
    NSError *error = nil;
    
    if ([context canEvaluatePolicy:policy error:&error]) {
        
        [context evaluatePolicy:policy localizedReason:@"通过Home键验证已有指纹" reply:^(BOOL success, NSError * _Nullable error) {
            
            if (success) {
                // 指纹识别成功，回主线程更新UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    //成功操作--马上调用纯指纹验证方法
                    if (policy == LAPolicyDeviceOwnerAuthentication)
                    {
                        [self startTouchIDWithPolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics locaizeFallbackTitle:desc BlockState:block];
                    }else{
                        NSLog(@"TouchID 验证成功");
                        block(TDTouchIDStateSuccess,error);

                    }
                    
                });
            }else if(error){
                switch (error.code) {
                    case LAErrorAuthenticationFailed:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"TouchID 验证失败");
                            block(TDTouchIDStateFail,error);
                        });
                        break;
                    }
                    case LAErrorUserCancel:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"TouchID 被用户手动取消");
                            block(TDTouchIDStateUserCancel,error);
                        });
                    }
                        break;
                    case LAErrorUserFallback:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"用户不使用TouchID,选择手动输入密码");
                            block(TDTouchIDStateInputPassword,error);
                        });
                    }
                        break;
                    case LAErrorSystemCancel:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"TouchID 被系统取消 (如遇到来电,锁屏,按了Home键等)");
                            block(TDTouchIDStateSystemCancel,error);
                        });
                    }
                        break;
                    case LAErrorPasscodeNotSet:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"TouchID 无法启动,因为用户没有设置密码");
                            block(TDTouchIDStatePasswordNotSet,error);
                        });
                    }
                        break;
                    case LAErrorTouchIDNotEnrolled:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"TouchID 无法启动,因为用户没有设置TouchID");
                            block(TDTouchIDStateTouchIDNotSet,error);
                        });
                    }
                        break;
                    case LAErrorTouchIDNotAvailable:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"TouchID 无效");
                            block(TDTouchIDStateTouchIDNotAvailable,error);
                        });
                    }
                        break;
                    case LAErrorTouchIDLockout:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"TouchID 被锁定(连续多次验证TouchID失败,系统需要用户手动输入密码)");
                            block(TDTouchIDStateTouchIDLockout,error);
                        });
                    }
                        break;
                    case LAErrorAppCancel:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"当前软件被挂起并取消了授权 (如App进入了后台等)");
                            block(TDTouchIDStateAppCancel,error);
                        });
                    }
                        break;
                    case LAErrorInvalidContext:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"当前软件被挂起并取消了授权 (LAContext对象无效)");
                            block(TDTouchIDStateInvalidContext,error);
                        });
                    }
                        break;
                    default:
                        break;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self handelWithError:error locaizeFallbackTitle:desc BlockState:block];
                });
            }
        }];
        
    }else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"当前设备被锁定TouchID");
            [self handelWithError:error locaizeFallbackTitle:desc BlockState:block];
        });
    }
}
/**
 处理错误数据
 @param error 错误信息
 */
- (void)handelWithError:(NSError *)error locaizeFallbackTitle:(NSString *)desc BlockState:(StateBlock)block{
    if (error) {
        switch (error.code) {
            case LAErrorTouchIDLockout: {
                //touchID 被锁定--ios9才可以
                //开启验证--调用非全指纹指纹验证
                [self startTouchIDWithPolicy:LAPolicyDeviceOwnerAuthentication locaizeFallbackTitle:desc BlockState:block];
                break;
            }
        }
    }
}
@end

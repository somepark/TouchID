//
//  TDHomeViewController.m
//  TDTouchID
//
//  Created by imtudou on 2016/11/19.
//  Copyright © 2016年 TuDou. All rights reserved.
//

#import "TDHomeViewController.h"

@interface TDHomeViewController ()<UIGestureRecognizerDelegate>

@end

@implementation TDHomeViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor greenColor];
    self.title = @"已经通过TouchID验证";
    //添加左边自定义返回按钮（图片为空）,系统会默认关闭右滑动手势返回
    [self setBackBarButtonItem];
    //重新开启系统默认右滑动手势返回
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
}
/**
 导航栏左侧的返回按钮
 */
- (void)setBackBarButtonItem
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage  imageNamed:@"backBarButtonImage"];
    [button addTarget:self action:@selector(backBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [button setImage:image forState:UIControlStateNormal];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
}
/**
 导航栏左侧的返回方法
 */
-(void)backBarButtonAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

//由于可以解决系统右滑动返回，但是在root‘s directory 下可能会造成Actioin disable so if we in the base class determine wether with directoy
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.navigationController.viewControllers.count > 1) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }else{
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}
@end

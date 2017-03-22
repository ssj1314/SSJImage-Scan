//
//  ViewController.m
//  FCLScanDemo
//
//  Created by DragonStark on 16/3/11.
//  Copyright © 2016年 付程隆. All rights reserved.
//



/*
 
 
 博客地址：http://www.jianshu.com/users/4022d464ba9c/latest_articles
 
 
 */




#import "ViewController.h"
#import "FCLScanVC.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configInit];
}
- (void)configInit
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 320, 100, 40);
    button.backgroundColor = [UIColor orangeColor];
    [button setTitle:@"点我扫描" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showScaning)forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}
- (void)showScaning
{
    FCLScanVC *fVC = [[FCLScanVC alloc]init];
    fVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:fVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

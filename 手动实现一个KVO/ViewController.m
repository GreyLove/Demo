//
//  ViewController.m
//  手动实现一个KVO
//
//  Created by gl on 2019/7/27.
//  Copyright © 2019年 gl. All rights reserved.
//

#import "ViewController.h"

#import "NSObject+MyKVO.h"

@interface ViewController ()
@property (nonatomic,strong)NSString *age;
@property (nonatomic,strong)NSString *name;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.age = @"1";
    
    [self addObserver:self forKeyPath:@"age" block:^(NSObject * _Nonnull observer, NSString * _Nonnull keyPath, id  _Nonnull newValue, id  _Nonnull oldValue) {
        NSLog(@"%@--%@--%@--%@",observer,keyPath,newValue,oldValue);
    }];
    
    [self addObserver:self forKeyPath:@"name" block:^(NSObject * _Nonnull observer, NSString * _Nonnull keyPath, id  _Nonnull newValue, id  _Nonnull oldValue) {
        NSLog(@"%@--%@--%@--%@",observer,keyPath,newValue,oldValue);
    }];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.age = @"2";
    self.name = @"3";
    
    NSLog(@"%@--%@",self.age,self.name);
}

@end

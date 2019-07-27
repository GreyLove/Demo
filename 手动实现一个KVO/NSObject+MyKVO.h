//
//  NSObject+MyKVO.h
//  手动实现一个KVO
//
//  Created by gl on 2019/7/27.
//  Copyright © 2019年 gl. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (MyKVO)
// 目前只能监听strong 类型
- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath block:(void(^)(NSObject *observer,NSString *keyPath,id newValue,id oldValue))block;

@end

NS_ASSUME_NONNULL_END

//
//  NSObject+MyKVO.m
//  手动实现一个KVO
//
//  Created by gl on 2019/7/27.
//  Copyright © 2019年 gl. All rights reserved.
//

#import "NSObject+MyKVO.h"
#import <objc/message.h>

static NSString * const KVOPreFix = @"GLKVO";
static NSString * const KVOKeyPathKey = @"GLKVO_keyPath";

@interface NSObject()
@property (nonatomic,strong) NSMutableDictionary *keyPathHash;
@end

@implementation NSObject (MyKVO)

- (void)setKeyPathHash:(NSMutableDictionary *)keyPathHash{
    objc_setAssociatedObject(self, "GLKVO_keyPathHash", keyPathHash, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)keyPathHash{
    return objc_getAssociatedObject(self, "GLKVO_keyPathHash");
}

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath block:(void(^)(NSObject *observer,NSString *keyPath,id newValue,id oldValue))block{
    
    NSString *setterName = [self setterName:keyPath];
    SEL setterSeletor = NSSelectorFromString(setterName);
    
    
    Class oriCalss;
    if (![self isKVOClass]) {
        oriCalss = object_getClass(self);
    }else{
        oriCalss = object_getClass(self).superclass;
    }
    
    
    Method oriCalssMethod = class_getInstanceMethod(oriCalss, setterSeletor);
    
    
    if (!oriCalssMethod) return;
        
    
    Class kvoClass;
    
    if (!self.keyPathHash) {
        self.keyPathHash = [NSMutableDictionary dictionary];
    }
    
    
    if (![self isKVOClass]) {
        kvoClass = objc_allocateClassPair(object_getClass(self), [[self getKVOClassName] UTF8String], 0);
        object_setClass(self, kvoClass);
        objc_registerClassPair(kvoClass);
    }else{
        kvoClass = object_getClass(self);
    }
    
    if (![self.keyPathHash objectForKey:keyPath]) {
        self.keyPathHash[keyPath] = block;
        const char *types = method_getTypeEncoding(oriCalssMethod);
        class_addMethod(kvoClass, setterSeletor, (IMP)setterIMP, types);
    }    
}



static void setterIMP(id self,SEL _cmd,id v){
    
    NSString *keyPath = NSStringFromSelector(_cmd);
    keyPath = [[keyPath substringFromIndex:3] lowercaseString];
    keyPath = [keyPath substringToIndex:keyPath.length-1];
    SEL setterSeletor = _cmd;
    Class superClass = [object_getClass(self) superclass];
    struct objc_super kSuper = {self,superClass};
    id old = objc_msgSendSuper(&kSuper, @selector(valueForKey:),keyPath);
    objc_msgSendSuper(&kSuper, setterSeletor,v);
    id new = v;
    void(^observe)(NSObject *observer,NSString *keyPath,id newValue,id oldValue)  = [self keyPathHash][keyPath];
    if (observe) {
        observe(self,keyPath,new,old);
    }
}


- (NSString*)getKVOClassName{
    NSString *className = [NSString stringWithFormat:@"%@_%@",KVOPreFix,object_getClass(self)];
    return className;
}

- (NSString*)setterName:(NSString*)keyPath{
    if (!keyPath.length) {
        return nil;
    }
    NSString *first = [keyPath substringToIndex:1];
    NSString *second = [keyPath substringFromIndex:1];
    NSString *capFirst = [first capitalizedString];
    
    NSString *setterName = [NSString stringWithFormat:@"set%@%@:",capFirst,second];
    return setterName;
}

- (BOOL)isKVOClass{
    if ([NSStringFromClass(self.class) hasPrefix:KVOPreFix]) {
        return YES;
    }
    return NO;
}

@end

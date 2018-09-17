//
//  NSObject+LZRuntime.m
//  Pods
//
//  Created by Dear.Q on 2017/12/9.
//
//

#import "NSObject+LZRuntime.h"
#import <objc/runtime.h>

@implementation NSObject (LZRuntime)

//MARK: - Public
/** 类方法交换 */
void LZ_exchangeClassMethod(Class class, SEL originSelector, SEL swizzleSelector) {
    LZ_exchangeMethod(YES, class, originSelector, swizzleSelector);
}

/** 对象方法交换 */
void LZ_exchangeInstanceMethod(Class class, SEL originSelector, SEL swizzleSelector) {
    LZ_exchangeMethod(NO, class, originSelector, swizzleSelector);
}

/** 添加属性 */
void LZ_setAssociatedObject(id object, const void *key, id value) {
    objc_setAssociatedObject(object, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/** 获取属性 */
id LZ_getAssociatedObject(id object, const void *key) {
    return objc_getAssociatedObject(object, key);
}

//MARK: - Private
/** 方法交换 */
void LZ_exchangeMethod(BOOL classMethod, Class destClass, SEL originSelector, SEL swizzleSelector) {
	
	Method swizzleMethod = classMethod ? class_getClassMethod(destClass, swizzleSelector) : class_getInstanceMethod(destClass, swizzleSelector);
	IMP swizzleIMP = method_getImplementation(swizzleMethod);
	const char *swizzleType = method_getTypeEncoding(swizzleMethod);
	
	BOOL exist = class_addMethod(destClass, swizzleSelector, swizzleIMP, swizzleType);
	if (!exist) {
		class_replaceMethod(destClass, originSelector, swizzleIMP, swizzleType);
	} else {
		
		Method originMethod = classMethod ? class_getClassMethod(destClass, originSelector) : class_getInstanceMethod(destClass, originSelector);
		method_exchangeImplementations(originMethod, swizzleMethod);
	}
}

@end

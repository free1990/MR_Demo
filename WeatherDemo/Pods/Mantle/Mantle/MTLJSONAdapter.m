//
//  MTLJSONAdapter.m
//  Mantle
//
//  Created by Justin Spahr-Summers on 2013-02-12.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "MTLJSONAdapter.h"
#import "MTLModel.h"
#import "MTLReflection.h"

NSString * const MTLJSONAdapterErrorDomain = @"MTLJSONAdapterErrorDomain";
const NSInteger MTLJSONAdapterErrorNoClassFound = 2;

// An exception was thrown and caught.
static const NSInteger MTLJSONAdapterErrorExceptionThrown = 1;

// Associated with the NSException that was caught.
static NSString * const MTLJSONAdapterThrownExceptionErrorKey = @"MTLJSONAdapterThrownException";

@interface MTLJSONAdapter ()

// The MTLModel subclass being parsed, or the class of `model` if parsing has
// completed.
@property (nonatomic, strong, readonly) Class modelClass;

// JSONKeyPathsByPropertyKey的字典的的备份，存储了数据属性的格式
// A cached copy of the return value of +JSONKeyPathsByPropertyKey.
@property (nonatomic, copy, readonly) NSDictionary *JSONKeyPathsByPropertyKey;

// 这个是实例方法不是类方法
// Looks up the NSValueTransformer that should be used for the given key.
// key - The property key to transform from or to. This argument must not be nil.
// Returns a transformer to use, or nil to not transform the property.
- (NSValueTransformer *)JSONTransformerForKey:(NSString *)key;

// Looks up the JSON key path that corresponds to the given key.
//
// key - The property key to retrieve the corresponding JSON key path for. This
//       argument must not be nil.
//
// Returns a key path to use, or nil to omit the property from JSON.
- (NSString *)JSONKeyPathForKey:(NSString *)key;

@end

@implementation MTLJSONAdapter

#pragma mark Convenience methods

+ (id)modelOfClass:(Class)modelClass fromJSONDictionary:(NSDictionary *)JSONDictionary error:(NSError **)error {
	
    //JSONDictionary是一个json的字典实例，modelClass为这个对应json的类
    MTLJSONAdapter *adapter = [[self alloc] initWithJSONDictionary:JSONDictionary modelClass:modelClass error:error];
	return adapter.model;
}

+ (NSDictionary *)JSONDictionaryFromModel:(MTLModel<MTLJSONSerializing> *)model {
	MTLJSONAdapter *adapter = [[self alloc] initWithModel:model];
	return adapter.JSONDictionary;
}

#pragma mark Lifecycle

- (id)init {
	NSAssert(NO, @"%@ must be initialized with a JSON dictionary or model object", self.class);
	return nil;
}

- (id)initWithJSONDictionary:(NSDictionary *)JSONDictionary modelClass:(Class)modelClass error:(NSError **)error {
	
    //很好的习惯，重要的形参进行入参判断
    NSParameterAssert(modelClass != nil);
	NSParameterAssert([modelClass isSubclassOfClass:MTLModel.class]);
	NSParameterAssert([modelClass conformsToProtocol:@protocol(MTLJSONSerializing)]);

	if (JSONDictionary == nil) return nil;
    
    NSLog(@"modelClass = %@",  modelClass);
	// 如果类实现了classForParsingJSONDictionary找个方法，那么就去调用，返回一个新的class的实例，并且去对找个对象进行验证
    if ([modelClass respondsToSelector:@selector(classForParsingJSONDictionary:)]) {
        
		modelClass = [modelClass classForParsingJSONDictionary:JSONDictionary];
		if (modelClass == nil) {
			if (error != NULL) {
				NSDictionary *userInfo = @{
					NSLocalizedDescriptionKey: NSLocalizedString(@"Could not parse JSON", @""),
					NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No model class could be found to parse the JSON dictionary.", @"")
				};

				*error = [NSError errorWithDomain:MTLJSONAdapterErrorDomain code:MTLJSONAdapterErrorNoClassFound userInfo:userInfo];
			}

			return nil;
		}

		NSAssert([modelClass isSubclassOfClass:MTLModel.class], @"Class %@ returned from +classForParsingJSONDictionary: is not a subclass of MTLModel", modelClass);
		NSAssert([modelClass conformsToProtocol:@protocol(MTLJSONSerializing)], @"Class %@ returned from +classForParsingJSONDictionary: does not conform to <MTLJSONSerializing>", modelClass);
	}

	self = [super init];
	if (self == nil) return nil;

    //类的名字
	_modelClass = modelClass;
    NSLog(@"_modelClass = %@", [_modelClass class]);
    
    //属性的字典
	_JSONKeyPathsByPropertyKey = [[modelClass JSONKeyPathsByPropertyKey] copy];
    
    NSLog(@"_JSONKeyPathsByPropertyKey = %@", _JSONKeyPathsByPropertyKey);

	NSMutableDictionary *dictionaryValue = [[NSMutableDictionary alloc] initWithCapacity:JSONDictionary.count];
    
    //获取原始值的字典
    //???:实现方法需要继续研究
	for (NSString *propertyKey in [self.modelClass propertyKeys]) {
		NSString *JSONKeyPath = [self JSONKeyPathForKey:propertyKey];
		if (JSONKeyPath == nil) continue;
        
		id value = [JSONDictionary valueForKeyPath:JSONKeyPath];
		if (value == nil) continue;
        
		@try {
            
            // 获取每个key的NSValueTransformer数据
			NSValueTransformer *transformer = [self JSONTransformerForKey:propertyKey];
			
            //如果为真name就说明存在自己处理的NSValueTransformer，则改变上面的value的值
            if (transformer != nil) {
				// Map NSNull -> nil for the transformer, and then back for the
				// dictionary we're going to insert into.
				if ([value isEqual:NSNull.null]) value = nil;
				value = [transformer transformedValue:value] ?: NSNull.null;
			}

			dictionaryValue[propertyKey] = value;
		} @catch (NSException *ex) {
			NSLog(@"*** Caught exception %@ parsing JSON key path \"%@\" from: %@", ex, JSONKeyPath, JSONDictionary);

			// Fail fast in Debug builds.
			#if DEBUG
			@throw ex;
			#else
			if (error != NULL) {
				NSDictionary *userInfo = @{
					NSLocalizedDescriptionKey: ex.description,
					NSLocalizedFailureReasonErrorKey: ex.reason,
					MTLJSONAdapterThrownExceptionErrorKey: ex
				};

				*error = [NSError errorWithDomain:MTLJSONAdapterErrorDomain code:MTLJSONAdapterErrorExceptionThrown userInfo:userInfo];
			}

			return nil;
			#endif
		}
	}

    // 通过把属性和值对应起来生成新的实例
	_model = [self.modelClass modelWithDictionary:dictionaryValue error:error];
    
	if (_model == nil) return nil;

	return self;
}

- (id)initWithModel:(MTLModel<MTLJSONSerializing> *)model {
	NSParameterAssert(model != nil);

	self = [super init];
	if (self == nil) return nil;

	_model = model;
	_modelClass = model.class;
	_JSONKeyPathsByPropertyKey = [[model.class JSONKeyPathsByPropertyKey] copy];

	return self;
}

#pragma mark Serialization

// 把model的数据转化成字典类型
- (NSDictionary *)JSONDictionary {
	NSDictionary *dictionaryValue = self.model.dictionaryValue;
	NSMutableDictionary *JSONDictionary = [[NSMutableDictionary alloc] initWithCapacity:dictionaryValue.count];

	[dictionaryValue enumerateKeysAndObjectsUsingBlock:^(NSString *propertyKey, id value, BOOL *stop) {
		NSString *JSONKeyPath = [self JSONKeyPathForKey:propertyKey];
		if (JSONKeyPath == nil) return;

		NSValueTransformer *transformer = [self JSONTransformerForKey:propertyKey];
		if ([transformer.class allowsReverseTransformation]) {
			// Map NSNull -> nil for the transformer, and then back for the
			// dictionaryValue we're going to insert into.
			if ([value isEqual:NSNull.null]) value = nil;
			value = [transformer reverseTransformedValue:value] ?: NSNull.null;
		}

		NSArray *keyPathComponents = [JSONKeyPath componentsSeparatedByString:@"."];

		// Set up dictionaries at each step of the key path.
		id obj = JSONDictionary;
		for (NSString *component in keyPathComponents) {
			if ([obj valueForKey:component] == nil) {
				// Insert an empty mutable dictionary at this spot so that we
				// can set the whole key path afterward.
				[obj setValue:[NSMutableDictionary dictionary] forKey:component];
			}

			obj = [obj valueForKey:component];
		}

		[JSONDictionary setValue:value forKeyPath:JSONKeyPath];
	}];

	return JSONDictionary;
}

- (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
	NSParameterAssert(key != nil);

    //此处构造特殊的key+JSONTransformer的方法
	SEL selector = MTLSelectorWithKeyPattern(key, "JSONTransformer");
    
    // 如果响应了特殊处理的方法
	if ([self.modelClass respondsToSelector:selector]) {
        
        // 由于是类方法，会提前注册在class的methodlist里面,所以此时是响应的
        // 由于没有办法去使用方法的名字,比如：[NSString init];
        // 所以此时使用NSInvocation的方法去调用
        
        // 调用类的方法
		NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self.modelClass methodSignatureForSelector:selector]];
		invocation.target = self.modelClass;
		invocation.selector = selector;
		[invocation invoke];

		__unsafe_unretained id result = nil;
		[invocation getReturnValue:&result];
		return result;
	}

    //协议的方法，进行处理
	if ([self.modelClass respondsToSelector:@selector(JSONTransformerForKey:)]) {
        
        NSLog(@"self.modelClass = %@", self.modelClass);
		return [self.modelClass JSONTransformerForKey:key];
	}

	return nil;
}

- (NSString *)JSONKeyPathForKey:(NSString *)key {
	NSParameterAssert(key != nil);

	id JSONKeyPath = self.JSONKeyPathsByPropertyKey[key];
	if ([JSONKeyPath isEqual:NSNull.null]) return nil;

	if (JSONKeyPath == nil) {
		return key;
	} else {
		return JSONKeyPath;
	}
}

@end

@implementation MTLJSONAdapter (Deprecated)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"

+ (id)modelOfClass:(Class)modelClass fromJSONDictionary:(NSDictionary *)JSONDictionary {
	return [self modelOfClass:modelClass fromJSONDictionary:JSONDictionary error:NULL];
}

- (id)initWithJSONDictionary:(NSDictionary *)JSONDictionary modelClass:(Class)modelClass {
	return [self initWithJSONDictionary:JSONDictionary modelClass:modelClass error:NULL];
}

#pragma clang diagnostic pop

@end
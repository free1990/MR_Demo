//
//  EXTRuntimeExtensions.m
//  extobjc
//
//  Created by Justin Spahr-Summers on 2011-03-05.
//  Copyright (C) 2012 Justin Spahr-Summers.
//  Released under the MIT license.
//

#import "EXTRuntimeExtensions.h"

//自定义mtl_propertyAttributes来代表成员变量的各种属性
mtl_propertyAttributes *mtl_copyPropertyAttributes (objc_property_t property) {
    
    //传入属性，然后开始做各种处理
    
//    attrString = T@"NSString",R,C,N,V_countryName
//    typeString = @"NSString",R,C,N,V_countryName
//    next = ,R,C,N,V_countryName
//    typeLength = 11
    
    //property的Attribute的字符串
    const char * const attrString = property_getAttributes(property);
    
    NSLog(@"attrString = %s", attrString);
    
    //为空，返回异常
    if (!attrString) {
        fprintf(stderr, "ERROR: Could not get attribute string from property %s\n", property_getName(property));
        return NULL;
    }
    
    if (attrString[0] != 'T') {
        fprintf(stderr, "ERROR: Expected attribute string \"%s\" for property %s to start with 'T'\n", attrString, property_getName(property));
        return NULL;
    }

    const char *typeString = attrString + 1;
    
    NSLog(@"typeString = %s", typeString);
    //返回位移指定字符转的
    const char *next = NSGetSizeAndAlignment(typeString, NULL, NULL);

     NSLog(@"next = %s", next);
    
    if (!next) {
        fprintf(stderr, "ERROR: Could not read past type in attribute string \"%s\" for property %s\n", attrString, property_getName(property));
        return NULL;
    }

    size_t typeLength = next - typeString;
    
    NSLog(@"typeLength = %zu", typeLength);
    
    if (!typeLength) {
        fprintf(stderr, "ERROR: Invalid type in attribute string \"%s\" for property %s\n", attrString, property_getName(property));
        return NULL;
    }
    
    // 生成了一个属性的结构体
    // allocate enough space for the structure and the type string (plus a NUL)
    mtl_propertyAttributes *attributes = calloc(1, sizeof(mtl_propertyAttributes) + typeLength + 1);
    
    if (!attributes) {
        fprintf(stderr, "ERROR: Could not allocate mtl_propertyAttributes structure for attribute string \"%s\" for property %s\n", attrString, property_getName(property));
        return NULL;
    }

    // copy the type string
    strncpy(attributes->type, typeString, typeLength);
    attributes->type[typeLength] = '\0';

    // if this is an object type, and immediately followed by a quoted string...
    if (typeString[0] == *(@encode(id)) && typeString[1] == '"') {
        // we should be able to extract a class name
        const char *className = typeString + 2;
        next = strchr(className, '"');
        
        if (!next) {
            fprintf(stderr, "ERROR: Could not read class name in attribute string \"%s\" for property %s\n", attrString, property_getName(property));
            return NULL;
        }

        if (className != next) {
            size_t classNameLength = next - className;
            char trimmedName[classNameLength + 1];

            strncpy(trimmedName, className, classNameLength);
            trimmedName[classNameLength] = '\0';

            // attempt to look up the class in the runtime
            attributes->objectClass = objc_getClass(trimmedName);
        }
    }

    if (*next != '\0') {
        // skip past any junk before the first flag
        next = strchr(next, ',');
    }

    while (next && *next == ',') {
        char flag = next[1];
        next += 2;

        switch (flag) {
        case '\0':
            break;

        case 'R':
            attributes->readonly = YES;
            break;

        case 'C':
            attributes->memoryManagementPolicy = mtl_propertyMemoryManagementPolicyCopy;
            break;

        case '&':
            attributes->memoryManagementPolicy = mtl_propertyMemoryManagementPolicyRetain;
            break;

        case 'N':
            attributes->nonatomic = YES;
            break;

        case 'G':
        case 'S':
            {
                const char *nextFlag = strchr(next, ',');
                SEL name = NULL;

                if (!nextFlag) {
                    // assume that the rest of the string is the selector
                    const char *selectorString = next;
                    next = "";

                    name = sel_registerName(selectorString);
                } else {
                    size_t selectorLength = nextFlag - next;
                    if (!selectorLength) {
                        fprintf(stderr, "ERROR: Found zero length selector name in attribute string \"%s\" for property %s\n", attrString, property_getName(property));
                        goto errorOut;
                    }

                    char selectorString[selectorLength + 1];

                    strncpy(selectorString, next, selectorLength);
                    selectorString[selectorLength] = '\0';

                    name = sel_registerName(selectorString);
                    next = nextFlag;
                }

                if (flag == 'G')
                    attributes->getter = name;
                else
                    attributes->setter = name;
            }

            break;

        case 'D':
            attributes->dynamic = YES;
            attributes->ivar = NULL;
            break;

        case 'V':
            // assume that the rest of the string (if present) is the ivar name
            if (*next == '\0') {
                // if there's nothing there, let's assume this is dynamic
                attributes->ivar = NULL;
            } else {
                attributes->ivar = next;
                next = "";
            }

            break;

        case 'W':
            attributes->weak = YES;
            break;

        case 'P':
            attributes->canBeCollected = YES;
            break;

        case 't':
            fprintf(stderr, "ERROR: Old-style type encoding is unsupported in attribute string \"%s\" for property %s\n", attrString, property_getName(property));

            // skip over this type encoding
            while (*next != ',' && *next != '\0')
                ++next;

            break;

        default:
            fprintf(stderr, "ERROR: Unrecognized attribute string flag '%c' in attribute string \"%s\" for property %s\n", flag, attrString, property_getName(property));
        }
    }

    if (next && *next != '\0') {
        fprintf(stderr, "Warning: Unparsed data \"%s\" in attribute string \"%s\" for property %s\n", next, attrString, property_getName(property));
    }

    if (!attributes->getter) {
        // use the property name as the getter by default
        attributes->getter = sel_registerName(property_getName(property));
    }

    if (!attributes->setter) {
        const char *propertyName = property_getName(property);
        size_t propertyNameLength = strlen(propertyName);

        // we want to transform the name to setProperty: style
        size_t setterLength = propertyNameLength + 4;

        char setterName[setterLength + 1];
        strncpy(setterName, "set", 3);
        strncpy(setterName + 3, propertyName, propertyNameLength);

        // capitalize property name for the setter
        setterName[3] = (char)toupper(setterName[3]);

        setterName[setterLength - 1] = ':';
        setterName[setterLength] = '\0';

        attributes->setter = sel_registerName(setterName);
    }
    
//    BOOL readonly;
//    BOOL nonatomic;
//    
//    BOOL weak;
//    BOOL canBeCollected;
//    BOOL dynamic;
//    mtl_propertyMemoryManagementPolicy memoryManagementPolicy;
//    SEL getter;
//    SEL setter;
//    const char *ivar;
//    Class objectClass;
//    char type[];
    
    //GDB 调试: print *attributes
    

    return attributes;

errorOut:
    free(attributes);
    return NULL;
}

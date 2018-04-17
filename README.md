# AMECategoryMaker
A category property maker without resigin<br>
![](Display/ACM-introduce.png)

##### ![cn](https://raw.githubusercontent.com/gosquared/flags/master/flags/flags/shiny/24/China.png) Chinese (Simplified): [中文说明](README_chs.md)

## What is this?
When you add a property to your category,you must write getter and setter by your self.This looks like a hassle. <br>
This plug-in may solve your problem.

e.g.
```
//copy
@property (nonatomic, copy) NSString * view_version;
//assign
@property (nonatomic, assign) NSInteger numVersion;
//strong
@property (nonatomic, strong) UIButton * button;

@property (atomic, strong) UIScrollView * scrollView;
/*过滤注释*/
//readOnly
@property (nonatomic, readonly, copy) NSString * readOnlyString;
//自动识别int float bool
@property (nonatomic, assign) CGFloat float0;
@property (nonatomic, assign) BOOL isAME;
```
↓↓↓
```
static char * view_versionKey = "view_versionKey";
static char * numVersionKey = "numVersionKey";
static char * buttonKey = "buttonKey";
static char * scrollViewKey = "scrollViewKey";
static char * readOnlyStringKey = "readOnlyStringKey";
static char * float0Key = "float0Key";
static char * isAMEKey = "isAMEKey";

- (void)setView_version:(NSString *)view_version{
    objc_setAssociatedObject(self, view_versionKey, view_version, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)view_version{
    if(!objc_getAssociatedObject(self, view_versionKey)){
        NSString *object = [[NSString alloc]init];
        objc_setAssociatedObject(self, view_versionKey, object, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    return objc_getAssociatedObject(self, view_versionKey);
}

- (void)setNumVersion:(NSInteger)numVersion{
    objc_setAssociatedObject(self, numVersionKey, @(numVersion), OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)numVersion{
    return [objc_getAssociatedObject(self, numVersionKey)integerValue];
}

- (void)setButton:(UIButton *)button{
    objc_setAssociatedObject(self, buttonKey, button, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIButton *)button{
    if(!objc_getAssociatedObject(self, buttonKey)){
        UIButton *object = [[UIButton alloc]init];
        objc_setAssociatedObject(self, buttonKey, object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return objc_getAssociatedObject(self, buttonKey);
}

- (void)setScrollView:(UIScrollView *)scrollView{
    objc_setAssociatedObject(self, scrollViewKey, scrollView, OBJC_ASSOCIATION_RETAIN);
}

- (UIScrollView *)scrollView{
    if(!objc_getAssociatedObject(self, scrollViewKey)){
        UIScrollView *object = [[UIScrollView alloc]init];
        objc_setAssociatedObject(self, scrollViewKey, object, OBJC_ASSOCIATION_RETAIN);
    }
    return objc_getAssociatedObject(self, scrollViewKey);
}

- (NSString *)readOnlyString{
    if(!objc_getAssociatedObject(self, readOnlyStringKey)){
        NSString *object = [[NSString alloc]init];
        objc_setAssociatedObject(self, readOnlyStringKey, object, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    return objc_getAssociatedObject(self, readOnlyStringKey);
}

- (void)setFloat0:(CGFloat)float0{
    objc_setAssociatedObject(self, float0Key, @(float0), OBJC_ASSOCIATION_ASSIGN);
}

- (CGFloat)float0{
    return [objc_getAssociatedObject(self, float0Key)doubleValue];
}

- (void)setIsAME:(BOOL)isAME{
    objc_setAssociatedObject(self, isAMEKey, @(isAME), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isAME{
    return [objc_getAssociatedObject(self, isAMEKey)boolValue];
}
```

![](Display/category-gif.gif)

## Installation
#### Xcode8.0+
1. [Download](Product/AMECategoryMaker.zip)<br>
2. Enable this plug-in in setting<br>
![](Display/extensionUse.png)<br>
3. You can Bind shortcuts in Xcode setting <br>
![](Display/binding.png)<br>

## Trouble Shooting
If your Xcode is 8.0+.<br>
Please install macOS Sierra (version 10.12) if your macOS is 10.11.<br>

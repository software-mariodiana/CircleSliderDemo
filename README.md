# CircleSliderDemo #

Demonstrate the usage of MDXCircleProgressView class. 

The class provides a progress view similar in functionality to UIProgressView, but in circular form. It is designed to be simple to use with sensible defaults. The class works with Interface Builder.

The project is written in Objective-C.

### Getting Started ###

Run the project, and play around either in Interface Builder or the ViewController.m file. The progress color and track color may be changed either manually or via the UIAppearance protocol. Progress is updated manually via the progress property, or by using an NSProgress object via the observedProgress property.

** MDXCircleProgressView.h **

```objectivec
#import <UIKit/UIKit.h>

@interface MDXCircleProgressView : UIView <NSCoding>

@property (nonatomic, assign) IBInspectable float progress;
@property (nonatomic, strong) NSProgress* observedProgress;
@property (nonatomic, strong) IBInspectable UIColor* progressTintColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) IBInspectable UIColor* trackTintColor UI_APPEARANCE_SELECTOR;

- (void)setProgress:(float)progress animated:(BOOL)animated;

@end
```

The MDXCircleProgressView class can be incorporated into any project simply by including the header and implementation files.

### Prerequisites ###

Xcode 11.3.1 and iOS 13.2.

## License ##

This project is licensed under the BSD 3 license. Copyright (c) 2021 Mario Diana.

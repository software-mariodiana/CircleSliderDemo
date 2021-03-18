//
// MDXCircleProgressView.m
//
// Copyright (c) 2021 Mario Diana
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
//
// 1. Redistributions of source code must retain the above copyright
// notice, this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright
// notice, this list of conditions and the following disclaimer in the
// documentation and/or other materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its
// contributors may be used to endorse or promote products derived from
// this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
// TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "MDXCircleProgressView.h"

#define MDXDefaultColor() [self tintColor]
#define FractionCompleted() NSStringFromSelector(@selector(fractionCompleted))

static void* MDXCircleProgressViewContext = &MDXCircleProgressViewContext;
static void* MDXTintColorContext = &MDXTintColorContext;

@interface MDXCircleProgressView ()
@property (nonatomic, assign, getter=isAnimated) BOOL animated;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, weak) CAShapeLayer* trackLayer;
@property (nonatomic, weak) CAShapeLayer* circleLayer;
@end

IB_DESIGNABLE
@implementation MDXCircleProgressView

#pragma mark - Object lifecycle

- (void)dealloc
{
    if (_observedProgress) {
        [_observedProgress removeObserver:self forKeyPath:FractionCompleted()];
    }
    
    [self removeObserver:self forKeyPath:@"progressTintColor"];
    [self removeObserver:self forKeyPath:@"trackTintColor"];
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _progress = 0.0;
        _progressTintColor = MDXDefaultColor();
        _lineWidth = 16.0;
        self.backgroundColor = [UIColor clearColor];
        
        [self initializeColorKVO];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _progress = 0.0;
        _progressTintColor = MDXDefaultColor();
        _lineWidth = 16.0;
        self.backgroundColor = [UIColor clearColor];
    }
    
    [self initializeColorKVO];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if (self) {
        _progress = [coder decodeFloatForKey:@"progress"];
        _progressTintColor = [coder decodeObjectForKey:@"progressTintColor"];
        _trackTintColor = [coder decodeObjectForKey:@"trackTintColor"];
        _lineWidth = 16.0;
        
        [self initializeColorKVO];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeFloat:_progress forKey:@"progress"];
    [coder encodeObject:_progressTintColor forKey:@"progressTintColor"];
    [coder encodeObject:_trackTintColor forKey:@"trackTintColor"];
}

- (void)initializeColorKVO
{
    // Should a view controller change colors at runtime, we need to know.
    [self addObserver:self
           forKeyPath:@"progressTintColor"
              options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
              context:MDXTintColorContext];
    
    [self addObserver:self
           forKeyPath:@"trackTintColor"
              options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
              context:MDXTintColorContext];
}

#pragma mark - Drawing code

- (CAShapeLayer *)createTrackLayerWithPath:(UIBezierPath *)path
{
    CGColorRef trackTintColorRef = [[self trackTintColor] CGColor];
    
    return [self createLayerWithPath:path CGColor:trackTintColorRef fractionCompleted:1.0];
}

- (CAShapeLayer *)createCircleLayerWithPath:(UIBezierPath *)path
{
    CAShapeLayer* layer = [self createLayerWithPath:path
                                            CGColor:[[self progressTintColor] CGColor]
                                  fractionCompleted:0.0];
    
    layer.lineCap = kCALineCapRound;
    return layer;
}

- (CAShapeLayer *)createLayerWithPath:(UIBezierPath *)path
                              CGColor:(CGColorRef)colorRef
                    fractionCompleted:(double)fractionCompleted
{
    CAShapeLayer* layer = [[CAShapeLayer alloc] init];
    layer.fillColor = UIColor.clearColor.CGColor;
    layer.path = path.CGPath;
    
    layer.strokeColor = colorRef;
    layer.strokeStart = 0.0;
    layer.strokeEnd = fractionCompleted;
    layer.lineWidth = [self lineWidth];
    
    return layer;
}

- (void)animateCircle
{
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.fromValue = [NSNumber numberWithDouble:[[self circleLayer] strokeEnd]];
    animation.toValue = [NSNumber numberWithDouble:[self progress]];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    self.circleLayer.strokeEnd = [self progress];
    [[self circleLayer] addAnimation:animation forKey:@"animateCircle"];
}

- (void)updateCircleLayer
{
    if ([self isAnimated]) {
        [self animateCircle];
    }
    else {
        self.circleLayer.strokeEnd = [self progress];
    }
}

- (void)drawRect:(CGRect)rect
{
    if (![self trackLayer]) {
        // Adjust the circle's rect to keep it from being clipped.
        CGFloat adjustment = [self lineWidth] / 2.0;
        CGPoint point = CGPointMake(rect.origin.x + adjustment, rect.origin.y + adjustment);
        CGSize size = CGSizeMake(rect.size.width - [self lineWidth], rect.size.height - [self lineWidth]);
        CGRect circleRect = CGRectMake(point.x, point.y, size.width, size.height);
        
        // Take the smaller, for when we're not enclosed in a square.
        CGFloat radius = (fmin(circleRect.size.width, circleRect.size.height) / 2.0);
        UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:circleRect cornerRadius:radius];
        
        CAShapeLayer* trackLayer = [self createTrackLayerWithPath:path];
        [[self layer] addSublayer:trackLayer];
        self.trackLayer = trackLayer;
        
        // Note: We check only for trackLayer but rely on setting circleLayer, too.
        CAShapeLayer* circleLayer = [self createCircleLayerWithPath:path];
        [[self layer] addSublayer:circleLayer];
        self.circleLayer = circleLayer;
    }
    
    [self updateCircleLayer];
}

- (BOOL)isDarkMode
{
    return [[UITraitCollection currentTraitCollection] userInterfaceStyle] == UIUserInterfaceStyleDark;
}

- (void)resetUI
{
    [[self circleLayer] removeFromSuperlayer];
    [[self trackLayer] removeFromSuperlayer];
    self.circleLayer = nil;
    self.trackLayer = nil;
    [self setNeedsDisplay];
}

- (void)tintColorDidChange
{
    [self resetUI];
}

#pragma mark - Public methods

- (void)setProgress:(float)progress animated:(BOOL)animated
{
    if ([self observedProgress]) {
        return;
    }
    
    _animated = animated;
    
    progress = (progress < 0.0) ? 0.0 : progress;
    _progress = (progress > 1.0) ? 1.0 : progress;
    
    [self setNeedsDisplay];
}

- (void)setProgress:(float)progress
{
    [self setProgress:progress animated:NO];
}

- (UIColor *)progressTintColor
{
    return _progressTintColor ?: MDXDefaultColor();
}

- (UIColor *)trackTintColor
{
    if (!_trackTintColor) {
        const CGFloat* components =
            CGColorGetComponents([[self progressTintColor] CGColor]);
        
        // The track needs to be a little heavier to be seen in Dark Mode.
        CGFloat alpha = [self isDarkMode] ? 0.15 : 0.05;
        
        // Adjust the alpha to be barely visible.
        return [UIColor colorWithRed:components[0]
                               green:components[1]
                                blue:components[2]
                               alpha:alpha];
    }
    else {
        return _trackTintColor;
    }
}

#pragma mark - Progress object KVC

- (void)setObservedProgress:(NSProgress *)observedProgress
{
    if (_observedProgress) {
        [_observedProgress removeObserver:self forKeyPath:FractionCompleted()];
    }
    
    [observedProgress addObserver:self
                       forKeyPath:FractionCompleted()
                          options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                          context:MDXCircleProgressViewContext];
    
    _animated = (observedProgress) ? YES : NO;
    _observedProgress = observedProgress;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == MDXCircleProgressViewContext) {
        if ([keyPath isEqualToString:FractionCompleted()]) {
            _progress = [[change objectForKey:@"new"] floatValue];
            [self setNeedsDisplay];
        }
    }
    else if (context == MDXTintColorContext) {
        if ([keyPath isEqualToString:@"progressTintColor"] || [keyPath isEqualToString:@"trackTintColor"]) {
            [self resetUI];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end

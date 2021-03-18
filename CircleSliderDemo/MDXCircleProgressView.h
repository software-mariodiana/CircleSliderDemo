//
// MDXCircleProgressView.h
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

#import <UIKit/UIKit.h>

/**
 * @class MDXCircleProgressView
 * 
 * @brief Mimic UIProgressView but using a circle.
 *
 * @discussion This is a progress view in a circular shape. Its functionality
 *             is similar to UIProgressView. The documentation below is brief
 *             and the UIProgressView documentation should be consulted for
 *             clarifying usage.
 *
 *             The class aims to make use of sensible defaults, and can be
 *             used without custom configuration. Users may typically modify
 *             the colors. The trackTintColor property will be, by default,
 *             the same color as progressTintColor but at a lower alpha value.
 */
@interface MDXCircleProgressView : UIView <NSCoding>

/**
 * The current progress shown by the receiver.
 *
 * @discussion Any value less than zero is constrained to 0.0; and value greater than
 *             one is constrained to 1.0.
 */
@property (nonatomic, assign) IBInspectable float progress;

/**
 * The progress object used for udating the progress view.
 *
 * @discussion Progress is updated according to the state of this NSProgress
 *             object, when the property is set. When the property is nil,
 *             progress must be updated manually. The default value is nil.
 */
@property (nonatomic, strong) NSProgress* observedProgress;

/**
 * The color shown for the portion of the progress bar that is filled.
 *
 * @discussion The property may be set manually. Alternately, the property
 *             conforms to the UIAppearance protocol. A nil value uses the
 *             default tintColor for UIView. The default is nil.
 */
@property (nonatomic, strong) IBInspectable UIColor* progressTintColor UI_APPEARANCE_SELECTOR;

/**
 * The color shown for the portion of the progress bar that is not filled.
 *
 * @discussion The property may be set manually. Alternately, the property
 *             conforms to the UIAppearance protocol. A nil value uses the
 *             color of the progressTintColor property, at a lower alpha
 *             value. The default is nil.
 */
@property (nonatomic, strong) IBInspectable UIColor* trackTintColor UI_APPEARANCE_SELECTOR;

/**
 * Adjusts the current progress shown by the receiver, optionally animating the change.
 *
 * @discussion Any value less than zero is constrained to 0.0; and value greater than
 *             one is constrained to 1.0. The animation is linear, and at the default
 *             speed for the operating system.
 *
 * @param progress The new progress value, constrained between 0.0 and 1.0, inclusive.
 * @param animated YES if the change should be animated, NO if the change should happen immediately.
 */
- (void)setProgress:(float)progress animated:(BOOL)animated;

@end

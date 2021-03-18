//
//  ViewController.m
//  CircleSliderDemo
//
//  Created by Mario Diana on 3/3/21.
//

#import "ViewController.h"
#import "MDXCircleProgressView.h"

@interface ViewController ()
@property (nonatomic, weak) IBOutlet UISlider *slider;
@property (nonatomic, weak) IBOutlet MDXCircleProgressView* circleProgressView;
@property (nonatomic, strong) NSProgress* progress;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.progress = [NSProgress discreteProgressWithTotalUnitCount:100];
    self.circleProgressView.observedProgress = self.progress;
    
    UIGestureRecognizer* tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTapped:)];
    
    [[self slider] addGestureRecognizer:tap];
    [self sliderUpdatedValue:self];
}

- (IBAction)sliderUpdatedValue:(id)sender
{
    self.progress.completedUnitCount = [[self slider] value] * 100;
}

- (void)sliderTapped:(UIGestureRecognizer *)tap
{
    CGPoint point = [tap locationInView:[self view]];
    CGPoint origin = self.slider.frame.origin;
    CGFloat sliderWidth = self.slider.frame.size.width;
    CGFloat value = ((point.x - origin.x) * [[self slider] maximumValue] / sliderWidth);
    
    [[self slider] setValue:value animated:YES];
    [self sliderUpdatedValue:self];
}

@end

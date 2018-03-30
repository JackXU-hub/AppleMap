//
//  JKAnnotationView.m
//  Maptest
//
//  Created by Mac on 2018/3/29.
//  Copyright © 2018年 Mac. All rights reserved.
//

#import "JKAnnotationView.h"

@implementation JKAnnotationView

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //        在大头针旁边(上下左右)加一个label
        self.label = [[UILabel alloc]initWithFrame:CGRectMake(-5, -20, 60, 50)];
        self.label.textColor = [UIColor blackColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont systemFontOfSize:10];
        self.label.lineBreakMode = 0;
        self.label.numberOfLines = 0;
        [self addSubview:self.label];
        
    }
    return self;
}


@end

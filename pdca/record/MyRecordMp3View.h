//
//  MyRecordMp3View.h
//  pdca
//
//  Created by caowk on 2017/11/24.
//  Copyright © 2017年 glimlab. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^FinishRecordMp3)(NSString* base64);

@interface MyRecordMp3View : UIView
@property (nonatomic, copy) FinishRecordMp3 finish;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)startAtView:(UIView *)view;
- (void)cancelRecord;

+(UIImage*) createImageWithColor:(UIColor*) color;
@end

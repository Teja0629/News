//
//  NewsListCell.h
//  NewsDigest
//
//  Created by Naga Teja on 10/06/16.
//  Copyright © 2016 None. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *noButton;

@property (weak, nonatomic) IBOutlet UILabel *newsType;

@property (weak, nonatomic) IBOutlet UILabel *newsTitle;

@property (weak, nonatomic) IBOutlet UILabel *newsDesc;

@property (weak, nonatomic) IBOutlet UIView *seperator;

@end

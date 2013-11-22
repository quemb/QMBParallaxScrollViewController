//
//  SampleTableViewController.h
//  QMBParallaxScrollView-Sample
//
//  Created by Toni Möckel on 03.11.13.
//  Copyright (c) 2013 Toni Möckel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMBParallaxScrollViewController.h"

@interface SampleTableViewController : UIViewController<QMBParallaxScrollViewHolder, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

@end

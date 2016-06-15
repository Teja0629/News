//
//  NewsListViewController.m
//  NewsDigest
//
//  Created by Naga Teja on 10/06/16.
//  Copyright © 2016 None. All rights reserved.
//

#import "NewsListViewController.h"
#import "NewsListCell.h"
#import "RssXMLParser.h"
#import "ParallaxHeaderView.h"
#import "MNMBottomPullToRefreshManager.h"

@interface NewsListViewController () <NSURLSessionDataDelegate, XMLParserDelegate> {
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
    BOOL isRefreshing;
}

@property (strong, nonatomic) NSMutableArray *rssData;
@property (assign) CGPoint scrollViewDragPoint;

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

@end

@implementation NewsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.

    isRefreshing = false;
    
    self.view.backgroundColor = [UIColor blackColor];
    self.mainTableView.backgroundColor = [UIColor clearColor];
    
    [self startSession];

    // Create ParallaxHeaderView with specified size, and set it as uitableView Header, that's it
    ParallaxHeaderView *headerView = [ParallaxHeaderView parallaxHeaderViewWithImage:[UIImage imageNamed:@"HeaderImage"] forSize:CGSizeMake(self.view.frame.size.width, 300)];
    headerView.headerTitleLabel.text = @"Under The Bridge";
    
    [self.mainTableView setTableHeaderView:headerView];
    
    
    pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:self.mainTableView withClient:self];

    
}

- (void)viewDidAppear:(BOOL)animated
{
    [(ParallaxHeaderView *)self.mainTableView.tableHeaderView refreshBlurViewForNewImage];
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshBottom {
    
}

#pragma mark Setup

- (void) startSession
{
    NSURL *url = [NSURL URLWithString:@"http://www.alexcurylo.com/blog/feed/"];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithURL:url
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        if(error == nil)
                                                        {
                                                            
                                                            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                            NSLog(@"%@", result);

                                                            
                                                            RssXMLParser *rssXMLParser = [[RssXMLParser alloc] init];
                                                            rssXMLParser.delegate = self;
                                                            [rssXMLParser parseRssXML:data];
                                                            
                                                        }
                                                        else
                                                        {
                                                            NSLog(@"Error: %@", error);
                                                        }
                                                    }];
    
    [dataTask resume];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rssData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NewsListCell *cell;
    if (isRefreshing == true) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"NewsCell" forIndexPath:indexPath];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"NewsListCell" forIndexPath:indexPath];
    }
;
    NSDictionary *data = [self.rssData objectAtIndex:indexPath.row];
    
    [cell.noButton setTitle:[NSString stringWithFormat:@"%ld", indexPath.row + 1] forState:UIControlStateNormal];
    cell.noButton.layer.cornerRadius = 10;
    cell.newsTitle.numberOfLines = 3;
    
    cell.newsTitle.text = [data objectForKey:@"description"];
    cell.newsDesc.text = [data objectForKey:@"pubDate"];
    cell.newsType.text = [data objectForKey:@"title"];
    
    return cell;
}


#pragma mark UISCrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.mainTableView)
    {
        // pass the current offset of the UITableView so that the ParallaxHeaderView layouts the subViews.
        [(ParallaxHeaderView *)self.mainTableView.tableHeaderView layoutHeaderViewForScrollViewOffset:scrollView.contentOffset];
        
        [pullToRefreshManager_ tableViewScrolled];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [pullToRefreshManager_ tableViewReleased];
}

- (void)bottomPullToRefreshTriggered:(MNMBottomPullToRefreshManager *)manager {
    isRefreshing = true;
    [self.mainTableView setTableHeaderView:nil];
    //pullToRefreshManager_ =nil;
    [self startSession]; 
    
}
#pragma mark - XML Parse 

- (void) onParserComplete:(NSObject *)data XMLParser:(RssXMLParser *)parser
{
    [parser setDelegate:nil];
    self.rssData = (NSMutableArray*)data;
    
    [self.mainTableView reloadData];
     if (isRefreshing == false) {
         [pullToRefreshManager_ tableViewReloadFinished];
     }
}



@end

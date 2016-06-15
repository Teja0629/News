//
//  RssXMLParser.h
//  NewsDigest
//
//  Created by Naga Teja on 13/06/16.
//  Copyright © 2016 None. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RssXMLParser;

@protocol XMLParserDelegate <NSObject>
@required
- (void) onParserComplete: (NSObject *) data XMLParser: (RssXMLParser *) parser;
@end

@interface RssXMLParser : NSObject <NSXMLParserDelegate>
{
    //for switch and case
    enum nodes {title = 1, postlink = 2, pubDate = 3, description = 4, invalidNode = -1};
    enum nodes aNode;

    NSMutableArray *data;
    
    //for holding the parsing result
    NSMutableDictionary *articles;
    
    //for matching the article title and link
    NSString *lastTitle;
}

@property (assign, nonatomic) id<XMLParserDelegate> delegate;
-(void) parseRssXML: (NSData *)xmldata;

@end


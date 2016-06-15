//
//  RssXMLParser.m
//  NewsDigest
//
//  Created by Naga Teja on 13/06/16.
//  Copyright © 2016 None. All rights reserved.
//

#import "RssXMLParser.h"

@implementation RssXMLParser

- (void) parseRssXML:(NSData *)xmldata
{
    data = [[NSMutableArray alloc] init];
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:xmldata];
    [xmlParser setDelegate:self];
    [xmlParser setShouldResolveExternalEntities:NO];
    [xmlParser parse];
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"item"])
    {
        aNode = invalidNode;
        if(articles == nil)
        {
            articles = [[NSMutableDictionary alloc] init];
        }
        else {
            [data addObject:articles];
            articles = [[NSMutableDictionary alloc] init];            
        }
    }
    else if([elementName isEqualToString:@"title"])
    {
        aNode = title;
    }
    else if([elementName isEqualToString:@"link"])
    {
        aNode = postlink;
    }
    else if([elementName isEqualToString:@"pubDate"])
    {
        aNode = pubDate;
    }
    else if([elementName isEqualToString:@"description"])
    {
        aNode = description;
    }
    else
    {
        aNode = invalidNode;
    }
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    
    if( [elementName isEqualToString:@"rss"] )
    {
        [self.delegate onParserComplete:data XMLParser:self];
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
    switch (aNode) {
        case description:
        {
            NSString *string = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
            string = [string stringByTrimmingCharactersInSet:[NSCharacterSet nonBaseCharacterSet]];
            string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if(string.length != 0)
            {
                [articles setObject:string forKey:@"description"];
            }
        }
            break;
        default:
            break;
    }

}

- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    switch (aNode) {
        case title:
        {
            string = [string stringByTrimmingCharactersInSet:[NSCharacterSet nonBaseCharacterSet]];
            string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if(string.length != 0)
            {
                [articles setObject:string forKey:@"title"];
            }
        }
            
            break;
        case postlink:
        {
            string = [string stringByTrimmingCharactersInSet:[NSCharacterSet nonBaseCharacterSet]];
            string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if(string.length != 0 && articles != nil)
            {
                [articles setObject:string forKey:@"link"];
            }
        }
            break;

        case pubDate:
        {
            string = [string stringByTrimmingCharactersInSet:[NSCharacterSet nonBaseCharacterSet]];
            string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if(string.length != 0 && articles != nil)
            {
                [articles setObject:string forKey:@"pubDate"];
            }
        }
            break;
        default:
            break;
    }
}

@end

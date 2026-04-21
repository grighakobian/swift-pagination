#import "Repository.h"

@implementation Repository

- (instancetype)initWithJSON:(NSDictionary *)json {
    self = [super init];
    if (self) {
        _identifier = [json[@"id"] integerValue];
        _name = [json[@"name"] copy] ?: @"";
        _fullName = [json[@"full_name"] copy] ?: @"";
        id desc = json[@"description"];
        _repositoryDescription = [desc isKindOfClass:[NSString class]] ? [desc copy] : nil;
        _stargazersCount = [json[@"stargazers_count"] integerValue];
        id lang = json[@"language"];
        _language = [lang isKindOfClass:[NSString class]] ? [lang copy] : nil;
        NSString *urlString = json[@"html_url"];
        _htmlURL = urlString ? [NSURL URLWithString:urlString] : [NSURL URLWithString:@"https://github.com"];
    }
    return self;
}

@end

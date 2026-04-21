#import "GitHubService.h"

@implementation GitHubService

- (instancetype)init {
    self = [super init];
    if (self) {
        _pageSize = 30;
    }
    return self;
}

- (void)fetchPopularRepositoriesAtPage:(NSInteger)page
                            completion:(void (^)(NSArray<Repository *> * _Nullable,
                                                 NSInteger,
                                                 NSError * _Nullable))completion {
    NSURLComponents *components =
        [NSURLComponents componentsWithString:@"https://api.github.com/search/repositories"];
    components.queryItems = @[
        [NSURLQueryItem queryItemWithName:@"q" value:@"stars:>1000"],
        [NSURLQueryItem queryItemWithName:@"sort" value:@"stars"],
        [NSURLQueryItem queryItemWithName:@"order" value:@"desc"],
        [NSURLQueryItem queryItemWithName:@"per_page"
                                    value:[NSString stringWithFormat:@"%ld", (long)self.pageSize]],
        [NSURLQueryItem queryItemWithName:@"page"
                                    value:[NSString stringWithFormat:@"%ld", (long)page]],
    ];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:components.URL];
    [request setValue:@"application/vnd.github+json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"2022-11-28" forHTTPHeaderField:@"X-GitHub-Api-Version"];

    NSURLSessionDataTask *task =
        [NSURLSession.sharedSession dataTaskWithRequest:request
                                      completionHandler:^(NSData * _Nullable data,
                                                          NSURLResponse * _Nullable response,
                                                          NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{ completion(nil, 0, error); });
            return;
        }
        NSError *jsonError = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:&jsonError];
        if (jsonError || ![json isKindOfClass:[NSDictionary class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{ completion(nil, 0, jsonError); });
            return;
        }
        NSNumber *totalCount = json[@"total_count"];
        NSArray *items = json[@"items"];
        NSMutableArray<Repository *> *repos = [NSMutableArray arrayWithCapacity:items.count];
        for (NSDictionary *item in items) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [repos addObject:[[Repository alloc] initWithJSON:item]];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(repos, totalCount.integerValue, nil);
        });
    }];
    [task resume];
}

@end

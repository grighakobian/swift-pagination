#import <Foundation/Foundation.h>
#import "Repository.h"

NS_ASSUME_NONNULL_BEGIN

/// A service that fetches popular GitHub repositories (stars > 1000).
@interface GitHubService : NSObject

/// GitHub caps the search API at 100 results per page.
@property (nonatomic, assign, readonly) NSInteger pageSize;

/// Fetches a page of popular repositories sorted by stars.
/// @param page 1-indexed page number.
/// @param completion Called on the main queue with a decoded list of repositories, the total count,
///        and any error. On failure, `repositories` is nil.
- (void)fetchPopularRepositoriesAtPage:(NSInteger)page
                            completion:(void (^)(NSArray<Repository *> * _Nullable repositories,
                                                 NSInteger totalCount,
                                                 NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END

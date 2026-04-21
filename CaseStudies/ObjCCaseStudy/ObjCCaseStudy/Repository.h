#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// A GitHub repository model.
@interface Repository : NSObject
@property (nonatomic, assign, readonly) NSInteger identifier;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *fullName;
@property (nonatomic, copy, readonly, nullable) NSString *repositoryDescription;
@property (nonatomic, assign, readonly) NSInteger stargazersCount;
@property (nonatomic, copy, readonly, nullable) NSString *language;
@property (nonatomic, copy, readonly) NSURL *htmlURL;

- (instancetype)initWithJSON:(NSDictionary *)json;
@end

NS_ASSUME_NONNULL_END

#import "RepositoriesViewController.h"
#import "GitHubService.h"
#import "Repository.h"
@import Pagination;

static NSString *const kCellReuseIdentifier = @"RepoCell";

#pragma mark - RepositoryCell

@interface RepositoryCell : UICollectionViewListCell
- (void)configureWithRepository:(Repository *)repository;
@end

@implementation RepositoryCell

- (void)configureWithRepository:(Repository *)repository {
    UIListContentConfiguration *content = [self defaultContentConfiguration];
    content.text = repository.fullName;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSString *stars = [formatter stringFromNumber:@(repository.stargazersCount)];
    content.secondaryText = [NSString stringWithFormat:@"★ %@ · %@",
                             stars, repository.language ?: @"—"];
    self.contentConfiguration = content;
}

@end

#pragma mark - RepositoriesViewController

@interface RepositoriesViewController () <PaginationDelegate>
@property (nonatomic, strong) NSMutableArray<Repository *> *repositories;
@property (nonatomic, strong) GitHubService *service;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL hasMorePages;
@end

@implementation RepositoriesViewController

- (instancetype)init {
    UICollectionLayoutListConfiguration *config =
        [[UICollectionLayoutListConfiguration alloc]
            initWithAppearance:UICollectionLayoutListAppearancePlain];
    UICollectionViewCompositionalLayout *layout =
        [UICollectionViewCompositionalLayout layoutWithListConfiguration:config];

    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        _repositories = [NSMutableArray array];
        _service = [[GitHubService alloc] init];
        _currentPage = 0;
        _hasMorePages = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.collectionView registerClass:[RepositoryCell class]
            forCellWithReuseIdentifier:kCellReuseIdentifier];

    self.collectionView.pagination.delegate = self;
    self.collectionView.pagination.direction = PaginationDirectionVertical;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.repositories.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RepositoryCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:kCellReuseIdentifier
                                                  forIndexPath:indexPath];
    [cell configureWithRepository:self.repositories[indexPath.item]];
    return cell;
}

#pragma mark - PaginationDelegate

- (void)pagination:(Pagination *)pagination
    prefetchNextPageWithContext:(PaginationContext *)context {
    [context updateState:PaginationStateStarted];

    NSInteger nextPage = self.currentPage + 1;
    __weak typeof(self) weakSelf = self;
    [self.service fetchPopularRepositoriesAtPage:nextPage
                                      completion:^(NSArray<Repository *> * _Nullable repos,
                                                   NSInteger totalCount,
                                                   NSError * _Nullable error) {
        typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return;
        if (error || !repos) {
            [context updateState:PaginationStateFailed];
            return;
        }
        [strongSelf.repositories addObjectsFromArray:repos];
        [strongSelf.collectionView reloadData];
        strongSelf.currentPage = nextPage;
        strongSelf.hasMorePages = strongSelf.repositories.count < totalCount;
        pagination.isEnabled = strongSelf.hasMorePages;
        [context updateState:PaginationStateCompleted];
    }];
}

@end

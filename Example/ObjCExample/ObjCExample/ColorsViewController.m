#import "ColorsViewController.h"
@import Pagination;

static NSArray<NSDictionary *> *ColorPalette(void) {
    return @[
        @{@"name": @"Red",      @"color": [UIColor colorWithRed:0.90 green:0.22 blue:0.21 alpha:1]},
        @{@"name": @"Blue",     @"color": [UIColor colorWithRed:0.13 green:0.59 blue:0.95 alpha:1]},
        @{@"name": @"Green",    @"color": [UIColor colorWithRed:0.30 green:0.69 blue:0.31 alpha:1]},
        @{@"name": @"Orange",   @"color": [UIColor colorWithRed:1.00 green:0.60 blue:0.00 alpha:1]},
        @{@"name": @"Purple",   @"color": [UIColor colorWithRed:0.61 green:0.15 blue:0.69 alpha:1]},
        @{@"name": @"Teal",     @"color": [UIColor colorWithRed:0.00 green:0.59 blue:0.53 alpha:1]},
        @{@"name": @"Pink",     @"color": [UIColor colorWithRed:0.91 green:0.12 blue:0.39 alpha:1]},
        @{@"name": @"Indigo",   @"color": [UIColor colorWithRed:0.25 green:0.32 blue:0.71 alpha:1]},
        @{@"name": @"Mint",     @"color": [UIColor colorWithRed:0.00 green:0.78 blue:0.55 alpha:1]},
        @{@"name": @"Cyan",     @"color": [UIColor colorWithRed:0.00 green:0.74 blue:0.83 alpha:1]},
    ];
}

#pragma mark - ColorItem

@interface ColorItem : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) UIColor *color;
+ (instancetype)itemWithName:(NSString *)name color:(UIColor *)color;
@end

@implementation ColorItem
+ (instancetype)itemWithName:(NSString *)name color:(UIColor *)color {
    ColorItem *item = [[ColorItem alloc] init];
    item.name = name;
    item.color = color;
    return item;
}
- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[ColorItem class]]) return NO;
    return [self.name isEqualToString:((ColorItem *)object).name];
}
- (NSUInteger)hash {
    return self.name.hash;
}
@end

#pragma mark - ColorCell

static NSString *const kCellReuseIdentifier = @"ColorCell";

@interface ColorCell : UICollectionViewCell
@property (nonatomic, strong) UIView *colorView;
@property (nonatomic, strong) UILabel *nameLabel;
@end

@implementation ColorCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _colorView = [[UIView alloc] init];
        _colorView.layer.cornerRadius = 12;
        _colorView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_colorView];

        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        _nameLabel.textColor = UIColor.labelColor;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_nameLabel];

        [NSLayoutConstraint activateConstraints:@[
            [_colorView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
            [_colorView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
            [_colorView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
            [_colorView.bottomAnchor constraintEqualToAnchor:_nameLabel.topAnchor constant:-8],

            [_nameLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
            [_nameLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
            [_nameLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
            [_nameLabel.heightAnchor constraintEqualToConstant:20],
        ]];
    }
    return self;
}

- (void)configureWithItem:(ColorItem *)item {
    self.colorView.backgroundColor = item.color;
    self.nameLabel.text = item.name;
}

@end

#pragma mark - ColorsViewController

@interface ColorsViewController () <PaginationDelegate>
@property (nonatomic, strong) NSMutableArray<ColorItem *> *colors;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger totalPages;
@end

@implementation ColorsViewController

- (instancetype)init {
    NSCollectionLayoutSize *itemSize =
        [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:0.5]
                                      heightDimension:[NSCollectionLayoutDimension fractionalWidthDimension:0.6]];
    NSCollectionLayoutItem *item = [NSCollectionLayoutItem itemWithLayoutSize:itemSize];
    item.contentInsets = NSDirectionalEdgeInsetsMake(8, 8, 8, 8);

    NSCollectionLayoutSize *groupSize =
        [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0]
                                      heightDimension:[NSCollectionLayoutDimension fractionalWidthDimension:0.6]];
    NSCollectionLayoutGroup *group =
        [NSCollectionLayoutGroup horizontalGroupWithLayoutSize:groupSize subitems:@[item]];

    NSCollectionLayoutSection *section = [NSCollectionLayoutSection sectionWithGroup:group];
    section.contentInsets = NSDirectionalEdgeInsetsMake(8, 8, 8, 8);

    UICollectionViewCompositionalLayout *layout =
        [[UICollectionViewCompositionalLayout alloc] initWithSection:section];

    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        _colors = [NSMutableArray array];
        _currentPage = 0;
        _totalPages = 5;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.collectionView.backgroundColor = UIColor.systemBackgroundColor;
    [self.collectionView registerClass:[ColorCell class]
            forCellWithReuseIdentifier:kCellReuseIdentifier];

    self.collectionView.pagination.delegate = self;
    self.collectionView.pagination.direction = PaginationDirectionVertical;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.colors.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ColorCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellReuseIdentifier
                                                               forIndexPath:indexPath];
    [cell configureWithItem:self.colors[indexPath.item]];
    return cell;
}

#pragma mark - PaginationDelegate

- (void)pagination:(Pagination *)pagination
    prefetchNextPageWithContext:(PaginationContext *)context {

    NSInteger nextPage = self.currentPage + 1;
    NSArray<NSDictionary *> *palette = ColorPalette();
    NSInteger pageSize = 20;

    // Simulate a network delay
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        NSMutableArray<ColorItem *> *newColors = [NSMutableArray array];
        for (NSInteger i = 0; i < pageSize; i++) {
            NSInteger globalIndex = (nextPage - 1) * pageSize + i;
            NSDictionary *entry = palette[globalIndex % palette.count];
            NSString *name = [NSString stringWithFormat:@"%@ %ld", entry[@"name"], (long)(globalIndex + 1)];
            [newColors addObject:[ColorItem itemWithName:name color:entry[@"color"]]];
        }

        [self.colors addObjectsFromArray:newColors];
        [self.collectionView reloadData];

        self.currentPage = nextPage;
        pagination.isEnabled = nextPage < self.totalPages;
        [context finish:YES];
    });
}

@end

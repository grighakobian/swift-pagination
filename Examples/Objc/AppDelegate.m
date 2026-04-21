#import "AppDelegate.h"
#import "RepositoriesViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];

    RepositoriesViewController *reposVC = [[RepositoriesViewController alloc] init];
    reposVC.title = @"Popular Repositories";

    UINavigationController *nav =
        [[UINavigationController alloc] initWithRootViewController:reposVC];
    nav.navigationBar.prefersLargeTitles = YES;

    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    return YES;
}

@end

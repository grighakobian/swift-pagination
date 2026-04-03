#import "AppDelegate.h"
#import "ColorsViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];

    ColorsViewController *colorsVC = [[ColorsViewController alloc] init];
    colorsVC.title = @"Colors";

    UINavigationController *nav =
        [[UINavigationController alloc] initWithRootViewController:colorsVC];
    nav.navigationBar.prefersLargeTitles = YES;

    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    return YES;
}

@end

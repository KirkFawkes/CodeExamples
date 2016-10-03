//
//  CPMainMenuViewController.m
//  CityParking
//
//  Created by Igor on 22.08.15.
//  Copyright (c) 2015 Fastforward. All rights reserved.
//

#import "CPMainMenuViewController.h"
#import "KFSlideMenuViewController.h"

#import "CPMainMenuViewModel.h"
#import "CPAboutViewController.h"

#import "CPAnalitics.h"
#import "CPNavigationController.h"
// services
#import "CPUserService.h"
#import "CPRouterService.h"
// categories
#import "UIStoryboard+CityParking.h"
// System
#import <PromiseKit/PromiseKit.h>
#import <PromiseKit/UIAlertView+PromiseKit.h>

NSString * const kMainMenuViewContollerShow = @"com.ff.slidemenu.show";
NSString * const kMainMenuViewContollerHide = @"com.ff.slidemenu.hide";
NSString * const kMainMenuViewContollerShowAuthorization = @"com.ff.slidemenu.ashow_uthorization";

NSString * const kMainMenuViewContollerShowViewController = @"com.ff.slidemenu.show.vc";

// Menu controllers IDs
NSString * const kMainMenuControllerSearchSpot = @"MapScreen";
NSString * const kMainMenuControllerPostSpot = @"PostSpotMapScreen";

static inline CPMainMenuItemModel *MenuItemMake(NSString *title, NSString *storyboardId, NSString *storyboardName, BOOL isEnabled, BOOL isRestricted) {
	return [CPMainMenuItemModel menuItmeWithTitle:title storyboardId:storyboardId storyboardName:storyboardName isEnabled:isEnabled isRestricted:isRestricted];
}

@interface CPMainMenuViewController () <CPMainMenuViewDelegate>
{
	CPMainMenuViewModel *_menuViewModel;
	NSMutableDictionary *_cachedViewControllers;
	BOOL _alreadyLoaded;
	dispatch_once_t _willAppearOnceToken;
}

@property (nonatomic, retain) KFSlideMenuViewController *slideMenu;
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (nonatomic, retain) id rootViewControllerId;
@property (nonatomic, retain) UIViewController *forcedViewController;
@end

@implementation CPMainMenuViewController

+ (instancetype)viewController
{
	return (id)[UIStoryboard cp_viewControllerWithIdentifier:@"MainMenuScreen" fromStoryboardName:@"Main"];
}

- (NSArray *)menuItems
{
	static NSArray *items;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		static NSString * const stroryboardMain = @"Main";
		static NSString * const stroryboardPayments = @"Payments";
		static NSString * const stroryboardProfile = @"Profile";
		
		NSMutableArray *array = [NSMutableArray array];
		[array addObject:MenuItemMake(NSLocalizedString(@"Rent a Spot", nil),		@"MapScreen",			stroryboardMain,		YES, NO)];
	//	[array addObject:MenuItemMake(NSLocalizedString(@"Post a Spot", nil),		@"PostSpotMapScreen",	stroryboardMain,		YES, NO)];
	//	[array addObject:MenuItemMake(NSLocalizedString(@"My Spots", nil),			@"FavoritesScreen",		stroryboardMain,		YES, YES)];
//		[array addObject:MenuItemMake(NSLocalizedString(@"Earn Free Parking", nil),	@"NotReadyScreen",		stroryboardMain,		YES, YES)];
//		[array addObject:MenuItemMake(NSLocalizedString(@"Promotions", nil),		@"PromocodesScreen",	stroryboardMain,		YES, YES)];
		[array addObject:MenuItemMake(NSLocalizedString(@"Payments", nil),			@"AccountsListScreen",	stroryboardPayments,	YES, YES)];
		[array addObject:MenuItemMake(NSLocalizedString(@"Profile", nil),			@"ProfileScreen",		stroryboardProfile,		YES, YES)];
        [array addObject:MenuItemMake(NSLocalizedString(@"Help", nil),			@"HelpScreen",		stroryboardMain,		YES, YES)];
         [array addObject:MenuItemMake(NSLocalizedString(@"About", nil),			@"AboutScreen",		stroryboardMain,		YES, YES)];
		items = [NSArray arrayWithArray:array];
	});
	
	return items;
}

- (UIViewController *)welcomeViewController
{
	return [UIStoryboard cp_viewControllerWithIdentifier:@"Auth" fromStoryboardName:@"WelcomeScreen"];
}

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self->_cachedViewControllers = [[NSMutableDictionary alloc] init];
	
	self.slideMenu = [[KFSlideMenuViewController alloc] init];
	self.slideMenu.menuView = [self bluredViewWithView:self.menuView];
	[self.view addSubview:self.slideMenu.view];
	[self addChildViewController:self.slideMenu];
	
	self->_menuViewModel = [[CPMainMenuViewModel alloc] initWithTableView:self.tableView];
	self->_menuViewModel.menuItems = [self menuItems];
	self->_menuViewModel.delegate = self;
	
	// Add icon to login button
	UIImage *loginButtonImage = [UIImage imageNamed:@"icon_login.png"];
	UIImageView *loginButtonImageView = [[UIImageView alloc] initWithImage:loginButtonImage];
	loginButtonImageView.frame = CGRectMake(0, 0, CGRectGetHeight(self.loginButton.bounds), CGRectGetHeight(self.loginButton.bounds));
	loginButtonImageView.frame = CGRectInset(loginButtonImageView.frame, 6, 6);
	loginButtonImageView.userInteractionEnabled = NO;
	[self.loginButton addSubview:loginButtonImageView];
	self.loginButton.titleEdgeInsets = UIEdgeInsetsMake(0, CGRectGetMaxX(loginButtonImageView.frame) + 6, 0, 0);

	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(showMenuNotification:) name:kMainMenuViewContollerShow object:nil];
	[nc addObserver:self selector:@selector(userChangedNotificaiton:) name:kCPUserServiceAuthorizationChanged object:nil];
	[nc addObserver:self selector:@selector(actLogin:) name:kMainMenuViewContollerShowAuthorization object:nil];
	[nc addObserver:self selector:@selector(actShowViewContoller:) name:kMainMenuViewContollerShowViewController object:nil];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
		
	[self updateUserInfo];
	
	dispatch_once(&self->_willAppearOnceToken, ^{
		if (self.forcedViewController)
		{
			self.slideMenu.rootViewController = self.forcedViewController;
		} else {
			id rootVCID = (self.rootViewControllerId == nil) ? [[self.menuItems firstObject] storyboardName] : self.rootViewControllerId;
			self.slideMenu.rootViewController = [UIStoryboard cp_viewControllerWithIdentifier:rootVCID];
		}
	});
}

#pragma mark -

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIView *)bluredViewWithView:(UIView *)view
{
	UIView *mView;
	
	if ([UIVisualEffectView class])
	{
		UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
		UIVisualEffectView *view = [[UIVisualEffectView alloc] initWithEffect:effect];
		mView = view;
	} else {
		UIToolbar *view = [[UIToolbar alloc] initWithFrame:CGRectZero];
		view.barStyle = UIBarStyleDefault;
		mView = view;
	}
	
	mView.frame = view.frame;
	[mView addSubview:view];
	view.frame = mView.bounds;
	view.backgroundColor = [UIColor clearColor];
	
	return mView;
}

- (void)showMenuNotification:(NSNotification *)notification
{
	DASSERTWARNING(self.analiticsService != nil);
	[self.analiticsService trackOpeningScreen:@"Menu Screen" withParams:nil];
	[self.slideMenu showMenu:YES animated:YES];
}

- (void)userChangedNotificaiton:(NSNotification *)notification
{
	[self updateUserInfo];
}

#pragma mark - CPMainMenuViewDelegate

- (void)mainMenuViewModel:(CPMainMenuViewModel *)model didSelectedItem:(CPMainMenuItemModel *)item
{
    NSLog(@"id ::%@",item.storyboardId);
    if([item.storyboardId isEqualToString:@"ProfileScreen"]||[item.storyboardId isEqualToString:@"AccountsListScreen"])
    {
        if (item.restricted && [[self.userService currentUser] isAuthorized] == NO) {
            [self actLogin:nil];
        } else {
            
            [self showViewControllerById:item.storyboardId storyboard:item.storyboardName animated:YES];
        }
    }
    else{
        
        [self showViewControllerById:item.storyboardId storyboard:item.storyboardName animated:YES];
        
    }
    
}

#pragma mark - Actions

- (IBAction)actLogin:(id)sender
{
	if ([self.userService.currentUser isAuthorized])
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Logout", nil)
															message:NSLocalizedString(@"Are you sure you want to logout?", nil)
														   delegate:nil
												  cancelButtonTitle:NSLocalizedString(@"No", nil)
												  otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
		[alertView promise].then(^(NSNumber *dismissedButtonIndex){
			if (dismissedButtonIndex.integerValue)
			{
				[self logout];
			}
		});
		
	} else {
		CPViewController *vc = (id)[UIStoryboard cp_viewControllerWithIdentifier:@"LoginScreen" fromStoryboardName:@"Auth"];
		CPNavigationController *nav = [[CPNavigationController alloc] initWithRootViewController:vc];
		[nav setNavigationBarHidden:YES animated:NO];
		
		if ([sender isKindOfClass:[NSNotification class]]) {
			id<CPViewControllerDelegate> delegate = (id)[(NSNotification *)sender object];
			
			if ([delegate conformsToProtocol:@protocol(CPViewControllerDelegate)]) {
				vc.delegate = sender;
			}
		}
		
		[self presentViewController:nav animated:YES completion:^{
			[self.slideMenu showMenu:NO animated:NO];
		}];
	}
}

- (IBAction)actShowViewContoller:(NSNotification *)sender
{
	[super awakeFromNib];
	
	DASSERT([sender isKindOfClass:[NSNotification class]]);
	DASSERT([sender.object isKindOfClass:[NSDictionary class]]);
	
	NSDictionary *params = sender.object;
	
	NSString *viewControllerName = params[@"name"];
	NSString *storyboardName = params[@"storyboard"];
	
	DASSERT(viewControllerName.length > 0);
	DASSERT(storyboardName.length > 0);
	
	BOOL usePopAnimation = [params[@"pop"] boolValue];
	NSDictionary *vc_params = params[@"params"];
	
	if (usePopAnimation) {
#warning need to implement switch with pop animation && send custom params to vc
//		UIViewController *vc = [self viewControllerById:viewControllerName];
//		DASSERT(vc != nil);
		[self showViewControllerById:viewControllerName storyboard:storyboardName animated:YES withParams:vc_params];
	} else {
		[self showViewControllerById:viewControllerName storyboard:storyboardName animated:YES withParams:vc_params];
	}
	
	self.forcedViewController = nil;
}

#pragma mark - Helpers

- (void)updateUserInfo
{
	DASSERTWARNING(self.userService != nil);
	
	NSString *title = [self.userService.currentUser isAuthorized] ? NSLocalizedString(@"Logout", nil) : NSLocalizedString(@"Login", nil);
	[self.loginButton setTitle:title forState:UIControlStateNormal];
}

- (void)logout
{
	DASSERTWARNING(self.userService != nil);
	
	self.loginButton.enabled = NO;
	[self.userService logout].then(^{
		[[NSNotificationCenter defaultCenter] postNotificationName:kCPUserServiceAuthorizationChanged object:nil];
		[self openWelcomeViewController];
	}).finally(^{
		self.loginButton.enabled = YES;
	});
}

#pragma mark - Helpers

- (void)openWelcomeViewController
{
	UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Auth" bundle:[NSBundle mainBundle]];
	UIViewController *vc = sb.instantiateInitialViewController;
	
	CPRouterServiceAnimationParams *params = [CPRouterServiceAnimationParams new];
	params.afterUpdates = NO;
	[self.routerService setRootViewController:vc withParams:params];
}

- (UIViewController *)viewControllerById:(nonnull NSString *)viewControllerId fromStoryboard:(nonnull NSString *)storyboardName
{
	UIViewController *vc = self->_cachedViewControllers[viewControllerId];
	if (vc == nil)
	{
		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
		vc = [storyboard instantiateViewControllerWithIdentifier:viewControllerId];
		self->_cachedViewControllers[viewControllerId] = vc;
	}
	
	return vc;
}

- (void)showViewControllerById:(NSString *)viewControllerId storyboard:(NSString *)storyboard animated:(BOOL)animated
{
	[self showViewControllerById:viewControllerId storyboard:storyboard animated:animated withParams:nil];
}

- (void)showViewControllerById:(NSString *)viewControllerId storyboard:(NSString *)storyboard animated:(BOOL)animated withParams:(NSDictionary *)params
{
	if ([self.slideMenu isOpened]) {
		[self.slideMenu showMenu:NO animated:animated];
	}
	
	if ([self.rootViewControllerId isEqual:viewControllerId]) {
		return;
	}
	
	UIViewController *rvc = [self viewControllerById:viewControllerId fromStoryboard:storyboard];
	if (![rvc isKindOfClass:[UINavigationController class]]) {
		rvc = [[CPNavigationController alloc] initWithRootViewController:rvc];
	}
    
	
	CPViewController *vc = (id)rvc;
	if ([vc isKindOfClass:[UINavigationController class]]) {
		vc = [(UINavigationController *)vc viewControllers].firstObject;
        
	}
    
	
	if ([vc isKindOfClass:[CPViewController class]] && params != nil) {
		[vc showWithParams:params];
	}
    if ([vc isKindOfClass:[CPAboutViewController class]]) {
        CPAboutViewController *vcs = (CPAboutViewController*)vc;
        vcs.loadingURL =kAboutURL;
    }
   
	
	self.rootViewControllerId = viewControllerId;
	self.slideMenu.rootViewController = rvc;
	self.forcedViewController = nil;
}

- (void)showViewController:(UIViewController *)vc animated:(BOOL)animated
{
	DASSERT(vc != nil);
	
	self.rootViewControllerId = nil;
	self.forcedViewController = vc;
	self.slideMenu.rootViewController = vc;
}

@end

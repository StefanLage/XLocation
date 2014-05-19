//
//  LXLocation.m
//  LXLocation
//
//  Created by Stefan Lage on 16/05/14.
//    Copyright (c) 2014 StefanLage. All rights reserved.
//

#import "LXLocation.h"
// Xcode
#import "IDEWorkspace.h"
#import "DVTFilePath.h"
#import "IDEIndex.h"
#import "IDEIndexCollection.h"
#import "IDEEditorDocument.h"
#import "IDEWorkspaceWindow.h"
#import "DVTSourceTextView.h"
#import "XcodeEditor.h"
// Gpx format
#import "NSString+Gpx.h"
// Window
#import "LWindow.h"
// Annotation
#import "LAnnotation.h"
// MapView
#import "LMapView.h"

// Singleton
static LXLocation *sharedPlugin;
// Google Map URL Request
static NSString * const gMapUrlRequestFromAddress     = @"http://maps.google.com/maps/api/geocode/json?address=%@,%@,%@,%@&sensor=false";
static NSString * const gMapUrlRequestFromCoordinates = @"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=false";
// Default Alert Messages
static NSString * const defaultErrorDesc = @"Something went wrong!\nCannot find the address!";
static NSString * const addressNotFound  = @"Address not found!";
static NSString * const projectNotFound  = @"Xcode project not found at path: %@";
static NSString * const noPointSelected  = @"Please select a location first!";
static NSString * const generateDone     = @"File %@.gpx created! This one has been added to your current project in the Group named GPX.";


@interface LXLocation()

@property (nonatomic, strong) NSBundle    * bundle;
@property (nonatomic, copy  ) NSString    * currentWorkspaceFilePath;
@property (nonatomic, copy  ) NSString    * currentXcodeProject;
@property (nonatomic, strong) NSMenuItem  * actionItem;
@property (nonatomic, strong) LWindow     * locationsWindow;
@property (nonatomic, strong) LAnnotation * pAnnotation;

// IBOutlets
@property (weak) IBOutlet NSTextField * filenameField;
@property (weak) IBOutlet NSTextField * addressField;
@property (weak) IBOutlet NSTextField * cityField;
@property (weak) IBOutlet NSTextField * postalCodeField;
@property (weak) IBOutlet NSTextField * countryField;
@property (weak) IBOutlet NSButton    * cancelBtn;
@property (weak) IBOutlet NSButton    * generateBtn;
@property (weak) IBOutlet NSButton    * cancelMap;
@property (weak) IBOutlet NSButton    * generateMap;
@property (weak) IBOutlet LMapView    * mapView;
@property (weak) IBOutlet NSTextField * addressLbl;

@end


@implementation LXLocation

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource acccess
        self.bundle = plugin;
        // Adds all observers
        [self addObservers];
        // Create new menu item in Debug
        NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Debug"];
        if (menuItem) {
            [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
            self.actionItem = [[NSMenuItem alloc] initWithTitle:@"Add new Location"
                                                         action:@selector(addNewLocationMenu)
                                                  keyEquivalent:@""];
            [[menuItem submenu] addItem:self.actionItem];
            // Init interface
            [self loadWindow];
        }
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObservers];
}

#pragma mark - Observers management

- (void)addObservers {
    // Register to notification center
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(workspaceWindowDidBecomeMain:)
                                                 name:NSWindowDidBecomeMainNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(findLocationFromPoint:)
                                                 name:@"findLocationFromPointNotification"
                                               object:nil];
}

- (void)removeObservers {
    // Remove from notification center
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSWindowDidBecomeMainNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"findLocationFromPointNotification"
                                                  object:nil];
}

#pragma mark - NSNotifications

// Get current Workspace
- (void)workspaceWindowDidBecomeMain:(NSNotification *)notification
{
    if ([[notification object] isKindOfClass:[IDEWorkspaceWindow class]]) {
        NSWindow *workspaceWindow                     = (NSWindow *)[notification object];
        NSWindowController *workspaceWindowController = (NSWindowController *)workspaceWindow.windowController;
        IDEWorkspace *workspace                       = (IDEWorkspace *)[workspaceWindowController valueForKey:@"_workspace"];
        DVTFilePath *representingFilePath             = workspace.representingFilePath;
        NSString *pathString                          = [representingFilePath.pathString stringByReplacingOccurrencesOfString:representingFilePath.fileName
                                                                                                                   withString:@""];
        // Save these informations
        self.currentXcodeProject                      = [representingFilePath.pathString stringByReplacingOccurrencesOfString:@".xcworkspace"
                                                                                                                   withString:@".xcodeproj"];
        self.currentWorkspaceFilePath                 = pathString;
        // Enable action button
        [self.actionItem setTarget:self];
    }
}

- (void)findLocationFromPoint:(NSNotification *)notification{
    if([notification.object isKindOfClass:[CLLocation class]]){
        [self cleanMap];
        CLLocation *loc = notification.object;
        [self findAddress:loc.coordinate];
    }
}

#pragma mark - Handler

// Sample Action, for menu item:
- (void)addNewLocationMenu
{
    if(self.currentWorkspaceFilePath && ![self.currentWorkspaceFilePath isEqualToString:@""])
        [self showWindow];
}

#pragma mark - Internal methods

-(void)showAlert:(NSString*)msg withDelegate:(id)delegate{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:msg];
    if(delegate)
        [alert beginSheetModalForWindow:self.locationsWindow
                          modalDelegate:delegate
                         didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                            contextInfo:nil];
    else
        [alert beginSheetModalForWindow:self.locationsWindow
                          modalDelegate:nil
                         didEndSelector:nil
                            contextInfo:nil];
}

// Be sure every field required are informed
-(BOOL)isRequiredInformed:(NSString*) city country:(NSString*)country{
    if([city isEqualToString:@""]
       || [country isEqualToString:@""]){
        [self showAlert:@"Please inform required fields!"
           withDelegate:nil];
        return NO;
    }
    else
        return YES;
}

/*
 * Get address from coordinates
 */
-(void)findAddress:(CLLocationCoordinate2D)location
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Form url
        NSString *url = [NSString stringWithFormat:gMapUrlRequestFromCoordinates,location.latitude,location.longitude];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
        // Get coordinates from address informed
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if(error || !data){
                                       // Error -> show alert
                                       [self showAlert:defaultErrorDesc
                                          withDelegate:nil];
                                       return;
                                   }
                                   NSError *errorJson = nil;
                                   id JSON = [NSJSONSerialization JSONObjectWithData:data
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:&errorJson];
                                   // Check the response status
                                   if(!errorJson){
                                       // Does the address exist ?
                                       if([[JSON objectForKey:@"status"] isEqualToString:@"OK"]){
                                           if([JSON objectForKey:@"results"]
                                              && [[JSON objectForKey:@"results"] count] > 0){
                                               // Save address
                                               NSString *city    = @"";
                                               NSString *country = @"";
                                               NSString *address = @"";
                                               NSString *zipCode = @"";
                                               for(NSDictionary* ar in JSON[@"results"][0][@"address_components"]){
                                                   if([ar objectForKey:@"types"]){
                                                       NSString *type = [ar objectForKey:@"types"][0];
                                                       NSString *value = [ar objectForKey:@"long_name"];
                                                       if([type isEqualToString:@"route"]){
                                                           address = value;
                                                       }
                                                       else if ([type isEqualToString:@"locality"]){
                                                           city = value;
                                                       }
                                                       else if ([type isEqualToString:@"country"]){
                                                           country = value;
                                                       }
                                                       else if ([type isEqualToString:@"postal_code"]){
                                                           zipCode = value;
                                                       }
                                                   }
                                               }
                                               if([city isEqualToString:@""] || [country isEqualToString:@""]){
                                                   // Not found
                                                   [self showAlert:addressNotFound
                                                      withDelegate:nil];
                                               }
                                               else{
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       // Adds annotation
                                                       self.pAnnotation = [[LAnnotation alloc] initWithCity:city
                                                                                                    country:country
                                                                                                    address:address
                                                                                                    zipCode:zipCode
                                                                                                   location:location];
                                                       [self.mapView addAnnotation:self.pAnnotation.annotation];
                                                       [self.addressLbl setStringValue:[self.pAnnotation concatAddress]];
                                                   });
                                               }
                                           }
                                       }
                                   }
                                   else{
                                       // Error -> Wrong address
                                       [self showAlert:defaultErrorDesc
                                          withDelegate:nil];
                                   }
                               }];
    });
}

/*
 * Get coordinates from address informed
 * Then generate the GPX file -> create a group named GPX into the current xcode project and add the gpx file to it
 */
-(void)generateGpx:(NSString*)filename address:(NSString*)ad city:(NSString*)ci postalCode:(NSString*)zip country:(NSString*)co{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Form url
        NSString *url = [NSString stringWithFormat:gMapUrlRequestFromAddress, ad, zip, ci, co];
        NSData *temp  = [url dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        url           = [[[NSString alloc] initWithData:temp encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        // Get coordinates from address informed
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if(error || !data){
                                       // Error -> show alert
                                       [self showAlert:defaultErrorDesc
                                          withDelegate:nil];
                                       return;
                                   }
                                   NSError *errorJson = nil;
                                   id JSON = [NSJSONSerialization JSONObjectWithData:data
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:&errorJson];
                                   if(!errorJson){
                                       // Does the address exist ?
                                       if([[JSON objectForKey:@"status"] isEqualToString:@"OK"]){
                                           if([[JSON objectForKey:@"results"] objectAtIndex:0]
                                              && [[[JSON objectForKey:@"results"] objectAtIndex:0] objectForKey:@"geometry"]
                                              && [[[[JSON objectForKey:@"results"] objectAtIndex:0] objectForKey:@"geometry"] objectForKey:@"location"]){
                                               // Save coordinates
                                               NSNumber *lat      = JSON[@"results"][0][@"geometry"][@"location"][@"lat"];
                                               NSNumber *lng      = JSON[@"results"][0][@"geometry"][@"location"][@"lng"];
                                               // Save the file
                                               [self generateGpxWithFilename:filename
                                                                     address:ad
                                                                        city:ci
                                                                  postalCode:zip
                                                                     country:co
                                                                         lat:lat
                                                                         lng:lng];
                                           }
                                       }
                                   }
                                   else{
                                       // Error -> show alert
                                       [self showAlert:defaultErrorDesc
                                          withDelegate:nil];
                                   }
                               }];
    });
}

-(void)generateGpxWithFilename:(NSString*)filename address:(NSString*)ad city:(NSString*)ci postalCode:(NSString*)zip country:(NSString*)co lat:(NSNumber*)lat lng:(NSNumber*)lng{
    // Project found ?
    if([[NSFileManager defaultManager] fileExistsAtPath:self.currentXcodeProject]){
        @try {
            // Be sure there is no space in the filename
            filename = [filename stringByReplacingOccurrencesOfString:@" " withString:@"_"];
            XCProject* project = [[XCProject alloc] initWithFilePath:self.currentXcodeProject];
            XCGroup* group     = [project groupWithPathFromRoot:@"GPX"];
            // GPX Group doesn't exist ?!
            if(!group){
                [[project rootGroup] addGroupWithPath:@"GPX"];
                // Re-init it
                group          = [project groupWithPathFromRoot:@"GPX"];
                [project save];
            }
            // Create a gpx file source
            XCSourceFileDefinition* sourceFileDefinition = [[XCSourceFileDefinition alloc] initWithName:[NSString stringWithFormat:@"%@.gpx", filename]
                                                                                                   text:[NSString generateGpxWithFilename:filename
                                                                                                                                 latitude:lat
                                                                                                                                longitude:lng
                                                                                                                                  address:ad
                                                                                                                                     city:ci
                                                                                                                                  country:co
                                                                                                                                      zip:zip]
                                                                                                   type:GPX];
            // Add it to the current xcode project
            [group addSourceFile:sourceFileDefinition];
            dispatch_async(dispatch_get_main_queue(), ^{
                [project save];
                // Everything done -> show alert
                [self showAlert:[NSString stringWithFormat:generateDone, filename]
                   withDelegate:self];
            });
        }
        @catch (NSException *exception) {
            [self showAlert:[NSString stringWithFormat:projectNotFound, self.currentXcodeProject]
               withDelegate:self];
        }
    }
    else{
        [self showAlert:[NSString stringWithFormat:projectNotFound, self.currentXcodeProject]
           withDelegate:self];
    }
}

/*
 * Remove annotation from the map + reset addressLbl text
 */
-(void)cleanMap{
    if(self.pAnnotation){
        [self.mapView removeAnnotations:self.mapView.annotations];
        self.pAnnotation = nil;
    }
    [self.addressLbl setStringValue:@"?"];
}

#pragma mark - Modal delegate

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo{
    [self close];
}

#pragma mark - UI
#pragma mark - LWindow management

/*
 * Get main window from the nib file LWindow.xib
 */
- (void) loadWindow{
    NSArray *topLevelObjects = nil;
    [self.bundle loadNibNamed:@"LWindow" owner:self topLevelObjects:&topLevelObjects];
    for (id object in topLevelObjects) {
        if ([object isKindOfClass:[NSWindow class]]) {
            NSWindow *window = (NSWindow *)object;
            if ([window.identifier isEqualToString:@"LocationWindow"]) {
                self.locationsWindow = (LWindow*)window;
            }
        }
    }
}

- (void)showWindow
{
    [[NSApp keyWindow] beginSheet:self.locationsWindow completionHandler:^(NSModalResponse returnCode) {
        [self.locationsWindow orderOut:self];
    }];
}

/*
 * Enable / Disable the buttons
 */
-(void)enableDisableActions:(BOOL)value{
    // Disable TabItem 1
    [[self cancelMap] setEnabled:value];
    [[self generateMap] setEnabled:value];
    // Disable TabItem 2
    [[self cancelBtn] setEnabled:value];
    [[self generateBtn] setEnabled:value];
}

/*
 *  Reset all NSTextField's text
 *  Set filenameField as first responder
 */
-(void)resetFields{
    // Reset all textfields
    [self.filenameField setStringValue:@""];
    [self.addressField setStringValue:@""];
    [self.cityField setStringValue:@""];
    [self.postalCodeField setStringValue:@""];
    [self.countryField setStringValue:@""];
    [self.filenameField becomeFirstResponder];

    // Clean the map
    [self cleanMap];
    // Reset map region
    [self.mapView resetRegion];

    // Enable button
    [self enableDisableActions:YES];
}

/*
 * Reset the interface then close the window
 */
- (void) close{
    [self resetFields];
    // Dismiss the window
    NSWindow *sheetWindow = self.locationsWindow.sheetParent;
    [self.locationsWindow close];
    [sheetWindow endSheet:self.locationsWindow];
}

#pragma mark - LWindow Handlers

- (IBAction)cancel:(id)sender {
    [self close];
}

/*
 * Start the process to generate a gpx
 */
- (IBAction)generateFromAddress:(id)sender {
    // Save values
    __block NSString *address  = ([[self.addressField stringValue] isEqualToString:@""]) ? @"Downtown" : [self.addressField stringValue];
    __block NSString *city     = [self.cityField stringValue];
    __block NSString *filename = ([[self.filenameField stringValue] isEqualToString:@""]) ? city : [self.filenameField stringValue];
    filename                   = [[NSString alloc] initWithData:[filename dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]
                                                       encoding:NSASCIIStringEncoding];
    __block NSString *pCode    = [self.postalCodeField stringValue];
    __block NSString *country  = [self.countryField stringValue];
    // Continue ?
    if([self isRequiredInformed:city country:country]){
        // Disable button
        [self enableDisableActions:NO];
        // Generate the file
        [self generateGpx:filename
                  address:address
                     city:city
               postalCode:pCode
                  country:country];
    }
}

- (IBAction)generateFromMap:(id)sender {
    if(!self.pAnnotation){
        // No point selected
        [self showAlert:noPointSelected
           withDelegate:nil];
        return;
    }
    else{
        NSString *address  = self.pAnnotation.address;
        NSString *city     = self.pAnnotation.city;
        NSString *filename = [[NSString alloc] initWithData:[city dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]
                                                   encoding:NSASCIIStringEncoding];
        NSString *pCode    = self.pAnnotation.zipCode;
        NSString *country  = self.pAnnotation.country;
        NSNumber *lat      = @(self.pAnnotation.annotation.coordinate.latitude);
        NSNumber *lng      = @(self.pAnnotation.annotation.coordinate.longitude);
        // Continue ?
        if([self isRequiredInformed:city country:country]){
            // Disable button
            [self enableDisableActions:NO];
            // Generate the file
            [self generateGpxWithFilename:filename
                                  address:address
                                     city:city
                               postalCode:pCode
                                  country:country
                                      lat:lat
                                      lng:lng];
        }
    }
}

@end
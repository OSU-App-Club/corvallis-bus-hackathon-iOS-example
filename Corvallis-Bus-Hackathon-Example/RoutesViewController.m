//
//  SecondViewController.m
//  Corvallis-Bus-Hackathon-Example
//
//  Created by Russell Barnes on 4/17/14.
//  Copyright (c) 2014 Russell Barnes. All rights reserved.
//

#import "RoutesViewController.h"
#import <GoogleMaps/GoogleMaps.h>

#define CORVALLIS_LAT 44.571319
#define CORVALLIS_LONG -123.275147


@interface RoutesViewController ()

@property (nonatomic, strong) NSArray *routes;

@end

@implementation RoutesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Retrieve the routes from the server:
    [self getRoutes];
}

- (void)getRoutes
{
    // Request all bus routes from the server
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:@"http://www.corvallis-bus.appspot.com/routes"]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                
                // Parse JSON result and store in dictionary (self.routes)
                
                NSError *jsonError;
                self.routes = [[NSJSONSerialization JSONObjectWithData:data
                                                              options:NSJSONReadingAllowFragments
                                                                error:&jsonError] objectForKey:@"routes"];
                if (jsonError != nil) {
                    NSLog(@"JSON error while requesting stops from server");
                    return;
                }
                
                // This is how to access route data:
                NSLog(@"First route - Name: %@ - Description: %@",
                      [[self.routes objectAtIndex:0] objectForKey:@"AdditionalName"],
                      [[self.routes objectAtIndex:0] objectForKey:@"Description"]);
                
                // Now, display all known routes on the map:
                [self showRoutes];
            }
      ] resume];
}

- (void)showRoutes
{
    // Running Google Maps on the main thread may lead to higher stability and performance
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        
        // Initialize the map
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude: CORVALLIS_LAT
                                                                longitude: CORVALLIS_LONG
                                                                     zoom:12];
        GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
        self.view = mapView;
        
        // --- Plot each bus route on the map ---
        for (NSDictionary *route in self.routes) {
            
            // Set the polyline's path
            GMSPolyline *polyline = [GMSPolyline polylineWithPath:[GMSPath pathFromEncodedPath:[route objectForKey:@"Polyline"]]];
            
            polyline.strokeWidth = 5.f;
            polyline.map = mapView;
            
            // Convert color from hex string (i.e. #RRGGBB)
            NSScanner *scanner = [NSScanner scannerWithString:route[@"Color"]];
            unsigned rgbValue = 0;
            [scanner scanHexInt:&rgbValue];
            polyline.strokeColor = [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];

        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

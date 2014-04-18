//
//  FirstViewController.m
//  Corvallis-Bus-Hackathon-Example
//
//  Created by Russell Barnes on 4/17/14.
//  Copyright (c) 2014 Russell Barnes. All rights reserved.
//
//  See https://developers.google.com/maps/documentation/ios/reference/interface_g_m_s_marker
//  for more details on the Google Maps SDK.

#import "StopsViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface StopsViewController ()

// Dictionary to hold bus stops
@property (nonatomic, strong) NSArray *stops;

@end

@implementation StopsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Retrieve the stops from the server:
    [self getStops];
}

- (void)getStops
{
    // Request all bus stops from the server
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:@"http://www.corvallis-bus.appspot.com/stops"]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
    
                // Parse JSON result and store in dictionary (self.stops)
            
                NSError *jsonError;
                self.stops = [[NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingAllowFragments
                                                               error:&jsonError] objectForKey:@"stops"];
                if (jsonError != nil) {
                    NSLog(@"JSON error while requesting stops from server");
                    return;
                }
                
                // This is how to access stop data:
                NSLog(@"First location - Lat: %f Long: %f",
                      [[[self.stops objectAtIndex:0] objectForKey:@"Lat"] floatValue],
                      [[[self.stops objectAtIndex:0] objectForKey:@"Long"] floatValue]);
                
                // Now, display all known points on the map:
                [self showStops];
            }
      ] resume];
}

- (void)showStops
{
    // Running Google Maps on the main thread may lead to higher stability and performance
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        
        // Initialize the map
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:44.571319
                                                                longitude:-123.275147
                                                                     zoom:12];
        GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
        self.view = mapView;
        
        // --- Plot each bus stop on the map ---
        
        int len = [self.stops count];
        for (int i = 0; i < len; i++) {
            GMSMarker *marker = [[GMSMarker alloc] init];
            
            // Set the marker's location to that of the bus stop:
            marker.position =
            CLLocationCoordinate2DMake([[[self.stops objectAtIndex:i] objectForKey:@"Lat"] floatValue],
                                       [[[self.stops objectAtIndex:i] objectForKey:@"Long"] floatValue]);
            
            // Set marker properties
            marker.snippet = [[self.stops objectAtIndex:i] objectForKey:@"Name"];
            marker.appearAnimation = kGMSMarkerAnimationPop;
            marker.map = mapView;
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

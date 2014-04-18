//
//  SecondViewController.m
//  Corvallis-Bus-Hackathon-Example
//
//  Created by Russell Barnes on 4/17/14.
//  Copyright (c) 2014 Russell Barnes. All rights reserved.
//

#import "RoutesViewController.h"
#import <GoogleMaps/GoogleMaps.h>

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
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:44.571319
                                                                longitude:-123.275147
                                                                     zoom:12];
        GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
        self.view = mapView;
        
        // --- Plot each bus route on the map ---
        
        int len = [self.routes count];
        for (int i = 0; i < len; i++) {
            
            // Set the polyline's path
            GMSPolyline *polyline = [GMSPolyline polylineWithPath:[GMSPath pathFromEncodedPath:[[self.routes objectAtIndex:i] objectForKey:@"Polyline"]]];
            
            polyline.strokeColor = [self randomColor];
            polyline.strokeWidth = 5.f;
            polyline.map = mapView;
        }
    }];
}

- (UIColor *)randomColor
{
    // Thanks to https://github.com/kylefox for this code!
    /*
     
     Distributed under The MIT License:
     http://opensource.org/licenses/mit-license.php
     
     Permission is hereby granted, free of charge, to any person obtaining
     a copy of this software and associated documentation files (the
     "Software"), to deal in the Software without restriction, including
     without limitation the rights to use, copy, modify, merge, publish,
     distribute, sublicense, and/or sell copies of the Software, and to
     permit persons to whom the Software is furnished to do so, subject to
     the following conditions:
     
     The above copyright notice and this permission notice shall be
     included in all copies or substantial portions of the Software.
     
     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
     EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
     NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
     LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
     OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
     WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
     */
    
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    return color;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
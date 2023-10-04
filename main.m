// main.m

// #import <Foundation/Foundation.h>
// import <UIKit/UIKit.h>
#import "HealthMetricsServer.h"
#import <GRPCClient/GRPCCall.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // Create an instance of your gRPC server and start it
        HealthMetricsServer *server = [[HealthMetricsServer alloc] init];
        [server startWithPort:50051]; // Replace with your desired port number

        // Run the server
        NSLog(@"Server started on port 50051"); // Adjust the log message as needed
        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
}

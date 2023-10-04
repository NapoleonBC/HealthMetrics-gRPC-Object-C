// HealthMetricsServer.m

#import "HealthMetricsServer.h"
#import <HealthMetrics/HealthMetrics.pbobjc.h> // Replace with your proto file name and package

@implementation HealthMetricsServer

- (void)streamMetricsWithRequest:(GRPCStreamingProtoCall *)request handler:(void (^)(GRXWriter *, NSError *))handler {
    // Implement the logic to handle the streamed metrics data from the client
    // You can access the request data using 'request.requestData' property

    // Process the data, store it, or perform any necessary actions

    // Once processing is complete, you can return a response or handle errors
    // Create a response message if needed
    HealthMetricsEmpty *response = [HealthMetricsEmpty message];

    // Call the handler with the response message or an error
    handler([[response delimitedData] grx]);
}

// Implement other service methods here

@end

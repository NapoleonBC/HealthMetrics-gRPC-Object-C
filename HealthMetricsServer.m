// HealthMetricsServer.m

#import "HealthMetricsServer.h"
#import <HealthMetrics/HealthMetrics.pbobjc.h>

@interface HealthMetricsServer ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<HealthMetric *> *> *metricData;
@property (nonatomic, strong) NSMutableArray<MetricConfiguration *> *configuredMetrics;

@end

@implementation HealthMetricsServer

- (instancetype)init {
    self = [super init];
    if (self) {
        _metricData = [NSMutableDictionary dictionary];
        _configuredMetrics = [NSMutableArray array];
    }
    return self;
}

- (void)streamMetricsWithRequest:(GRPCStreamingProtoCall *)request handler:(void (^)(GRXWriter *, NSError *))handler {
    [request receiveNextMessageWithHandler:^(HealthMetric *metric, NSError *errorOrNil) {
        if (errorOrNil) {
            // Handle error
            NSLog(@"Error streaming metric: %@", errorOrNil);
            handler(nil, errorOrNil);
            return;
        }

        // Process the streamed metric
        [self processMetric:metric];

        // Acknowledge receipt of the metric
        HealthMetricsEmpty *response = [HealthMetricsEmpty message];
        handler([[response delimitedData] grx]);
    }];

    [request finishWithError:nil];
}

- (void)configureMetricsWithRequest:(GRPCStreamingProtoCall *)request handler:(void (^)(GRXWriter *, NSError *))handler {
    [request receiveNextMessageWithHandler:^(MetricConfiguration *config, NSError *errorOrNil) {
        if (errorOrNil) {
            // Handle error
            NSLog(@"Error configuring metrics: %@", errorOrNil);
            handler(nil, errorOrNil);
            return;
        }

        // Store the configured metrics
        [self.configuredMetrics addObject:config];

        // Acknowledge receipt of the configuration
        HealthMetricsEmpty *response = [HealthMetricsEmpty message];
        handler([[response delimitedData] grx]);
    }];

    [request finishWithError:nil];
}

- (void)getMetricsWithRequest:(GRPCStreamingProtoCall *)request handler:(void (^)(GRXWriter *, NSError *))handler {
    [request receiveNextMessageWithHandler:^(MetricConfiguration *config, NSError *errorOrNil) {
        if (errorOrNil) {
            // Handle error
            NSLog(@"Error retrieving metrics: %@", errorOrNil);
            handler(nil, errorOrNil);
            return;
        }

        // Retrieve and send requested metrics based on the configuration
        [self sendMetricsForConfiguration:config toHandler:handler];
    }];

    [request finishWithError:nil];
}

- (void)checkStatusWithRequest:(HealthMetricsEmpty *)request handler:(void (^)(HealthMetricsEmpty *, NSError *))handler {
    // Implement server status check logic if needed
    HealthMetricsEmpty *response = [HealthMetricsEmpty message];
    handler(response, nil);
}

- (void)logDiagnosticInfoWithRequest:(StringValue *)request handler:(void (^)(HealthMetricsEmpty *, NSError *))handler {
    NSLog(@"Diagnostic Info: %@", request.value);
    HealthMetricsEmpty *response = [HealthMetricsEmpty message];
    handler(response, nil);
}

- (void)reportErrorWithRequest:(StringValue *)request handler:(void (^)(HealthMetricsEmpty *, NSError *))handler {
    NSLog(@"Error: %@", request.value);
    HealthMetricsEmpty *response = [HealthMetricsEmpty message];
    handler(response, nil);
}

#pragma mark - Private Methods

- (void)processMetric:(HealthMetric *)metric {
    // Store the metric data in the appropriate data structure
    NSMutableArray<HealthMetric *> *metricsForName = self.metricData[metric.metric_name];
    if (!metricsForName) {
        metricsForName = [NSMutableArray array];
        self.metricData[metric.metric_name] = metricsForName;
    }
    [metricsForName addObject:metric];
}

- (void)sendMetricsForConfiguration:(MetricConfiguration *)config toHandler:(void (^)(GRXWriter *, NSError *))handler {
    NSMutableArray<HealthMetric *> *requestedMetrics = [NSMutableArray array];

    for (NSString *metricName in config.metric_names) {
        NSMutableArray<HealthMetric *> *metricsForName = self.metricData[metricName];
        if (metricsForName) {
            // Add the requested metrics to the response
            [requestedMetrics addObjectsFromArray:metricsForName];
        }
    }

    // Create a stream of requested metrics
    GRXWriter *writer = [[GRXWriter writerWithValue:[HealthMetric class]] writerWithValue:requestedMetrics];

    handler(writer, nil);
}

@end

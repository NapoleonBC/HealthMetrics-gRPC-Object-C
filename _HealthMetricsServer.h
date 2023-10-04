// HealthMetricsServer.h

#import <Foundation/Foundation.h>
#import <GRPCClient/GRPCCall.h>

@interface HealthMetricsServer : NSObject <GRPCHealthMetricsService>
@end

//
//  NSData+NSInputStream.m
//  CityParking
//
//  Created by Igor Zubko on 17.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "NSData+NSInputStream.h"

#define BUFSIZE 65536U
@implementation NSData (NSInputStream)

+ (NSData *)cp_dataWithContentsOfStream:(NSInputStream *)input initialCapacity:(NSUInteger)capacity error:(NSError **)error
{
	size_t bufsize = MIN(BUFSIZE, capacity);
	uint8_t *buf = malloc(bufsize);
	
	if (buf == NULL)
	{
		if (error) {
			*error = [NSError errorWithDomain:NSPOSIXErrorDomain code:ENOMEM userInfo:nil];
		}
		return nil;
	}
	
	NSMutableData *result = capacity == NSUIntegerMax ? [NSMutableData data] : [NSMutableData dataWithCapacity:capacity];
	@try {
		while (true)
		{
			NSInteger n = [input read:buf maxLength:bufsize];
			if (n < 0)
			{
				result = nil;
				if (error) {
					*error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil];
				}
				break;
			} else if (n == 0) {
				break;
			} else {
				[result appendBytes:buf length:n];
			}
		}
	} @catch (NSException * exn) {
		DLOG(@"Caught exception writing to file: %@", exn);
		result = nil;
		if (error) {
			*error = [NSError errorWithDomain:NSPOSIXErrorDomain code:EIO userInfo:nil];
		}
	}
	
	free(buf);
	
	return result;
}

- (NSString *)toString
{
	return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}

- (NSString *)togHexSting
{
	const char *data = self.bytes;
	NSMutableString *hexString = [NSMutableString string];
	
	for (int i = 0; i < self.length; i++) {
		[hexString appendFormat:@"%02.2hhX", data[i]];
	}

	return [NSString stringWithString:hexString];
}

@end
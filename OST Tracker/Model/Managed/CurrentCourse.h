#import "_CurrentCourse.h"

@interface CurrentCourse : _CurrentCourse
// Custom logic goes here.

+ (CurrentCourse*) getCurrentCourse;
- (NSArray*) getSplitInIds;
- (NSArray*) getSplitOutIds;

@end

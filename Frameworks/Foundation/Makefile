FRAMEWORK=Foundation
MK_AUTO_OBJ=yes
NO_FMWK_COMMON=yes
.include "../framework.common.mk"


SRCS= \
	NSFormatter.m \
	NSDictionary/NSEnumerator_dictionaryObjects.m \
	NSDictionary/NSMutableDictionary.m \
	NSDictionary/NSEnumerator_dictionaryKeys.m \
	NSDictionary/NSDictionary.m \
	NSDictionary/NSMutableDictionary_mapTable.m \
	NSDictionary/NSDictionary_mapTable.m \
	NSArchiver.m \
	NSAssertionHandler.m \
	NSTimeZone/NSTimeZone.m \
	NSTimeZone/NSTimeZone_absolute.m \
	NSTimeZone/NSTimeZoneTransition.m \
	NSTimeZone/NSTimeZoneType.m \
	NSStream/NSOutputStream_socket.m \
	NSStream/NSSelectInputSourceSet.m \
	NSStream/NSFileHandle_stream.m \
	NSStream/NSFileHandle.m \
	NSStream/NSSocket.m \
	NSStream/CFSSLHandler.m \
	NSStream/NSInputStream.m \
	NSStream/NSOutputStream_buffer.m \
	NSStream/NSOutputStream_data.m \
	NSStream/NSOutputStream_file.m \
	NSStream/NSSelectSet.m \
	NSStream/NSOutputStream.m \
	NSStream/NSStream.m \
	NSStream/NSInputStream_socket.m \
	NSStream/NSInputStream_file.m \
	NSStream/NSSelectInputSource.m \
	NSStream/NSInputStream_data.m \
	NSGarbageCollector.m \
	NSScanner/NSScanner.m \
	NSScanner/NSScanner_concrete.m \
	NSNotificationCenter/NSNotificationCenter.m \
	NSNotificationCenter/NSObjectToObservers.m \
	NSNotificationCenter/NSNotificationObserver.m \
	NSInvocation.m \
	NSIndexPath.m \
	NSScript/NSScriptWhoseTests.m \
	NSEnumerator.m \
	NSException/debugHelpers.m \
	NSException/NSException.m \
	NSException/NSRaise.m \
	NSStringsFileFormat/NSStringsFileParser.m \
	NSNetService/bonjour.m \
	NSNetService/NSNetServices.m \
	NSDebug.m \
	NSSortDescriptor.m \
	NSRange.m \
	NSConcreteDirectoryEnumerator.m \
	NSPointerArray.m \
	NSUndoManager/NSUndoManager.m \
	NSUndoManager/NSUndoGroup.m \
	NSError.m \
	NSKeyedArchiving/NSKeyedUnarchiver.m \
	NSKeyedArchiving/NSKeyedArchiver.m \
	NSSpellServer.m \
	NSPipe.m \
	NSByteOrder.m \
	NSNumberFormatter.m \
	NSHashTable.m \
	NSDirectoryEnumerator.m \
	NSProcessInfo.m \
	NSData/NSData.m \
	NSData/NSData_mapped.m \
	NSData/NSData_concrete.m \
	NSData/NSMutableData.m \
	NSData/NSMutableData_concrete.m \
	NSUnarchiver.m \
	NSURL/NSURLCredential.m \
	NSURL/NSHTTPURLResponse.m \
	NSURL/NSURLAuthenticationChallenge.m \
	NSURL/NSMutableURLRequest.m \
	NSURL/NSURLCredentialStorage.m \
	NSURL/NSURLDownload.m \
	NSURL/NSURLError.m \
	NSURL/NSURL.m \
	NSURL/NSURLRequest.m \
	NSURL/NSURLHandle.m \
	NSURL/NSURLProtectionSpace.m \
	NSURL/NSURLConnectionState.m \
	NSURL/NSURLConnection.m \
	NSURL/NSURLResponse.m \
	NSURL/NSURLCache.m \
	NSURL/NSURLProtocol_http.m \
	NSURL/NSCachedURLResponse.m \
	NSURL/NSURLProtocol.m \
	xml/NSXMLDocument.m \
	xml/NSXMLParser.m \
	xml/NSXMLNode.m \
	xml/NSXMLDTD.m \
	xml/NSXMLDTDNode.m \
	xml/NSXMLElement.m \
	NSKeyValueCoding/NSDictionary+KVC.m \
	NSKeyValueCoding/NSKVCMutableArray.m \
	NSKeyValueCoding/NSKVOInfoPerObject.m \
	NSKeyValueCoding/NSString+KVCAdditions.m \
	NSKeyValueCoding/NSKeyValueCoding.m \
	NSKeyValueCoding/NSKeyValueObserving.m \
	NSKeyValueCoding/NSKeyObserver.m \
	NSKeyValueCoding/NSArray+KVC.m \
	NSKeyValueCoding/NSKeyPathObserver.m \
	NSPointerFunctions.m \
	NSOrthography.m \
	NSString/NSDarwinString.m \
	NSString/NSStringUTF8.m \
	NSString/NSString_placeholder.m \
	NSString/NSMutableString.m \
	NSString/NSString_unicode.m \
	NSString/NSPathUtilities.m \
	NSString/NSString_nextstep.m \
	NSString/unibuffer.m \
	NSString/NSString_win1252.m \
	NSString/NSString_nextstepCString.m \
	NSString/NSUnicodeCaseMapping.m \
	NSString/NSString.m \
	NSString/NSStringSymbol.m \
	NSString/NSStringFormatter.m \
	NSString/NSConstantString-Impl.m \
	NSString/NSConstantString_tiny-Impl.m \
	NSString/NSMutableString_unicodePtr.m \
	NSString/NSString_isoLatin1.m \
	NSString/NSString_macOSRoman.m \
	NSString/NSString_unicodePtr.m \
	NSString/NSString_cString.m \
	NSString/NSStringFileIO.m \
	NSString/NSStringEncoder.m \
	NSString/NSString_isoLatin2.m \
	NSSpellEngine.m \
	NSConnection/NSConnection.m \
	NSConnection/NSDistantObject.m \
	NSConnection/NSSocketPort.m \
	NSConnection/NSPortCoder.m \
	NSConnection/NSProtocolChecker.m \
	NSConnection/NSPortMessage.m \
	NSConnection/NSMessagePort.m \
	NSConnection/NSPort.m \
	NSNull.m \
	NSHTTPCookie/NSHTTPCookieStorage.m \
	NSHTTPCookie/NSHTTPCookie.m \
	NSLocale.m \
	NSNotificationQueue/NSNotificationQueue.m \
	NSNotificationQueue/NSNotificationAndModes.m \
	NSMapTable.m \
	NSAutoreleasePool/NSAutoreleasePool.m \
	NSValueTransformer/NSValueTransformer_IsNotNil.m \
	NSValueTransformer/NSValueTransformer.m \
	NSValueTransformer/NSValueTransformer_IsNil.m \
	NSValueTransformer/NSValueTransformer_KeyedUnarchiveFromData.m \
	NSValueTransformer/NSValueTransformer_UnarchiveFromData.m \
	NSValueTransformer/NSValueTransformer_NegateBoolean.m \
	NSArray/NSArray_placeholder.m \
	NSArray/NSEnumerator_array.m \
	NSArray/NSMutableArray_concrete.m \
	NSArray/NSArray_concrete.m \
	NSArray/NSMutableArray.m \
	NSArray/NSEnumerator_arrayReverse.m \
	NSArray/NSArray.m \
	NSThread/NSThread.m \
	NSOperation/NSOperationQueue.m \
	NSOperation/NSAtomicList.m \
	NSOperation/NSOperation.m \
	NSObjCRuntime.m \
	NSDistributedNotificationCenter.m \
	NSMethodSignature.m \
	NSPredicate/NSExpression_variable.m \
	NSPredicate/NSCompoundPredicate.m \
	NSPredicate/NSExpression_operator.m \
	NSPredicate/NSExpression_constant.m \
	NSPredicate/NSExpression_array.m \
	NSPredicate/NSPredicate_BOOL.m \
	NSPredicate/NSExpression_keypath.m \
	NSPredicate/NSExpression_assignment.m \
	NSPredicate/NSExpression_function.m \
	NSPredicate/NSPredicate.m \
	NSPredicate/NSComparisonPredicate.m \
	NSPredicate/NSExpression.m \
	NSPredicate/NSExpression_self.m \
	NSCoder.m \
	platform_posix/NSPersistantDomain_posix.m \
	platform_posix/NSPipe_posix.m \
	platform_posix/NSSocketPort_posix.m \
	platform_posix/NSTask_posix.m \
	platform_posix/NSTimeZone_posix.m \
	platform_posix/NSRecursiveLock_posix.m \
	platform_posix/NSString_defaultEncoding_posix.m \
	platform_posix/NSSelectSet_bsd.m \
	platform_posix/NSCondition_posix.m \
	platform_posix/NSFileHandle_posix.m \
	platform_posix/NSConstantString.m \
	platform_posix/NSLocale_posix.m \
	platform_bsd/libmain.m \
	platform_bsd/NSMemoryFunctions_bsd.m \
	platform_bsd/NSPlatform_ravynOS.m \
	platform_posix/NSPlatform_posix.m \
	platform_posix/NSLock_posix.m \
	platform_posix/NSCancelInputSource_posix.m \
	platform_posix/NSFileManager_posix.m \
	platform_posix/NSConditionLock_posix.m \
	platform_posix/NSMemoryFunctions_posix.m \
	platform_posix/NSSocket_bsd.m \
	platform_posix/NSRunLoopState_posix.m \
	NSUserDefaults/NSUserDefaults.m \
	NSUserDefaults/NSPersistantDomain.m \
	NSIndexSet/NSMutableIndexSet.m \
	NSIndexSet/NSIndexSet.m \
	NSCharacterSet/NSMutableCharacterSet_bitmap.m \
	NSCharacterSet/NSCharacterSet_range.m \
	NSCharacterSet/NSCharacterSet_string.m \
	NSCharacterSet/NSCharacterSet_bitmap.m \
	NSCharacterSet/NSCharacterSet_rangeInverted.m \
	NSCharacterSet/NSCharacterSet.m \
	NSCharacterSet/NSMutableCharacterSet.m \
	NSProxy.m \
	NSGeometry.m \
	NSLock/NSRecursiveLock.m \
	NSLock/NSConditionLock.m \
	NSLock/NSCondition.m \
	NSLock/NSLock.m \
	NSLock/NSSynchronization.m \
	NSTextCheckingResult.m \
	NSValue/NSValue.m \
	NSValue/NSValue_placeholder.m \
	NSValue/NSValue_nonRetainedObject.m \
	NSValue/NSValue_concrete.m \
	NSValue/NSValue_pointer.m \
	NSPortNameServer/NSMessagePortNameServer.m \
	NSPortNameServer/NSPortNameServer.m \
	NSPortNameServer/NSSocketPortNameServer.m \
	NSDecimal/NSDecimal.m \
	NSDecimal/NSDecimalNumber.m \
	NSDecimal/NSDecimalNumberPlaceholder.m \
	NSNumber/NSNumber_unsignedInt.m \
	NSNumber/NSNumber_unsignedShort.m \
	NSNumber/NSNumber_unsignedLong.m \
	NSNumber/NSNumber_char.m \
	NSNumber/NSNumber_longLong.m \
	NSNumber/NSNumber_int.m \
	NSNumber/NSNumber_BOOL_const.m \
	NSNumber/NSNumber_CF.m \
	NSNumber/NSNumber.m \
	NSNumber/NSNumber_float.m \
	NSNumber/NSNumber_short.m \
	NSNumber/NSNumber_unsignedLongLong.m \
	NSNumber/NSNumber_placeholder.m \
	NSNumber/NSNumber_BOOL.m \
	NSNumber/NSNumber_double.m \
	NSNumber/NSNumber_unsignedChar.m \
	NSNumber/NSNumber_long.m \
	NSTimer/NSTimer_targetAction.m \
	NSTimer/NSTimer_concrete.m \
	NSTimer/NSTimer_invocation.m \
	NSTimer/NSTimer.m \
	NSClassDescription.m \
	NSTask.m \
	NSSet/NSSet_placeholder.m \
	NSSet/NSMutableSet_concrete.m \
	NSSet/NSSet_concrete.m \
	NSSet/NSEnumerator_set.m \
	NSSet/NSCountedSet.m \
	NSSet/NSInlineSetTable.m \
	NSSet/NSMutableSet.m \
	NSSet/NSSet.m \
	NSAttributedString/NSRangeEntries.m \
	NSAttributedString/NSAttributedString_manyAttributes.m \
	NSAttributedString/NSMutableAttributedString_concrete.m \
	NSAttributedString/NSAttributedString_nilAttributes.m \
	NSAttributedString/NSAttributedString.m \
	NSAttributedString/NSAttributedString_placeholder.m \
	NSAttributedString/NSAttributedString_oneAttribute.m \
	NSAttributedString/NSMutableString_proxyToMutableAttributedString.m \
	NSAttributedString/NSMutableAttributedString.m \
	NSObject/NSObject.m \
	NSObject/objc_forward_ffi.m \
	NSObject/objc_size_alignment.m \
	NSObject/NSZombieObject.m \
	NSObject/forwarding.m \
	NSDistributedLock.m \
	NSMetadata/NSMetadataQuery.m \
	NSMetadata/NSMetadataQueryResultGroup.m \
	NSMetadata/NSMetadataItem.m \
	NSMetadata/NSMetadataQueryAttributeValueTuple.m \
	NSPlatform.m \
	NSPropertyList/NSOldXMLAttribute.m \
	NSPropertyList/NSOldXMLElement.m \
	NSPropertyList/NSPropertyListReader_binary1.m \
	NSPropertyList/NSOldXMLReader.m \
	NSPropertyList/CFUID.m \
	NSPropertyList/NSPropertyListWriter_xml1.m \
	NSPropertyList/NSPropertyList.m \
	NSPropertyList/NSPropertyListWriter_vintage.m \
	NSPropertyList/NSOldXMLDocument.m \
	NSPropertyList/NSPropertyListReader.m \
	NSPropertyList/NSPropertyListReader_xml1.m \
	NSPropertyList/NSPropertyListReader_vintage.m \
	NSHost.m \
	NSBundle.m \
	NSRunLoop/NSRunLoop.m \
	NSRunLoop/NSInputSource.m \
	NSRunLoop/NSRunLoopState.m \
	NSRunLoop/NSOrderedPerform.m \
	NSRunLoop/NSInputSourceSet.m \
	NSRunLoop/NSDelayedPerform.m \
	NSFileManager.m \
	NSAffineTransform.m \
	NSNotification/NSNotification_concrete.m \
	NSNotification/NSNotification.m \
	NSZone/NSVirtualMemory.m \
	NSZone/NSZone.m \
	NSDate/NSCalendar.m \
	NSDate/NSDate_timeInterval.m \
	NSDate/NSCalendarDate.m \
	NSDate/NSDate.m \
	NSDate/NSDateComponents.m \
	NSDate/NSDateFormatter.m 

INCS= \
	NSLocale.h \
	NSNull.h \
	NSDictionary/NSMutableDictionary_mapTable.h \
	NSDictionary/NSDictionary.h \
	NSDictionary/NSEnumerator_dictionaryKeys.h \
	NSDictionary/NSDictionary_mapTable.h \
	NSDictionary/NSEnumerator_dictionaryObjects.h \
	NSDictionary/NSMutableDictionary.h \
	NSSpellEngine.h \
	NSOrthography.h \
	NSPointerFunctions.h \
	NSTimeZone/NSTimeZoneType.h \
	NSTimeZone/NSTimeZone_absolute.h \
	NSTimeZone/NSTimeZone.h \
	NSTimeZone/NSTimeZoneTransition.h \
	NSStream/NSOutputStream.h \
	NSStream/NSSelectSet.h \
	NSStream/NSInputStream_socket.h \
	NSStream/NSStream.h \
	NSStream/NSInputStream_data.h \
	NSStream/NSSelectInputSource.h \
	NSStream/NSInputStream_file.h \
	NSStream/NSOutputStream_socket.h \
	NSStream/NSFileHandle_stream.h \
	NSStream/NSSelectInputSourceSet.h \
	NSStream/NSInputStream.h \
	NSStream/CFSSLHandler.h \
	NSStream/NSSocket.h \
	NSStream/NSFileHandle.h \
	NSStream/NSOutputStream_file.h \
	NSStream/NSOutputStream_data.h \
	NSStream/NSOutputStream_buffer.h \
	NSScanner/NSScanner_concrete.h \
	NSScanner/NSScanner.h \
	NSCoder.h \
	NSNotificationCenter/NSNotificationObserver.h \
	NSNotificationCenter/NSNotificationCenter.h \
	NSNotificationCenter/NSObjectToObservers.h \
	NSMethodSignature.h \
	NSDistributedNotificationCenter.h \
	NSObjCRuntime.h \
	NSScript/NSScriptWhoseTests.h \
	NSAtomicCompareAndSwap.h \
	NSMapTable.h \
	NSException/NSException.h \
	NSException/NSRaise.h \
	NSException/NSRaiseException.h \
	NSException/debugHelpers.h \
	NSStringsFileFormat/NSStringsFileParser.h \
	NSNetService/NSNetServices.h \
	NSNetService/bonjour.h \
	NSPlatform.h \
	NSDistributedLock.h \
	NSClassDescription.h \
	NSTask.h \
	NSTextCheckingResult.h \
	NSUndoManager/NSUndoGroup.h \
	NSUndoManager/NSUndoManager.h \
	Foundation.h \
	NSGeometry.h \
	NSProxy.h \
	NSKeyedArchiving/NSKeyedUnarchiver.h \
	NSKeyedArchiving/NSKeyedArchiver.h \
	NSFileManager.h \
	NSAffineTransform.h \
	NSBundle.h \
	NSData/NSData.h \
	NSData/NSMutableData_concrete.h \
	NSData/NSData_mapped.h \
	NSData/NSMutableData.h \
	NSData/NSData_concrete.h \
	NSHost.h \
	NSURL/NSURL.h \
	NSURL/NSURLError.h \
	NSURL/NSURLProtectionSpace.h \
	NSURL/NSURLHandle.h \
	NSURL/NSURLRequest.h \
	NSURL/NSURLProtocol_http.h \
	NSURL/NSURLCache.h \
	NSURL/NSURLResponse.h \
	NSURL/NSURLConnection.h \
	NSURL/NSURLConnectionState.h \
	NSURL/NSURLProtocol.h \
	NSURL/NSCachedURLResponse.h \
	NSURL/NSHTTPURLResponse.h \
	NSURL/NSURLCredential.h \
	NSURL/NSURLAuthenticationChallenge.h \
	NSURL/NSURLDownload.h \
	NSURL/NSURLCredentialStorage.h \
	NSURL/NSMutableURLRequest.h \
	xml/NSXMLDTDNode.h \
	xml/NSXMLDTD.h \
	xml/NSXMLNode.h \
	xml/NSXMLElement.h \
	xml/NSXMLNodeOptions.h \
	xml/NSXMLParser.h \
	xml/NSXMLDocument.h \
	NSKeyValueCoding/NSKeyObserver.h \
	NSKeyValueCoding/NSKeyPathObserver.h \
	NSKeyValueCoding/NSKVCMutableArray.h \
	NSKeyValueCoding/NSKeyValueObserving-Private.h \
	NSKeyValueCoding/NSKeyValueCoding.h \
	NSKeyValueCoding/NSString+KVCAdditions.h \
	NSKeyValueCoding/NSKVOInfoPerObject.h \
	NSKeyValueCoding/NSKeyValueObserving.h \
	NSGarbageCollector.h \
	NSAssertionHandler.h \
	NSString/NSMutableString_unicodePtr.h \
	NSString/NSStringHashing.h \
	NSString/NSString_macOSRoman.h \
	NSString/NSString_isoLatin1.h \
	NSString/NSStringFileIO.h \
	NSString/NSString_cString.h \
	NSString/NSString_unicodePtr.h \
	NSString/NSString_isoLatin2.h \
	NSString/Encoding/8859-1.h \
	NSString/Encoding/CP1256.h \
	NSString/Encoding/CP1252.h \
	NSString/Encoding/CP1258.h \
	NSString/Encoding/8859-5.h \
	NSString/Encoding/8859-16.h \
	NSString/Encoding/CP1255.h \
	NSString/Encoding/8859-8.h \
	NSString/Encoding/8859-2.h \
	NSString/Encoding/8859-11.h \
	NSString/Encoding/8859-6.h \
	NSString/Encoding/CP874.h \
	NSString/Encoding/8859-15.h \
	NSString/Encoding/CP1251.h \
	NSString/Encoding/CP1254.h \
	NSString/Encoding/8859-10.h \
	NSString/Encoding/8859-3.h \
	NSString/Encoding/8859-9.h \
	NSString/Encoding/CP950.h \
	NSString/Encoding/8859-14.h \
	NSString/Encoding/8859-7.h \
	NSString/Encoding/CP1250.h \
	NSString/Encoding/8859-13.h \
	NSString/Encoding/CP936.h \
	NSString/Encoding/CP1257.h \
	NSString/Encoding/CP1253.h \
	NSString/Encoding/8859-4.h \
	NSString/Encoding/CP932.h \
	NSString/Encoding/CP949.h \
	NSString/NSStringEncoder.h \
	NSString/NSMutableString.h \
	NSString/NSString_defaultEncoding.h \
	NSString/NSString_placeholder.h \
	NSString/NSStringUTF8.h \
	NSString/NSString_win1252.h \
	NSString/unibuffer.h \
	NSString/NSString_nextstep.h \
	NSString/NSPathUtilities.h \
	NSString/NSString_unicode.h \
	NSString/NSStringFormatter.h \
	NSString/NSStringSymbol.h \
	NSString/NSString.h \
	NSString/NSUnicodeCaseMapping.h \
	NSString/NSString_nextstepCString.h \
	NSArchiver.h \
	NSConnection/NSSocketPort.h \
	NSConnection/NSProtocolChecker.h \
	NSConnection/NSPortCoder.h \
	NSConnection/NSPortMessage.h \
	NSConnection/NSPort.h \
	NSConnection/NSMessagePort.h \
	NSConnection/NSConnection.h \
	NSConnection/NSDistantObject.h \
	NSHTTPCookie/NSHTTPCookieStorage.h \
	NSHTTPCookie/NSHTTPCookie.h \
	NSFormatter.h \
	NSNotificationQueue/NSNotificationQueue-Private.h \
	NSNotificationQueue/NSNotificationAndModes.h \
	NSNotificationQueue/NSNotificationQueue.h \
	NSEnumerator.h \
	NSAutoreleasePool/NSAutoreleasePool.h \
	NSAutoreleasePool/NSAutoreleasePool-private.h \
	NSValueTransformer/NSValueTransformer_KeyedUnarchiveFromData.h \
	NSValueTransformer/NSValueTransformer_IsNil.h \
	NSValueTransformer/NSValueTransformer_NegateBoolean.h \
	NSValueTransformer/NSValueTransformer_UnarchiveFromData.h \
	NSValueTransformer/NSValueTransformer_IsNotNil.h \
	NSValueTransformer/NSValueTransformer.h \
	NSArray/NSArray_concrete.h \
	NSArray/NSMutableArray.h \
	NSArray/NSArray.h \
	NSArray/NSEnumerator_arrayReverse.h \
	NSArray/NSArray_placeholder.h \
	NSArray/NSMutableArray_concrete.h \
	NSArray/NSEnumerator_array.h \
	NSIndexPath.h \
	NSThread/NSThread-Private.h \
	NSThread/NSThread.h \
	NSOperation/NSOperation.h \
	NSOperation/NSOperationQueue.h \
	NSOperation/NSAtomicList.h \
	NSPredicate/NSPredicate.h \
	NSPredicate/NSExpression_function.h \
	NSPredicate/NSExpression.h \
	NSPredicate/NSComparisonPredicate.h \
	NSPredicate/NSExpression_self.h \
	NSPredicate/NSExpression_variable.h \
	NSPredicate/NSExpression_array.h \
	NSPredicate/NSExpression_constant.h \
	NSPredicate/NSCompoundPredicate.h \
	NSPredicate/NSExpression_operator.h \
	NSPredicate/NSPredicate_BOOL.h \
	NSPredicate/NSExpression_assignment.h \
	NSPredicate/NSExpression_keypath.h \
	NSInvocation.h \
	platform_bsd/NSPlatform_ravynOS.h \
	platform_posix/NSPlatform_posix.h \
	platform_posix/NSFileHandle_posix.h \
	platform_posix/NSCondition_posix.h \
	platform_posix/NSLock_posix.h \
	platform_posix/NSFileManager_posix.h \
	platform_posix/NSConditionLock_posix.h \
	platform_posix/NSCancelInputSource_posix.h \
	platform_posix/NSSocket_bsd.h \
	platform_posix/NSRunLoopState_posix.h \
	platform_posix/NSPipe_posix.h \
	platform_posix/NSPersistantDomain_posix.h \
	platform_posix/NSSocketPort_posix.h \
	platform_posix/NSTask_posix.h \
	platform_posix/NSSelectSet_bsd.h \
	platform_posix/NSTimeZone_posix.h \
	platform_posix/NSRecursiveLock_posix.h \
	platform_posix/NSLocale_posix.h \
	NSUserDefaults/NSPersistantDomain.h \
	NSUserDefaults/NSUserDefaults.h \
	NSIndexSet/NSMutableIndexSet.h \
	NSIndexSet/NSIndexSet.h \
	NSCharacterSet/NSCharacterSet_rangeInverted.h \
	NSCharacterSet/NSMutableCharacterSet.h \
	NSCharacterSet/NSCharacterSet.h \
	NSCharacterSet/NSMutableCharacterSet_bitmap.h \
	NSCharacterSet/bitmapRepresentation.h \
	NSCharacterSet/NSCharacterSet_range.h \
	NSCharacterSet/NSCharacterSet_string.h \
	NSCharacterSet/NSCharacterSet_bitmap.h \
	NSLock/NSLock.h \
	NSLock/NSSynchronization.h \
	NSLock/NSConditionLock.h \
	NSLock/NSRecursiveLock.h \
	NSError.h \
	NSValue/NSValue_pointer.h \
	NSValue/NSValue_placeholder.h \
	NSValue/NSValue.h \
	NSValue/NSValue_nonRetainedObject.h \
	NSValue/NSValue_concrete.h \
	NSPortNameServer/NSPortNameServer.h \
	NSPortNameServer/NSSocketPortNameServer.h \
	NSPortNameServer/NSMessagePortNameServer.h \
	NSDecimal/NSDecimalNumberPlaceholder.h \
	NSDecimal/NSDecimalNumber.h \
	NSDecimal/NSDecimal.h \
	NSPointerArray.h \
	NSNumber/NSNumber_double_const.h \
	NSNumber/NSNumber_BOOL_const_impl.h \
	NSNumber/NSNumber_double.h \
	NSNumber/NSNumber_BOOL.h \
	NSNumber/NSNumber_long.h \
	NSNumber/NSNumber_unsignedChar.h \
	NSNumber/NSConstObject.h \
	NSNumber/NSNumber_unsignedShort.h \
	NSNumber/NSNumber_unsignedInt.h \
	NSNumber/NSNumber_BOOL_const.h \
	NSNumber/NSNumber_int.h \
	NSNumber/NSNumber_char.h \
	NSNumber/NSNumber_longLong.h \
	NSNumber/NSNumber_unsignedLong.h \
	NSNumber/NSNumber_placeholder.h \
	NSNumber/NSNumber_unsignedLongLong.h \
	NSNumber/NSNumber_short.h \
	NSNumber/NSNumber_float.h \
	NSNumber/NSNumber.h \
	NSNumber/NSNumber_CF.h \
	NSTimer/NSTimer.h \
	NSTimer/NSTimer_targetAction.h \
	NSTimer/NSTimer_invocation.h \
	NSTimer/NSTimer_concrete.h \
	NSConcreteDirectoryEnumerator.h \
	NSSet/NSInlineSetTable.h \
	NSSet/NSCountedSet.h \
	NSSet/NSSet.h \
	NSSet/NSMutableSet.h \
	NSSet/NSSet_placeholder.h \
	NSSet/NSSet_concrete.h \
	NSSet/NSMutableSet_concrete.h \
	NSSet/NSEnumerator_set.h \
	FoundationErrors.h \
	NSAttributedString/NSAttributedString_placeholder.h \
	NSAttributedString/NSAttributedString_nilAttributes.h \
	NSAttributedString/NSAttributedString.h \
	NSAttributedString/NSMutableAttributedString.h \
	NSAttributedString/NSMutableString_proxyToMutableAttributedString.h \
	NSAttributedString/NSAttributedString_oneAttribute.h \
	NSAttributedString/NSRangeEntries.h \
	NSAttributedString/NSMutableAttributedString_concrete.h \
	NSAttributedString/NSAttributedString_manyAttributes.h \
	NSObject/forwarding.h \
	NSObject/NSObject.h \
	NSObject/objc_forward_ffi.h \
	NSObject/NSZombieObject.h \
	NSObject/objc_size_alignment.h \
	NSMetadata/NSMetadataItem.h \
	NSMetadata/NSMetadataQueryAttributeValueTuple.h \
	NSMetadata/NSMetadataQueryResultGroup.h \
	NSMetadata/NSMetadataQuery.h \
	NSDebug.h \
	NSSortDescriptor.h \
	NSRange.h \
	NSPropertyList/NSPropertyListWriter_vintage.h \
	NSPropertyList/NSPropertyListReader.h \
	NSPropertyList/NSOldXMLDocument.h \
	NSPropertyList/NSPropertyListReader_vintage.h \
	NSPropertyList/NSPropertyListReader_xml1.h \
	NSPropertyList/NSOldXMLReader.h \
	NSPropertyList/NSPropertyListReader_binary1.h \
	NSPropertyList/NSOldXMLAttribute.h \
	NSPropertyList/NSOldXMLElement.h \
	NSPropertyList/NSPropertyListWriter_xml1.h \
	NSPropertyList/CFUID.h \
	NSPropertyList/NSPropertyList.h \
	NSUnarchiver.h \
	NSProcessInfo.h \
	NSRunLoop/NSRunLoopState.h \
	NSRunLoop/NSOrderedPerform.h \
	NSRunLoop/NSDelayedPerform.h \
	NSRunLoop/NSInputSourceSet.h \
	NSRunLoop/NSRunLoop.h \
	NSRunLoop/NSRunLoop-InputSource.h \
	NSRunLoop/NSInputSource.h \
	NSNotification/NSNotification_concrete.h \
	NSNotification/NSNotification.h \
	NSZone/NSZone.h \
	NSDate/NSDateComponents.h \
	NSDate/NSDate.h \
	NSDate/NSDateFormatter.h \
	NSDate/NSCalendar.h \
	NSDate/NSDate_timeInterval.h \
	NSDate/NSCalendarDate.h \
	NSHashTable.h \
	NSNumberFormatter.h \
	NSDirectoryEnumerator.h \
	NSPipe.h \
	NSByteOrder.h \
	NSCFTypeID.h \
	NSSpellServer.h

RESOURCES=Info.plist English.lproj \
	NSCharacterSet/alphanumericCharacterSet.bitmap \
	NSCharacterSet/controlCharacterSet.bitmap \
	NSCharacterSet/decimalDigitCharacterSet.bitmap \
	NSCharacterSet/illegalCharacterSet.bitmap \
	NSCharacterSet/letterCharacterSet.bitmap \
	NSCharacterSet/lowercaseLetterCharacterSet.bitmap \
	NSCharacterSet/punctuationCharacterSet.bitmap \
	NSCharacterSet/uppercaseLetterCharacterSet.bitmap \
	NSCharacterSet/whitespaceAndNewlineCharacterSet.bitmap \
	NSCharacterSet/whitespaceCharacterSet.bitmap

DIRS= \
	NSScript \
	NSMetadata \
	NSDictionary \
	NSHTTPCookie \
	NSNotificationCenter \
	NSStringsFileFormat \
	NSNumber \
	NSValueTransformer \
	NSPropertyList \
	NSConnection \
	NSKeyValueCoding \
	NSCharacterSet \
	NSValue \
	NSException \
	NSTimer \
	NSScanner \
	NSSet \
	NSZone \
	NSAutoreleasePool \
	NSRunLoop \
	NSTimeZone \
	NSStream \
	NSKeyedArchiving \
	NSDecimal \
	NSThread \
	NSIndexSet \
	NSNotification \
	NSData \
	NSOperation \
	NSLock \
	NSPortNameServer \
	NSUndoManager \
	NSUserDefaults \
	NSString \
	NSString/Encoding \
	NSString/English.lproj \
	NSDate \
	NSAttributedString \
	NSNotificationQueue \
	NSObject \
	NSObject/platform_linux \
	NSArray \
	NSNetService \
	NSURL \
	NSPredicate \
	platform_posix \
	platform_linux \
	platform_bsd \
	xml



CFLAGS+= ${FMWK_CFLAGS} -I${SRCTOP}/gnu/lib/libobjc2 -IHeaders -I${.CURDIR}/.. \
	 -I${BUILDROOT}/usr/include -pthread
LDFLAGS+= ${FMWK_LDFLAGS} \
	  -Wl,-R/System/Library/Frameworks/CFNetwork.framework/Versions/A \
	  -L${BUILDROOT}/System/Library/Frameworks/CFNetwork.framework/Versions/Current \
	  -lCFNetwork \
	  -lobjc -lexecinfo -lpthread

.if ${MACHINE_CPUARCH} == "aarch64"
CFLAGS += -DCOCOTRON_DISALLOW_FORWARDING=1
SRCS += NSObject/platform_linux/msgSendv-aarch64.s
.elif ${MACHINE_CPUARCH} == "i386" || ${MACHINE_CPUARCH} == "amd64"
SRCS += NSObject/platform_linux/msgSendv-x64.s
.endif

marshalheaders: .PHONY
	mkdir -p Headers/Foundation
	find ${.CURDIR} -name \*.h -exec cp -f {} Headers/Foundation \;

make-obj-dirs: .PHONY
	echo ${FRAMEWORK} ${TARGET} in ${MAKEOBJDIR}
.for subdir in ${DIRS}
	mkdir -pv ${MAKEOBJDIR}/${subdir}
.endfor

_install-hook:
	rm -rf ${BUILDROOT}/System/Library/Frameworks/${FRAMEWORK}.framework
	mv ${FRAMEWORK_DIR}/Resources/NSCharacterSet/*.bitmap \
		${FRAMEWORK_DIR}/Resources/
	rmdir ${FRAMEWORK_DIR}/Resources/NSCharacterSet
	mv -fv ${MAKEOBJDIR}/libFoundation.so ${FRAMEWORK_DIR}/Versions/A/
	cp -av ${FRAMEWORK_DIR} ${BUILDROOT}/System/Library/Frameworks/


.include <rvn.framework.mk>

post-resources: _install-hook

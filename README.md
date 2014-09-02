#LRUCache
This is the **dispatch version** of the original LRUCache that used the ```@synchronize``` directive.

<b>@synchronized</b> is easy to use, but is <em>very expensive</em> even when there is little contention.

The ```dispatch_barrier_async``` and ```dispatch_sync``` directives wrap <em>thread-sensitive</em> portions of the code to allow for thread safety.

They're used within a static concurrent queue that was created within 'RicCache' instantiated object.

<b>Purpose:</b>
&nbsp;&nbsp;&nbsp;&nbsp; LRUCache enhances data-access by storing frequently-used data in memory (cache) and allowing
the cache to purge least-recently-used (LRU) data.

‘MyLRU’ is a proof-of-concept of using LRU (Least Recently Used) cache design pattern.
‘MyLRU’ serializes user-data (NSData) into a NSData object within the in-memory cache layer and  archive and unarchive some of the cache’s contents when memory is limiting.

<b>Modus Operandi:</b>
&nbsp;&nbsp;&nbsp;&nbsp; A dictionary is used to hold your cached data in memory.  There’s a size limit to the memory; so
when anything is added to the cache after it’s full, the least-recently used object (least recently used) should be saved to file (flash memory).

&nbsp;&nbsp;&nbsp;&nbsp; This code also handles memory warnings and write the in-memory cache to flash memory (as files).
All in-memory cache are written to flash memory (files) when the app is closed or
quit or when it enters the background.

<b>Variables:</b>
* A NSMutableDictionary for storing the cache data.
* A NSMutableArray is used to keep track of recently-used items, in chronological order, and an integer that limits the maximum size of this cache.


A Unit-Testing target is provided.

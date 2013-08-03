/*
LLClasses is licenced under the terms of the MIT License (MIT)

Copyright (c) 2013 Basile Burg

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

module LLClasses;

import core.exception;
import core.stdc.string;
import core.memory : GC;
import std.stdio, std.string, std.c.stdlib;
import std.traits, std.demangle, std.conv, std.range;

version (Windows)
{
	import core.sys.windows.windows, std.windows.syserror, std.c.windows.windows;

	immutable newlineA = "\r\n";
	// LS separator (std.uni) is not widely supported.
	immutable newlineW = "\r\n"w;
	immutable newlineD = "\r\n"d;
	//
	immutable AltnewlineA = "\n";
	// LS separator (std.uni) is not widely supported.
	immutable AltnewlineW = "\n"w;
	immutable AltnewlineD = "\n"d;
	//
	immutable IsWin = true;
	immutable IsPosix = false;
	
	alias HANDLE FileHandle;
	alias HANDLE SystemHandle;

	const READ_WRITE = GENERIC_WRITE | GENERIC_READ;

	const FSCTL_UNLOCK_VOLUME   = 0x0009001c;
	const FSCTL_LOCK_VOLUME     = 0x00090018;
	const IOCTL_DISK_GET_DRIVE_GEOMETRY     = 0x0070000;
	const IOCTL_DISK_GET_DRIVE_GEOMETRY_EX  = 0x00700a0;
	const IOCTL_STORAGE_QUERY_PROPERTY      = 0x002D1400;

	enum MEDIA_TYPE {
			Unknown         = 0x00,
			F5_1Pt2_512     = 0x01,
			F3_1Pt44_512    = 0x02,
			F3_2Pt88_512    = 0x03,
			F3_20Pt8_512    = 0x04,
			F3_720_512      = 0x05,
			F5_360_512      = 0x06,
			F5_320_512      = 0x07,
			F5_320_1024     = 0x08,
			F5_180_512      = 0x09,
			F5_160_512      = 0x0a,
			RemovableMedia  = 0x0b,
			FixedMedia      = 0x0c,
			F3_120M_512     = 0x0d,
			F3_640_512      = 0x0e,
			F5_640_512      = 0x0f,
			F5_720_512      = 0x10,
			F3_1Pt2_512     = 0x11,
			F3_1Pt23_1024   = 0x12,
			F5_1Pt23_1024   = 0x13,
			F3_128Mb_512    = 0x14,
			F3_230Mb_512    = 0x15,
			F8_256_128      = 0x16,
			F3_200Mb_512    = 0x17,
			F3_240M_512     = 0x18,
			F3_32M_512      = 0x19
	};

	enum PARTITION_STYLE
	{
		PARTITION_STYLE_MBR  = 0,
		PARTITION_STYLE_GPT  = 1,
		PARTITION_STYLE_RAW  = 2
	};

	enum STORAGE_PROPERTY_ID
	{
		StorageDeviceProperty                  = 0,     // Indicates that the caller is querying for the device descriptor.
		StorageAdapterProperty                 = 1,     // Indicates that the caller is querying for the adapter descriptor.
		StorageDeviceIdProperty                = 2,     // Indicates that the caller is querying for the device identifiers provided with the SCSI vital product data pages.
		StorageDeviceUniqueIdProperty          = 3,     // Indicates that the caller is querying for the unique device identifiers. Vista/Server2008 or +.
		StorageDeviceWriteCacheProperty        = 4,     // Indicates that the caller is querying for the write cache property. Vista/Server2008 or +.
		StorageMiniportProperty                = 5,     // Indicates that the caller is querying for the miniport driver descriptor. Vista/Server2008 or +.
		StorageAccessAlignmentProperty         = 6,     // Indicates that the caller is querying for the access alignment descriptor. Vista/Server2008 or +.
		StorageDeviceSeekPenaltyProperty       = 7,     // Indicates that the caller is querying for the seek penalty descriptor. 7/Server2008R2 or +.
		StorageDeviceTrimProperty              = 8,     // Indicates that the caller is querying for the trim descriptor. 7/Server2008R2 or +.
		StorageDeviceWriteAggregationProperty  = 9,     // Indicates that the caller is querying for the write aggregation descriptor. 8/Server2012 or +.
		StorageDeviceDeviceTelemetryProperty   = 10,    // This value is reserved. 8/Server2012 or +.
		StorageDeviceLBProvisioningProperty    = 11,    // Indicates that the caller is querying for the logical block provisioning descriptor, usually to detect whether the storage system uses thin provisioning. 8/Server2012 or +.
		StorageDevicePowerProperty             = 12,    // Indicates that the caller is querying for the power disk drive descriptor. 8/Server2012 or +.
		StorageDeviceCopyOffloadProperty       = 13,    // Indicates that the caller is querying for the write offload descriptor. 8/Server2012 or +.
		StorageDeviceResiliencyProperty        = 14     // Indicates that the caller is querying for the device resiliency descriptor. 8/Server2012 or +.
	};
	alias STORAGE_PROPERTY_ID* PSTORAGE_PROPERTY_ID;

	enum STORAGE_QUERY_TYPE
	{
		PropertyStandardQuery    = 0, // Instructs the driver to return an appropriate descriptor.
		PropertyExistsQuery      = 1, // Instructs the driver to report whether the descriptor is supported.
		PropertyMaskQuery        = 2, // Not currently supported. Do not use.
		PropertyQueryMaxDefined  = 3  // Specifies the upper limit of the list of query types. This is used to validate the query type.
	};
	alias STORAGE_QUERY_TYPE* PSTORAGE_QUERY_TYPE;

	struct  GUID
	{
		DWORD Data1;
		WORD  Data2;
		WORD  Data3;
		BYTE  Data4[8];
	}

	struct DISK_GEOMETRY
	{
		LARGE_INTEGER Cylinders;
		MEDIA_TYPE    MediaType;
		DWORD         TracksPerCylinder;
		DWORD         SectorsPerTrack;
		DWORD         BytesPerSector;
	};

	struct DISK_GEOMETRY_EX {
		DISK_GEOMETRY Geometry;
		LARGE_INTEGER DiskSize;
		BYTE          Data[1];
	};

	struct DISK_PARTITION_INFO {
		DWORD           SizeOfPartitionInfo;
		PARTITION_STYLE PartitionStyle;
		union {
			struct Mbr
			{
				DWORD Signature;
			};
			struct Gpt
			{
				GUID DiskId;
			};
		};
	};
	alias DISK_PARTITION_INFO* PDISK_PARTITION_INFO;

	alias DISK_GEOMETRY_EX* PDISK_GEOMETRY_EX;

	struct STORAGE_ACCESS_ALIGNMENT_DESCRIPTOR
	{
		DWORD Version;
		DWORD Size;
		DWORD BytesPerCacheLine;
		DWORD BytesOffsetForCacheAlignment;
		DWORD BytesPerLogicalSector;
		DWORD BytesPerPhysicalSector;
		DWORD BytesOffsetForSectorAlignment;
	};

	alias STORAGE_ACCESS_ALIGNMENT_DESCRIPTOR* PSTORAGE_ACCESS_ALIGNMENT_DESCRIPTOR;

	struct STORAGE_PROPERTY_QUERY
	{
		STORAGE_PROPERTY_ID PropertyId;
		STORAGE_QUERY_TYPE  QueryType;
		ubyte               AdditionalParameters[1];
	}
	alias STORAGE_PROPERTY_QUERY* PSTORAGE_PROPERTY_QUERY;

	extern (Windows)
	{
		export BOOL SetEndOfFile(in HANDLE hFile);

		export BOOL GetDiskFreeSpaceA(
					  in  LPCTSTR lpRootPathName,
					  LPDWORD lpSectorsPerCluster,
					  LPDWORD lpBytesPerSector,
					  LPDWORD lpNumberOfFreeClusters,
					  LPDWORD lpTotalNumberOfClusters);

		export BOOL DeviceIoControl(
					in HANDLE hDevice,
					in DWORD dwIoControlCode,
					in LPVOID lpInBuffer,
					in DWORD nInBufferSize,
					LPVOID lpOutBuffer,
					in DWORD nOutBufferSize,
					LPDWORD lpBytesReturned,
					OVERLAPPED* lpOverlapped);
	}
}
version (Posix)
{
	import core.sys.posix.fcntl, core.sys.posix.unistd;
	import core.sys.posix.sys.statvfs;

	immutable newlineA = "\n";
	// LS separator (std.uni) is not widely supported.
	immutable newlineW = "\n"w;
	immutable newlineD = "\n"d;
	//
	immutable AltnewlineA = "\r\n";
	// LS separator (std.uni) is not widely supported.
	immutable AltnewlineW = "\r\n"w;
	immutable AltnewlineD = "\r\n"d;
	//
	immutable IsWin = false;
	immutable IsPosix = true;

	alias int FileHandle;
	alias int SystemHandle;
}

version (linux) version (X86_64) version = linux64;

alias void delegate(Object aNotifier) nothrow dNotification;
// generate simple accessors for the dNotification: http://dpaste.dzfl.pl/d9bcb560

/**
 * this class allocator/deallocator is globally implemented in each super class 
 * and can be globally activated using the version specifier "-version=uncollectclasses"
 */
mixin template mUncollectedClass()
{
	deprecated new(size_t sz)
	{
		auto p = malloc(sz);
		if (!p) throw new OutOfMemoryError();
		return p;
	}
	deprecated delete(void* p)
	{
		if (p) free(p);
	}
}
mixin template mConditionallyUncollected()
{
	version(uncollectclasses) mixin UncollectedClass;
}

/**
 * A simple Object which is not collected by the GC.
 * It's not affected by the global "uncollectclasses" version specifier.
 */
class cUncollected
{
	mixin mUncollectedClass;
	unittest
	{
		auto foo = new cUncollected;
		scope(exit) delete foo;
		assert( GC.addrOf(&foo) == null );
	}
}

/**
 * An extended, still unspecialised, Object.
 *
 * Extensions:
 * - interface utilities: IsImplementator(), QueryInterface().
 * - serializable: includes an empty, overridable, implementation of ISearializable.
 * - properties: Tag, Opaque and ptr
 */
class cObjectEx: iSerializable
{
	private
	{
		int fTag;
		void* fOpaque;
	}
	/**
	 * Returns the true "&this" pointer.
	 * Only valid in the class scope (?).
	 */
	protected void* ptr()
	{
		return cast(void*) this;
	}
	public
	{
		mixin mConditionallyUncollected;
		/**
		 * Returns true if this implements the interface I.
		 */
		bool IsImplementator(I)()
		{
			return (cast(I) this) !is null;
		}
		/**
		 * Returns the interface I.
		 */
		I QueryInterface(I)()
		{
			return cast(I) this;
		}
		/**
		 * Any descendant can overrides this method in order to be read/written.
		 */
		void DeclareProperties(cMasterSerializer aSerializer)
		{
			aSerializer.AddProperty!int(intprop(&Tag, &Tag, "Tag"));
		}
		bool IsSerializationRecursive()
		{
			return true;
		}
		bool IsReference(iSerializable aSerializable)
		{
			return false;
		}
		@property
		{
			/**
			 * integer tag. not set to size_t because it's serialized.
			 */
			int Tag(){return fTag;}
			/// ditto
			void Tag(int aValue){fTag = aValue;}
			/**
			 * Opaque data.
			 */
			void* TagPointer(){return fOpaque;}
			/// ditto
			void TagPointer(void* aValue){fOpaque = aValue;}
		}
		version(unittest)
		{
			void TestThisPtr(cObjectEx* aExtPtr)
			{
				assert(cast(size_t)aExtPtr == cast(size_t)ptr);
			}
		}
	}
	unittest
	{
		interface ITest
		{
			bool Bar();
		}
		interface ITest2
		{
			bool Baz();
		}
		class Foo: cObjectEx, ITest
		{
			bool Bar(){return true;}
		}

		auto foo = new Foo;
		assert(foo.IsImplementator!ITest());
		assert(!foo.IsImplementator!ITest2());
		auto bar = foo.QueryInterface!ITest();
		assert(bar !is null);
		assert(bar.Bar());
		assert(foo.IsImplementator!iSerializable());
		foo.TestThisPtr(cast(cObjectEx*)foo);

		writeln("cObjectEx passed the tests");
	}
}

/**
 * Parametrized array.
 *
 * sTypedArray(T) implements a single-dimension array of uncollected memory.
 * It internally pre-allocates the memory to minimize the reallocations fingerprint.
 *
 * Its layout differs from standard D's dynamic arrays and they cannot be casted as T[].
 */
struct sTypedArray(T)
{
	private
	{
		size_t fLength;
		static void* fElems;
		static uint fGranularity;
		size_t fBlockCount;

		void SetLength(size_t aLength)
		{
			size_t lBlockCount = ((aLength * T.sizeof) / fGranularity) + 1;
			if (fBlockCount != lBlockCount)
			{
				fBlockCount = lBlockCount;
				fElems = cast(T*) realloc(cast(void*) fElems, fGranularity * fBlockCount);
				if (fElems == null)
				{
					throw new OutOfMemoryError();
				}
			}
			fLength = aLength;
		}
	}
	protected
	{
		void Grow()
		{
			SetLength(fLength + 1);
		}
		void Shrink()
		{
			SetLength(fLength - 1);
		}
	}
	public
	{
		static this()
		{
			fGranularity = 4096;
			fElems = malloc(fGranularity);
			if (!fElems)
			{
				throw new OutOfMemoryError();
			}
		}
		~this()
		{
			std.c.stdlib.free(fElems);
		}
		this(T[] someElement)
		{
			if (someElement.length == 0) return;
			SetLength(someElement.length);
			for (size_t i; i<fLength; i++)
			{
				*cast(T*) (fElems + i * T.sizeof) = someElement[i];
			}
		}
		/**
		 * Indicates the memory allocation block-size.
		 */
		uint Granurality()
		{
			return fGranularity;
		}
		/**
		 * Sets the memory allocation block-size.
		 * aValue should be set to 16 or 4096 (the default).
		 */
		void Granularity(uint aValue)
		{
			if (fGranularity == aValue) return;
			if (aValue < T.sizeof)
			{
				aValue = 16 * T.sizeof;
			}
			if (aValue < 16)
			{
				aValue = 16;
			}
			while (fGranularity % 16 != 0)
			{
				aValue--;
			}
			fGranularity = aValue;
			SetLength(fLength);
		}
		/**
		 * Indicates how many block contains the array.
		 */
		size_t BlockCount()
		{
			return fBlockCount;
		}
		/**
		 * Element count.
		 */
		size_t Length()
		{
			return fLength;
		}
		/// ditto
		void Length(size_t aLength)
		{
			if (aLength == fLength) return;
			SetLength(aLength);
		}
		/**
		 * Pointer to the first element.
		 * Initially valid, thus cannot be used to
		 * determine if the array is empty.
		 */
		void* ptr()
		{
			return fElems;
		}
		/**
		 * Class operators
		 */
		T opIndex(size_t i)
		{
			return *cast(T*) (fElems + i * T.sizeof);
		}
		/// ditto
		void opIndexAssign(T aItem, size_t i)
		{
			*cast(T*) (fElems + i * T.sizeof) = aItem;
		}
		/// ditto
		int opApply(int delegate(ref T) dg)
		{
			int result = 0;
			for (ptrdiff_t i = 0; i < fLength; i++)
			{
				result = dg(*cast(T*) (fElems + i * T.sizeof));
				if (result) break;
			}
			return result;
		}
		/// ditto
		int opApplyReverse(int delegate(ref T) dg)
		{
			int result = 0;
			for (ptrdiff_t i = fLength-1; i >= 0; i--)
			{
				result = dg(*cast(T*) (fElems + i * T.sizeof));
				if (result) break;
			}
			return result;
		}
		/// ditto
		void opAssign(T[] someElements)
		{
			Length = someElements.length;
			for (ptrdiff_t i = 0; i < someElements.length; i++)
			{
				*cast(T*) (fElems + i * T.sizeof) = someElements[i];
			}
		}
	}
}
final private class cTypedArrayTester
{
	unittest
	{
		sTypedArray!int intarr;
		intarr.Length = 2;
		intarr[0] = 8;
		intarr[1] = 9;
		assert( intarr[0] == 8);
		assert( intarr[1] == 9);
		auto floatarr = sTypedArray!float ([0.0f, 0.1f, 0.2f, 0.3f, 0.4f]);
		assert( floatarr.Length == 5);
		assert( floatarr[0] == 0.0f);
		assert( floatarr[1] == 0.1f);
		assert( floatarr[2] == 0.2f);
		assert( floatarr[3] == 0.3f);
		assert( floatarr[4] == 0.4f);
		int i;
		foreach(float aflt; floatarr)
		{
			float v = i * 0.1f;
			assert( aflt == v);
			i++;
		}
		foreach_reverse(float aflt; floatarr)
		{
			i--;
			float v = i * 0.1f;
			assert( aflt == v);
		}

		intarr.Length = 10_000_000;
		intarr[intarr.Length-1] = cast(int) intarr.Length-1;
		assert(intarr[intarr.Length-1] == intarr.Length-1);
		intarr.Length = 10;
		intarr.Length = 10_000_000;
		intarr[intarr.Length-1] = cast(int) intarr.Length-1;
		assert(intarr[intarr.Length-1] == intarr.Length-1);

		writeln("sTypedArray(T) passed the tests");
	}
}

enum eListChangeKind {ckAdd,ckInsert,ckRemove,ckExtract,ckExchange};

/**
 * cList interface.
 */
abstract class cList(T)
{
	alias void delegate(Object aNotifier, eListChangeKind aChangeKind, T* anItem) dListNotification;
	/**
	 * Virtual method responsible for "cleaning" the items when
	 * the property MustCleanItems is set to true.
	 */
	protected void Cleanup();
	/**
	 * Returns the index of aItem if found otherwise returns -1.
	 * Comparison is pointer-based (heap address).
	 */
	ptrdiff_t IndexOf(T* aItem);
	/**
	 * Returns the index of the first item whose value compares to aItem 
	 * if found otherwise returns -1.
	 * Comparison is value-based (dereference of heap address as T)
	 */
	ptrdiff_t FindValue(T aItem);
	/**
	 * Add an item to the back of the list and returns its index.
	 * If the property AllowDup is set to false and if aItem is already
	 * held within the list, returns -1.
	 */
	ptrdiff_t Add(T* aItem);
	/**
	 * Add someItem to the list.
	 */
	void AddSome(T someItem[]);
	/**
	 * Insert aItem at position aIndex.
	 */
	void Insert(ptrdiff_t aIndex, T* aItem);
	/**
	 * Remove the item located at aIndex.
	 */
	void Remove(ptrdiff_t aIndex);
	/**
	 * Remove aItem if it's held within the list.
	 */
	void Remove(T* aItem);
	/**
	 * Removes and returns the item located at aIndex.
	 */
	T* Extract(ptrdiff_t aIndex);
	/**
	 * Removes and extracts aItem if it's held within the list.
	 */
	T* Extract(T* aItem);
	/**
	 * Exchange the items located at aIndex1 and at aIndex2.
	 */
	void Exchange(ptrdiff_t aIndex1, ptrdiff_t aIndex2);
	/**
	 * Exchange aItem1 and aItem2 position if both are held within the list.
	 */
	void Exchange(T* aItem1, T* aItem2);
	/**
	 * class operators
	 */
	T* opIndex(ptrdiff_t i);
	/// ditto
	void opIndexAssign(T* aItem, ptrdiff_t i);
	/// ditto
	int opApply(int delegate(T*) dg);
	/// ditto
	int opApplyReverse(int delegate(T*) dg);
	/**
	 * Returns the count of items held within the list.
	 */
	ptrdiff_t Count();
	/**
	 * Defines if an item can stand more than once within the list.
	 */
	void AllowDup(bool aValue);
	/// ditto
	bool AllowDup();
	/**
	 * Clear the items.
	 */
	void Clear();
	/**
	 * Defines if the items must be cleaned when the list is destroyed.
	 * Depending on the context, cleaning denotes freeing memory or destroying some objects.
	 */
	bool MustCleanItems();
	void MustCleanItems(bool aValue);
	/**
	 * Returns the first item (front).
	 */
	T* First();
	/**
	 * Returns the last item (back).
	 */
	T* Last();
	/**
	 * Iterate through the Items, from the first to the last and
	 * call the callback aClbck for each item.
	 * Similar to a foreach() loop with an additional "context identifier"
	 * (allowing to use the same callback for different purposes)
	 * and an user parameter.
	 */
	void Iterate(size_t aReason, void delegate(size_t aReason, T* aItem, void* aUserDt, out bool doStop) aClbck, void* aUserDt = null);
	/**
	 * Iterate through the items, in reverse order.
	 */
	void IterateReverse(size_t aReason, void delegate(size_t aReason, T* aItem, void* aUserDt, out bool doStop) aClbck, void* aUserDt = null);
	/**
	 * Sort the items with a typed comparison callback
	 */
	void Sort(bool delegate(T* Item1, T* Item2) aCompareClbck);
	/**
	 * The OnChange property can be assigned to get informed for each list change.
	 */
	dListNotification OnChange();
	/// ditto
	void OnChange(dListNotification aValue);
}

/**
 * Parametrized "static" list.
 *
 * This list is fast for adding (not for inserting) and iterating through the items
 * but not for being randomly reorganized. Thus once the items added, they
 * shouldn't be removed (except from the very last item) or exchanged
 * but they should rather remain "static".
 *
 * Its items are stored as pointers in an uncollected sTypedArray.
 */
class cStaticList(T): cList!T
{
	private
	{
		sTypedArray!(T*) fItems;
		bool fAllowDup;
		bool fCleanupItems;
		dListNotification fOnChange;
	}
	protected
	{
		override void Cleanup(){};
	}
	public
	{
		mixin mConditionallyUncollected;
		this()
		{
			fAllowDup = true;
		}
		~this()
		{
			if (fCleanupItems) Cleanup;
		}
		final override ptrdiff_t IndexOf(T* aItem)
		{
			for (ptrdiff_t i; i < fItems.Length; i++)
			{
				if (fItems[i] == aItem) return i;
			}
			return -1;
		}
		final override ptrdiff_t FindValue(T aItem)
		{
			for (ptrdiff_t i; i < fItems.Length; i++)
			{
				if (*fItems[i] == aItem) return i;
			}
			return -1;
		}
		final override ptrdiff_t Add(T* aItem)
		{
			if ((!fAllowDup) && (IndexOf(aItem) != -1)) return -1;
			fItems.Grow;
			size_t lIndex = fItems.Length-1;
			fItems[lIndex] = aItem;
			if (fOnChange) fOnChange(this,eListChangeKind.ckAdd,aItem);
			return lIndex;
		}
		final override void AddSome(T someItem[])
		{
			for(uint i = 0; i < someItem.length; i++ )
			{
				Add(&someItem[i]);
			}
		}
		final override void Insert(ptrdiff_t aIndex, T* aItem)
		{
			if ((!fAllowDup) && (IndexOf(aItem) != -1)) return;
			fItems.Grow;
			for (size_t i = fItems.Length; i > aIndex; i--)
			{
				fItems[i] = fItems[i-1];
			}
			fItems[aIndex] = aItem;
			if (fOnChange) fOnChange(this,eListChangeKind.ckInsert,aItem);
		}
		final override void Remove(T* aItem)
		{
			auto lIndex = IndexOf(aItem);
			if (lIndex == -1) return;
			for (size_t i = lIndex; i < fItems.Length-1; i++)
			{
				fItems[i] = fItems[i+1];
			}
			fItems.Shrink;
			if (fOnChange) fOnChange(this,eListChangeKind.ckRemove,aItem);
		}
		final override void Remove(ptrdiff_t aIndex)
		{
			auto lItem = fItems[aIndex];
			for (size_t i = aIndex; i < fItems.Length-1; i++)
			{
				fItems[i] = fItems[i+1];
			}
			fItems.Shrink;
			if (fOnChange) fOnChange(this,eListChangeKind.ckRemove,lItem);
		}
		final override T* Extract(T* aItem)
		{
			auto lIndex = IndexOf(aItem);
			if (lIndex == -1) return null;
			Remove(lIndex);
			return aItem;
		}
		final override T* Extract(ptrdiff_t aIndex)
		{
			auto lRes = fItems[aIndex];
			for (size_t i = aIndex; i < fItems.Length-1; i++)
			{
				fItems[i] = fItems[i+1];
			}
			fItems.Shrink;
			if (fOnChange) fOnChange(this,eListChangeKind.ckExtract,lRes);
			return lRes;
		}
		final override void Exchange(ptrdiff_t aIndex1, ptrdiff_t aIndex2)
		{
			auto lCopy = fItems[aIndex1];
			fItems[aIndex1] = fItems[aIndex2];
			fItems[aIndex2] = lCopy;
			if (fOnChange) fOnChange(this,eListChangeKind.ckExchange,null);
		}
		final override void Exchange(T* aItem1, T* aItem2)
		{
			auto lIndex1 = IndexOf(aItem1);
			if (lIndex1 == -1) return;
			auto lIndex2 = IndexOf(aItem2);
			if (lIndex2 == -1) return;
			Exchange(lIndex1,lIndex2);
		}
		final override void Clear()
		{
			fItems.Length = 0;
			if (fOnChange) fOnChange(this,eListChangeKind.ckRemove,null);
		}
		final override void Iterate(size_t aReason, void delegate(size_t aReason, T* aItem, void* aUserDt, out bool doStop) aClbck, void* aUserDt = null)
		{
			bool doStop;
			for (ptrdiff_t i = 0; i < fItems.Length; i++)
			{
				aClbck(aReason, fItems[i], aUserDt, doStop);
				if (doStop) break;
			}
		}
		final override void IterateReverse(size_t aReason, void delegate(size_t aReason, T* aItem, void* aUserDt, out bool doStop) aClbck, void* aUserDt = null)
		{
			bool doStop;
			for (ptrdiff_t i = fItems.Length -1; i >= 0; i--)
			{
				aClbck(aReason, fItems[i], aUserDt, doStop);
				if (doStop) break;
			}
		}
		final override T* opIndex(ptrdiff_t i)
		{
			return fItems[i];
		}
		final override void opIndexAssign(T* aItem, ptrdiff_t i)
		{
			if ((!fAllowDup) && (IndexOf(aItem) != -1)) return;
			fItems[i] = aItem;
		}
		final override int opApply(int delegate(T*) dg)
		{
			int result = 0;

			for (ptrdiff_t i = 0; i < fItems.Length; i++)
			{
				result = dg(fItems[i]);
				if (result) break;
			}
			return result;
		}
		final override int opApplyReverse(int delegate(T*) dg)
		{
			int result = 0;

			for (ptrdiff_t i = fItems.Length-1; i >= 0; i--)
			{
				result = dg(fItems[i]);
				if (result)
					break;
			}
			return result;
		}
		final override T* First()
		{
			if (fItems.Length == 0) return null;
			return fItems[0];
		}
		final override T* Last()
		{
			if (fItems.Length == 0) return null;
			return fItems[fItems.Length-1];
		}
		final override ptrdiff_t Count()
		{
			return fItems.Length;
		}
		final override bool AllowDup()
		{
			return fAllowDup;
		}
		final override void AllowDup(bool aValue)
		{
			if (fAllowDup == aValue) return;
			fAllowDup = aValue;
			if (!fAllowDup)
			{
				size_t lAddr1,lAddr2;
				for (size_t i = 0; i < fItems.Length; i++)
				{
					lAddr1 = cast(size_t) &(*fItems[i]);
					for (size_t j = fItems.Length-1; j > i; j--)
					{
						lAddr2 = cast(size_t) &(*fItems[j]);
						if (lAddr1 - lAddr2 == 0) Remove(j);
					}
				}
			}
		}
		final override bool MustCleanItems()
		{
			return fCleanupItems;
		}
		final override void MustCleanItems(bool aValue)
		{
			fCleanupItems = aValue;
		}
		final override void Sort(bool delegate(T* Item1, T* Item2) aCompareClbck)
		{
		}
		final override dListNotification OnChange() {return fOnChange;}
		final override void OnChange(dListNotification aValue){fOnChange = aValue;}
	}
}
final private class StaticListTester
{
	unittest
	{
		struct Foo{int a,b,c;}
		Foo Foos[1000];
		auto FooList = new cStaticList!Foo;
		FooList.AddSome(Foos);
		assert( FooList.Count == Foos.length);
		assert( FooList.IndexOf( &Foos[500] ) == 500);
		assert( FooList.IndexOf( &Foos[999] ) == 999);
		assert( *FooList[246] == Foos[246]);
		FooList.AddSome(Foos);
		assert( FooList.Count == Foos.length * 2);
		FooList.Remove(1500);
		assert( FooList.Count == Foos.length * 2 -1);
		assert( *FooList[1500] == Foos[501]);
		FooList.AllowDup = false;
		assert( FooList.Count == Foos.length);
		FooList.Insert(1, &Foos[5]);
		assert( FooList.Count == Foos.length);
		FooList.AllowDup = true;
		FooList.Insert(1, &Foos[5]);
		assert( *FooList[0] == Foos[0]);
		assert( *FooList[1] == Foos[5]);
		assert( *FooList[2] == Foos[1]);
		FooList.Clear;
		FooList.AddSome(Foos);
		FooList.Insert(0,&Foos[999]);
		assert( *FooList[0] == Foos[999]);
		assert( *FooList.First == Foos[999]);
		assert( *FooList[1] == Foos[0]);
		FooList.Clear;
		assert( FooList.Count == 0);
		FooList.AddSome(Foos);
		FooList.Exchange(0,999);
		assert( *FooList.First == Foos[999]);
		assert( *FooList.Last == Foos[0]);
		assert( *FooList[0] == Foos[999]);
		assert( *FooList[999] == Foos[0]);
		FooList.Exchange(&Foos[0],&Foos[999]);
		assert( *FooList[0] == Foos[0]);
		assert( *FooList[999] == Foos[999]);
		int i;
		void IteratorClbck1(size_t aReason, Foo* aItem, void* aUserDt, out bool doStop)
		{
			aItem.a = i;
			i++;
		}
		FooList.Iterate(0, &IteratorClbck1);
		assert( Foos[0].a == 0);
		assert( Foos[500].a == 500);
		assert( Foos[999].a == 999);
		void IteratorClbck2(size_t aReason, Foo* aItem, void* aUserDt, out bool doStop)
		{
			i--;
			aItem.b = i;
		}
		FooList.IterateReverse(0, &IteratorClbck2);
		assert( Foos[0].b == 0);
		assert( Foos[500].b == 500);
		assert( Foos[999].b == 999);
		FooList.Clear;
		FooList.AddSome(Foos);
		foreach(Foo* Item; FooList)
		{
			Item.c = i;
			i++;
		}
		assert( Foos[0].c == 0);
		assert( Foos[500].c == 500);
		assert( Foos[999].c == 999);

		writeln("cStaticList passed the tests");
	}
}

/**
 * "Pseudo" structure used by the double-linked list.
 * It's basically structured around a pointer (aItemCaps) which can be considered as a "this"
 */
template tDLListItem(T)
{
	const cPrevOffs = size_t.sizeof;
	const cNextOffs = size_t.sizeof + size_t.sizeof;
	void* NewItemCaps(T* aData, void* aPrevious, void* aNext)
	{
		auto lPt = std.c.stdlib.malloc( 3 * size_t.sizeof );
		if (!lPt)
		{
			throw new OutOfMemoryError();
		}
		*cast(size_t*)  lPt = cast(size_t) aData;
		*cast(size_t*) (lPt + cPrevOffs) = cast(size_t) aPrevious;
		*cast(size_t*) (lPt + cNextOffs) = cast(size_t) aNext;
		return lPt;
	}
	void DeleteItemCaps(void* aItemCaps)
	{
		std.c.stdlib.free(aItemCaps);
	}
	void SetItemCapsPrev(void* aItemCaps, void* aPrevious)
	{
		*cast(size_t*) (aItemCaps + cPrevOffs) = cast(size_t) aPrevious;
	}
	void SetItemCapsNext(void* aItemCaps, void* aNext)
	{
		*cast(size_t*) (aItemCaps + cNextOffs) = cast(size_t) aNext;
	}
	void SetItemCapsData(void* aItemCaps, T* aData)
	{
		*cast(size_t*) aItemCaps = cast(size_t) aData;
	}
	T* GetItemCapsData(void* aItemCaps)
	{
		version(Win32) asm
		{
			naked;
			mov     EAX, [EAX];
			ret;
		}
		else version(Win64) asm
		{
			naked;
			mov     RAX, [RCX];
			ret;
		}
		else version(linux64)asm
		{
			naked;
			mov     RAX, [RDI];
			ret;
		}
		else
		{
			return *cast(T**) (aItemCaps);
		}
	}
	void* PreviousItemCaps(void* aItemCaps)
	{
		version(Win32) asm
		{
			naked;
			mov     EAX, [EAX + cPrevOffs];
			ret;
		}
		else version(Win64) asm
		{
			naked;
			mov     RAX, [RCX + cPrevOffs];
			ret;
		}
		else version(linux64)asm
		{
			naked;
			mov     RAX, [RDI + cPrevOffs];
			ret;
		}
		else
		{
			return *cast(size_t**) (aItemCaps + cPrevOffs);
		}
	}
	void* NextItemCaps(void* aItemCaps)
	{
		version(X86) asm
		{
			naked;
			mov     EAX, [EAX + cNextOffs];
			ret;
		}
		else version(Win64) asm
		{
			naked;
			mov     RAX, [RCX + cNextOffs];
			ret;
		}
		else version(linux64)asm
		{
			naked;
			mov     RAX, [RDI + cNextOffs];
			ret;
		}
		else
		{
			return *cast(size_t**) (aItemCaps + cNextOffs);
		}
	}
}

/**
 * Parametrized "double-linked" list.
 *
 * Its items "capsules" are stored in some uncollected chunks.
 * This list is faster than a "cStaticList" when the items are
 * often randomly reorganized (inserted, exchanged or removed).
 */
class cDoubleLinkedList(T): cList!T
{
	private
	{
		bool fAllowDup;
		bool fCleanupItems;
		size_t fCount;
		void* fLast;
		void* fFirst;
		dListNotification fOnChange;

		void* GetItemCaps(size_t aIndex)
		{
			void* lItemCaps;
			lItemCaps = fFirst;
			for (uint i = 0; i < aIndex; i++)
			{
				lItemCaps = tDLListItem!T.NextItemCaps(lItemCaps);
			}
			return lItemCaps;
		}
		void* GetItemCaps(T* aItem)
		{
			void* lItemCaps;
			lItemCaps = fFirst;
			while( tDLListItem!T.GetItemCapsData(lItemCaps) != aItem )
			{
				lItemCaps = tDLListItem!T.NextItemCaps(lItemCaps);
				if (lItemCaps == null) return null;
			}
			return lItemCaps;
		}
	}
	protected
	{
		override void Cleanup(){};
	}
	public
	{
		mixin mConditionallyUncollected;
		this()
		{
			fAllowDup = true;
		}
		~this()
		{
			if (fCleanupItems) Cleanup;
			Clear;
		}
		final override ptrdiff_t IndexOf(T* aItem)
		{
			ptrdiff_t lRes;
			void* lItemCaps;
			lItemCaps = fFirst;
			if (fCount == 0) return -1;
			while( (tDLListItem!T.GetItemCapsData(lItemCaps)) != aItem )
			{
				lItemCaps = tDLListItem!T.NextItemCaps(lItemCaps);
				if (lItemCaps == null) return -1;
				lRes++;
			}
			return lRes;
		}
		final override ptrdiff_t FindValue(T aItem)
		{
			ptrdiff_t lRes;
			void* lItemCaps;
			lItemCaps = fFirst;
			if (fCount == 0) return -1;
			while( *(tDLListItem!T.GetItemCapsData(lItemCaps)) != aItem )
			{
				lItemCaps = tDLListItem!T.NextItemCaps(lItemCaps);
				if (lItemCaps == null) return -1;
				lRes++;
			}
			return lRes;
		}
		final override ptrdiff_t Add(T* aItem)
		{
			if ((!fAllowDup) && (IndexOf(aItem) != -1)) return -1;
			auto lNew = tDLListItem!T.NewItemCaps(aItem,fLast,null);
			if (fCount == 0)
			{
				fFirst = lNew;
			}
			else
			{
				tDLListItem!T.SetItemCapsNext(fLast,lNew);
			}
			fLast = lNew;
			if (fOnChange) fOnChange(this,eListChangeKind.ckAdd,aItem);
			return fCount++;
		}
		final override void AddSome(T someItem[])
		{
			for(uint i = 0; i < someItem.length; i++ )
			{
				Add(&someItem[i]);
			}
		}
		final override void Insert(ptrdiff_t aIndex, T* aItem)
		{
			if ((!fAllowDup) && (IndexOf(aItem) != -1)) return;
			if ((fCount == 0) | (aIndex >= fCount))
			{
				Add(aItem);
				return;
			}
			auto lOld = GetItemCaps(aIndex);
			auto lPrev = tDLListItem!T.PreviousItemCaps(lOld);
			auto lNew = tDLListItem!T.NewItemCaps(aItem,lPrev,lOld);
			if (lOld == fFirst) fFirst = lNew;
			if (lPrev != null) tDLListItem!T.SetItemCapsNext(lPrev,lNew);
			if (lOld != null) tDLListItem!T.SetItemCapsPrev(lOld,lNew);
			fCount++;
			if (fOnChange) fOnChange(this,eListChangeKind.ckInsert,aItem);
		}
		final override void Remove(T* aItem)
		{
			auto lItemCaps = GetItemCaps(aItem);
			if (lItemCaps == null) return;
			auto lPrev = tDLListItem!T.PreviousItemCaps(lItemCaps);
			auto lNext = tDLListItem!T.NextItemCaps(lItemCaps);
			if (lItemCaps == fFirst)
			{
				fFirst = lNext;
				if (lNext != null) tDLListItem!T.SetItemCapsPrev(lNext,null);
			}
			else if (lItemCaps == fLast)
			{
				fLast = lPrev;
				if (lPrev != null) tDLListItem!T.SetItemCapsNext(lPrev,null);
			}
			else
			{
				tDLListItem!T.SetItemCapsNext(lPrev,lNext);
				tDLListItem!T.SetItemCapsPrev(lNext,lPrev);
			}
			tDLListItem!T.DeleteItemCaps(lItemCaps);
			fCount--;
			if (fOnChange) fOnChange(this,eListChangeKind.ckRemove,aItem);
		}
		final override void Remove(ptrdiff_t aIndex)
		{
			auto lItemCaps = GetItemCaps(aIndex);
			if (lItemCaps == null) return;
			auto lPrev = tDLListItem!T.PreviousItemCaps(lItemCaps);
			auto lNext = tDLListItem!T.NextItemCaps(lItemCaps);
			auto lRes = tDLListItem!T.GetItemCapsData(lItemCaps);
			if (lItemCaps == fFirst)
			{
				fFirst = lNext;
				if (lNext != null) tDLListItem!T.SetItemCapsPrev(lNext,null);
			}
			else if (lItemCaps == fLast)
			{
				fLast = lPrev;
				if (lPrev != null) tDLListItem!T.SetItemCapsNext(lPrev,null);
			}
			else
			{
				tDLListItem!T.SetItemCapsNext(lPrev,lNext);
				tDLListItem!T.SetItemCapsPrev(lNext,lPrev);
			}
			tDLListItem!T.DeleteItemCaps(lItemCaps);
			fCount--;
			if (fCount == 0)
			{
				fFirst = null;
				fLast = null;
			}
			if (fOnChange) fOnChange(this,eListChangeKind.ckRemove,lRes);
		}
		final override T* Extract(T* aItem)
		{
			auto lIndex = IndexOf(aItem);
			if (lIndex == -1) return null;
			Remove(lIndex);
			return aItem;
		}
		final override T* Extract(ptrdiff_t aIndex)
		{
			auto lItemCaps = GetItemCaps(aIndex);
			if (lItemCaps == null) return null;
			auto lRes = tDLListItem!T.GetItemCapsData(lItemCaps);
			auto lPrev = tDLListItem!T.PreviousItemCaps(lItemCaps);
			auto lNext = tDLListItem!T.NextItemCaps(lItemCaps);
			if (lItemCaps == fFirst)
			{
				fFirst = lNext;
				if (lNext != null) tDLListItem!T.SetItemCapsPrev(lNext,null);
			}
			else if (lItemCaps == fLast)
			{
				fLast = lPrev;
				if (lPrev != null) tDLListItem!T.SetItemCapsNext(lPrev,null);
			}
			else
			{
				tDLListItem!T.SetItemCapsNext(lPrev,lNext);
				tDLListItem!T.SetItemCapsPrev(lNext,lPrev);
			}
			tDLListItem!T.DeleteItemCaps(lItemCaps);
			fCount--;
			if (fCount == 0)
			{
				fFirst = null;
				fLast = null;
			}
			if (fOnChange) fOnChange(this,eListChangeKind.ckExtract,lRes);
			return lRes;
		}
		final override void Exchange(ptrdiff_t aIndex1, ptrdiff_t aIndex2)
		{
			auto lItemCaps1 = GetItemCaps(aIndex1);
			if (lItemCaps1 == null) return;
			auto lItemCaps2 = GetItemCaps(aIndex2);
			if (lItemCaps2 == null) return;
			auto lItemCaps1Data = tDLListItem!T.GetItemCapsData(lItemCaps1);
			tDLListItem!T.SetItemCapsData(lItemCaps1,tDLListItem!T.GetItemCapsData(lItemCaps2));
			tDLListItem!T.SetItemCapsData(lItemCaps2,lItemCaps1Data);
			if (fOnChange) fOnChange(this,eListChangeKind.ckExchange,null);
		}

		final override void Exchange(T* aItem1, T* aItem2)
		{
			auto lItemCaps1 = GetItemCaps(aItem1);
			if (lItemCaps1 == null) return;
			auto lItemCaps2 = GetItemCaps(aItem2);
			if (lItemCaps2 == null) return;
			auto lItemCaps1Data = tDLListItem!T.GetItemCapsData(lItemCaps1);
			tDLListItem!T.SetItemCapsData(lItemCaps1,tDLListItem!T.GetItemCapsData(lItemCaps2));
			tDLListItem!T.SetItemCapsData(lItemCaps2,lItemCaps1Data);
			if (fOnChange) fOnChange(this,eListChangeKind.ckExchange,null);
		}
		final override void Clear()
		{
			if (fFirst == null) return;
			auto lItemCaps = fFirst;
			while(lItemCaps != null)
			{
				auto lOld = lItemCaps;
				lItemCaps = tDLListItem!T.NextItemCaps(lItemCaps);
				tDLListItem!T.DeleteItemCaps(lOld);
			}
			fCount = 0;
			fFirst = null;
			fLast = null;
			if (fOnChange) fOnChange(this,eListChangeKind.ckRemove,null);
		}
		final override void Iterate(size_t aReason, void delegate(size_t aReason, T* aItem, void* aUserDt, out bool doStop) aClbck, void* aUserDt = null)
		{
			bool doStop;
			auto lItemCaps = fFirst;
			for (ptrdiff_t i = 0; i < fCount; i++)
			{
				aClbck(aReason, tDLListItem!T.GetItemCapsData(lItemCaps), aUserDt, doStop);
				if (doStop) break;
				lItemCaps = tDLListItem!T.NextItemCaps(lItemCaps);
			}
		}
		final override void IterateReverse(size_t aReason, void delegate(size_t aReason, T* aItem, void* aUserDt, out bool doStop) aClbck, void* aUserDt = null)
		{
			bool doStop;
			auto lItemCaps = fLast;
			for (ptrdiff_t i = 0; i < fCount; i++)
			{
				aClbck(aReason, tDLListItem!T.GetItemCapsData(lItemCaps), aUserDt, doStop);
				if (doStop) break;
				lItemCaps = tDLListItem!T.PreviousItemCaps(lItemCaps);
			}
		}
		final override T* opIndex(ptrdiff_t i)
		{
			auto lItemCaps = GetItemCaps(i);
			if (lItemCaps == null) return null;
			return tDLListItem!T.GetItemCapsData(lItemCaps);
		}
		final override void opIndexAssign(T* aItem, ptrdiff_t i)
		{
			if ((!fAllowDup) && (IndexOf(aItem) != -1)) return;
			auto lItemCaps = GetItemCaps(i);
			if (lItemCaps == null) return;
			tDLListItem!T.SetItemCapsData(lItemCaps,aItem);
		}
		final override int opApply(int delegate(T*) dg)
		{
			int result = 0;
			auto lItemCaps = fFirst;
			for (ptrdiff_t i = 0; i < fCount; i++)
			{
				result = dg(tDLListItem!T.GetItemCapsData(lItemCaps));
				if (result) break;
				lItemCaps = tDLListItem!T.NextItemCaps(lItemCaps);
			}
			return result;
		}
		final override int opApplyReverse(int delegate(T*) dg)
		{
			int result = 0;
			auto lItemCaps = fLast;
			for (ptrdiff_t i = 0; i < fCount; i++)
			{
				result = dg(tDLListItem!T.GetItemCapsData(lItemCaps));
				if (result) break;
				lItemCaps = tDLListItem!T.PreviousItemCaps(lItemCaps);
			}
			return result;
		}
		final override T* First()
		{
			if (!fFirst) 
				return null;
			else 
				return tDLListItem!T.GetItemCapsData(fFirst);
		}
		final override T* Last()
		{
			if (!fLast) 
				return null;
			else 
				return tDLListItem!T.GetItemCapsData(fLast);
		}
		final override ptrdiff_t Count()
		{
			return fCount;
		}
		final override bool AllowDup()
		{
			return fAllowDup;
		}
		final override void AllowDup(bool aValue)
		{
			if (fAllowDup == aValue) return;
			fAllowDup = aValue;
			if (!fAllowDup)
			{
				auto lItemCaps1 = fFirst;
				for (size_t i = 0; i < fCount; i++)
				{
					auto lItem1 = tDLListItem!T.GetItemCapsData(lItemCaps1);
					lItemCaps1 = tDLListItem!T.NextItemCaps(lItemCaps1);
					auto lItemCaps2 = fLast;
					for (size_t j = fCount-1; j > i; j--)
					{
						auto lItem2 = tDLListItem!T.GetItemCapsData(lItemCaps2);
						lItemCaps2 = tDLListItem!T.PreviousItemCaps(lItemCaps2);
						if (lItem2 == lItem1) Remove(j);
					}
				}
			}
		}
		final override bool MustCleanItems()
		{
			return fCleanupItems;
		}
		final override void MustCleanItems(bool aValue)
		{
			fCleanupItems = aValue;
		}
		final override void Sort(bool delegate(T* Item1, T* Item2) aCompareClbck)
		{
		}
		final override dListNotification OnChange() {return fOnChange;}
		final override void OnChange(dListNotification aValue){fOnChange = aValue;}
	}
}
final private class cDoubleLinkedListTester
{
	unittest
	{
		struct Foo{int a,b,c;}
		Foo Foos[1000];
		auto FooList = new cDoubleLinkedList!Foo;
		FooList.AddSome(Foos);

		FooList[10] = &Foos[20];
		auto b = FooList.IndexOf( &Foos[20] );
		assert( b == 10, format("%d",b));
		assert( *FooList[10] == Foos[20]);
		FooList[10] = &Foos[10];

		assert( FooList.Count == Foos.length);
		assert( FooList.IndexOf( &Foos[500] ) == 500);
		assert( FooList.IndexOf( &Foos[999] ) == 999);
		assert( *FooList[246] == Foos[246]);
		FooList.AddSome(Foos);
		assert( FooList.Count == Foos.length * 2);
		FooList.Remove(1500);
		assert( FooList.Count == Foos.length * 2 -1);
		assert( *FooList[1500] == Foos[501]);
		FooList.AllowDup = false;
		assert( FooList.Count == Foos.length);
		FooList.Insert(1, &Foos[5]);
		assert( FooList.Count == Foos.length);
		FooList.AllowDup = true;
		FooList.Insert(1, &Foos[5]);
		assert( *FooList[0] == Foos[0]);
		assert( *FooList[1] == Foos[5]);
		assert( *FooList[2] == Foos[1]);
		FooList.Clear;
		FooList.AddSome(Foos);
		FooList.Insert(0,&Foos[999]);
		assert( *FooList[0] == Foos[999]);
		assert( *FooList.First == Foos[999]);
		assert( *FooList[1] == Foos[0]);
		FooList.Clear;
		assert( FooList.Count == 0);
		FooList.AddSome(Foos);
		FooList.Exchange(0,999);
		assert( *FooList.First == Foos[999]);
		assert( *FooList.Last == Foos[0]);
		assert( *FooList[0] == Foos[999]);
		assert( *FooList[999] == Foos[0]);
		FooList.Exchange(&Foos[0],&Foos[999]);
		assert( *FooList[0] == Foos[0]);
		assert( *FooList[999] == Foos[999]);
		int i;
		void IteratorClbck1(size_t aReason, Foo* aItem, void* aUserDt, out bool doStop)
		{
			aItem.a = i;
			i++;
		}
		FooList.Iterate(0, &IteratorClbck1);
		assert( Foos[0].a == 0);
		assert( Foos[500].a == 500);
		assert( Foos[999].a == 999);
		void IteratorClbck2(size_t aReason, Foo* aItem, void* aUserDt, out bool doStop)
		{
			i--;
			aItem.b = i;
		}
		FooList.IterateReverse(0, &IteratorClbck2);
		assert( Foos[0].b == 0);
		assert( Foos[500].b == 500);
		assert( Foos[999].b == 999);
		FooList.Clear;
		FooList.AddSome(Foos);
		foreach(Foo* Item; FooList)
		{
			Item.c = i;
			i++;
		}
		assert( Foos[0].c == 0);
		assert( Foos[500].c == 500);
		assert( Foos[999].c == 999);

		writeln("cDoubleLinkedList(T) passed the tests");
	}
}
alias cDoubleLinkedList cDynamicList;

enum eLineEndingMode {lemSystem,lemWin,lemPosix};

alias cGenericStringList!char cStringList;
alias cGenericStringList!wchar cWideStringList;
alias cGenericStringList!dchar cDoubleStringList;

/**
 * List specialized for managing strings
 */
class cGenericStringList(T): cDynamicList!(T[]), iSerializable
if (isSomeChar!T)
{
	private
	{
		enum  RdKind {rdA,rdW,rdD};
		RdKind fReadKind;
	}
	protected
	{
		StringType[] fBackStrings;
	}
	public
	{
		alias T[] StringType;
		/**
		 * Saves the list to a file.
		 * The encoding is relative to the character type of the list.
		 */
		final void SaveToFile(in char[] aFilename, eLineEndingMode aLineEndingMode = eLineEndingMode.lemSystem)
		{
			auto lStr = new cMemoryStream;
			scope(exit) delete lStr;
			// writes BOM according to T
			static if (is(T==char)) 
			{
				ubyte[3] lBOM = [0xEF, 0xBB, 0xBF];
				lStr.Write(lBOM.ptr,3);
			}
			else if (is(T==wchar)) 
			{
				ubyte[2] lBOM = [0xFF, 0xFE];
				lStr.Write(lBOM.ptr,2);
			}
			else if (is(T==dchar)) 
			{
				ubyte[4] lBOM = [0xFF, 0xFE, 0x00, 0x00];
				lStr.Write(lBOM.ptr,4);
			}
			// prepares the line ending buffer
			StringType lEol;
			if(	(((aLineEndingMode == eLineEndingMode.lemWin) & IsWin) 		| (aLineEndingMode == eLineEndingMode.lemSystem)) |
				(((aLineEndingMode == eLineEndingMode.lemPosix) & IsPosix) 	| (aLineEndingMode == eLineEndingMode.lemSystem)) )
			{
				static if (is(T==char))  lEol = newlineA.dup; else
				static if (is(T==wchar)) lEol = newlineW.dup; else
				static if (is(T==dchar)) lEol = newlineD.dup;
			}
			else
			{
				static if (is(T==char))  lEol = AltnewlineA.dup; else
				static if (is(T==wchar)) lEol = AltnewlineW.dup; else
				static if (is(T==dchar)) lEol = AltnewlineD.dup;
			}
			// write content
			for(ptrdiff_t i = 0; i < Count; i++)
			{
				StringType* lItem = this[i];
				lStr.Write( lItem.ptr, lItem.length * T.sizeof );
				if ( i == Count-1) break;
				lStr.Write( lEol.ptr, lEol.length * T.sizeof );
			}
			// saves the file
			lStr.SaveToFile(aFilename);
		}
		/**
		 * Loads the list from a file.
		 * A possible data loss can append due to an internal conversion 
		 * (i.e UTF-16 file loaded in an cGenericStringList!char).
		 */
		final void LoadFromFile(in char[] aFilename)
		{
			auto lStr = new cMemoryStream;
			scope(exit) delete lStr;
			lStr.LoadFromFile(aFilename);
			Clear;
			if (lStr.Size == 0) return;
			char[] lStringA;
			wchar[] lStringW;
			dchar[] lStringD;
			uint lBOM;
			bool lIsRaw;
			ubyte lSz = 1;
			lStr.Read( &lBOM, lBOM.sizeof);
			// ascii ?
			if ((lBOM & 0xBFBBEF) == 0xBFBBEF)
			{ 
				fReadKind = RdKind.rdA;
				lStr.Position = 3;
			}
			else if ((lBOM & 0xFEFF) == 0xFEFF)
			{
				// UCS-4 le ?
				if ((lBOM & 0xFFFF0000) == 0) 
				{
					fReadKind = RdKind.rdD;
					lSz = 4;
				} 
				// UCS-2 le ?
				else 
				{
					fReadKind = RdKind.rdW;
					lStr.Position = 2;
					lSz = 2;
				}
			}
			else
			{
				fReadKind = RdKind.rdA;
				lStr.Position = 0;
				lIsRaw = true;
			}
			// guess the EOL format
			ulong lStored = lStr.Position;
			ubyte[] lEolScanner;
			lEolScanner.length = lSz * 2;
			bool lIsWinEOL;
			uint lPosixCount, lWinCount;
			while (lStr.Position < lStr.Size )
			{
				lStr.Read( lEolScanner.ptr, lSz * 2);
				if (lSz == 1)
				{
					lPosixCount += ((lEolScanner[1] == 0x0A) & (lEolScanner[0] != 0x0D));
					lWinCount 	+= ((lEolScanner[1] == 0x0A) & (lEolScanner[0] == 0x0D));
				}
				else if (lSz == 2)
				{
					lPosixCount += ((lEolScanner[2] == 0x0A) & (lEolScanner[0] != 0x0D));
					lWinCount 	+= ((lEolScanner[2] == 0x0A) & (lEolScanner[0] == 0x0D));
				}
				else if (lSz == 4)
				{
					lPosixCount += ((lEolScanner[4] == 0x0A) & (lEolScanner[0] != 0x0D));
					lWinCount 	+= ((lEolScanner[4] == 0x0A) & (lEolScanner[0] == 0x0D));
				}
				if ((lPosixCount > lWinCount + 4) | (lWinCount > lPosixCount + 4)) break;
			}
			lIsWinEOL = lWinCount > lPosixCount;
			lStr.Position = lStored;
			//
			if (lIsRaw && lPosixCount == lPosixCount && lPosixCount == 0 && lStr.Size > 255 * T.sizeof)
			{
				throw new Exception("cGenericStringList exception, LoadFromFile() can only load text files");
			}
			// routines used while filling
			bool IsReadingA(){return (fReadKind == RdKind.rdA);}
			bool IsReadingW(){return (fReadKind == RdKind.rdW);}
			bool IsReadingD(){return (fReadKind == RdKind.rdD);}
			void AddString()
			{
				// warning: the string should be decoded first
				fBackStrings.length = fBackStrings.length + 1;
				if (IsReadingA) fBackStrings[$-1] = to!StringType(lStringA); else
				if (IsReadingW) fBackStrings[$-1] = to!StringType(lStringW); else
				if (IsReadingD) fBackStrings[$-1] = to!StringType(lStringD);
				Add(&fBackStrings[$-1]);
			}
			// Sets the local strings length to 255 chars to avoid reallocations
			if (IsReadingA) lStringA.length = 0xFF; else
			if (IsReadingW) lStringW.length = 0xFF; else
			if (IsReadingD) lStringD.length = 0xFF;

			// fills the list
			uint lLen;
			while(lStr.Position < lStr.Size)
			{
				if (IsReadingA) lStr.Read(&lStringA[lLen],lSz); else
				if (IsReadingW) lStr.Read(&lStringW[lLen],lSz); else
				if (IsReadingD) lStr.Read(&lStringD[lLen],lSz);
				lLen++;
				if(lLen > 0xFF) 
				{
					if (IsReadingA) lStringA.length = lStringA.length + 1; else
					if (IsReadingW) lStringW.length = lStringW.length + 1; else
					if (IsReadingD) lStringD.length = lStringD.length + 1;
				}
				if 
				(  	
					((IsReadingA) && (lStringA[lLen-1] == '\n')) |
				    ((IsReadingW) && (lStringW[lLen-1] == '\n')) |
				    ((IsReadingD) && (lStringD[lLen-1] == '\n')) 
				)
				{
					if ((IsReadingA) && ((!lIsWinEOL) | (lIsWinEOL & (lStringA[lLen-2] == '\r'))))
					{
						lLen--;
						if(lIsWinEOL) lLen--;
						lStringA.length = lLen;
						AddString;
						lLen = 0;
						lStringA.length = 0xFF;
					}
					else if ((IsReadingW) && ((!lIsWinEOL) | (lIsWinEOL & (lStringW[lLen-2] == '\r'))))
					{
						lLen--;
						if(lIsWinEOL) lLen--;
						lStringW.length = lLen;
						AddString;
						lLen = 0;
						lStringW.length = 0xFF;
					} 
					else if ((IsReadingD) && ((!lIsWinEOL) | (lIsWinEOL & (lStringD[lLen-2] == '\r'))))
					{
						lLen--;
						if(lIsWinEOL) lLen--;
						lStringD.length = lLen;
						AddString;
						lLen = 0;
						lStringD.length = 0xFF;
					}
				}
			}
			// adds the remaining string (not detectable via \n)
			if (lLen > 0) AddString;
		}

		void DeclareProperties(cMasterSerializer aSerializer)
		{
			// note: Text() cant be declared as a property because it cant be represented
			// when a MasterSerializer use the skText format ( as 1 prop = 1 line ).
			int lCount = cast(int) Count;
			auto lCountDescr = intprop(&lCount,"Count");
			aSerializer.AddProperty!int(lCountDescr);
			StringType[] lItems;
			lItems.length = lCount;
			if (aSerializer.IsReading)
			{
				while (Count < lCount) Add(&lItems[Count]);
			}
			for (uint i = 0; i < lCount; i++)
			{ 
				lItems[i] = *this[i];
				auto lDescriptor = sPropDescriptor!StringType(&lItems[i],format("item%d",i));
				aSerializer.AddProperty!StringType(lDescriptor);
				this[i] = &lItems[i];
			}
		}
		bool IsSerializationRecursive()
		{
			return true;
		}
		bool IsReference(iSerializable aSerializable)
		{
			return false;
		}
		@property
		{
			/**
			 * Represents all the items, merged in a string.
			 */
			StringType Text()
			{
				StringType lResult;
				foreach(StringType* lItem; this)
				{
					static if (is(T==char))  lResult ~= *lItem ~ newlineA;
					static if (is(T==wchar)) lResult ~= *lItem ~ newlineW;
					static if (is(T==dchar)) lResult ~= *lItem ~ newlineD;
				}
				return lResult;
			}
			/// ditto
			void Text(StringType aValue)
			{
				Clear;
				AddSome(splitLines(aValue));
			}
		}
	}
}
final private class cStringListTester
{
	unittest
	{
		auto List = new cStringList;
		List.StringType[4] Items;
		Items = ["item1".dup,"item2".dup,"item3".dup,"item4".dup];
		List.AddSome(Items);
		assert( List.Text == "item1" ~ std.ascii.newline ~ "item2" ~ std.ascii.newline ~  
		       	"item3" ~ std.ascii.newline ~ "item4" ~ std.ascii.newline);
		
		List.Clear;
		List.Text = ("a1" ~ std.ascii.newline ~ "a2" ~ std.ascii.newline ~ "a3" ~ std.ascii.newline ~ "a4").dup;
		assert( List.Count == 4);
		assert( *List[0] == "a1" );
		assert( *List[3] == "a4" );

		auto lStr = new cMemoryStream;
		
		auto lSer = new cMasterSerializer(eSerializationKind.sktext);
		lSer.Serialize(cast(iSerializable)List,lStr);
		List.Clear;

		lStr.Position = 0;
		lSer.Deserialize( cast(iSerializable)List,lStr);
		assert(List.Count == 4);
		assert( *List[0] == "a1");
		assert( *List[3] == "a4");

		auto WList = new cWideStringList;
		scope(exit) delete WList;
		for( int i = 0; i < 1000; i++)
		{
			wchar[] litem = "aaaa bbbb cccc dddd 1111 2222"w.dup ;
			WList.Add(&litem);
		}
		WList.SaveToFile("wlist.txt",eLineEndingMode.lemPosix);
		WList.LoadFromFile("wlist.txt");
		assert(WList.Count == 1000);
		version(Windows) DeleteFileA(toStringz("wlist.txt"));
		version(Posix) core.stdc.stdio.remove(toStringz("wlist.txt"));

		auto DList = new cDoubleStringList;
		scope(exit) delete DList;
		for( int i = 0; i < 1000; i++)
		{
			dchar[] litem = "aaaa bbbb cccc dddd 1111 2222"d.dup ;
			DList.Add(&litem);
		}
		DList.SaveToFile("dlist.txt",eLineEndingMode.lemWin);
		DList.LoadFromFile("dlist.txt");
		assert(DList.Count == 1000);
		version(Windows) DeleteFileA(toStringz("dlist.txt"));
		version(Posix) core.stdc.stdio.remove(toStringz("dlist.txt"));
		
		writeln("cStringList passed the tests");
	}
}

/**
 * Stream interface.
 */
interface iStream
{
	/**
	 * Read aCount bytes in an allocated chunk starting at aBuffer.
	 */
	size_t Read(void* aBuffer, size_t aCount);
	/**
	 * Write aCount bytes from aBuffer.
	 */
	size_t Write(void* aBuffer, size_t aCount);
	/**
	 * Set the position to aOffset if aOrigin = 0,
	 * to Position + aOffset if aOrigin = 1 or
	 * to Size + aOffset if aOrigin = 2.
	 */
	ulong Seek(ulong aOffset, int aOrigin);
	/**
	 * Size of the stream
	 */
	ulong Size();
	void Size(ulong aValue);
	void Size(uint aValue);
	/**
	 * Position of the stream
	 */
	ulong Position();
	void Position(ulong aValue);
	/**
	 * Reset the stream size to 0.
	 */
	void Clear();
}

/**
 * This is the interface IStreamPersist
 * By convention an implementer of SaveToStream
 * should maintain the initial positions.
 */
interface iStreamPersist
{
	void SaveToStream(iStream aStream);
	void LoadFromStream(iStream aStream);
}

/**
 * This is the interface IFilePerist8.
 * Implemented for file persistence using an ANSI string as file name.
 */
interface iFilePersistA
{
	void SaveToFile(in char[] aFilename);
	void LoadFromFile(in char[] aFilename);
}

/**
* This is the interface IFilePerist8.
* Implemented for file persistence using an a wide string as file name.
*/
interface iFilePeristW
{
	void SaveToFile(in wchar[] aFilename);
	void LoadFromFile(in wchar[] aFilename);
}

/**
 * Implements a contiguous memory stream.
 * Its maximal theoretic size is limited to 2^32 bytes.
 */
class cMemoryStream: iStream, iStreamPersist, iFilePersistA, iFilePeristW
{
	private
	{
		void* fMemory;
		uint fSize;
		uint fPosition;
		void IntSaveToFile(FileHandle aHandle)
		{
			version(Windows)
			{
				uint lCount;
				SetFilePointer(aHandle, 0, null, FILE_BEGIN);
				WriteFile(aHandle, fMemory, fSize, &lCount, null);
				CloseHandle(aHandle);
			}
			version(Posix)
			{
				auto lCount = core.sys.posix.unistd.write(aHandle, fMemory, fSize);
				ftruncate64(aHandle, fSize);
				core.sys.posix.unistd.close(aHandle);
			}
			if (lCount != fSize) throw new Error("cMemoryStream error, SaveToFile failed");
		}
		void IntLoadFromFile(FileHandle aHandle)
		{
			version(Windows)
			{
				uint lSize, lCount;
				lSize = SetFilePointer(aHandle, 0, null, FILE_END);
				Size = lSize;
				SetFilePointer(aHandle, 0, null, FILE_BEGIN);
				ReadFile(aHandle, fMemory, lSize, &lCount, null);
				fPosition = 0;
				CloseHandle(aHandle);
			}
			version(Posix)
			{
				auto lSize = core.sys.posix.unistd.lseek64(aHandle, 0, SEEK_END);
				Size = lSize;
				core.sys.posix.unistd.lseek64(aHandle, 0, SEEK_SET);
				auto lCount = core.sys.posix.unistd.read(aHandle, fMemory, lSize);
				fPosition = 0;
				core.sys.posix.unistd.close(aHandle);
			}
			if (lCount != lSize) throw new Error("cMemoryStream error, LoadFromFile failed");
		}
	}
	public
	{
		mixin mConditionallyUncollected;
		this()
		{
			fMemory = std.c.stdlib.malloc(16);
			if (!fMemory) throw new OutOfMemoryError();
		}
		~this()
		{
			if(fMemory != null) std.c.stdlib.free(fMemory);
		}
		size_t Read(void* aBuffer, size_t aCount)
		{
			if (aCount + fPosition > fSize) aCount = fSize - fPosition;
			memmove(aBuffer, fMemory + fPosition, aCount);
			fPosition += aCount;
			return aCount;
		}
		size_t Write(void* aBuffer, size_t aCount)
		{
			if (aCount + fPosition > fSize) Size(aCount + fPosition);
			memmove(fMemory + fPosition, aBuffer, aCount);
			fPosition += aCount;
			return aCount;
		}
		ulong Seek(ulong aOffset, int aOrigin)
		{
			switch(aOrigin)
			{
				case 0:		
					fPosition = cast(uint) aOffset;
					if (fPosition > fSize)fPosition = fSize;
					return fPosition;		
				case 1:	
					fPosition += aOffset;
					if (fPosition > fSize) fPosition = fSize;
					return fPosition;	
				case 2:
					return fSize;	
				default: 
					return fPosition;
			}
		}
		void  TypedWrite(T)(T* aValue)
		if (! ((is (T== class)) | (is (T== struct)) | (is (T== enum)) | (isArray!T) | (!is (OriginalType!T)) ))
		{
			Write( aValue, T.sizeof );
		}
		void TypedRead(T)(T* aValue)
		if (! ((is (T== class)) | (is (T== struct)) | (is (T== enum)) | (isArray!T) | (!is (OriginalType!T)) ))
		{
			Read( aValue, T.sizeof );
		}
		void Clear()
		{
			fMemory = std.c.stdlib.realloc(fMemory,16);
			if (!fMemory) throw new OutOfMemoryError();
			fSize = 0;
			fPosition = 0;
		}
		ulong Size()
		{
			return fSize;
		}
		void Size(uint aValue)
		{
			if (fSize == aValue) return;
			if (aValue ==  0)
			{
				Clear;
				return;
			}
			fMemory = std.c.stdlib.realloc(fMemory,aValue);
			if (fMemory == null)
			{
				throw new OutOfMemoryError();
			}
			else
			{
				fSize = aValue;
			}
		}
		void Size(ulong aValue)
		{
			if (aValue > 0xFFFFFFFF)
			{
				throw new Exception("cMemoryStream exception: cannot allocate more than 0xFFFFFFFF bytes");
			}
			Size(cast(uint) aValue);
		}
		ulong Position()
		{
			return fPosition;
		}
		void Position(ulong aValue)
		{
			Seek(aValue,0);
		}
		void* Memory()
		{
			return fMemory;
		}
		/**
		 * Save the stream to another one.
		 * This method maintains the position and resets the target's one.
		 */
		void SaveToStream(iStream aStream)
		{
			aStream.Size = fSize;
			aStream.Position = 0;
			aStream.Write(fMemory,fSize);
			aStream.Position = 0;
		}
		/**
		 * Fills the stream with another stream.
		 * This method maintains the target's position and resets the stream's one.
		 */
		void LoadFromStream(iStream aStream)
		{
			Size = aStream.Size;
			auto lSaved = aStream.Position;
			scope(exit) aStream.Position = lSaved;
			aStream.Position = 0;
			aStream.Read(fMemory,fSize);
		}
		version(Windows)
		{
			void SaveToFile(in char[] aFilename)
			{
				auto Hdl = CreateFileA(toStringz(aFilename), GENERIC_WRITE, 0,  (SECURITY_ATTRIBUTES*).init, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, HANDLE.init);
				if (Hdl == INVALID_HANDLE_VALUE)
				{
					throw new Error(format("cMemoryStream exception: cannot create or overwrite '%s'",aFilename));
				}
				else
				{
					IntSaveToFile(Hdl);
				}
			}
			void SaveToFile(in wchar[] aFilename)
			{
				auto Hdl = CreateFileW(std.utf.toUTF16z(aFilename), GENERIC_WRITE, 0,  (SECURITY_ATTRIBUTES*).init, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, HANDLE.init);
				if (Hdl == INVALID_HANDLE_VALUE)
				{
					throw new Error(format("cMemoryStream exception: cannot create or overwrite '%s'",aFilename));
				}
				else
				{
					IntSaveToFile(Hdl);
				}
			}
			void LoadFromFile(in char[] aFilename)
			{
				auto Hdl = CreateFileA(toStringz(aFilename), GENERIC_READ, FILE_SHARE_READ, (SECURITY_ATTRIBUTES*).init,    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, HANDLE.init);
				if (Hdl == INVALID_HANDLE_VALUE)
				{
					throw new Error(format("cMemoryStream exception: cannot open '%s'",aFilename));
				}
				else
				{
					IntLoadFromFile(Hdl);
				}
			}
			void LoadFromFile(in wchar[] aFilename)
			{
				auto Hdl = CreateFileW(std.utf.toUTF16z(aFilename), GENERIC_READ, FILE_SHARE_READ, (SECURITY_ATTRIBUTES*).init, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, HANDLE.init);
				if (Hdl == INVALID_HANDLE_VALUE)
				{
					throw new Error(format("cMemoryStream exception: cannot open '%s'",aFilename));
				}
				else
				{
					IntLoadFromFile(Hdl);
				}
			}
		}
		version(Posix)
		{
			void SaveToFile(in char[] aFilename)
			{
				auto Hdl = open(toStringz(aFilename), O_CREAT | O_TRUNC | O_WRONLY, octal!666);
				if (Hdl <= -1)
				{
					throw new Error(format("cMemoryStream exception: cannot open '%s'",aFilename));
				}
				else
				{
					IntSaveToFile(Hdl);
				}
			}
			void SaveToFile(in wchar[] aFilename)
			{
			}
			void LoadFromFile(in char[] aFilename)
			{
				auto Hdl = open(toStringz(aFilename), O_CREAT | O_RDONLY, octal!666);
				if (Hdl <= -1)
				{
					throw new Error(format("cMemoryStream exception: cannot open '%s'",aFilename));
				}
				else
				{
					IntLoadFromFile(Hdl);
				}
			}
			void LoadFromFile(in wchar[] aFilename)
			{
			}
		}
	}
	unittest
	{
		auto Foo = new cMemoryStream;
		int[7] someInts = [0,1,2,3,4,5,6];
		foreach(int a; someInts) Foo.Write(&a,int.sizeof);
		assert(Foo.Size == someInts.length * int.sizeof, "cMemoryStream failed, invalid size");
		Foo.Position = 6465464;
		assert(Foo.Position == Foo.Size, "cMemoryStream failed, invalid position (1)");
		Foo.Seek(4,2);
		assert(Foo.Position == Foo.Size, "cMemoryStream failed, invalid position (2)");
		Foo.Seek(4,1);
		assert(Foo.Position == Foo.Size, "cMemoryStream failed, invalid position (3)");
		Foo.Position = 0;
		int b;
		for (int i = 0; i < someInts.length; i++)
		{
			Foo.Read( &b, b.sizeof);
			assert(b==someInts[i],"cMemoryStream failed, invalid value read");
		}
		auto Filename = "file1.txt";
		Foo.SaveToFile(Filename);
		Foo.Clear;
		assert(Foo.Size == 0, "cMemoryStream failed, invalid size after Clear() ");
		Foo.LoadFromFile(Filename);
		assert(Foo.Size == someInts.length * int.sizeof, "cMemoryStream failed, invalid size after LoadFromFile()");
		for (int i = 0; i < someInts.length; i++)
		{
			Foo.Read( &b, b.sizeof);
			assert(b==someInts[i],"cMemoryStream failed, invalid value read after LoadFromFile()");
		}
		auto Bar = new cMemoryStream;
		Bar.LoadFromStream(Foo);
		Bar.Position = 0;
		assert(Bar.Size == someInts.length * int.sizeof, "cMemoryStream failed, invalid size after LoadFromStream()");
		for (int i = 0; i < someInts.length; i++)
		{
			Bar.Read( &b, b.sizeof);
			assert(b==someInts[i],"cMemoryStream failed, invalid value read after LoadFromStream()");
		}
		Bar.Clear;
		Foo.SaveToStream(Bar);
		assert(Bar.Size == someInts.length * int.sizeof, "cMemoryStream failed, invalid size after SaveToStream()");
		for (int i = 0; i < someInts.length; i++)
		{
			Bar.Read( &b, b.sizeof);
			assert(b==someInts[i],"cMemoryStream failed, invalid value read after SaveToStream()");
		}
		version(Windows) DeleteFileA(toStringz(Filename));
		version(Posix) core.stdc.stdio.remove(toStringz(Filename));

		uint Sz = 10000000;
		Foo.Size = Sz;
		Foo.Position = Sz - 4;
		int u = 8;
		Foo.Write( &u, 4);
		Foo.Position = Sz - 4;
		Foo.Read( &u, 4);
		assert( u == 8 );

		auto lSaved = Foo.Position;
		Foo.TypedWrite!uint(&Sz);
		Foo.Position = lSaved;
		Sz = 0;
		Foo.TypedRead!uint(&Sz);
		assert( Foo.Position == lSaved + Sz.sizeof);
		assert( Sz == 10000000);

		writeln("cMemoryStream passed the tests");
	}
}

/**
 * Implements a generic system stream (handle-based).
 * This is not a final class and it cannot be used directly.
 */
class cSystemStream: iStream
{
	protected
	{
		FileHandle fHandle;
		final bool IsHandleValid()
		{
			version(Windows) return fHandle != INVALID_HANDLE_VALUE;
			version(Posix) return fHandle > -1;
		}
	}
	public
	{
		mixin mConditionallyUncollected;
		~this()
		{
			version(Windows) if (fHandle != INVALID_HANDLE_VALUE) CloseHandle(fHandle);
		}
		override size_t Read(void* aBuffer, size_t aCount)
		{
			version(Windows)
			{
				if (fHandle == INVALID_HANDLE_VALUE) return 0;
				uint lCount = cast(uint) aCount;
				LARGE_INTEGER Li;
				Li.QuadPart = aCount;
				ReadFile(fHandle, aBuffer, Li.LowPart, &lCount, null);
				return lCount;
			}
			version(Posix)
			{
				if (fHandle <= -1) return 0;
				return core.sys.posix.unistd.read(fHandle, aBuffer, aCount);
			}
		}
		override size_t Write(void* aBuffer, size_t aCount)
		{
			version(Windows)
			{
				if (fHandle == INVALID_HANDLE_VALUE) return 0;
				uint lCount = cast(uint) aCount;
				LARGE_INTEGER Li;
				Li.QuadPart = aCount;
				WriteFile(fHandle, aBuffer, Li.LowPart, &lCount, null);
				return lCount;
			}
			version(Posix)
			{
				if (fHandle <= -1) return 0;
				return core.sys.posix.unistd.write(fHandle, aBuffer, aCount);
			}
		}
		override ulong Seek(ulong aOffset, int aOrigin)
		{
			version(Windows)
			{
				if (fHandle == INVALID_HANDLE_VALUE) return 0;
				LARGE_INTEGER Li;
				Li.QuadPart = aOffset;
				Li.LowPart = SetFilePointer(fHandle, Li.LowPart, &Li.HighPart, aOrigin);
				return Li.QuadPart;
			}
			version(Posix)
			{
				if (fHandle <= -1) return 0;
				return core.sys.posix.unistd.lseek64(fHandle, aOffset, aOrigin);
			}
		}
		final void TypedWrite(T)(T* aValue)
		{
			// TODO
		}
		final void TypedRead(T)(T* aValue)
		{
			// TODO
		}
		override void Clear()
		{
			Size(0);
		}
		override ulong Size()
		{
			ulong lRes, lSaved;
			version(Windows)
			{
				if (fHandle == INVALID_HANDLE_VALUE) return 0;
				lSaved = Seek(0,FILE_CURRENT);
				lRes = Seek(0,FILE_END);
				Seek(lSaved,FILE_BEGIN);
			}
			version(Posix)
			{
				if (fHandle <= -1) return 0;
				lSaved = Seek(0,SEEK_CUR);
				lRes = Seek(0,SEEK_END);
				Seek(lSaved,SEEK_SET);
			}
			return lRes;
		}
		override void Size(uint aValue)
		{
			version(Windows)
			{
				if (fHandle == INVALID_HANDLE_VALUE) return;
				SetFilePointer(fHandle, aValue, null, FILE_BEGIN);
				SetEndOfFile(fHandle);
			}
			version(Posix)
			{
				if (fHandle <= -1) return;
				ftruncate(fHandle,aValue);
			}
		}
		override void Size(ulong aValue)
		{
			if (Size == aValue) return;
			version(Windows)
			{
				if (fHandle == INVALID_HANDLE_VALUE) return;
				LARGE_INTEGER Li;
				Li.QuadPart = aValue;
				SetFilePointer(fHandle, Li.LowPart, &Li.HighPart, FILE_BEGIN);
				SetEndOfFile(fHandle);
			}
			version(Posix)
			{
				if (fHandle <= -1) return;
				ftruncate(fHandle,aValue);
			}
		}
		override ulong Position()
		{
			version(Windows) return Seek(0,FILE_CURRENT);
			version(Posix) return Seek(0,SEEK_CUR);
		}
		override void Position(ulong aValue)
		{
			ulong lSize = Size;
			if (aValue >  lSize) aValue = lSize;
			version(Windows) Seek(aValue,FILE_BEGIN);
			version(Posix) Seek(aValue,SEEK_SET);
		}
		/**
		 * Returns the handle.
		 * Depending on to the implementation, it can be used for additional operations.
		 */
		SystemHandle Handle()
		{
			return fHandle;
		}
	}
}

 /**
  * Implements a "direct from disk" file stream.
  * Its theoretic size is limited to 2^64 bytes.
  * This limit is itself clamped by the amount of disk space available.
  * Its handle is maintained during the whole stream life-time
  */
class cFileStream: cSystemStream, iStreamPersist
{
	private
	{
		wstring fFilename;
	}
	public
	{
		/**
		 * Construct the stream and calls OpenFile(aFilename).
		 */
		this(in char[] aFilename = "")
		{
			if (aFilename.length > 0) OpenFile(aFilename);
		}
		~this()
		{
			CloseFile;
		}
		/**
		 * Close current file.
		 */
		void CloseFile()
		{
			version(Windows)
			{
				if (fHandle != INVALID_HANDLE_VALUE) CloseHandle(fHandle);
				fHandle = INVALID_HANDLE_VALUE;
			}
			version(Posix)
			{
				if (fHandle > 0) core.sys.posix.unistd.close(fHandle);
				fHandle = -1;
			}
			fFilename = "";
		}
		/**
		 * Create or open the file aFilename.
		 * The file is shared for reading.
		 */
		void OpenFile(in char[] aFilename)
		{
			CloseFile;
			version(Windows)
			{

				fHandle = CreateFileA(toStringz(aFilename), READ_WRITE, FILE_SHARE_READ,
								  (SECURITY_ATTRIBUTES*).init, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, HANDLE.init);
				if (fHandle == INVALID_HANDLE_VALUE)
				{
					throw new Error(format("cFileStream exception: cannot create or overwrite '%s'",aFilename));
				}
			}
			version(Posix)
			{
				fHandle = open(toStringz(aFilename), O_CREAT | O_RDWR, octal!666);
				if (fHandle <= -1)
				{
					throw new Error(format("cFileStream exception: cannot create or overwrite '%s'",aFilename));
				}
			}
			if (IsHandleValid) fFilename = std.utf.toUTF16(aFilename).idup;

		}
		/// ditto
		void OpenFile(in wchar[] aFilename)
		{
			CloseFile;
			version(Windows)
			{
				fHandle = CreateFileW(std.utf.toUTF16z(aFilename), READ_WRITE, FILE_SHARE_READ,
									  (SECURITY_ATTRIBUTES*).init, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, HANDLE.init);
				if (fHandle == INVALID_HANDLE_VALUE)
				{
					throw new Error(format("cFileStream exception: cannot create or overwrite '%s'",aFilename));
				}
			}
			version(Posix)
			{
			}
			if (IsHandleValid) fFilename = (aFilename).idup;
		}
		/**
		 * Open the file aFilename for reading only.
		 * The file is shared for reading.
		 */
		void OpenReadOnlyFile(in char[] aFilename)
		{
			CloseFile;
			version(Windows)
			{
				fHandle = CreateFileA(toStringz(aFilename), GENERIC_READ, FILE_SHARE_READ,
								  (SECURITY_ATTRIBUTES*).init, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, HANDLE.init);
				if (fHandle == INVALID_HANDLE_VALUE)
				{
					throw new Error(format("cFileStream exception: cannot create or overwrite '%s'",aFilename));
				}
			}
			version(Posix)
			{
				fHandle = open(toStringz(aFilename), O_CREAT | O_RDONLY, octal!666);
				if (fHandle <= -1)
				{
					throw new Error(format("cFileStream exception: cannot create or overwrite '%s'",aFilename));
				}
			}
			if (IsHandleValid) fFilename = std.utf.toUTF16(aFilename).idup;
		}
		/// ditto
		void OpenReadOnlyFile(in wchar[] aFilename)
		{
			version(Windows)
			{
				CloseFile;
				fHandle = CreateFileW(std.utf.toUTF16z(aFilename), GENERIC_READ, FILE_SHARE_READ,
									  (SECURITY_ATTRIBUTES*).init, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, HANDLE.init);
				if (fHandle == INVALID_HANDLE_VALUE)
				{
					throw new Error(format("cFileStream exception: cannot create or overwrite '%s'",aFilename));
				}
			}
			version(Posix)
			{
			}
			if (IsHandleValid) fFilename = (aFilename).idup;
		}
		/**
		 * Save the stream to another stream.
		 * This method maintains the position and resets the target's one.
		 */
		void SaveToStream(iStream aStream)
		{
			ulong lSaved = Position;
			ulong lSize = Size;
			aStream.Size = lSize;
			if (lSize == 0) return;
			aStream.Position = 0;
			Position = 0;
			size_t lCount;
			ulong lRemaining = lSize;
			ulong lProcessed;
			auto lBuff = std.c.stdlib.malloc(4096);
			scope(exit) std.c.stdlib.free(lBuff);
			while(lRemaining != 0)
			{
				lCount = Read(lBuff,4096);
				aStream.Write(lBuff,lCount);
				lRemaining -= lCount;
			}
			aStream.Position = 0;
			Position = lSaved;
		}
		/**
		 * Fills the stream with another stream.
		 * This method maintains the target's position and resets the stream's one.
		 */
		void LoadFromStream(iStream aStream)
		{
			ulong lSaved = aStream.Position;
			ulong lSize = aStream.Size;
			Size = lSize;
			if (lSize == 0) return;
			aStream.Position = 0;
			Position = 0;
			size_t lCount;
			ulong lRemaining = lSize;
			ulong lProcessed;
			auto lBuff = std.c.stdlib.malloc(4096);
			scope(exit) std.c.stdlib.free(lBuff);
			while(lRemaining != 0)
			{
				lCount = aStream.Read(lBuff,4096);
				Write(lBuff,lCount);
				lRemaining -= lCount;
			}
			Position = 0;
			aStream.Position = lSaved;
		}
		/**
		 * Returns current file name. (fully qualified).
		 * Data loss can occurs if using the Ansi version and if the file was opened by an unicode method.
		 */
		wstring Filename()
		{
			return fFilename;
		}
		/// ditto
		string Filename()
		{
			return std.utf.toUTF8(fFilename);
		}
	}
	unittest
	{
		auto Filename1 = "file1.txt";
		auto Filename2 = "file2.txt";
		auto Big = new cFileStream("huge.bin");
		Big.Size = 0x1FFFFFFFF;
		Big.CloseFile;
		version(Windows) DeleteFileA(toStringz("huge.bin"));
		version(Posix) core.stdc.stdio.remove(toStringz("huge.bin"));
		auto Foo = new cFileStream(Filename1);
		int[7] someInts = [0,1,2,3,4,5,6];
		foreach(int a; someInts) Foo.Write(&a,int.sizeof);
		assert(Foo.Size == someInts.length * int.sizeof, "cFileStream failed, invalid size");

		Foo.Position = 6465464;
		assert(Foo.Position == Foo.Size, "cFileStream failed, invalid position (1)");
		Foo.Seek(4,0);
		assert(Foo.Position == 4, "cFileStream failed, invalid position (2)");
		Foo.Seek(4,1);
		assert(Foo.Position == 8, "cFileStream failed, invalid position (3)");

		Foo.Position = 0;
		int b;
		for (int i = 0; i < someInts.length; i++)
		{
			Foo.Read( &b, b.sizeof);
			assert(b==someInts[i],"cFileStream failed, invalid value read");
		}
		Foo.CloseFile;
		assert(Foo.Size == 0, "cFileStream failed, invalid size after CloseFile() ");
		Foo.OpenFile(Filename1);
		assert(Foo.Size == someInts.length * int.sizeof, "cFileStream failed, invalid size after OpenFile()");
		for (int i = 0; i < someInts.length; i++)
		{
			Foo.Read( &b, b.sizeof);
			assert(b==someInts[i],"cFileStream failed, invalid value read after OpenFile()");
		}
		auto Bar = new cFileStream(Filename2);
		Bar.LoadFromStream(Foo);
		Bar.Position = 0;
		assert(Bar.Size == someInts.length * int.sizeof, format("cFileStream failed, invalid size after LoadFromStream() current %d - expected %d",Bar.Size,someInts.length * int.sizeof));
		for (int i = 0; i < someInts.length; i++)
		{
			Bar.Read( &b, b.sizeof);
			assert(b==someInts[i],"cFileStream failed, invalid value read after LoadFromStream()");
		}
		Bar.Clear;
		Foo.SaveToStream(Bar);
		assert(Bar.Size == someInts.length * int.sizeof, "cFileStream failed, invalid size after SaveToStream()");
		for (int i = 0; i < someInts.length; i++)
		{
			Bar.Read( &b, b.sizeof);
			assert(b==someInts[i],"cFileStream failed, invalid value read after SaveToStream()");
		}
		Foo.CloseFile;
		Bar.CloseFile;
		version(Windows)
		{
			DeleteFileA(toStringz(Filename1));
			DeleteFileA(toStringz(Filename2));
		}
		version(Posix)
		{
			core.stdc.stdio.remove(toStringz(Filename1));
			core.stdc.stdio.remove(toStringz(Filename2));
		}

		writeln("cFileStream passed the tests");
	}
}

/**
 * Implements a volume stream.
 * This stream allows the raw edition of a
 * file system (formatted disk, formatted flash drive, ...).
 * It also permits to read any read-only volume (DVD/CD ROM) in RAW mode.
 *
 * Its size relies on the target volume and cannot be modified.
 *
 * When not opened in read-only mode, changes are physically written when
 * a new cluster is put in cache or when the stream is destroyed.
 * Thus a tricky way to force a flush is to increase/decrease the
 * stream position by the value of ClusterSize.
 */
class cVolumeStream: cSystemStream
{
	private
	{
		uint fClusterSize;
		uint fSectPerCluster;
		uint fBytesPerSector;
		uint fClusterCount;
		uint fCachePosition;
		void* fClusterCache;
		ulong fClusterIndex;
		ulong fSize;
		bool fClusterChanged;
		bool fReadOnly;

		/**
		 * Write currently cached cluster.
		 */
		void WriteBackCache()
		{
			if (!fClusterChanged) return;
			if (fReadOnly) return;
			version(Windows)
			{
				uint lCount;
				if (!DeviceIoControl(fHandle, FSCTL_LOCK_VOLUME, null, 0, null, 0, &lCount, null))
				{
					new Error("cVolumeStream error, impossible to lock the volume.");
				}
				else
				{
					WriteFile(fHandle, fClusterCache, fClusterSize, &lCount, null);
					fClusterChanged = false;
					if (!DeviceIoControl(fHandle, FSCTL_UNLOCK_VOLUME, null, 0, null, 0, &lCount, null))
					{
						new Error("cVolumeStream error, impossible to lock the volume.");
					}
				}
			}
			version(Posix)
			{
				core.sys.posix.unistd.write(fHandle, fClusterCache, fClusterSize);
			}
		}
		/**
		 * Read a cluster in the cache
		 */
		void ReadCache()
		{
			version(Windows)
			{
				uint lCount;
				ReadFile(fHandle, fClusterCache, fClusterSize, &lCount, null);
			}
			version(Posix)
			{
				core.sys.posix.unistd.read(fHandle, fClusterCache, fClusterSize);
			}
		}
		/**
		 * Retrieve the cluster index at a given position.
		 */
		ulong PositionToClusterIndex(ulong aPosition)
		{
			return aPosition / fClusterSize;
		}
		/**
		 * Retrieve the cluster first byte position relative to aPosition.
		 */
		ulong DiscretePosition(ulong aPosition)
		{
			return (aPosition / fClusterSize) * fClusterSize;
		}
		/**
		 * Set the current cluster index and handles caching operations.
		 */
		void ClusterIndex(ulong aValue)
		{
			if (fClusterIndex != aValue)
			{
				version(Windows)
				{
					LARGE_INTEGER Li;
					WriteBackCache;
					fClusterIndex = aValue;
					fCachePosition = 0;
					Li.QuadPart = fClusterIndex * fClusterSize;
					SetFilePointer(fHandle, Li.LowPart, &Li.HighPart, FILE_BEGIN);
					ReadCache;
					// restore the position modified by ReadCache()
					Li.QuadPart = fClusterIndex * fClusterSize;
					SetFilePointer(fHandle, Li.LowPart, &Li.HighPart, FILE_BEGIN);
				}
				version(Posix)
				{
					WriteBackCache;
					fClusterIndex = aValue;
					fCachePosition = 0;
					core.sys.posix.unistd.lseek64(fHandle, fClusterIndex * fClusterSize, 0);
					ReadCache;
					// restore the position modified by ReadCache()
					core.sys.posix.unistd.lseek64(fHandle, fClusterIndex * fClusterSize, 0);
				}
			}
		}
	}
	public
	{
		this(in char aVolumeLetter, bool readOnly = false)
		{
			char[1] lVol;
			lVol[0] = aVolumeLetter;
			OpenVolume(lVol,readOnly);
		}
		~this()
		{
			CloseVolume;
			if (fClusterCache != null) std.c.stdlib.free(fClusterCache);
		}
		/**
		 * Open the volume identified by aVolumeLetter.
		 */
		version(Windows) void OpenVolume(in char aVolumeLetter, bool readOnly = false)
		{
			OpenVolume(  `\\.\` ~ aVolumeLetter ~ `:`, readOnly );
		}
		/**
		 * Open the volume identified by the letter aVolumeLetter.
		 * The volume can optionally be accesssed in read-only mode.
		 * In this case, writting operations are still processed at the cache-level
		 * but a cluster will never be physically replaced.
		 */
		void OpenVolume(in char[] aVolume, bool readOnly = false)
		{
			CloseVolume;
			uint lUnused;
			version(Windows)
			{
				fHandle = CreateFileA(  toStringz(aVolume), READ_WRITE, FILE_SHARE_READ|FILE_SHARE_WRITE,
										(SECURITY_ATTRIBUTES*).init, OPEN_EXISTING, 0, null);
				if (fHandle == INVALID_HANDLE_VALUE)
				{
					throw new Error("cVolumeStream error, impossible to create a view on the volume.");
				}
				else
				{
					bool lIsCacheSet;
					LARGE_INTEGER Li;
					Li.QuadPart = 0;
					Li.LowPart = SetFilePointer( fHandle, Li.LowPart, &Li.HighPart, FILE_END);
					fSize = Li.QuadPart;
					SetFilePointer( fHandle, 0, null, FILE_BEGIN);

					DISK_GEOMETRY_EX lGeom;
					uint lCount;

					STORAGE_ACCESS_ALIGNMENT_DESCRIPTOR lAlignmentDescriptor;
					STORAGE_PROPERTY_QUERY lQuery;
					lQuery.QueryType  = STORAGE_QUERY_TYPE.PropertyStandardQuery;
					lQuery.PropertyId = STORAGE_PROPERTY_ID.StorageAccessAlignmentProperty;

					// try to set the cache size according to the logical sector size.
					if (DeviceIoControl(fHandle, IOCTL_STORAGE_QUERY_PROPERTY, &lQuery, lQuery.sizeof, &lAlignmentDescriptor, lAlignmentDescriptor.sizeof, &lCount, null))
					{
						fClusterSize = lAlignmentDescriptor.BytesPerLogicalSector;
						lIsCacheSet = (fClusterSize > 0);
					}
					// try to set the cache size according to the physical sector size.
					if (!lIsCacheSet) if (DeviceIoControl( fHandle, IOCTL_DISK_GET_DRIVE_GEOMETRY_EX, null, 0, &lGeom, lGeom.sizeof, &lCount, null))
					{
						// should be the same value that the one retrieved by seeking
						//assert( lGeom.DiskSize.QuadPart == fSize, "WARNING: volume size conflict");
						//writeln(fSize);
						//writeln(lGeom.DiskSize.QuadPart);

						fClusterSize = lGeom.Geometry.BytesPerSector;
						lIsCacheSet = (fClusterSize > 0);
					}
					if (lIsCacheSet)
					{
						fClusterCache = std.c.stdlib.malloc(fClusterSize);
						if (!fClusterCache)
						{
							throw new OutOfMemoryError("cVolumeStream error, impossible to allocate the cluster cache");
						}

						fReadOnly = readOnly;
						ReadCache;
					}
					else
					{
						CloseVolume;
						throw new Error("cVolumeStream error, impossible to determine the cache size.");
					}
				}
			}
			version(Posix)
			{
				statvfs_t lInfs;
				if (statvfs( toStringz(aVolume), &lInfs) > -1 )
				{
					fClusterSize = cast(uint)lInfs.f_frsize;
					fSize = lInfs.f_bsize;
					if (fSize == 0)
					{
						throw new Error("cVolumeStream error, invalid volume size.");
					}
					if (fClusterSize == 0)
					{
						throw new Error("cVolumeStream error, invalid physical sector size.");
					}
					fHandle = open( toStringz(aVolume), O_CREAT | O_RDWR, octal!666);
					if (fHandle <= -1)
					{
						throw new Error("cVolumeStream error, impossible to create a view on the volume.");
					}
					else
					{
						fClusterCache = std.c.stdlib.malloc(fClusterSize);
						if (!fClusterCache)
						{
							throw new OutOfMemoryError("cVolumeStream error, impossible to allocate the cluster cache");
						}
						fReadOnly = readOnly;
						ReadCache;
					}
				}
				else
				{
					throw new Error(format("cVolumeStream, impossible to retrieve '%s' informations", aVolume));
				}
			}
		}
		/**
		 * Closes the current volume and optionally writes remaining changes from the cache.
		 */
		void CloseVolume()
		{
			WriteBackCache;
			fSize = 0;
			fCachePosition = 0;
			fClusterIndex = 0;
			fSectPerCluster = 0;
			fBytesPerSector = 0;
			fClusterCount = 0;
			fClusterChanged = false;
			fReadOnly = false;
			version(Windows)
			{
				CloseHandle(fHandle);
				fHandle = INVALID_HANDLE_VALUE;
			}
			version(Posix)
			{
				core.sys.posix.unistd.close(fHandle);
				fHandle = -1;
			}
		}
		override size_t Read(void* aBuffer, size_t aCount)
		{
			if (Position + aCount > fSize)
			{
				aCount = cast(uint) (fSize - Position);
			}
			auto lRemaining = aCount;
			uint lProcessed;
			uint lAvailable;
			while(lRemaining != 0)
			{
				lAvailable = fClusterSize - fCachePosition;
				if (lAvailable >= lRemaining)
				{
					memmove(aBuffer + lProcessed, fClusterCache + fCachePosition, lRemaining);
					fCachePosition += lRemaining;
					lProcessed += lRemaining;
					lRemaining = 0;
				}
				else
				{
					memmove(aBuffer + lProcessed, fClusterCache + fCachePosition, lAvailable);
					ClusterIndex = ClusterIndex + 1;
					lProcessed += lAvailable;
					lRemaining -= lAvailable;
				}
			}
			if (fCachePosition == fClusterSize) ClusterIndex = ClusterIndex + 1;
			return lProcessed;
		}
		override size_t Write(void* aBuffer, size_t aCount)
		{
			if (Position + aCount > fSize)
			{
				aCount = cast(uint) (fSize - Position);
			}
			auto lRemaining = aCount;
			uint lProcessed;
			uint lAvailable;
			while(lRemaining != 0)
			{
				lAvailable = fClusterSize - fCachePosition;
				if (lAvailable >= lRemaining)
				{
					memmove(fClusterCache + fCachePosition, aBuffer + lProcessed, lRemaining);
					fClusterChanged = true;
					fCachePosition += lRemaining;
					lProcessed += lRemaining;
					lRemaining = 0;
				}
				else
				{
					memmove(fClusterCache + fCachePosition, aBuffer + lProcessed, lAvailable);
					fClusterChanged = true;
					ClusterIndex = ClusterIndex + 1;
					lProcessed += lAvailable;
					lRemaining -= lAvailable;
				}
			}
			if (fCachePosition == fClusterSize)
			{
				ClusterIndex = ClusterIndex + 1;
			}
			return lProcessed;
		}
		override ulong Seek(ulong aOffset, int aOrigin)
		{
			version(Windows)
			{
				if (fHandle == INVALID_HANDLE_VALUE) return 0;
			}
			switch(aOrigin)
			{
				// TODO: clipping
				case(0):
					ClusterIndex = aOffset / fClusterSize;
					fCachePosition = cast(uint) (aOffset - ClusterIndex * fClusterSize);
					break;
				case(1):
					ClusterIndex = (Position + aOffset) / fClusterSize;
					fCachePosition = cast(uint) ((Position + aOffset) - ClusterIndex * fClusterSize);
					break;
				default:
					ClusterIndex = fSize / fClusterSize;
					fCachePosition = fClusterSize;
			}
			return Position;
		}
		override ulong Size()
		{
			version(Windows) if (fHandle == INVALID_HANDLE_VALUE) return 0;
			version(Posix) if (fHandle <= -1) return 0;
			return fSize;
		}
		override ulong Position()
		{
			return (ClusterIndex * fClusterSize) + fCachePosition;
		}
		override void Position(ulong aValue)
		{
			if (aValue > fSize) aValue = fSize;
			Seek(aValue,0);
		}
		/**
		 * Forces the cluster cache to be physically written.
		 * This method is rarely usefull since the changes are most
		 * of the time automatically written by the internal caching process.
		 */
		void Flush()
		{
			WriteBackCache;
			// Restore FilePointer
			version(Windows)
			{
				LARGE_INTEGER Li;
				Li.QuadPart = fClusterIndex * fClusterSize;
				SetFilePointer(fHandle, Li.LowPart, &Li.HighPart, FILE_BEGIN);
			}
			version(Posix)
			{
				core.sys.posix.unistd.lseek64(fHandle, fClusterIndex * fClusterSize, 0);
			}
		}
		/**
		 * Overwrites the cluster aClusterIndex with the chunk
		 * starting at aBuffer.
		 * aBuffer is expected to have at least a size of ClusterSize bytes.
		 */
		void SetCluster(ulong aClusterIndex, in void* aBuffer)
		{
			ClusterIndex = aClusterIndex;
			memmove(fClusterCache, aBuffer, fClusterSize);
		}
		/**
		 * Fills the chunk aBuffer with the cluster aClusterIndex.
		 * If aBuffer is not allocated then the method allocates ClusterSize bytes.
		 */
		void GetCluster(ulong aClusterIndex, out void* aBuffer, out uint* aSize)
		{
			ClusterIndex = aClusterIndex;
			*aSize = fClusterSize;
			if (aBuffer == null) aBuffer = std.c.stdlib.malloc(fClusterSize);
			memmove(aBuffer, fClusterCache, fClusterSize);
		}
		/**
		 * Fills the stream aStream with the cluster aClusterIndex.
		 */
		void SaveClusterToStream(ulong aClusterIndex, iStream aStream)
		{
			ClusterIndex = aClusterIndex;
			aStream.Size = fClusterSize;
			aStream.Position = 0;
			aStream.Write(fClusterCache,fClusterSize);
		}
		/**
		 * Replaces the cluster aClusterIndex with the content of the stream aStream.
		 */
		void LoadClusterFromStream(ulong aClusterIndex, iStream aStream)
		{
			if (aStream.Size + aStream.Position < fClusterSize)
			{
				throw new Error("cVolumeStream error, Stream size is too small to overwrite a cluster");
			}
			aStream.Read( fClusterCache, fClusterSize);
		}
		/**
		 * Returns current cluster index.
		 */
		ulong ClusterIndex()
		{
			return fClusterIndex;
		}
		/**
		 * Returns the volume cluster count.
		 */
		ulong ClusterCount()
		{
			return fClusterCount;
		}
		/**
		 * Returns the size of a cluster.
		 * (! this is not necessarly the cluster size but the physical sector size)
		 */
		uint ClusterSize()
		{
			return fClusterSize;
		}
		/**
		 * These methods have no effect in this iStream implementation
		 */
		override void Clear(){/*N/A*/}
		override void Size(uint aValue){/*N/A*/}
		override void Size(ulong aValue){/*N/A*/}
	}
}

/**
 * Flag used to denote the basic type of a property.
 */
enum ePropKind {
	pknone,     // denotes an error
	pkobject,   // sub-object; optionnaly as reference.
	pkmethod, pkenum, // unsupported in the prop. format version 0
	pkbyte, pkubyte, pkshort, pkushort, pkint, pkuint, pklong, pkulong,
	pkfloat, pkdouble,
	pkchar, pkwchar, pkdchar,
	pkstring, pkwstring, pkdstring,
	pkunsafe    // other types will share this value
};

/**
 * Flag used to describe the accessors combination.
 */
enum ePropAccess {
	paNone, // denotes an error, no accessors.
	paRO,   // read-only, has only a getter.
	paWO,   // write-only, has only a dSetter.
	paRW    // read & write, has both accessors.
};

/**
 * Describes a property.
 *
 * PropDescriptors are made of accessors, a setter method and a getter method.
 * Optionally a sPropDescriptor can define the setter or the getter directly
 * on a data, which is not possible from the strict "D" point of view (because
 * you cannot have a data and a method with the same name).
 *
 * a PropDescriptors could need another identifier: a Name (string)
 * according to the context.
 */
struct sPropDescriptor(T)
{
	alias void delegate (T value) dSetter;
	alias T delegate() dGetter;

	private
	{
		dSetter fSetter;
		dGetter fGetter;

		T* fSetPtr;
		T* fGetPtr;

		ePropAccess fAccess;

		static ePropKind fKind;
		char[] fName;

		void UpdateAccess()
		{
			if ((fSetter is null) && (fGetter is null))
			{
				fAccess = ePropAccess.paNone; return;
			}
			else if ((fSetter is null) && (fGetter !is null))
			{
				fAccess = ePropAccess.paRO; return;
			}
			else if ((fSetter !is null) && (fGetter is null))
			{
				fAccess = ePropAccess.paWO; return;
			}
			else if ((fSetter !is null)  && (fGetter !is null))
			{
				fAccess = ePropAccess.paRW; return;
			}
			// else
			fAccess = ePropAccess.paNone;
		}
		// pseudo setter internally used when the prop is directly accessed
		void DirectSetter(T value)
		{
			T LValue = Getter()();
			if (value != LValue)
			{
				*fSetPtr = value;
			}
		}
		// pseudo getter internally used when the prop is directly accessed
		T DirectGetter()
		{
			return *fGetPtr;
		}
	}
	public
	{
		static immutable ubyte DescriptorFormat = 0;
		static this()
		{
			// fKind is pointless since everything is parametrized.
			// (only used by cBinarySerializer.)
			if (is(T == Object))   	fKind = ePropKind.pkobject;
			if (is(T == byte))     	fKind = ePropKind.pkbyte; else
			if (is(T == ubyte))    	fKind = ePropKind.pkubyte; else
			if (is(T == short))    	fKind = ePropKind.pkshort; else
			if (is(T == ushort))   	fKind = ePropKind.pkushort; else
			if (is(T == int))      	fKind = ePropKind.pkint; else
			if (is(T == uint))     	fKind = ePropKind.pkuint; else
			if (is(T == long))     	fKind = ePropKind.pklong; else
			if (is(T == ulong))    	fKind = ePropKind.pkulong; else
			if (is(T == float))    	fKind = ePropKind.pkfloat; else
			if (is(T == double))   	fKind = ePropKind.pkdouble; else
			if (is(T == char))     	fKind = ePropKind.pkchar; else
			if (is(T == wchar))    	fKind = ePropKind.pkwchar; else
			if (is(T == dchar))    	fKind = ePropKind.pkdchar; else
			if (is(T == string))   	fKind = ePropKind.pkstring; else
			if (is(T == wstring))  	fKind = ePropKind.pkwstring; else
			if (is(T == dstring))  	fKind = ePropKind.pkdstring; else
									fKind = ePropKind.pkunsafe; 
		}
		/**
		 * Constructs a sPropDescriptor with a dSetter and a getter method.
		 */
		this(dSetter aSetter, dGetter aGetter, in char[] aName = "")
		{
			Define(aSetter,aGetter,aName);
		}
		/**
		 * Constructs a sPropDescriptor with a dSetter method and a direct source data.
		 */
		this(dSetter aSetter, T* aSourceData, in char[] aName = "")
		{
			Define(aSetter,aSourceData,aName);
		}
		/**
		 * Constructs a sPropDescriptor with a single data used as source/target
		 */
		this(T* aData, in char[] aName = "")
		{
			Define(aData,aName);
		}
		/**
		 * Defines a sPropDescriptor with a setter and a getter method.
		 */
		void Define(dSetter aSetter, dGetter aGetter, in char[] aName = "")
		{
			Setter(aSetter);
			Getter(aGetter);
			if (aName != "") {Name(aName);}
		}
		/**
		 * Defines a sPropDescriptor with a dSetter method and a direct source data.
		 */
		void Define(dSetter aSetter, T* aSourceData, in char[] aName = "")
		{
			Setter(aSetter);
			SetPropSource(aSourceData);
			if (aName != "") {Name(aName);}
		}
		/**
		 * Defines a sPropDescriptor with a single data used as source/target
		 */
		void Define(T* aData, in char[] aName = "")
		{
			SetPropSource(aData);
			SetPropTarget(aData);
			if (aName != "") {Name(aName);}
			/*fReference = aRef;*/
		}
		/**
		 * Sets the property setter using a standard method.
		 */
		void Setter(dSetter aSetter)
		{
			fSetter = aSetter;
			UpdateAccess;
		}
		/**
		 * Sets the property setter using a pointer to a direct data
		 */
		void SetPropTarget(T* aLoc)
		{
			fSetPtr = aLoc;
			fSetter = &DirectSetter;
			UpdateAccess;
		}
		dSetter Setter(){return fSetter;}
		/** 
		 * Sets the property getter using a standard method.
		 */
		void Getter(dGetter aGetter)
		{
			fGetter = aGetter;
			UpdateAccess;
		}
		/** 
		 * Sets the property getter using a pointer to a direct data
		 */
		void SetPropSource(T* aLoc)
		{
			fGetPtr = aLoc;
			fGetter = &DirectGetter;
			UpdateAccess;
		}
		dGetter Getter(){return fGetter;}
		/** 
		 * Informs about the prop accessibility
		 */
		ePropAccess Access()
		{
			return fAccess;
		}
		/** 
		 * Defines a string used to identify the prop
		 */
		void Name(in char[] aName)
		{
			fName = aName.dup;
		}
		string Name()
		{
			return fName.idup;
		}
		/** 
		 * Informs about the type
		 */
		ePropKind Kind()
		{
			return fKind;
		}
	}
}

alias sPropDescriptor!Object objprop;
alias sPropDescriptor!byte byteprop;
alias sPropDescriptor!ubyte ubyteprop;
alias sPropDescriptor!short shortprop;
alias sPropDescriptor!ushort ushortprop;
alias sPropDescriptor!int intprop;
alias sPropDescriptor!uint uintprop;
alias sPropDescriptor!long longprop;
alias sPropDescriptor!ulong ulongprop;
alias sPropDescriptor!float floatprop;
alias sPropDescriptor!double doubleprop;
alias sPropDescriptor!char charprop;
alias sPropDescriptor!wchar wcharprop;
alias sPropDescriptor!dchar dcharprop;
alias sPropDescriptor!string stringprop;
alias sPropDescriptor!wstring wstringprop;
alias sPropDescriptor!dstring dstringprop;

/**
 * Property synchronizer.
 *
 * This binder can be used to implement
 * some Master/Slave links but also some
 * interdependent links. In the last case
 * it's mandatory for a setter to filter any duplicated value.
 *
 * Properties to add must be described according to the the sPropDescriptor format.
 * The sPropDescriptor Name can be omitted.
 */
class cPropBinder(T)
{
	private
	{
		cDynamicList!(sPropDescriptor!T) fItems;
		sPropDescriptor!T* fSource;
		sPropDescriptor!T fBackItems[];
	}
	public
	{
		mixin mConditionallyUncollected;
		this()
		{
			fItems = new cDynamicList!(sPropDescriptor!T);
			fItems.AllowDup = false;
		}
		~this()
		{
			delete fItems;
		}
		/**
		 * Add a property to the list.
		 * Note that this method is very slow on large lists
		 * because the container used internally doesn't allow duplicated bindings.
		 * The first version is designed to be called using a local descriptor as argument.
		 */
		ptrdiff_t AddBinding(sPropDescriptor!T aProp, bool isSource = false)
		{
			fBackItems.length = fBackItems.length + 1;
			fBackItems[$-1] = aProp;
			return AddBinding(&fBackItems[$-1], isSource);
		}
		/// ditto
		ptrdiff_t AddBinding(sPropDescriptor!T* aProp, bool isSource = false)
		{
			if (isSource) Source = aProp;
			return fItems.Add(aProp);
		}
		/**
		 * Remove the aIndex-nth property from the list.
		 */
		void RemoveBinding(const ptrdiff_t aIndex)
		{
			fItems.Remove(aIndex);
			// + clean back items
		}
		/**
		 * Removes aProp from the list.
		 */
		void RemoveBinding(sPropDescriptor!T* aProp)
		{
			fItems.Remove(aProp);
		}
		/**
		 * Triggers the setter of each property.
		 * This method is usually called at the end of
		 * a setter method (the "master/source" prop).
		 * When some interdependent bindings are used
		 * Change() must be called for each property
		 * setter of the list.
		 */
		void Change(T value)
		{
			foreach(sPropDescriptor!T* lItem; fItems)
			{
				if (lItem.Access == ePropAccess.paNone) continue;
				if (lItem.Access == ePropAccess.paRO) continue;
				lItem.Setter()(value);
			}
		}
		/**
		 * Call Change() using the value of Source.
		 */
		void UpdateFromSource()
		{
			if (!fSource) return;
			Change(fSource.Getter()());
		}
		@property
		{
			/**
			 * Sets the property used as source in UpdateFromSource().
			 */
			void Source(sPropDescriptor!T* aSource){fSource = aSource;}
			/**
			 * cList access for additional operations.
			 */
			cList!(sPropDescriptor!T) Items()
			{
				return fItems;
			}
		}
	}
}
private final class cPropBinderTester
{
	unittest
	{
		alias cPropBinder!int intprops;
		alias cPropBinder!float floatprops;

		class foo
		{
			private
			{
				int fA;
				float fB;
				intprops fASlaves;
				floatprops fBSlaves;
			}
			public
			{
				this()
				{
					fASlaves = new intprops;
					fBSlaves = new floatprops;
				}
				~this()
				{
					delete fASlaves;
					delete fBSlaves;
				}
				void A(int value)
				{
					if (fA == value) return;
					fA = value;
					fASlaves.Change(fA);
				}
				int A(){return fA;}

				void B(float value)
				{
					if (fB == value) return;
					fB = value;
					fBSlaves.Change(fB);
				}
				float B(){return fB;}

				void AddABinding(intprop* aProp)
				{
					fASlaves.AddBinding(aProp);
				}

				void AddBBinding(floatprop* aProp)
				{
					fBSlaves.AddBinding(aProp);
				}
			}
		}

		class foosync
		{
			private
			{
				int fA;
				float fB;
			}
			public
			{
				void A(int value){fA = value;}
				int A(){return fA;}
				void B(float value){fB = value;}
				float B(){return fB;}
			}
		}

		class bar: Object
		{
			public int A;
			public float B;
		}

		// 1 master, 2 slaves
		auto a0 = new foo;
		auto a1 = new foosync;
		auto a2 = new foosync;
		auto a3 = new bar;

		auto prp1 = intprop(&a1.A,&a1.A);
		a0.AddABinding(&prp1);

		auto prp2 = intprop(&a2.A,&a2.A);
		a0.AddABinding(&prp2);

		intprop prp3;
		prp3.SetPropTarget(&a3.A);
		prp3.SetPropSource(&a3.A);
		a0.AddABinding(&prp3);

		auto prpf1 = floatprop(&a1.B,&a1.B);
		auto prpf2 = floatprop(&a2.B,&a2.B);
		auto prpf3 = floatprop(&a3.B);
		a0.AddBBinding(&prpf1);
		a0.AddBBinding(&prpf2);
		a0.AddBBinding(&prpf3);

		a0.A = 2;
		assert( a1.A == a0.A);
		a1.A = 3;
		assert( a1.A != a0.A);
		a0.A = 4;
		assert( a2.A == a0.A);
		a0.A = 5;
		assert( a3.A == a0.A);

		a0.B = 2.5;
		assert( a1.B == a0.B);
		a1.B = 3.5;
		assert( a1.B != a0.B);
		a0.B = 4.5;
		assert( a2.B == a0.B);
		a0.B = 5.5;
		assert( a3.B == a0.B);

		// interdependent bindings
		auto m0 = new foo;
		auto m1 = new foo;
		auto m2 = new foo;

		intprop mprp0;
		mprp0.Setter = &m0.A;
		mprp0.Getter = &m0.A;

		intprop mprp1;
		mprp1.Setter = &m1.A;
		mprp1.Getter = &m1.A;

		intprop mprp2;
		mprp2.Setter = &m2.A;
		mprp2.Getter = &m2.A;

		m0.AddABinding(&mprp1);
		m0.AddABinding(&mprp2);

		m1.AddABinding(&mprp0);
		m1.AddABinding(&mprp2);

		m2.AddABinding(&mprp0);
		m2.AddABinding(&mprp1);

		m0.A = 2;
		assert( m1.A == m0.A);
		assert( m2.A == m0.A);
		m1.A = 3;
		assert( m0.A == m1.A);
		assert( m2.A == m1.A);
		m2.A = 4;
		assert( m1.A == m2.A);
		assert( m0.A == m2.A);

		delete a0;
		delete a1;
		delete a2;
		delete a3;
		delete m0;
		delete m1;
		delete m2;

		writeln("cPropBinder(T) passed the tests");
	}
}

/**
 * iSerializable is implemented to
 * allow the serialization by a cMasterSerializer.
 * An implementer is designed to call cMasterSerializer.AddProperty() in DeclareProperties().
 *
 * (IsSerializationRecursive() is called by a cMasterSerializer to know
 * if it must serialize the sub Objects.
 *
 * IsReference(iSerializable aSerializable) is called by a cMasterSerializer when
 * it needs to know if a sub-object must be stored as a reference (external sub object)
 * or as an internal sub object.
 * In the first case, the object properties are not stored as it mights be serialized elsewhere. 
 * In the second case all the object properties are stored.
 *
 * The declarations rules are:
 * - The PropDescriptors must includes a Name.
 * - The declarations order should not change.
 * - The sPropDescriptor access must be paRW.
 * - The sPropDescriptor must not describe a property whose type is aliased.
 */
interface iSerializable
{
	void DeclareProperties(cMasterSerializer aSerializer);
	bool IsSerializationRecursive();
	bool IsReference(iSerializable aSerializable);
}

/**
 * iReferenceable is implemented to link a class to an unique identifier.
 * It's used in conjunction with the static cReferentialMan class.
 * Any implementer must call cReferentialMan.Remove(ReferentialID) in its destructor.
 */
interface iReferenceable
{
	/**
	 * Sets the ID. 
	 */
	void ReferentialID(uint aValue); 
	/**
	 * Gets the ID. 
	 */
	uint ReferentialID();
	/**
	 * This method is called by the cReferentialMan each time an ID is removed.
	 * It's designed to let a class removing any reference to the invalid Object. 
	 * anObj is granted to be an iReferenceable implementer.
	 */
	void RemoveNotify(Object* anObj);
}

/**
 * The default iReferenceable implementation. It grants an unique identifier.
 * This mixin breaks the visibility attribute.
 */
mixin template mReferencableDefaultImpl()
{
	private uint fReferentialID;
	void RemoveNotify(Object* anObj){}
	public @property
	{
		void ReferentialID(uint aValue)
		{
			fReferentialID = aValue;
			if (fReferentialID != 0)
			{
				if (!(cReferentialMan.Add(&fReferentialID, cast(Object*)this))) 
				{
					fReferentialID = cReferentialMan.GetUnique;
					cReferentialMan.Add(&fReferentialID, cast(Object*)this);
				}
			}
		}
		uint ReferentialID(){return fReferentialID;}
	}
}

/**
 * This class is used by a cMasterSerializer when
 * it stores/restores an Object reference.
 * It provides the informations needed to retrieve, at the run-time, a referenced Object.
 */
private final class cStorableReference: iSerializable
{
	private
	{
		char[] fType;
		uint fRef;
	}
	public
	{
		mixin mUncollectedClass;
		this(){};
		this(uint aRef, in char[] aType)
		{
			fType = aType.dup;
			fRef = aRef;
		}
		final void DeclareProperties(cMasterSerializer aSerializer)
		{
			auto lTypeDescr = sPropDescriptor!(char[])(&fType,"Type");
			auto lRefDescr = sPropDescriptor!(uint)(&fRef,"ReferentialID");
			aSerializer.AddProperty!(char[])(lTypeDescr);
			aSerializer.AddProperty!uint(lRefDescr);
		}
		final bool IsSerializationRecursive(){return false;}
		final bool IsReference(iSerializable aSerializable){return false;}
	}
}

version(unittest)
{
	enum eOneTwo{otOne,otTwo}
	private final class Foo3: iSerializable, iReferenceable
	{
		~this()
		{
			cReferentialMan.Remove(&fReferentialID);
		}
		void DeclareProperties(cMasterSerializer aSerializer){}
		bool IsSerializationRecursive()
		{
			return true;
		}
		bool IsReference(iSerializable aSerializable)
		{
			return false;
		}
		mixin mReferencableDefaultImpl;
	}
	private final class Foo2: iSerializable
	{
		private
		{
			struct Strc{}
			int fA;
			float fB;
			char[] fC;
			size_t fError1;
			Strc fError2;
			eOneTwo fOt;
			cMemoryStream fS;
			void SetStream(iStream aStream)
			{
				fS.Clear;
				fS.LoadFromStream(aStream);
				fS.Position = 0;
			}
			void GetStream(iStream aStream)
			{
				aStream.Clear;
				fS.SaveToStream(aStream);
				aStream.Position = 0;
			}
		}
		public
		{
			this()
			{
				fS = new cMemoryStream;
			}
			~this()
			{
				delete fS;
			}
			void A(int aValue){ if(fA != aValue)fA = aValue; }
			int A(){return fA;}
			void B(float aValue){ if(fB != aValue)fB = aValue; }
			float B(){return fB;}
			void C(char[] aValue){ fC = aValue; }
			char[] C(){return fC;}
			bool IsSerializationRecursive()
			{
				return true;
			}
			bool IsReference(iSerializable aSerializable)
			{
				return false;
			}
			void DeclareProperties(cMasterSerializer aSerializer)
			{
				//auto ADescr = intprop(&A,&A,"Foo2PropA");
				auto BDescr = floatprop(&B,&B,"Foo2PropB");
				auto CDescr = sPropDescriptor!(char[])(&C,&C,"Foo2PropC");

				aSerializer.AddProperty!int(/*ADescr*/ intprop(&A,&A,"Foo2PropA"));
				aSerializer.AddProperty!float(BDescr);
				aSerializer.AddProperty!(char[])(CDescr);
				aSerializer.AddBinaryProperty("Foo2PropS",&GetStream,&SetStream);

				aSerializer.AddProperty!eOneTwo( sPropDescriptor!eOneTwo(&fOt,"OneTwo") );

				//aSerializer.AddProperty!size_t( sPropDescriptor!size_t(&fError1,"Foo2Error1") );
				//aSerializer.AddProperty!Strc( sPropDescriptor!Strc(&fError2,"Foo2Error2") );
			}
		}
	}
	private final class Foo1: iSerializable
	{
		private
		{
			int fA;
			float fB;
			char[] fC;
			int[] fD;
			Foo2 fO1;
			Foo2 fO2;
			Foo3 fO3;
		}
		public
		{
			this()
			{
				fO1 = new Foo2;
				fO2 = new Foo2;
			}
			~this()
			{
				delete fO1;
				delete fO2;
			}
			void A(int aValue){ if(fA != aValue)fA = aValue; }
			int A(){return fA;}
			void B(float aValue){ if(fB != aValue)fB = aValue; }
			float B(){return fB;}
			void C(char[] aValue){ fC = aValue; }
			char[] C(){return fC;}
			bool IsSerializationRecursive()
			{
				return true;
			}
			bool IsReference(iSerializable aSerializable)
			{
				return ( aSerializable is fO3 );
			}
			void DeclareProperties(cMasterSerializer aSerializer)
			{
				auto ADescr  = intprop(&A,&A,"Foo1PropA");
				auto BDescr  = floatprop(&B,&B,"Foo1PropB");
				auto CDescr  = sPropDescriptor!(char[])(&C,&C,"Foo1PropC");
				auto DDescr  = sPropDescriptor!(int[])(&fD,"Foo1PropD");
				auto O1Descr = objprop(cast(Object*)&fO1,"Foo1PropO1");
				auto O2Descr = objprop(cast(Object*)&fO2,"Foo1PropO2");
				auto O3Descr = objprop(cast(Object*)&fO3,"Foo1PropO3");

				aSerializer.AddProperty!int(ADescr);
				aSerializer.AddProperty!float(BDescr);
				aSerializer.AddProperty!(char[])(CDescr);
				aSerializer.AddProperty!(int[])(DDescr);
				aSerializer.AddProperty!Object(O1Descr);
				aSerializer.AddProperty!Object(O2Descr);
				aSerializer.AddProperty!Object(O3Descr);
			}
		}
	}
}

alias void delegate (iStream aStream) dBinPropAccess;

/**
 * Flag used to denote the serialization format.
 */
enum eSerializationKind {skbin,sktext};

static bool IsSerializableType(T)()
{
	// a config. file saved from a 64 bit pc and used on a 32 bit one.
	// may not be reloadable if it contains architecture-specific types such as size_t, ptrdiff_t.
	//static if (!is (OriginalType!T == T)) return false;
	
	// a struct cannot implements iSerializable. AddBinaryProp() is made for such special cases.
	static if (is (T == struct)) 
		return false;
	// ok, special case
	else if (is (T == class)) 
		return true;
	// single dimm array ok, special case
	else  if (isArray!T)
	{
		// + test if array has a single dim
		// + test if element type isBasic
		return true;
	}
	// otherwise all basic types
	else  if (isBasicType!T) 
		return true;
	else 
		return false;
}

/**
 * Serializes or deserializes an iSerializable implementer,
 * recursively and in a selectable format.
 */
final class cMasterSerializer
{
	alias void delegate (in cMasterSerializer aSerializer, out iSerializable) dSerWantObject;
	private
	{
		enum eSerializationDirection {sdRead,sdWrite};

		uint fLevel;
		dSerWantObject fOnWantObject;
		iStream fStream;
		iSerializable fSerializable;
		eSerializationKind fSerializationKind;
		eSerializationDirection fSerDir;
		void InternalSerialize(ref iSerializable aSerializable)
		{
			fSerDir = eSerializationDirection.sdWrite;
			aSerializable.DeclareProperties(this);
		}
		void InternalDeserialize(ref iSerializable aSerializable)
		{
			fSerDir = eSerializationDirection.sdRead;
			aSerializable.DeclareProperties(this);
		}
		iPropSerializer!T NewPropSerializer(T)()
		{
			if (fSerializationKind == eSerializationKind.skbin) return new cBinarySerializer!T;
			if (fSerializationKind == eSerializationKind.sktext) return new cTEXTSerializer!T;
			assert(0);
		}
	}
	public
	{
		mixin mConditionallyUncollected;
		/**
		 * Creates an instance with an optional Serialization kind specifier.
		 */
		this(eSerializationKind aSerializationKind = eSerializationKind.skbin)
		{
			fSerializationKind = aSerializationKind;
		}
		/**
		 * Serializes anObject in aStream if it's an iSerializable.
		 */
		final void Serialize(Object anObject, iStream aStream)
		{
			iSerializable lSer;
			lSer = cast(iSerializable) anObject;
			if (lSer !is null) Serialize(lSer,aStream);
			else throw new Exception("cMasterSerializer Exception, the object to serialize is not
									  an iSerializable implementer");
		}
		/**
		 * Serializes aSerializable in aStream.
		 */
		final void Serialize(iSerializable aSerializable, iStream aStream)
		{
			fStream = aStream;
			fSerializable = aSerializable;
			auto lSer = NewPropSerializer!int;
			scope(exit) delete lSer;
			lSer.WriteMasterHeader(aStream);
			InternalSerialize(aSerializable);
		}
		/**
		 * Deserializes anObject from aStream if it's an iSerializable.
		 */
		final void Deserialize(Object anObject, iStream aStream)
		{
			Deserialize(cast(iSerializable) anObject, aStream);
		}
		/**
		 * Deserializes aSerializable in aStream.
		 */
		final void Deserialize(iSerializable aSerializable, iStream aStream)
		{
			fStream = aStream;
			if (aSerializable is null)
			{
				if (fOnWantObject) fOnWantObject(this,aSerializable);
				if (aSerializable is null)
				{
					throw new Exception("cMasterSerializer Exception, serialization target is null");
				}
			}
			fSerializable = aSerializable;
			auto lSer = NewPropSerializer!int;
			scope(exit) delete lSer;
			lSer.ReadMasterHeader(aStream);
			InternalDeserialize(fSerializable);
		}
		/**
		 * AddProperty() is called by an iSerializable in its DeclareProperties() implementation
		 * when it needs to declare a persistent property.
		 * The first version is designed to be called using a local descriptor as argument.
		 */
		final void AddProperty(T)(sPropDescriptor!T aDescriptor)
		if (IsSerializableType!T)
		{
			AddProperty!T(aDescriptor);
		}
		/// ditto
		final void AddProperty(T)(ref sPropDescriptor!T aDescriptor)
		if (IsSerializableType!T)
		{
			if (aDescriptor.Name == "")
			{
				throw new Exception("cMasterSerializer error, unnamed property descriptor");
			}
			if (aDescriptor.Access != ePropAccess.paRW)
			{
				throw new Exception("cMasterSerializer error, property must be R/W");
			}
			// delegates relative to the serializer direction
			void delegate(sPropDescriptor!T aProp, uint aLevel, iStream aStream) dPropProc;
			void delegate(uint aLevel, iStream aStream) dObjStartProc;
			void delegate(uint aLevel, iStream aStream) dObjStopProc;
			void delegate(ref iSerializable aSerializable) dSerProc;
			// creates the right serializer
			auto lSer = NewPropSerializer!T;
			scope(exit) delete lSer;
			// setup the delegates
			if (IsReading)
			{
				dPropProc = &lSer.ReadProperty;
				dObjStartProc = &lSer.ReadObjectStart;
				dObjStopProc = &lSer.ReadObjectStop;
				dSerProc = &InternalDeserialize;
				if (fStream.Position == fStream.Size)
				{
					throw new Exception("cMasterSerializer exception, nothing else to read");
				}
			}
			else
			{
				dPropProc = &lSer.WriteProperty;
				dObjStartProc = &lSer.WriteObjectStart;
				dObjStopProc = &lSer.WriteObjectStop;
				dSerProc = &InternalSerialize;
			}
			// let the serializer do its job		
			static if (!is(T == Object)) dPropProc(aDescriptor,fLevel,fStream);
			else
			{
				if (fSerializable.IsSerializationRecursive)
				{
					auto lSubObj = cast(iSerializable) (cast(objprop) aDescriptor).Getter()();
					if (fSerializable.IsReference(lSubObj))
					{
						// the sub object is not available while reading
						// a cStorableReferenceis used in place of the real subobj.
						cStorableReference lStorable;				
						auto lReferencable = cast(iReferenceable) lSubObj;
						if ((lReferencable !is null) & (IsWriting))
						{		
							auto lName = demangle((cast(objprop) aDescriptor).Getter()().classinfo.name).dup;
							auto i = lastIndexOf(lName, '.');
							i++;
							auto lShortName = lName[i..$];
							lStorable = new cStorableReference(lReferencable.ReferentialID,lShortName);					
						}
						// during deser, the lStorable doesn't have to be initialized
						else if (IsReading) lStorable = new cStorableReference;
						// declare lStorable
						auto lProp = objprop(cast(Object*)&lStorable,aDescriptor.Name.dup);
						AddProperty!Object(lProp);
						// lStorable is now filled with the infos we use to set the ref.
						if (IsReading)
						{
							Object* lTarget = cReferentialMan.FindReference(lStorable.fRef);
							(cast(objprop) aDescriptor).Setter()(cast(Object)lTarget);						
						}
						if(lStorable) delete lStorable;
					}
					else
					{
						dPropProc(aDescriptor,fLevel,fStream);
						dObjStartProc(fLevel,fStream);
						fLevel++;
						dSerProc(lSubObj);
						dObjStopProc(fLevel,fStream);
						fLevel--;
					}	
				}
			}
		}
		/**
		 * AddBinaryProp is used by an iSerializable in its DeclareProperties()
		 * when it has to declare a persistent property which cannot
		 * be described with a sPropDescriptor (such as multi-dimensional arrays, encrypted data, ...).
		 */
		final void AddBinaryProperty(string aPropertyName, dBinPropAccess aGetProc, dBinPropAccess aSetProc)
		{
			if (aPropertyName == "")
			{
				throw new Exception("cMasterSerializer error, unnamed property descriptor");
			}
			auto lSer = NewPropSerializer!int;
			scope(exit) delete lSer;
			if (fSerDir == eSerializationDirection.sdRead)
			{
				lSer.ReadBinaryProperty( fStream, aPropertyName, fLevel, aSetProc);
			}
			else
			{
				lSer.WriteBinaryProperty( aGetProc, aPropertyName, fLevel, fStream);
			}
		}
		@property
		{
			/**
			 * OnWantObject property can be assigned to handle the construction of 
			 * a sub-object, if not yet assigned during the deserialization.
			 */
			final void OnWantObject(dSerWantObject aValue){fOnWantObject = aValue;}
			/// ditto
			final dSerWantObject OnWantObject(){return fOnWantObject;}
			/**
			 * Indicates the serialization direction. It can be used in the iSerializable
			 * DeclareProperties() method to identify the serialization context.
			 */
			final bool IsReading (){return fSerDir == eSerializationDirection.sdRead;}
			/// ditto
			final bool IsWriting (){return fSerDir == eSerializationDirection.sdWrite;}	
		}
	}
	unittest
	{
		cMasterSerializer MSer;
		Foo1 Target;
		cMemoryStream Str;
		MSer = new cMasterSerializer;
		Target = new Foo1;
		Str = new cMemoryStream;

		auto Ref1 = new Foo3; Ref1.ReferentialID = 8;
		auto Ref2 = new Foo3; Ref2.ReferentialID = 456;

		Target.fO3 = Ref2;

		Target.A = 8;
		Target.B = 0.5f;
		Target.C = "kaboom".dup;
		Target.fD = [12,13];
		Target.fO1.A = 9;
		Target.fO1.B = 2.5f;
		Target.fO1.C = "youplaboom".dup;
		Target.fO2.A = 91;
		Target.fO2.B = 8.5f;
		Target.fO2.C = "badaboom".dup;
		Target.fO2.fOt = eOneTwo.otTwo;
		for (int i = 0; i < 8; i++)
		{
			Target.fO1.fS.Write(&i,4);
			Target.fO2.fS.Write(&i,4);
		}
		Target.fO1.fS.Position = 0;
		Target.fO2.fS.Position = 0;

		MSer.fSerializationKind = eSerializationKind.sktext;

		MSer.Serialize( cast(iSerializable) Target, Str );
		Str.SaveToFile("ser1.bin");
		Target.fO3 = null;

		Target.A = 0;
		Target.B = 0.0f;
		Target.C = "".dup;
		Target.fD = [0,0];
		Target.fO1.A = 0;
		Target.fO1.B = 0.0f;
		Target.fO1.C = "".dup;
		Target.fO1.fS.Clear;
		Target.fO2.A = 0;
		Target.fO2.B = 0.0f;
		Target.fO2.C = "".dup;
		Target.fO2.fOt = eOneTwo.otOne;
		Target.fO2.fS.Clear;

		void CreateTarget(in cMasterSerializer aSer, out iSerializable aTarget)
		{
			aTarget = new Foo1;
			Target = cast(Foo1) aTarget;
			Target.fO3 = null;
		}

		delete Target;
		Str.Position = 0;
		MSer.OnWantObject = &CreateTarget;
		MSer.Deserialize(cast(iSerializable) Target, Str );

		assert(Target.A == 8);
		assert(Target.B == 0.5f);
		assert(Target.C == "kaboom");
		assert(Target.fD == [12,13]);
		assert(Target.fO1.A == 9);
		assert(Target.fO1.B == 2.5f);
		assert(Target.fO1.C == "youplaboom");
		assert(Target.fO2.A == 91);
		assert(Target.fO2.B == 8.5f);
		assert(Target.fO2.C == "badaboom");
		assert(Target.fO2.fOt == eOneTwo.otTwo);
		assert(Target.fO3 is Ref2);

		Target.fO1.fS.Position = 0;
		Target.fO2.fS.Position = 0;
		for (int i = 0; i < 8; i++)
		{
			int lD;
			Target.fO1.fS.Read(&lD,4);
			assert(lD == i);
			Target.fO2.fS.Read(&lD,4);
			assert(lD == i);
		}

		delete MSer;
		delete Target;
		delete Ref1;
		delete Ref2;

		//version(Windows) DeleteFileA(toStringz("ser1.bin"));
		version(Posix) core.stdc.stdio.remove(toStringz("ser1.bin"));

		writeln("cMasterSerializer passed the tests");
	}
}

/**
 * iPropSerializer is a plug-in interface, automatically handled by a cMasterSerializer.
 * A descendant proposes a way to de/serialize a single property described in sPropDescriptor.
 */
interface iPropSerializer(T)
{
	/**
	 * Writes or Reads the "Master Header".
	 * These methods are called by a cMasterSerializer
	 * at the beginning of the de/serialization process.
	 * It can be used to perform an overall format checking.
	 */
	void WriteMasterHeader(iStream aStream);
	void ReadMasterHeader(iStream aStream);
	/**
	 * Writes or Reads the Object delimiters.
	 * These methods are called by a cMasterSerializer when
	 * an iSerializable declares an Object .
	 */
	void WriteObjectStart(uint aLevel, iStream aStream);
	void WriteObjectStop(uint aLevel, iStream aStream);
	void ReadObjectStart(uint aLevel, iStream aStream);
	void ReadObjectStop(uint aLevel, iStream aStream);
	/**
	 * Writes or Reads the Property described by aProp.
	 * This includes all the numeric types, optionnaly organized in array.
	 * These methods are directly called by a cMasterSerializer when an
	 * iSerializable declares a property.
	 */
	void WriteProperty(sPropDescriptor!T aProp, uint aLevel, iStream aStream);
	void ReadProperty(sPropDescriptor!T aProp, uint aLevel, iStream aStream);
	/**
	 * Writes or Reads an opaque property.
	 * These methods are directly called by a cMasterSerializer when an
	 * iSerializable declares a binary property.
	 */
	void WriteBinaryProperty(dBinPropAccess aGetProc, string aPropertyName, uint aLevel, iStream aOutStream);
	void ReadBinaryProperty(iStream aInStream, string aPropertyName, uint aLevel, dBinPropAccess aSetProc);
}

/**
 * iPropSerializer implementer specialized into
 * de/serializing the properties in a binary format.
 * Although it lacks of readability, it has the advantage
 * to handle all the property kinds, to include a lot of checking,
 * and to be hardly editable.
 */
private final class cBinarySerializer(T): iPropSerializer!T
{
	private ubyte fver = 0x00;
	private ubyte fmrk = 0x99;
	private ubyte fbin = 0xFF;
	mixin mUncollectedClass;
	final void WriteMasterHeader(iStream aStream){}
	final void ReadMasterHeader(iStream aStream){}
	final void WriteObjectStart(uint aLevel, iStream aStream)
	{
		ubyte lSym = 0xA9;
		aStream.Write(&lSym, 1);
	}
	final void WriteObjectStop(uint aLevel, iStream aStream)
	{
		ubyte lSym = 0xB9;
		aStream.Write(&lSym, 1);
	}
	final void ReadObjectStart(uint aLevel, iStream aStream)
	{
		ubyte lSym;
		aStream.Read(&lSym, 1);
		if (lSym != 0xA9)
		{
			throw new Error("cBinarySerializer error, invalid object start marker");
		}
	}
	final void ReadObjectStop(uint aLevel, iStream aStream)
	{
		ubyte lSym;
		aStream.Read(&lSym, 1);
		if (lSym != 0xB9)
		{
			throw new Error("cBinarySerializer error, invalid object end marker");
		}
	}
	final void WriteProperty(sPropDescriptor!T aProp, uint aLevel, iStream aStream)
	{
		uint lCount;
		// start mark
		aStream.Write(&fmrk,1);
		// serializer version
		aStream.Write(&fver,1);
		char[] lName = aProp.Name.dup;
		// name length
		lCount = cast(uint) lName.length;
		aStream.Write(&lCount,lCount.sizeof);
		// name data
		aStream.Write(lName.ptr,lCount);
		// type + data
		ubyte lType = cast(ubyte) aProp.Kind;
		aStream.Write(&lType,1);
		T lValue = aProp.Getter()();
		static if (isArray!T)
		{
			// data length
			lCount = cast(uint) (lValue.length * lValue[0].sizeof);
			aStream.Write(&lCount,lCount.sizeof);
			// data
			aStream.Write(lValue.ptr,lCount);
		}
		else static if (is(T == Object))
		{
			lName = demangle(lValue.classinfo.name).dup;
			auto i = lastIndexOf(lName, '.');
			i++;
			lCount = cast(uint) (lName.length - i);
			aStream.Write(&lCount,lCount.sizeof);
			aStream.Write(lName.ptr + i,lCount);
		}
		else
		{
			// data length
			lCount = cast(uint) T.sizeof;
			aStream.Write(&lCount,lCount.sizeof);
			// data
			lCount = cast(uint) T.sizeof;
			aStream.Write(&lValue,lCount);
		}
	}
	final void ReadProperty(sPropDescriptor!T aProp, uint aLevel, iStream aStream)
	{
		void GotoNext()
		{
			ubyte lReader;
			while(true)
			{
				aStream.Read(&lReader,1);
				if ((lReader == fmrk) | (aStream.Position == aStream.Size))
				{
					aStream.Position = aStream.Position -1;
					break;
				}
			}
		}
		ubyte lver, lsym;
		uint lCount;
		try
		{
			// start mark
			aStream.Read(&lsym,1);
			if (lsym == fmrk)
			{
				// serializer version
				aStream.Read(&lver,1);
				if (lver == 0)
				{
					// name length
					aStream.Read(&lCount,lCount.sizeof);
					// data name
					char[] lName;
					lName.length = lCount;
					aStream.Read(lName.ptr,lCount);
					if (lName != aProp.Name)
					{
						throw new Exception("cBinarySerializer error, property order/name mismatch");
					}
					// data type
					ubyte lType;
					aStream.Read(&lType,1);
					if (lType != cast(ubyte) aProp.Kind)
					{
						throw new Exception("cBinarySerializer error, property type mismatch");
					}
					static if (isArray!T)
					{
						T lValue;
						// data length
						aStream.Read(&lCount,lCount.sizeof);
						lValue.length = 1;
						lValue.length = lCount / lValue[0].sizeof;
						// data
						aStream.Read(lValue.ptr,lCount);
						aProp.Setter()(lValue);
					}
					else static if (is(T == Object))
					{
						T lValue = aProp.Getter()();
						aStream.Read(&lCount,lCount.sizeof);
						lName.length = lCount;
						aStream.Read(lName.ptr,lCount);
						auto lName2 = demangle(lValue.classinfo.name).dup;
						auto i = lastIndexOf(lName2, '.');
						i++;
						lName2 = lName2[i..$];
						if (lName != lName2)
						{
							throw new Exception("cBinarySerializer error, Object class mismatch");
						}
					}
					else
					{
						// data length
						aStream.Read(&lCount,lCount.sizeof);
						// data
						T lValue;
						aStream.Read(&lValue,lCount);
						aProp.Setter()(lValue);
					}
				}
				else
				{
					throw new Exception("cBinarySerializer error, unsupported format version");
				}
			}
			else
			{
				throw new Exception("cBinarySerializer error, invalid property start marker");
			}
		}
		catch
		{
			GotoNext;
		}
	}
	final void WriteBinaryProperty(dBinPropAccess aGetProc, string aPropertyName, uint aLevel, iStream aOutStream)
	{
		uint lCount;
		// start mark
		aOutStream.Write(&fmrk,1);
		// serializer version
		aOutStream.Write(&fver,1);
		char[] lName = aPropertyName.dup;
		// name length
		lCount = cast(uint) lName.length;
		aOutStream.Write(&lCount,lCount.sizeof);
		// data name 
		aOutStream.Write(lName.ptr,lCount);
		// data type
		aOutStream.Write(&fbin,1);
		//
		auto lInStream = new cMemoryStream;
		aGetProc(lInStream);
		lInStream.Position = 0;
		// data length
		lCount = cast(uint) lInStream.Size;
		aOutStream.Write(&lCount,lCount.sizeof);
		// data
		auto lPt = malloc(lCount);
		lInStream.Read(lPt,lCount);
		aOutStream.Write(lPt,lCount);
		delete lInStream;
		free(lPt);
	}
	final void ReadBinaryProperty(iStream aInStream, string aPropertyName, uint aLevel, dBinPropAccess aSetProc)
	{
		void GotoNext()
		{
			ubyte lReader;
			while(true)
			{
				aInStream.Read(&lReader,1);
				if ((lReader == fmrk) | (aInStream.Position == aInStream.Size))
				{
					aInStream.Position = aInStream.Position -1;
					break;
				}
			}
		}
		ubyte lver, lsym;
		uint lCount;
		try
		{
			// start mark
			aInStream.Read(&lsym,1);
			if (lsym == fmrk)
			{
				// serializer version
				aInStream.Read(&lver,1);
				if (lver == 0)
				{
					// name length
					aInStream.Read(&lCount,lCount.sizeof);
					// data name
					char[] lName;
					lName.length = lCount;
					aInStream.Read(lName.ptr,lCount);
					if (lName != aPropertyName)
					{
						throw new Exception("cBinarySerializer error, property order/name mismatch");
					}
					// data type
					ubyte lType;
					aInStream.Read(&lType,1);
					if (lType != fbin)
					{
						throw new Exception("cBinarySerializer error, binary property type mismatch");
					}
					// data length
					aInStream.Read(&lCount,lCount.sizeof);
					// data
					auto lOutStream = new cMemoryStream;
					auto lPt = malloc(lCount);
					aInStream.Read(lPt,lCount);
					lOutStream.Write(lPt,lCount);
					lOutStream.Position = 0;
					aSetProc(lOutStream);
					free(lPt);
					delete lOutStream;
				}
				else
				{
					throw new Exception("cBinarySerializer error, unsupported format version");
				}
			}
			else
			{
				throw new Exception("cBinarySerializer error, invalid property start marker");
			}
		}
		catch(Throwable e)
		{
			version(Release)
			{
				GotoNext;
			}
			else
			{
				writeln(e.toString);
				GotoNext;
			}
		}
	}
}

/**
 * iPropSerializer implementer specialized into
 * de/serializing a property in a simple text format.
 * the format is characterized by:
 * - ANSI.
 * - 1 property per line.
 * - UNIX line ending.
 * - PropertyName=PropertyValue.
 * - PropertyValue is encoded/decoded using the phobos formatting/conversion routines format(%s),to()().
 * - Sub objects are visually denoted by a variable amount of TAB.
 * Its advantages are to be easily editable and to generate smaller streams than
 * the other formats.
 */
private final class cTEXTSerializer(T): iPropSerializer!T
{
	mixin mUncollectedClass;
	final void WriteMasterHeader(iStream aStream){}
	final void ReadMasterHeader(iStream aStream){}
	final void WriteObjectStart(uint aLevel, iStream aStream){}
	final void WriteObjectStop(uint aLevel, iStream aStream){}
	final void ReadObjectStart(uint aLevel, iStream aStream){}
	final void ReadObjectStop(uint aLevel, iStream aStream){}
	final void WriteProperty(sPropDescriptor!T aProp, uint aLevel, iStream aStream)
	{
		uint lCount;
		char[] lData;
		char lSym;
		// Level
		ubyte[] ltabs;
		ltabs.length = aLevel;
		ltabs[] = 0x09;
		aStream.Write(ltabs.ptr, ltabs.length);
		// Property Name
		lData = aProp.Name.dup;
		aStream.Write(lData.ptr,lData.length);
		// Name/Value separator
		lSym = '=';
		aStream.Write(&lSym, 1);
		// Property Value
		static if (is(T == Object))
		{
			T lValue = aProp.Getter()();
			lData = demangle(lValue.classinfo.name).dup;
			auto i = lastIndexOf(lData, '.');
			i++;
			lCount = cast(uint) (lData.length - i);
			aStream.Write(lData.ptr + i,lCount);
		}
		else
		{
			T lValue = aProp.Getter()();
			lData = format("%s", lValue).dup;
			aStream.Write( lData.ptr, lData.length);
		}
		// new line
		lSym = 0x0A;
		aStream.Write(&lSym, 1);
	}
	final void ReadProperty(sPropDescriptor!T aProp, uint aLevel, iStream aStream)
	{
		void GotoNext()
		{
			ubyte lReader;
			while(true)
			{
				aStream.Read(&lReader,1);
				if ((lReader == 0x0A) | (aStream.Position == aStream.Size))
				{
					break;
				}
			}
		}
		char[] lData, lLine, lPropName, lPropValueStr;
		char lSym;
		ulong lPos,lLen;
		bool lEqu;
		uint lLev, lNameLen, lValueLen;
		lPos = aStream.Position;
		try
		{
			// check the line
			while (true)
			{
				aStream.Read(&lSym,1);
				if (lSym == 0x0A)
				{
					lValueLen = (cast (uint) (aStream.Position - lPos)) - aLevel -1 - lNameLen -1;
					break;
				}
				if (lSym == '=')
				{
					lEqu = true;
					lNameLen = (cast (uint) (aStream.Position - lPos)) - aLevel -1;
				}
				if (lSym == 0x09) lLev++;
				if (aStream.Position == aStream.Size) break;
			}
			if (lSym != 0x0A)
			{
				throw new Exception("cTEXTSerializer error, invalid property line, LF expected");
			}
			if (!lEqu)
			{
				throw new Exception("cTEXTSerializer error, invalid property line, equality symbol expected");
			}
			if (lLev != aLevel)
			{
				throw new Exception("cTEXTSerializer error, invalid property line, invalid property level");
			}
			lLen = aStream.Position - lPos - aLevel;
			aStream.Position = lPos + aLevel;
			lLine.length = cast(uint) lLen;
			aStream.Read( lLine.ptr, lLine.length);
			lPropName.length = lNameLen;
			lPropValueStr.length = lValueLen;
			lPropName[0..$] = lLine[0..lNameLen];
			lPropValueStr[0..$] = lLine[lNameLen + 1..$-1];
			// prop name
			if (lPropName != aProp.Name)
			{
				throw new Exception("cTEXTSerializer error, property name mismatch");
			}
			// prop Value
			T lValue;
			static if (is(T == Object))
			{
				auto lName2 = demangle(aProp.Getter()().classinfo.name).dup;
				auto i = lastIndexOf(lName2, '.');
				i++;
				lName2 = lName2[i..$];
				if (lPropValueStr != lName2)
				{
					throw new Exception("cTEXTSerializer error, Object class mismatch");
				}
			}
			else
			{
				lValue = to!T(lPropValueStr);
				aProp.Setter()(lValue);
			}
		}
		catch
		{
			GotoNext;
		}
	}
	final void WriteBinaryProperty(dBinPropAccess aGetProc, string aPropertyName, uint aLevel, iStream aOutStream)
	{
		uint lCount,lDone;
		char[] lData;
		char lSym;
		ubyte lByte;
		// Level
		ubyte[] ltabs;
		ltabs.length = aLevel;
		ltabs[] = 0x09;
		aOutStream.Write(ltabs.ptr, ltabs.length);
		// Property Name
		lData = aPropertyName.dup;
		aOutStream.Write(lData.ptr,lData.length);
		// "="
		lSym = '=';
		aOutStream.Write(&lSym, 1);
		// Property Value
		auto lInStream = new cMemoryStream;
		aGetProc(lInStream);
		lCount = cast(uint) lInStream.Size;
		lData.length = 2;
		while (lDone != lCount)
		{
			lInStream.Read(&lByte,1);
			lData = format( "%.2x",lByte).dup;
			aOutStream.Write( lData.ptr,2);
			lDone++;
		}
		delete lInStream;
		// new line
		lSym = 0x0A;
		aOutStream.Write(&lSym, 1);
	}
	final void ReadBinaryProperty(iStream aInStream, string aPropertyName, uint aLevel, dBinPropAccess aSetProc)
	{
		void GotoNext()
		{
			ubyte lReader;
			while(true)
			{
				aInStream.Read(&lReader,1);
				if ((lReader == 0x0A) | (aInStream.Position == aInStream.Size))
				{
					break;
				}
			}
		}
		char[] lData, lLine, lPropName, lPropValueStr;
		char lSym;
		ulong lPos,lLen;
		bool lEqu;
		uint lLev, lNameLen, lValueLen, lDone;
		lPos = aInStream.Position;
		try
		{
			// check the line
			while (true)
			{
				aInStream.Read(&lSym,1);
				if (lSym == 0x0A)
				{
					lValueLen = (cast (uint) (aInStream.Position - lPos)) - aLevel -1 - lNameLen -1;
					break;
				}
				if (lSym == '=')
				{
					lEqu = true;
					lNameLen = (cast (uint) (aInStream.Position - lPos)) - aLevel -1;
				}
				if (lSym == 0x09) lLev++;
				if (aInStream.Position == aInStream.Size) break;
			}
			if (lSym != 0x0A)
			{
				throw new Exception("cTEXTSerializer error, invalid property line, LF expected");
			}
			if (!lEqu)
			{
				throw new Exception("cTEXTSerializer error, invalid property line, equality symbol expected");
			}
			if (lLev != aLevel)
			{
				throw new Exception("cTEXTSerializer error, invalid property line, invalid property level");
			}
			lLen = aInStream.Position - lPos - aLevel;
			aInStream.Position = lPos + aLevel;
			lLine.length = cast(uint) lLen;
			aInStream.Read( lLine.ptr, lLine.length);
			lPropName.length = lNameLen;
			lPropValueStr.length = lValueLen;
			lPropName[0..$] = lLine[0..lNameLen];
			lPropValueStr[0..$] = lLine[lNameLen + 1..$-1];
			// prop name
			if (lPropName != aPropertyName)
			{
				throw new Exception("cTEXTSerializer error, property name mismatch");
			}
			// len check
			if (lPropValueStr.length % 2 != 0)
			{
				throw new Exception("cTEXTSerializer error, invalid binary value length");
			}
			// prop data
			ubyte lValue;
			lData.length = 2;
			auto lOutStream = new cMemoryStream;
			while(lDone != lPropValueStr.length)
			{
				lData[0] = *(lPropValueStr.ptr + lDone);
				lDone++;
				lData[1] = *(lPropValueStr.ptr + lDone);
				lDone++;
				lValue = to!byte(lData);
				lOutStream.Write(&lValue,1);
			}
			aSetProc(lOutStream);
			delete lOutStream;
		}
		catch(Throwable e)
		{
			version(Release)
			{
				GotoNext;
			}
			else
			{
				writeln(e.toString);
				GotoNext;
			}
		}
	}
}

/**
 * Helper class designed to write/read an iSerializable to/from a cMemoryStream.
 */
alias cGenericObjectStream!cMemoryStream cObjectMemoryStream;
/**
 * Helper class designed to write/read an iSerializable to/from a cFileStream.
 */
alias cGenericObjectStream!cFileStream cObjectFileStream;
class cGenericObjectStream(StreamClass)
if (isImplicitlyConvertible!(StreamClass,iStream))
{
	private
	{
		StreamClass fStr;
		cMasterSerializer fSer;
	}
	public
	{
		this(eSerializationKind aSerializationKind = eSerializationKind.skbin)
		{
			fStr = new StreamClass;
			fSer = new cMasterSerializer(aSerializationKind);
		}
		~this()
		{
			delete fStr;
			delete fSer;
		}
		/**
		 * Serializes aSerializable in Stream.
		 */
		void WriteObject(iSerializable aSerializable)
		{
			fSer.Serialize(aSerializable, fStr);
		}
		/**
		 * Deserializes aSerializable from Stream.
		 */
		void ReadObject(iSerializable aSerializable)
		{
			fStr.Position = 0;
			fSer.Deserialize(aSerializable, fStr);
		}
		@property
		{
			/**
			 * Stream access for additional operations (i.e: MyWriter.Stream.SaveToFile())
			 */
			StreamClass Stream(){return fStr;}
		}
	}
}

/**
 * Adds a parent/child relationship in a T descendant.
 */
class cRamified(T): T
{
	private
	{
		cDynamicList!RamifiedClass fChildren;
		RamifiedClass* fParent;
		int fIndex;
	}
	protected
	{
		final RamifiedClass* AtThis()
		{
			return cast (RamifiedClass*) this;
		}
	}
	public
	{
		alias cRamified!T RamifiedClass;
		/**
		 * Creates an instance of the ramified class with an optional parent.
		 */
		this(RamifiedClass* aParent = null) // parameter not tested, and will fail (like in unmanaged)
		{
			fChildren = new cDynamicList!RamifiedClass;
			if (aParent != null) Parent = aParent;
		}
		~this()
		{
			Parent = null;
			RemoveChildren;
			delete fChildren;
		}
		/**
		 * Remove all the children.
		 * The Parent() dSetter of each children is called.
		 */
		void RemoveChildren()
		{
			while(fChildren.Count != 0)
			{
				auto lOld = Children(fChildren.Count-1);
				lOld.Parent = null;
			}
		}
		/**
		 * Returns this instance Parent.
		 */
		final RamifiedClass* Parent()
		{
			return fParent;
		}
		/**
		 * Sets this instance parent.
		 * This method is designed to be overridden to perform some additional context-specific updates.
		 */
		void Parent(RamifiedClass* aParent)
		{
			if (aParent == fParent) return;
			if (fParent != null) fParent.fChildren.Remove(AtThis);
			if (aParent != null) aParent.fChildren.Add(AtThis);
			fParent = aParent;
		}
		/**
		 * Returns the index of this instance in its parent.
		 * Returns 0 if the parent is null.
		 */
		final int Index()
		{
			if (fParent == null) return 0;
			return cast(int) fParent.fChildren.IndexOf(AtThis);
		}
		/**
		 * Sets the index of this instance in its parent.
		 * This method is designed to be overridden to perform some additional context-specific updates.
		 */
		void Index(int aValue)
		{
			if (fParent == null) return;
			if (Index == aValue) return;
			fParent.fChildren.Remove(AtThis);
			fParent.fChildren.Insert(aValue,AtThis);
		}
		/**
		 * Returns children count.
		 */
		final ptrdiff_t ChildrenCount()
		{
			return fChildren.Count;
		}
		/**
		 * Returns the i-nth children.
		 * Use this method and not directly the list to avoid the "strange-stack-issues".
		 */
		final RamifiedClass Children(ptrdiff_t i)
		{
			return cast(RamifiedClass) fChildren[i];
		}
		/**
		 * Returns the ramification count.
		 */
		final uint Level()
		{
			uint lCount;
			auto lParent = fParent;
			while (lParent != null)
			{
				lParent = lParent.Parent;
				lCount++;
			}
			return lCount;
		}
		/**
		 * Returns the ramification origin.
		 */
		final RamifiedClass* Root()
		{
			RamifiedClass* lPrev;
			auto lParent = fParent;
			while (lParent != null)
			{
				lPrev = lParent;
				lParent = lParent.Parent;
			}
			return lPrev;
		}
	}
}
alias cRamified!cObjectEx cRamifiedcObjectEx;
private final class cRamifiedTester
{
	unittest
	{
		const int Count = 1000;
		int lIdx, a1;
		cRamifiedcObjectEx[Count] Objs;
		auto Root = new cRamifiedcObjectEx;
		for (int i = 0; i < Count; i++) Objs[i] = new cRamifiedcObjectEx;

		for (int i = 0; i < Count; i++)
		{
			Objs[i].Parent = &Root;
			assert(Root.ChildrenCount == i+1);
			assert(Objs[i].Parent == &Root);
			lIdx = Objs[i].Index;
			assert(lIdx == i);
		}
		assert(Root.ChildrenCount == Count);

		Objs[Count-1].Index = 1;
		assert(Objs[Count-1].Index == 1);
		assert(Objs[Count-2].Index == Count-1);
		assert(Objs[1].Index == 2);

		Root.RemoveChildren;
		assert(Root.ChildrenCount == 0);
		for (int i = 0; i < Count; i++)
		{
			assert(Objs[i].Parent == null);
		}

		Objs[0].Parent = &Root;
			Objs[3].Parent = &Objs[0];
				Objs[ 9].Parent = &Objs[3];
				Objs[10].Parent = &Objs[3];
			Objs[4].Parent = &Objs[0];
				Objs[11].Parent = &Objs[4];
				Objs[12].Parent = &Objs[4];
		Objs[1].Parent = &Root;
			Objs[5].Parent = &Objs[1];
				Objs[13].Parent = &Objs[5];
				Objs[14].Parent = &Objs[5];
			Objs[6].Parent = &Objs[1];
				Objs[15].Parent = &Objs[6];
				Objs[16].Parent = &Objs[6];
		Objs[2].Parent = &Root;
			Objs[7].Parent = &Objs[2];
				Objs[17].Parent = &Objs[7];
				Objs[18].Parent = &Objs[7];
			Objs[8].Parent = &Objs[2];
				Objs[19].Parent = &Objs[8];
				Objs[20].Parent = &Objs[8];

		assert(Objs[20].Level == 3);
		assert(Objs[20].Root  == &Root);
		assert(Objs[14].Level == 3);
		assert(Objs[16].Root  == &Root);
		assert(Objs[ 3].Level == 2);
		assert(Objs[12].Root  == &Root);
		assert(Objs[ 6].Level == 2);
		assert(Objs[ 8].Root  == &Root);
		assert(Objs[ 1].Level == 1);
		assert(Objs[ 2].Root  == &Root);
		assert(Objs[ 2].Level == 1);
		assert(Objs[ 1].Root  == &Root);
		assert(Root.Level == 0);
		assert(Root.Root == null);
		assert(Root.ChildrenCount == 3);
		assert(Objs[2].ChildrenCount == 2);
		assert(Objs[4].ChildrenCount == 2);
		assert(Objs[16].ChildrenCount == 0);

		for (int i = 0; i < Count; i++) delete Objs[i];
		delete Root;

		writeln("cRamified passed the tests");
	}
}

/**
 * Simple, uncollected, Object list.
 */
class cObjectList: cDynamicList!Object
{
	protected final override void Cleanup()
	{
		while (Count != 0)
		{
			Object* lObj = Extract(Count-1);
			if(lObj) delete *lObj;
		}
	}
	public
	{
		version(uncollectclasses){}
		else 
			mixin mUncollectedClass;
		this()
		{
			MustCleanItems = true;
		}
	}
	unittest
	{
		const Count = 1000;
		cObjectList list;
		cUncollected Objs[Count];

		list = new cObjectList;
		for( int i = 0; i < Count; i++)
		{
			Objs[i] = new cUncollected;
			list.Add(cast(Object*) &Objs[i]);
		}

		delete list;
		for( int i = 0; i < Count; i++) assert(Objs[i] is null);

		writeln("cObjectList passed the tests");
	}
}

/**
 * ReferentialManager is a "static" class used to 
 * grants some unique identities to the iReferenceable
 * implementers.
 *
 * note: static methods and fields are used to emulate
 * the initialization/finalization sections of a Pascal unit
 * so there should be a single cReferentialMan per program/process
 * ( which could fails in the context of a dll/plug-in )
 */
final class cReferentialMan
{
	private
	{
		static cDynamicList!uint fIds;
		static cDynamicList!Object fSources;
	}
	public
	{
		static this()
		{
			fIds = new cDynamicList!uint;
			fSources = new cDynamicList!Object;
		}
		static ~this()
		{
			delete fIds;
			delete fSources;
		}
		/**
		 * Returns true if the unique identity anID is
		 * added to the referential.
		 */
		static bool Add(uint* anID, Object* aSource)
		{
			if (!anID) return false;
			if (!aSource) return false;
			bool lAvailable = ((fIds.FindValue(*anID) == -1) & (*anID != 0));
			if (lAvailable) 
			{
				fIds.Add(anID);
				fSources.Add(aSource);
			}
			return lAvailable;
		}
		/**
		 * Try to remove the unique identity anID from the referential.
		 * Typically called in an iReferenceable destructor.
		 */
		static void Remove(uint* anID)
		{
			if (!anID) return;
			if (*anID == 0) return;
			auto lIdx = fIds.IndexOf(anID);
			if (lIdx != -1)
			{
				auto lSource = fSources[lIdx];
				foreach(Object* lObj; fSources)
				{
					if (*lObj == *lSource) continue;
					auto lRefObj = cast(iReferenceable) *lObj;
					if(lRefObj) lRefObj.RemoveNotify(lSource);
				}
				fIds.Remove(anID);
				fSources.Remove(lIdx);
			}
		}
		/**
		 * Returns a non null value if an unique identity is available.
		 */
		static uint GetUnique()
		{
			uint lId = 1;
			while(true)
			{
				if (fIds.FindValue(lId) == -1) return lId;
				if (lId == 0xFFFFFFFF) return 0;
				lId++;
			}
		}
		/**
		 * Returns a pointer to the Object identified by anID if
		 * it's referenced otherwise null.
		 */
		static Object* FindReference(uint anID)
		{
			auto lIndex = fIds.FindValue(anID);
			if (lIndex != -1) return fSources[lIndex];
			else return null;
		}
	}
}

/**
 * cOwned proposes a way to manage uncollected Object memory by
 * using an ownership system.
 */
class cOwned: cObjectEx, iReferenceable
{
	private
	{
		cOwned fOwner;
		cObjectList fOwned;
		void AddOwned(cOwned* aOwned)
		{
			fOwned.Add(cast(Object*) aOwned);
			aOwned.fOwner = this;
		}
	}
	public
	{
		version(uncollectclasses){}
		else 
			mixin mUncollectedClass;

		mixin mReferencableDefaultImpl;

		this()
		{
			fOwned = new cObjectList;
		}
		~this()
		{
			delete fOwned;
			cReferentialMan.Remove(&fReferentialID);
		}
		/**
		 * Creates an new owned object on the variable aOwned.
		 * T must be an cOwned descendant.
		 */
		T* NewOwned(T)(cOwned* aOwned)
		{
			*aOwned = cast(cOwned) new T;
			AddOwned(aOwned);
			return cast(T*) aOwned;
		}
		override void DeclareProperties(cMasterSerializer aSerializer)
		{
			super.DeclareProperties(aSerializer);
			auto fId = uintprop(&ReferentialID, &ReferentialID, "ReferentialID");
			aSerializer.AddProperty!uint(fId);
		}
		@property
		{
			cOwned Owner() {return fOwner;}
		}
	}
	unittest
	{
		const Count = 1000;
		cOwned Root;
		cOwned Objs[Count];

		Root = new cOwned;
		for( int i = 0; i < Count; i++) Root.NewOwned!cOwned(&Objs[i]);
		assert( Objs[Count-1].Owner is Root );

		Objs[0].ReferentialID = 1;
		Objs[1].ReferentialID = 1;
		assert(Objs[1].ReferentialID == 2);
		assert(cReferentialMan.fIds.Count == 2);

		delete Root;
		for( int i = 0; i < Count; i++) assert(Objs[i] is null);

		writeln("cOwned passed the tests");
	}
}

alias cSerializableCollection!cCollectionItem cBaseCollection;

/**
 * This is the base class for any cSerializableCollection item.
 * cBaseCollection instances are managed by their collections.
 */
class cCollectionItem: iSerializable
{
	private
	{
		cBaseCollection* fCollection;
		uint fIndex;
	}
	public
	{
		mixin mUncollectedClass;
		bool IsSerializationRecursive(){return false;}
		final bool IsReference(iSerializable aSerializable){return false;}
		void DeclareProperties(cMasterSerializer aSerializer){}
		@property
		{
			/**
			 * The container collection. Automatically set.
			 */
			final cSerializableCollection!cCollectionItem Collection()
			{
				return cast(cSerializableCollection!cCollectionItem) fCollection;
			}
			/**
			 * Gives the position in the collection. Automatically set by the collection.
			 */
			final uint Index(){return fIndex;}
		}
	}
}

/**
 * cSerializableCollection manages a collection of cCollectionItem descendants. 
 * It's designed to handle automatically its items serialization.
 */
class cSerializableCollection(ItemClass): iSerializable
if (isImplicitlyConvertible!(ItemClass,cCollectionItem))
{
	private
	{
		cDynamicList!ItemClass fItems;
		ItemClass[] fBackItems;
		//
		void ListChange(Object aNotifier, eListChangeKind aChangeKind, ItemClass* anItem)
		{
			if ((aChangeKind == eListChangeKind.ckRemove) | (aChangeKind == eListChangeKind.ckExtract))
			{
				if (anItem) delete *anItem;
			}
		}
	}
	public
	{
		alias cSerializableCollection!ItemClass CollectionClass;
		this()
		{
			fItems = new cDynamicList!ItemClass;
			fItems.OnChange = &ListChange;
		}
		~this()
		{
			Clear;
			delete fItems;
		}
		final void DeclareProperties(cMasterSerializer aSerializer)
		{
			// dynamic item persistence: the right amount of item to read is created in Count().
			auto lCountProp = uintprop(&Count,&Count,"Count");
			aSerializer.AddProperty!uint(lCountProp);
			objprop lProp;
			foreach(ItemClass* lItem; fItems)
			{
				lProp.Define(cast(Object*)lItem,format("Item%d",lItem.Index));
				aSerializer.AddProperty!Object(lProp);
			}
		}
		final bool IsSerializationRecursive(){return true;}
		bool IsReference(iSerializable aSerializable){return false;}

		/**
		 * Creates and Adds a new item to the collection, using an internal variable.
		 */
		ItemClass* NewItem()
		{
			Count = Count + 1;
			return fItems.Last;
		}
		/**
		 * Creates and adds a new item to the collection, using an external variable.
		 */
		ItemClass* NewItem(ItemClass* anItemPtr)
		{
			if(!anItemPtr) *anItemPtr = new ItemClass;
			fItems.Add(anItemPtr);
			anItemPtr.fIndex = cast(uint) fItems.Count - 1;
			anItemPtr.fCollection = cast(cBaseCollection*) this;
			return anItemPtr;
		}
		/**
		 * Empties the collection.
		 */
		void Clear()
		{
			fItems.Clear;
			for( size_t i = 0; i < fBackItems.length; i++) delete fBackItems[i];
			fBackItems.length = 0;
		}
		@property
		{
			/**
			 * Internal list access for additional cList operations.
			 */
			cDynamicList!ItemClass Items(){return fItems;}
			/**
			 * Returns or sets the collection items count, using the internal NewItem()
			 * method. To use Items.Count() instead of this.Count() will break the
			 * basic functionalities of the class.
			 */
			uint Count(){return cast(uint) fItems.Count;}
			/// ditto
			void Count(uint aValue)
			{
				if (aValue == fItems.Count) return;
				if (aValue < fItems.Count)
				{
					while(fItems.Count != aValue) fItems.Remove(fItems.Count-1);
				} 
				else
				{
					while(fItems.Count != aValue)
					{
						fBackItems.length = fBackItems.length + 1;
						fBackItems[$-1] = new ItemClass;
						fItems.Add(&fBackItems[$-1]);
						fBackItems[$-1].fCollection = cast(cBaseCollection*) this;
						fBackItems[$-1].fIndex = cast(uint) fItems.Count - 1;
					}
				}
			}
		}
	}
}
version(unittest)
{
	class cItem: cCollectionItem
	{
		private
		{
			uint a;
			float b;
			char[] c;
		}
		override void DeclareProperties(cMasterSerializer aSerializer)
		{
			auto propa = uintprop(&a,"member a");
			auto propb = floatprop(&b,"member b");
			auto propc = sPropDescriptor!(char[])(&c,"member c") ;
			aSerializer.AddProperty!uint( propa );
			aSerializer.AddProperty!float( propb );
			aSerializer.AddProperty!(char[])( propc );
		}
	}
	alias cSerializableCollection!cItem cItemCollection;
}
private final class cCollectionTester
{
	unittest
	{
		auto Coll = new cItemCollection;
		auto lStr = new cMemoryStream;
		auto lSer = new cMasterSerializer(eSerializationKind.sktext);

		scope(exit) delete Coll;
		scope(exit) delete lStr;
		scope(exit) delete lSer;

		auto Count = 100;
		for(int i = 0; i < Count; i++)
		{
			auto lItem = Coll.NewItem;
			lItem.a = i;
			lItem.b = i * 0.333;
			lItem.c = format("this is the %d nth item of the collection",i).dup;
		}
		
		assert(Coll.Count == Count);
		assert(Coll.Items[10].a == 10);
		assert(Coll.Items[10].Collection is Coll);

		lSer.Serialize( cast(iSerializable) Coll, lStr );
		lStr.SaveToFile("CollSer.txt");

		Coll.Clear;
		assert(!Coll.Count);
		lStr.Position = 0;
		lSer.Deserialize(cast(iSerializable) Coll, lStr);
	
		assert(Coll.Count == Count);
		assert(Coll.Items[10].a == 10);
		assert(Coll.Items[10].Collection is Coll);

		version(Windows) DeleteFileA(toStringz("CollSer.txt"));
		version(Posix) core.stdc.stdio.remove(toStringz("CollSer.txt"));

		writeln("cSerializableCollection(T) passed the tests");
	}
}

interface iStates(StateItemStruct)
{
	void ClearStates();
	size_t StatesCount();
	void StatesLimit(size_t aValue);
	size_t StatesLimit();
	bool CanUndo();
	bool CanRedo();
	void Undo();
	void Redo();
	size_t StatesPosition();
	void AddState(StateItemStruct* aUndoItem, StateItemStruct* aRedoItem);
	void ProcessItem(StateItemStruct* aState);
	void OptimizeStates();
}

enum eEditorChange {scInsert, scDelete, scPosition, scReplace, scSelect}

interface iStdEditor
{
	void EditorInsert(ulong aPosition, ulong aSize, void* aData, bool IsStorable);
	void EditorReplace(ulong aPosition, ulong aSize, void* aData, bool IsStorable);
	void EditorDelete(ulong aPosition, ulong aSize, bool IsStorable);
	void EditorSelect(ulong aPosition, ulong aSize, bool IsStorable);
	void EditorPosition(ulong aPosition, bool IsStorable);
}

class cStateMan(T): iStates!T
if (is(T==struct))
{
	private
	{
		cDynamicList!T fUndos;
		cDynamicList!T fRedos;
		ptrdiff_t fPosition;
		size_t fLimit;
		bool fIsProcessing;
	}
	protected
	{
		sEditorState* AllocState()
		{
			auto lNewStruct = malloc(T.sizeof);
			memset(lNewStruct,0,T.sizeof);
			return cast(T*) lNewStruct;
		}
		void FreeState(T* aState)
		{
			std.c.stdlib.free(aState);
		}
		void ListChange(Object aNotifier, eListChangeKind aChangeKind, T* anItem)
		{
			if ((aChangeKind == eListChangeKind.ckRemove) | (aChangeKind == eListChangeKind.ckExtract))
			{
				if (anItem) FreeState( anItem );
			}
		}
		void AddState(T* aUndoItem, T* aRedoItem)
		{
			if (fUndos.Count == fLimit)
			{
				fUndos.Remove(fUndos.Last);
				fRedos.Remove(fRedos.Last);
				fPosition--;
			}
			fUndos.Insert(fPosition,aUndoItem);
			fRedos.Insert(fPosition,aRedoItem);
			fPosition++;
			OptimizeStates;
			if (fPosition > 0)
			{
				// new branch
			}
		}
		void ProcessItem(T* aState)
		{
			// virtual
		}
		void OptimizeStates()
		{
			// virtual
		}
	}
	public
	{
		this()
		{
			fLimit = 1000;
			fPosition = 0;
			fUndos = new cDynamicList!T;
			fRedos = new cDynamicList!T;
			fUndos.OnChange = &ListChange;
			fRedos.OnChange = &ListChange;
		}
		~this()
		{
			delete fUndos;
			delete fRedos;
		}
		void ClearStates()
		{
			fPosition = 0;
			fUndos.Clear;
			fRedos.Clear;
		}
		void Undo()
		{
			if(fPosition == -1) return;
			fPosition--;
			ProcessItem(fUndos[fPosition]);
		}
		void Redo()
		{
			if (fPosition == fRedos.Count) return;
			ProcessItem(fRedos[fPosition]);
			fPosition++;
		}
		@property
		{
			void StatesLimit(size_t aValue)
			{
				if (fLimit == aValue) return;			
				if (aValue < fLimit)
				{
					while(fUndos.Count != fLimit)
					{
						fUndos.Remove(fUndos.Last);
						fRedos.Remove(fRedos.Last);
					}
					if (fPosition > aValue)
					{
						fPosition = aValue;
					}
				}
				fLimit = aValue;
			}
			size_t StatesLimit()
			{
				return fLimit;
			}
			size_t StatesCount(){return fUndos.Count;}
			size_t StatesPosition(){return fPosition;}
			bool CanUndo(){return fPosition > 0;}
			bool CanRedo(){return fPosition < fRedos.Count;}
		}
	}
}

struct sEditorState
{
	eEditorChange ChangeKind;
	ulong ChangePosition;
	void* ChangeData;
	ulong ChangeSize;
}

class cEditorStateMan: cStateMan!sEditorState
{
	private
	{
		iStdEditor fEditor;
		uint fPosThreshold;	
	}
	protected
	{
		override void ListChange(Object aNotifier, eListChangeKind aChangeKind, sEditorState* anItem)
		{
			if ((aChangeKind == eListChangeKind.ckRemove) | (aChangeKind == eListChangeKind.ckExtract))
			{
				if (anItem && anItem.ChangeData) 
					std.c.stdlib.free(anItem.ChangeData);
			}
			super.ListChange(aNotifier, aChangeKind, anItem);
		}
	}
	public
	{
		~this()
		{
			foreach(sEditorState* lState; fUndos) 
				FreeState(lState);
			foreach(sEditorState* lState; fRedos) 
				FreeState(lState);
		}
		override void ProcessItem(sEditorState* aState)
		{
			if(!fEditor) return;
			if(!aState) return;
			//
			switch(aState.ChangeKind)
			{
				case eEditorChange.scDelete:
					fEditor.EditorDelete(aState.ChangePosition,aState.ChangeSize,false);
					break;
				case eEditorChange.scInsert:
					assert( aState.ChangeData != null);
					fEditor.EditorInsert(aState.ChangePosition,aState.ChangeSize,aState.ChangeData,false);
					break;
				case eEditorChange.scPosition:
					fEditor.EditorPosition(aState.ChangePosition,false);
					break;
				case eEditorChange.scReplace:
					assert( aState.ChangeData != null);
					fEditor.EditorReplace(aState.ChangePosition,aState.ChangeSize,aState.ChangeData,false);
					break;
				case eEditorChange.scSelect:
					fEditor.EditorSelect(aState.ChangePosition,aState.ChangeSize,false);
					break;
				default: 
					break;
			}
		}
		override void OptimizeStates()
		{
			if(!fEditor) return;
			while(true)
			{
				// merge very small insertion
				// skip pos changes groups
				break;
			}
		}
		@property
		{
			iStdEditor Editor(){return fEditor;}
			void Editor(iStdEditor aValue){fEditor = aValue;}
		}
	}
}

class cMemoryStreamStates: cMemoryStream, iStdEditor
{
	private
	{
		cEditorStateMan fStatesMan;

		// hide iStream
/*
		final override size_t Read(void* aBuffer, size_t aCount){return super.Read(aBuffer,aCount);}
		final override size_t Write(void* aBuffer, size_t aCount){return super.Write(aBuffer,aCount);}
		final override ulong Seek(ulong aOffset, int aOrigin){return super.Seek(aOffset,aOrigin);}
*/

	}
	public
	{
		this()
		{
			fStatesMan = new cEditorStateMan;
			fStatesMan.Editor = this;
		}
		~this()
		{
			delete fStatesMan;
		}
		//
		void EditorInsert(ulong aPosition, ulong aSize, void* aData, bool IsStorable = true)
		{
			Position = aPosition;
			auto lNewPos = Position;
			//
			sEditorState* lNewState, lOldState;
			if(IsStorable)
			{
				lNewState = fStatesMan.AllocState;
				lOldState = fStatesMan.AllocState;
				lNewState.ChangeKind = eEditorChange.scInsert;
				lOldState.ChangeKind = eEditorChange.scDelete;
				lNewState.ChangePosition = lNewPos;
				lOldState.ChangePosition = lNewPos;
				lNewState.ChangeSize = aSize;
				lOldState.ChangeSize = aSize;
				lNewState.ChangeData = malloc(cast(size_t) aSize); 
			}
			//
			auto lRemainSz = Size - Position;
			Size = Size + aSize;
			memmove( Memory + lNewPos + aSize, Memory + lNewPos, cast(size_t) lRemainSz);
			memmove( Memory + lNewPos, aData, cast(size_t) aSize);  
			if(IsStorable)
			{
				memmove( lNewState.ChangeData, aData, cast(size_t) aSize);
				fStatesMan.AddState(lOldState,lNewState);
			}
		}
		void EditorReplace(ulong aPosition, ulong aSize, void* aData, bool IsStorable = true)
		{
			Position = aPosition;
			auto lNewPos = Position;
			//
			sEditorState* lNewState, lOldState;
			if(IsStorable)
			{
				lNewState = fStatesMan.AllocState;
				lOldState = fStatesMan.AllocState;
				lNewState.ChangeKind = eEditorChange.scReplace;
				lOldState.ChangeKind = eEditorChange.scReplace;
				lNewState.ChangePosition = lNewPos;
				lOldState.ChangePosition = lNewPos;
				lNewState.ChangeSize = aSize;
				lOldState.ChangeSize = aSize;
				lNewState.ChangeData = malloc(cast(size_t) aSize);
				lOldState.ChangeData = malloc(cast(size_t) aSize);
				//
				memmove( lNewState.ChangeData, aData, cast(size_t) aSize); 
				memmove( lOldState.ChangeData, Memory + lNewPos, cast(size_t) aSize);
			}
			memmove( Memory + lNewPos, aData, cast(size_t) aSize );
			//
			if(IsStorable) fStatesMan.AddState(lOldState,lNewState);
		}
		void EditorDelete(ulong aPosition, ulong aSize, bool IsStorable = true)
		{
			Position = aPosition;
			auto lNewPos = Position;
			sEditorState* lNewState, lOldState;
			if(IsStorable)
			{
				lNewState = fStatesMan.AllocState;
				lOldState = fStatesMan.AllocState;
				lNewState.ChangeKind = eEditorChange.scDelete;
				lOldState.ChangeKind = eEditorChange.scInsert;
				lNewState.ChangeSize = aSize;
				lOldState.ChangeSize = aSize;
				lOldState.ChangeData = malloc(cast(size_t) aSize);
			}
			//
			if(IsStorable) memmove( lOldState.ChangeData, Memory + lNewPos, cast(size_t) aSize);
			memmove( Memory + lNewPos, Memory + lNewPos + aSize, cast(size_t) (Size - (lNewPos + aSize)));
			Size = Size - aSize;
			//
			if(IsStorable) fStatesMan.AddState(lOldState,lNewState);
		}
		void EditorSelect(ulong aPosition, ulong aSize, bool IsStorable = true)
		{
		}
		void EditorPosition(ulong aPosition, bool IsStorable = true)
		{
			auto lSavedPos = Position;
			if(lSavedPos == Position) return;
			Position = aPosition;
			auto lNewPos = Position;
			if(IsStorable)
			{
				auto lNewState = fStatesMan.AllocState;
				auto lOldState = fStatesMan.AllocState;
				lNewState.ChangeKind = eEditorChange.scPosition;
				lOldState.ChangeKind = eEditorChange.scPosition;
				lNewState.ChangePosition = lNewPos;
				lOldState.ChangePosition = lSavedPos;
				//
				fStatesMan.AddState(lOldState,lNewState);
			}
		}
		@property
		{
			cEditorStateMan StatesManager(){return fStatesMan;}
		}
	}
	unittest
	{
		uint[1000] Filler;
		auto Str = new cMemoryStreamStates;
		scope(exit) delete Str;
		//
		assert( !Str.StatesManager.CanUndo );
		assert( !Str.StatesManager.CanRedo );
		//
		foreach(uint i; Filler)
		{
			Str.EditorInsert( Str.Position, i.sizeof, &i, true);
		}
		assert( Str.StatesManager.CanUndo );
		assert( !Str.StatesManager.CanRedo );
		assert( Str.StatesManager.StatesCount == Filler.length );
		foreach(uint i; Filler)
		{
			Str.StatesManager.Undo;
		}
		assert( Str.Size == 0 );
		assert( !Str.StatesManager.CanUndo );
		assert( Str.StatesManager.CanRedo );
		//
		while(Str.StatesManager.CanRedo) Str.StatesManager.Redo;
		assert( Str.Size == Filler.length * Filler[0].sizeof);
		assert( Str.StatesManager.CanUndo );
		assert( !Str.StatesManager.CanRedo );
		//
		while(Str.StatesManager.CanUndo) Str.StatesManager.Undo;
		assert( Str.Size == 0);
		assert( !Str.StatesManager.CanUndo );
		assert( Str.StatesManager.CanRedo );
		//
		while(Str.StatesManager.CanRedo) Str.StatesManager.Redo;
		assert( Str.Size == Filler.length * Filler[0].sizeof);
		assert( Str.StatesManager.CanUndo );
		assert( !Str.StatesManager.CanRedo );
	}
}



module VolStream;

import std.stdio, std.string;
import LLClasses;

void main(string args[])
{

	if (args.length == 1)
	{
		writeln("unspecified volume letter");
		return;
	}
	
	char VLetter = args[1][1];
	VolumeStream volume;
	MemoryStream Dumper;
	
	void WriteCluster(ulong aIndex)
	{
		volume.SaveClusterToStream(aIndex,Dumper);	
		Dumper.SaveToFile(format("%c.Cluster%d.bin",VLetter,aIndex));
	}

	volume = new VolumeStream(VLetter,false);
	Dumper = new MemoryStream;
	try
	{
		volume.Position = volume.ClusterSize + 0;
		uint[4] uLine;
		for (int i = 0; i < (4096 * 8) / 16; i++)
		{
			uLine[0] = (i * 4);
			uLine[1] = (i * 4) + 1;
			uLine[2] = (i * 4) + 2;
			uLine[3] = (i * 4) + 3;
			volume.Write(uLine.ptr,16);
		}

		WriteCluster(0);
		WriteCluster(1);
		WriteCluster(2);
		WriteCluster(3);
		WriteCluster(4);
		WriteCluster(5);	
		WriteCluster(6);
		WriteCluster(7);
		WriteCluster(8);

	}
	finally
	{
		delete volume;
		delete Dumper;
	}


	/*volume = new VolumeStream(VLetter,true);
	Dumper = new MemoryStream;
	try
	{	
		ulong Clamper = cast(ulong)1024 * cast(ulong)1024 * cast(ulong)1024 * cast(ulong)16;
		assert(volume.Size < Clamper, "oops, you can only test a dedicated volume");
		
		WriteCluster(0);
		WriteCluster(1);
		WriteCluster(2);	
	}
	finally
	{
		delete volume;
		delete Dumper;
	}
	
	volume = new VolumeStream(VLetter,false);
	Dumper = new MemoryStream;
	try
	{
		
		ulong Clamper = cast(ulong)1024 * cast(ulong)1024 * cast(ulong)1024 * cast(ulong)16;
		assert(volume.Size < Clamper, "oops, you can only test a dedicated volume");
		
		ubyte[4096*4] blk;
		volume.Position = 4096;
		volume.Write( blk.ptr, 4096 * 4);
		volume.Position = 0;
		
		ubyte Buff;
		uint  iBuff;
		assert(volume.Position == 0, format("wrong pos (0,%d)",volume.Position));
		volume.Position = 4096;
		assert(volume.Position == 4096, format("wrong pos (1,%d)",volume.Position));
		
		Buff = 0xCC;
		volume.Write(&Buff, 1);
		assert(volume.Position == 4097, format("wrong pos (2,%d)",volume.Position));
		Buff = 0x00;
		volume.Write(&Buff, 1);
		volume.Write(&Buff, 1);
		volume.Write(&Buff, 1);
		
		volume.Position = 8191;
		assert(volume.Position == 8191, format("wrong pos (3,%d)",volume.Position));
		iBuff = 0xAABBCCDD;
		volume.Write(&iBuff, 4);
		assert(volume.Position == 8195, format("wrong pos (4,%d)",volume.Position));
		
		volume.Position = 12287;
		assert(volume.Position == 12287, format("wrong pos (3,%d)",volume.Position));		
		Buff = 0xCD;
		volume.Write(&Buff, 1);
		assert(volume.Position == 12288, format("wrong pos (4,%d)",volume.Position));	
		volume.CloseVolume;
		
		volume.OpenVolume(VLetter,false);
		WriteCluster(0);
		WriteCluster(1);
		WriteCluster(2);
		WriteCluster(3);
		volume.CloseVolume;
		
	}
	finally
	{
		delete volume;
		delete Dumper;
	}	*/
	
	
	
}
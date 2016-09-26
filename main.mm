//
//  main.mm
//  MetalTest
//
//  Created by Takahiro Harada on 9/21/16.
//  Copyright © 2016 Takahiro Harada. All rights reserved.
//

#include <iostream>

#import <Metal/Metal.h>

inline
NSString* ec( const char* src )
{
	return [NSString stringWithCString:src encoding:[NSString defaultCStringEncoding]];
}

int main(int argc, const char * argv[])
{
	id<MTLDevice> device = MTLCreateSystemDefaultDevice();
	
	id<MTLCommandQueue> q = [device newCommandQueue];
	
	const int n = 64;
	id<MTLBuffer> buff = [device newBufferWithLength:n*sizeof(int) options:MTLResourceOptionCPUCacheModeDefault];
	id<MTLBuffer> buff1 = [device newBufferWithLength:n*sizeof(int) options:MTLResourceOptionCPUCacheModeDefault];
	
	{
		int* d = (int*)[buff contents];
		int* d1 = (int*)[buff1 contents];
		for(int i=0; i<n; i++)
		{
			d[i] = i;
			d1[i] = 0;
		}
	}
	
	std::string src = "#include<metal_stdlib>\n using namespace metal;\n";
	src +=
		"kernel void AddKernel(const device int* In1[[buffer(0)]], \n\
			const device int* In2[[buffer(1)]], \n \
			device int* Out[[buffer(2)]], \n \
			uint tid [[thread_position_in_grid]]) \n \
		{ \n \
			Out[tid] = In1[tid] + In2[tid]; \n \
		}";
	NSError *errors;
	id<MTLLibrary> lib = [device newLibraryWithSource:ec(src.c_str()) options:0 error:&errors];
	id<MTLFunction> func = [lib newFunctionWithName:ec("AddKernel")];
	id<MTLComputePipelineState> state = [device newComputePipelineStateWithFunction:func error:&errors];
	id<MTLCommandBuffer> cmd = [q commandBuffer];
	id<MTLComputeCommandEncoder> e = [cmd computeCommandEncoder];
	[e setComputePipelineState:state];
	
	[e setBuffer:buff offset:0 atIndex:0];
	[e setBuffer:buff offset:0 atIndex:1];
	[e setBuffer:buff1 offset:0 atIndex:2];
	
	//	run
	MTLSize ng = {1,1,1};
	MTLSize nt = {n,1,1};
	[e dispatchThreadgroups:ng threadsPerThreadgroup:nt];
	[e endEncoding];
	[cmd commit];
	[cmd waitUntilCompleted];
	
	bool passed = true;
	{
		int* s = (int*)[buff contents];
		int* d = (int*)[buff1 contents];
		for(int i=0; i<n && passed; i++)
		{
			if( i<10 )
				printf("[%d] %d\n", i, d[i]);
			if( s[i] * 2 != d[i] )
				passed = false;
		}
	}
	
	std::cout << "Hello Metal Compute!\n";
	std::cout << "Test [" << ((passed)?"Passed":"Failed") << "]\n";
	
	return 0;
}

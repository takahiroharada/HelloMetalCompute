solution "HelloMetal"
	configurations { "Debug", "Release" }
	configuration "Debug"
		defines { "_DEBUG" }
		flags { "Symbols" }
	configuration "Release"
		defines { "NDEBUG" }
		flags { "Optimize" }
	configuration {}
	
	language "C++"
	flags { "NoMinimalRebuild", "EnableSSE2" }

	platforms {"x64"}
	
	configuration {}
		
	project "Metal"
		kind "ConsoleApp"
		location "./build/"
		linkoptions{"-framework Metal"}
		files { "./*.mm" } 

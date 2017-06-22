# iOS-OnAirSdk

Importing ZixiOnAirSDKStatic.Framework to your project :

1. Click on project navigator
2. Select your project (in project navigator)
3. Select your target
4. Click on "Build Phases"
5. Expand "Embedded Binaries"
6. Drag and drop "ZixiOnAirSDK.Framework" on to the list
7. Click on "Build Settings" and type 'search' in the search box
8. Make sure that XCode added the path of ZixiOnAirSDK to "Framework Search Paths"
9. Type 'Other Linker Flags' in the search box
10. Add '-all_load' flag to 'Other Linker Flags'
11. Open your project's "Info.Plist"
13. Add "Privacy - Camera Usage Description" key and value to the App Info.plist (NSCameraUsageDescription)
14. Add "Privacy - Microphone Usage Description" key and value to the App Info.plist (NSMicrophoneUsageDescription)

#import <ZixiOnAirSDK/ZixiOnAirSDK.h> from a .m file (e.g. UIViewController.m)


Two more things :
* Make sure to set a correct Team under General->Signing

* If you are testing onairsdktester, you will have to perform steps 1-8 on the project settings


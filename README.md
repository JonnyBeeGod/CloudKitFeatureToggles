# CloudKit FeatureToggles

![](https://github.com/JonnyBeeGod/CloudKitFeatureToggles/workflows/Swift/badge.svg)
[![codecov](https://codecov.io/gh/JonnyBeeGod/CloudKitFeatureToggles/branch/master/graph/badge.svg?token=y21zGNAsLL)](https://codecov.io/gh/JonnyBeeGod/CloudKitFeatureToggles)
<img src="https://img.shields.io/badge/Swift-5.1-orange.svg" />
<a href="https://swift.org/package-manager">
    <img src="https://img.shields.io/badge/swiftpm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
</a>
<img src="https://img.shields.io/badge/platforms-iOS-brightgreen.svg?style=flat" alt="iOS" />
<a href="https://twitter.com/jonezdotcom">
    <img src="https://img.shields.io/badge/twitter-@jonezdotcom-blue.svg?style=flat" alt="Twitter: @jonezdotcom" />
</a>

## What does it do?

## How to install?
CloudKitFeatureToggles is compatible with Swift Package Manager. To install, simply add this repository URL to your swift packages as package dependency in Xcode. 
Alternatively, add this line to your `Package.swift` file:

```
dependencies: [
    .package(url: "https://github.com/JonnyBeeGod/CloudKitFeatureToggles", from: "0.1.0")
]
```

And don't forget to add the dependency to your target(s). 

## How to use?
1. In your AppDelegate, initialize a `FeatureToggleApplicationService` and hook its two `UIApplicationDelegate` methods into the AppDelegate lifecycle like so: 

```
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return featureToggleApplicationService.application(application, didFinishLaunchingWithOptions: launchOptions)
}
func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        featureToggleApplicationService.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
}

```
2. Anywhere in your code you can create an instance of `FeatureToggleUserDefaultsRepository` and call `retrieve` to fetch the latest status for your feature toggle. 


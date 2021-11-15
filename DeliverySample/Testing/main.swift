//
//  main.swift
//  DeliverySample
//

import UIKit

let kIsRunningTests = NSClassFromString("XCTestCase") != nil
let kAppDelegateClass = kIsRunningTests ? nil : NSStringFromClass(AppDelegate.self)

UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, kAppDelegateClass)

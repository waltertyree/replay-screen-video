//
//  AppDelegate.swift
//  replaydebug
//
//  Created by Walter Tyree on 7/30/21.
//

import UIKit
import ReplayKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
//    RPScreenRecorder.shared().startClipBuffering { err in
//      if let err = err {
//        print("error attempting to start buffering \(err.localizedDescription)")
//      } else {
//        print("Clip buffering started.")
//      }
//    }
    return true
  }

  func applicationWillTerminate(_ application: UIApplication) {
//    RPScreenRecorder.shared().stopClipBuffering { err in
//      if let err = err {
//        print("Error attempting to stop buffering \(err.localizedDescription)")
//      } else {
//        print("Clip buffering stopped.")
//      }
//    }
  }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }



}


extension UIWindow {
  open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    print("I was shooken.")
    let clipURL: URL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(UUID().description).mov")
    RPScreenRecorder.shared().exportClip(to: clipURL, duration: TimeInterval(15)) { err in
      if let err = err {
        print("An error? \(err.localizedDescription )")
      } else {
        print("Clip saved to url \(clipURL)")
      }

      // Create the Array which includes the files you want to share
      var filesToShare = [Any]()

      // Add the path of the file to the Array
      filesToShare.append(clipURL)

      // Make the activityViewContoller which shows the share-view
      let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)

      // Show the share-view
      // on the main thread
      DispatchQueue.main.async {
        self.rootViewController?.present(activityViewController, animated: true, completion: nil)
      }

    }
  }
}


import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {

    private let channel = "app_casal_flutter/external_apps"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
        [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        let controller =
            window?.rootViewController as! FlutterViewController

        let methodChannel = FlutterMethodChannel(
            name: channel,
            binaryMessenger: controller.binaryMessenger
        )

        methodChannel.setMethodCallHandler { call, result in

            if call.method == "openUrl" {

                if let args = call.arguments as? [String: Any],
                   let urlString = args["url"] as? String,
                   let url = URL(string: urlString) {

                    UIApplication.shared.open(url)

                    result(nil)
                }
            }
        }

        GeneratedPluginRegistrant.register(with: self)

        return super.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
    }
}

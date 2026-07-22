import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {

    private let channel = "app_casal_flutter/external_apps"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        GeneratedPluginRegistrant.register(with: self)

        DispatchQueue.main.async {

            guard
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let window = windowScene.windows.first,
                let controller = window.rootViewController as? FlutterViewController
            else {
                return
            }

            let methodChannel = FlutterMethodChannel(
                name: self.channel,
                binaryMessenger: controller.binaryMessenger
            )

            methodChannel.setMethodCallHandler { call, result in

                guard call.method == "openUrl" else {
                    result(FlutterMethodNotImplemented)
                    return
                }

                guard
                    let args = call.arguments as? [String: Any],
                    let urlString = args["url"] as? String,
                    let url = URL(string: urlString)
                else {
                    result(
                        FlutterError(
                            code: "INVALID_URL",
                            message: "URL inválida",
                            details: nil
                        )
                    )
                    return
                }

                UIApplication.shared.open(
                    url,
                    options: [:]
                ) { success in
                    result(success)
                }
            }
        }

        return super.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
    }
}

//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import biometric_storage
import firebase_core
import geolocator_apple
import location
import package_info_plus
import path_provider_foundation
import sqflite

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  BiometricStorageMacOSPlugin.register(with: registry.registrar(forPlugin: "BiometricStorageMacOSPlugin"))
  FLTFirebaseCorePlugin.register(with: registry.registrar(forPlugin: "FLTFirebaseCorePlugin"))
  GeolocatorPlugin.register(with: registry.registrar(forPlugin: "GeolocatorPlugin"))
  LocationPlugin.register(with: registry.registrar(forPlugin: "LocationPlugin"))
  FPPPackageInfoPlusPlugin.register(with: registry.registrar(forPlugin: "FPPPackageInfoPlusPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  SqflitePlugin.register(with: registry.registrar(forPlugin: "SqflitePlugin"))
}

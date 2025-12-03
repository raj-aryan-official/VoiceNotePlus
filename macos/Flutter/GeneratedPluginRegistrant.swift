//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import audio_session
import just_audio
import path_provider_foundation
import record_macos
import share_plus
import speech_to_text_macos

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  AudioSessionPlugin.register(with: registry.registrar(forPlugin: "AudioSessionPlugin"))
  JustAudioPlugin.register(with: registry.registrar(forPlugin: "JustAudioPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  RecordMacosPlugin.register(with: registry.registrar(forPlugin: "RecordMacosPlugin"))
  SharePlusMacosPlugin.register(with: registry.registrar(forPlugin: "SharePlusMacosPlugin"))
  SpeechToTextMacosPlugin.register(with: registry.registrar(forPlugin: "SpeechToTextMacosPlugin"))
}

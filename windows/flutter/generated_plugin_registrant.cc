//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <screen_retriever/screen_retriever_plugin.h>
#include <veilid/veilid_plugin.h>
#include <window_manager/window_manager_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  ScreenRetrieverPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ScreenRetrieverPlugin"));
  VeilidPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("VeilidPlugin"));
  WindowManagerPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowManagerPlugin"));
}

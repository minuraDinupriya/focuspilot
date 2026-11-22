#ifndef RUNNER_DESKTOP_INTEGRATION_H_
#define RUNNER_DESKTOP_INTEGRATION_H_

#include <windows.h>
#include <shellapi.h>

#include <flutter/method_channel.h>

#include <optional>
#include <string>

class DesktopIntegration {
 public:
  DesktopIntegration(HWND window, flutter::BinaryMessenger* messenger);
  ~DesktopIntegration();

  std::optional<LRESULT> HandleMessage(UINT message, WPARAM wparam,
                                       LPARAM lparam);

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  NOTIFYICONDATAW TrayIconData() const;
  bool EnsureTrayIcon();
  void RemoveTrayIcon();
  bool HideToTray();
  void RestoreWindow();
  void ShowTrayMenu(POINT position);
  bool UpdateTray(std::wstring status, bool is_running, bool is_paused);
  bool ShowIntervalEnded(const std::wstring& title, const std::wstring& body);

  const HWND window_;
  flutter::MethodChannel<flutter::EncodableValue> channel_;
  const UINT taskbar_created_message_;
  std::wstring status_ = L"FocusPilot";
  bool tray_icon_added_ = false;
  bool hidden_to_tray_ = false;
  bool hotkey_registered_ = false;
  bool timer_running_ = false;
  bool timer_paused_ = false;
};

#endif  // RUNNER_DESKTOP_INTEGRATION_H_

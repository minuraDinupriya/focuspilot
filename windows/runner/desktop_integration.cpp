#include "desktop_integration.h"

#include <flutter/standard_method_codec.h>
#include <windowsx.h>

#include <utility>

#include "resource.h"

namespace {

constexpr UINT kTrayCallback = WM_APP + 10;
constexpr UINT kTrayIconId = 1;
constexpr int kShowWindowHotkey = 1;
constexpr int kShowWindow = 1;
constexpr int kTogglePause = 2;
constexpr int kExit = 3;

std::wstring FromUtf8(const std::string& text) {
  const int length = MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS,
                                         text.c_str(), -1, nullptr, 0);
  if (length <= 0) {
    return {};
  }
  std::wstring wide(static_cast<size_t>(length), L'\0');
  if (MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, text.c_str(), -1,
                          wide.data(), length) == 0) {
    return {};
  }
  wide.pop_back();
  return wide;
}

template <class Value>
const Value* Argument(const flutter::EncodableValue* arguments,
                      const char* key) {
  const auto* map = std::get_if<flutter::EncodableMap>(arguments);
  if (!map) {
    return nullptr;
  }
  const auto item = map->find(flutter::EncodableValue(key));
  return item == map->end() ? nullptr : std::get_if<Value>(&item->second);
}

}  // namespace

DesktopIntegration::DesktopIntegration(HWND window,
                                       flutter::BinaryMessenger* messenger)
    : window_(window),
      channel_(messenger, "focuspilot/desktop",
               &flutter::StandardMethodCodec::GetInstance()),
      taskbar_created_message_(RegisterWindowMessageW(L"TaskbarCreated")) {
  channel_.SetMethodCallHandler([this](const auto& call, auto result) {
    HandleMethodCall(call, std::move(result));
  });
}

DesktopIntegration::~DesktopIntegration() {
  channel_.SetMethodCallHandler(nullptr);
  if (hotkey_registered_) {
    UnregisterHotKey(window_, kShowWindowHotkey);
  }
  RemoveTrayIcon();
}

void DesktopIntegration::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  bool success;
  if (call.method_name() == "hideToTray") {
    success = HideToTray();
  } else if (call.method_name() == "updateTray") {
    const auto* status = Argument<std::string>(call.arguments(), "status");
    const auto* running = Argument<bool>(call.arguments(), "isRunning");
    const auto* paused = Argument<bool>(call.arguments(), "isPaused");
    if (!status || !running || !paused) {
      result->Error("invalid_arguments", "Expected tray status and timer state.");
      return;
    }
    success = UpdateTray(FromUtf8(*status), *running, *paused);
  } else if (call.method_name() == "showIntervalEnded") {
    const auto* title = Argument<std::string>(call.arguments(), "title");
    const auto* body = Argument<std::string>(call.arguments(), "body");
    if (!title || !body) {
      result->Error("invalid_arguments", "Expected notification title and body.");
      return;
    }
    success = ShowIntervalEnded(FromUtf8(*title), FromUtf8(*body));
  } else {
    result->NotImplemented();
    return;
  }

  if (success) {
    result->Success();
  } else {
    result->Error("desktop_operation_failed",
                  "Windows could not complete the desktop operation.");
  }
}

NOTIFYICONDATAW DesktopIntegration::TrayIconData() const {
  NOTIFYICONDATAW icon{};
  icon.cbSize = sizeof(icon);
  icon.hWnd = window_;
  icon.uID = kTrayIconId;
  return icon;
}

bool DesktopIntegration::EnsureTrayIcon() {
  if (tray_icon_added_) {
    return true;
  }

  auto icon = TrayIconData();
  icon.uFlags = NIF_MESSAGE | NIF_ICON | NIF_TIP | NIF_SHOWTIP;
  icon.uCallbackMessage = kTrayCallback;
  icon.hIcon = LoadIconW(GetModuleHandleW(nullptr), MAKEINTRESOURCEW(IDI_APP_ICON));
  if (!icon.hIcon) {
    return false;
  }
  wcsncpy_s(icon.szTip, status_.c_str(), _TRUNCATE);
  if (!Shell_NotifyIconW(NIM_ADD, &icon)) {
    return false;
  }

  tray_icon_added_ = true;
  icon.uVersion = NOTIFYICON_VERSION_4;
  if (!Shell_NotifyIconW(NIM_SETVERSION, &icon)) {
    RemoveTrayIcon();
    return false;
  }
  return true;
}

void DesktopIntegration::RemoveTrayIcon() {
  if (!tray_icon_added_) {
    return;
  }
  auto icon = TrayIconData();
  Shell_NotifyIconW(NIM_DELETE, &icon);
  tray_icon_added_ = false;
}

bool DesktopIntegration::HideToTray() {
  if (hidden_to_tray_) {
    return true;
  }
  if (!EnsureTrayIcon()) {
    return false;
  }

  // Register the global shortcut only while the user has chosen to hide the
  // window. A shortcut conflict still leaves the tray icon available.
  hotkey_registered_ =
      RegisterHotKey(window_, kShowWindowHotkey,
                     MOD_CONTROL | MOD_ALT | MOD_SHIFT | MOD_NOREPEAT, 'P') !=
      FALSE;
  hidden_to_tray_ = true;
  ShowWindow(window_, SW_HIDE);
  return true;
}

void DesktopIntegration::RestoreWindow() {
  if (hotkey_registered_) {
    UnregisterHotKey(window_, kShowWindowHotkey);
    hotkey_registered_ = false;
  }
  hidden_to_tray_ = false;
  ShowWindow(window_, IsIconic(window_) ? SW_RESTORE : SW_SHOW);
  SetForegroundWindow(window_);
  RemoveTrayIcon();
  channel_.InvokeMethod("shown", nullptr);
}

bool DesktopIntegration::UpdateTray(std::wstring status, bool is_running,
                                    bool is_paused) {
  status_ = status.empty() ? L"FocusPilot" : std::move(status);
  timer_running_ = is_running;
  timer_paused_ = is_paused;
  if (!tray_icon_added_) {
    return true;
  }
  auto icon = TrayIconData();
  icon.uFlags = NIF_TIP | NIF_SHOWTIP;
  wcsncpy_s(icon.szTip, status_.c_str(), _TRUNCATE);
  return Shell_NotifyIconW(NIM_MODIFY, &icon) != FALSE;
}

bool DesktopIntegration::ShowIntervalEnded(const std::wstring& title,
                                           const std::wstring& body) {
  if (!EnsureTrayIcon()) {
    return false;
  }
  auto icon = TrayIconData();
  icon.uFlags = NIF_INFO;
  icon.dwInfoFlags = NIIF_INFO | NIIF_NOSOUND | NIIF_RESPECT_QUIET_TIME;
  wcsncpy_s(icon.szInfoTitle, title.c_str(), _TRUNCATE);
  wcsncpy_s(icon.szInfo, body.c_str(), _TRUNCATE);
  if (Shell_NotifyIconW(NIM_MODIFY, &icon)) {
    return true;
  }
  if (!hidden_to_tray_) {
    RemoveTrayIcon();
  }
  return false;
}

void DesktopIntegration::ShowTrayMenu(POINT position) {
  const HMENU menu = CreatePopupMenu();
  if (!menu) {
    return;
  }
  AppendMenuW(menu, MF_STRING | MF_GRAYED, 0, status_.c_str());
  AppendMenuW(menu, MF_SEPARATOR, 0, nullptr);
  AppendMenuW(menu, MF_STRING, kShowWindow, L"Show FocusPilot");
  if (timer_running_ || timer_paused_) {
    AppendMenuW(menu, MF_STRING, kTogglePause,
                timer_paused_ ? L"Resume timer" : L"Pause timer");
  }
  AppendMenuW(menu, MF_STRING, kExit, L"Exit FocusPilot");
  const HWND window = window_;
  SetForegroundWindow(window);
  const auto selected =
      TrackPopupMenu(menu, TPM_RETURNCMD | TPM_RIGHTBUTTON | TPM_NONOTIFY,
                     position.x, position.y, 0, window, nullptr);
  DestroyMenu(menu);
  // The menu runs a nested message loop and the window can close while it is
  // open. Check the saved handle before accessing members again.
  if (!IsWindow(window)) {
    return;
  }
  PostMessageW(window, WM_NULL, 0, 0);

  switch (selected) {
    case kShowWindow:
      RestoreWindow();
      break;
    case kTogglePause:
      channel_.InvokeMethod("togglePause", nullptr);
      break;
    case kExit:
      PostMessageW(window_, WM_CLOSE, 0, 0);
      break;
  }
}

std::optional<LRESULT> DesktopIntegration::HandleMessage(UINT message,
                                                        WPARAM wparam,
                                                        LPARAM lparam) {
  if (taskbar_created_message_ != 0 && message == taskbar_created_message_) {
    tray_icon_added_ = false;
    if (hidden_to_tray_ && !EnsureTrayIcon()) {
      RestoreWindow();
    }
    return 0;
  }
  if (message == WM_HOTKEY && wparam == kShowWindowHotkey &&
      hotkey_registered_) {
    RestoreWindow();
    return 0;
  }
  if (message == WM_POWERBROADCAST && wparam == PBT_APMRESUMEAUTOMATIC) {
    // Reconcile elapsed time even if the window remains hidden after sleep.
    channel_.InvokeMethod("shown", nullptr);
  }
  if (message != kTrayCallback || HIWORD(lparam) != kTrayIconId) {
    return std::nullopt;
  }

  switch (LOWORD(lparam)) {
    case WM_CONTEXTMENU:
      ShowTrayMenu(POINT{GET_X_LPARAM(wparam), GET_Y_LPARAM(wparam)});
      break;
    case NIN_SELECT:
    case NIN_KEYSELECT:
    case NIN_BALLOONUSERCLICK:
      RestoreWindow();
      break;
    case NIN_BALLOONHIDE:
    case NIN_BALLOONTIMEOUT:
      if (!hidden_to_tray_) {
        RemoveTrayIcon();
      }
      break;
  }
  return 0;
}

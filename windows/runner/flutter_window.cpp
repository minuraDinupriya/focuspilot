#include "flutter_window.h"

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <algorithm>

#include "flutter/generated_plugin_registrant.h"

namespace {

constexpr int kMiniTimerWidth = 350;
constexpr int kMiniTimerHeight = 260;
constexpr int kMiniTimerMargin = 16;

std::optional<RECT> MiniTimerBounds(HWND window) {
  MONITORINFO monitor_info{};
  monitor_info.cbSize = sizeof(monitor_info);
  const HMONITOR monitor =
      MonitorFromWindow(window, MONITOR_DEFAULTTONEAREST);
  if (!GetMonitorInfo(monitor, &monitor_info)) {
    return std::nullopt;
  }

  const UINT dpi = GetDpiForWindow(window);
  if (dpi == 0) {
    return std::nullopt;
  }

  RECT frame{0, 0, MulDiv(kMiniTimerWidth, dpi, USER_DEFAULT_SCREEN_DPI),
             MulDiv(kMiniTimerHeight, dpi, USER_DEFAULT_SCREEN_DPI)};
  const auto style = static_cast<DWORD>(GetWindowLongPtr(window, GWL_STYLE));
  const auto extended_style =
      static_cast<DWORD>(GetWindowLongPtr(window, GWL_EXSTYLE));
  if (!AdjustWindowRectExForDpi(&frame, style, FALSE, extended_style, dpi)) {
    return std::nullopt;
  }

  const RECT& work_area = monitor_info.rcWork;
  const LONG margin = MulDiv(kMiniTimerMargin, dpi, USER_DEFAULT_SCREEN_DPI);
  const LONG width =
      std::min(frame.right - frame.left, work_area.right - work_area.left);
  const LONG height =
      std::min(frame.bottom - frame.top, work_area.bottom - work_area.top);
  const LONG x = std::max(work_area.left, work_area.right - width - margin);
  const LONG y = std::max(work_area.top, work_area.bottom - height - margin);
  return RECT{x, y, x + width, y + height};
}

bool SetTopmost(HWND window, bool topmost) {
  return SetWindowPos(window, topmost ? HWND_TOPMOST : HWND_NOTOPMOST, 0, 0, 0,
                      0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE |
                             SWP_NOOWNERZORDER) != FALSE;
}

}  // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter::MethodChannel<flutter::EncodableValue> mini_timer_channel(
      flutter_controller_->engine()->messenger(), "focuspilot/mini_timer",
      &flutter::StandardMethodCodec::GetInstance());
  mini_timer_channel.SetMethodCallHandler(
      [this](const auto& call, auto result) {
        if (call.method_name() != "setEnabled") {
          result->NotImplemented();
          return;
        }
        const auto* enabled = std::get_if<bool>(call.arguments());
        if (!enabled) {
          result->Error("invalid_argument", "Expected a boolean.");
        } else if (!SetMiniTimerEnabled(*enabled)) {
          result->Error("window_operation_failed",
                        "Unable to change the focus timer window.");
        } else {
          result->Success();
        }
      });

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

bool FlutterWindow::SetMiniTimerEnabled(bool enabled) {
  if (enabled == window_before_mini_timer_.has_value()) {
    return true;
  }
  const HWND window = GetHandle();
  if (!window) {
    return false;
  }

  if (!enabled) {
    const auto& previous = *window_before_mini_timer_;
    if (!SetTopmost(window, previous.topmost)) {
      return false;
    }
    if (!SetWindowPlacement(window, &previous.placement)) {
      SetTopmost(window, true);
      return false;
    }
    window_before_mini_timer_.reset();
    return true;
  }

  SavedWindowState previous;
  previous.placement.length = sizeof(previous.placement);
  if (!GetWindowPlacement(window, &previous.placement)) {
    return false;
  }
  previous.topmost = (GetWindowLongPtr(window, GWL_EXSTYLE) & WS_EX_TOPMOST) != 0;
  const auto bounds = MiniTimerBounds(window);
  if (!bounds) {
    return false;
  }

  if (IsZoomed(window) || IsIconic(window)) {
    ShowWindow(window, SW_RESTORE);
  }
  if (!SetWindowPos(window, HWND_TOPMOST, bounds->left, bounds->top,
                    bounds->right - bounds->left, bounds->bottom - bounds->top,
                    SWP_NOACTIVATE | SWP_NOOWNERZORDER)) {
    SetWindowPlacement(window, &previous.placement);
    return false;
  }
  window_before_mini_timer_ = previous;
  return true;
}

void FlutterWindow::OnDestroy() {
  window_before_mini_timer_.reset();
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}

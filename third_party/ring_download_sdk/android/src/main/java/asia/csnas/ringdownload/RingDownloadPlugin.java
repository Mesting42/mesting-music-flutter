package asia.csnas.ringdownload;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.os.Handler;
import android.os.Looper;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/** Per-engine network adapter. No addresses, SSIDs or persistent identifiers
 * cross the channel. A failed query never authorizes sharing. */
public final class RingDownloadPlugin implements FlutterPlugin,
    MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
  private ConnectivityManager manager;
  private MethodChannel methods;
  private EventChannel events;
  private EventChannel.EventSink sink;
  private ConnectivityManager.NetworkCallback callback;
  private final Handler main = new Handler(Looper.getMainLooper());
  private int generation;

  @Override public void onAttachedToEngine(FlutterPluginBinding binding) {
    manager = (ConnectivityManager) binding.getApplicationContext()
        .getSystemService(Context.CONNECTIVITY_SERVICE);
    methods = new MethodChannel(binding.getBinaryMessenger(), "ring_download_sdk/network");
    events = new EventChannel(binding.getBinaryMessenger(), "ring_download_sdk/network_events");
    methods.setMethodCallHandler(this);
    events.setStreamHandler(this);
  }

  @Override public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    if ("getNetworkType".equals(call.method)) result.success(current());
    else result.notImplemented();
  }

  private String current() {
    try {
      if (manager == null) return "unknown";
      Network active = manager.getActiveNetwork();
      NetworkCapabilities caps = manager.getNetworkCapabilities(active);
      if (caps == null) return "unknown";
      if (caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)) {
        return caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_NOT_METERED)
            ? "wifi_unmetered" : "wifi_metered";
      }
      return caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)
          ? "cellular" : "unknown";
    } catch (RuntimeException ignored) { return "unknown"; }
  }

  @Override public void onListen(Object arguments, EventChannel.EventSink next) {
    stop();
    sink = next;
    final int owner = generation;
    if (manager != null) {
      callback = new ConnectivityManager.NetworkCallback() {
        @Override public void onAvailable(Network network) { emit(owner, next); }
        @Override public void onLost(Network network) { emit(owner, next); }
        @Override public void onCapabilitiesChanged(Network network, NetworkCapabilities caps) {
          emit(owner, next);
        }
      };
      try { manager.registerDefaultNetworkCallback(callback); }
      catch (RuntimeException ignored) { callback = null; }
    }
    next.success(current());
  }

  private void emit(int owner, EventChannel.EventSink target) {
    main.post(() -> {
      if (generation == owner && sink == target) target.success(current());
    });
  }

  private void stop() {
    generation++;
    sink = null;
    if (manager != null && callback != null) {
      try { manager.unregisterNetworkCallback(callback); }
      catch (RuntimeException ignored) { /* Already released or permission revoked. */ }
    }
    callback = null;
  }

  @Override public void onCancel(Object arguments) { stop(); }

  @Override public void onDetachedFromEngine(FlutterPluginBinding binding) {
    stop();
    methods.setMethodCallHandler(null);
    events.setStreamHandler(null);
    manager = null;
  }
}

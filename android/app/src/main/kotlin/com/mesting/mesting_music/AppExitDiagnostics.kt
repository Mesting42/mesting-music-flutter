package com.mesting.music

import android.app.ActivityManager
import android.app.ApplicationExitInfo
import android.content.Context
import android.os.Build

/** Own-process system history, queried only when local source diagnostics are enabled.
 * Do not read tombstones, traces, account data or descriptions: these can contain
 * private paths and URLs. A historical exit cannot be assigned to this build.
 */
object AppExitDiagnostics {
    fun recent(context: Context): List<Map<String, Any>> {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) return emptyList()
        return try {
            val manager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            manager.getHistoricalProcessExitReasons(context.packageName, 0, 5)
                .filter { it.processName == context.packageName }
                .mapNotNull { exit ->
                    val reason = when (exit.reason) {
                        ApplicationExitInfo.REASON_CRASH -> "java_crash"
                        ApplicationExitInfo.REASON_CRASH_NATIVE -> "native_crash"
                        ApplicationExitInfo.REASON_ANR -> "anr"
                        ApplicationExitInfo.REASON_LOW_MEMORY -> "low_memory"
                        ApplicationExitInfo.REASON_SIGNALED -> "signal"
                        ApplicationExitInfo.REASON_EXCESSIVE_RESOURCE_USAGE -> "resource_limit"
                        else -> return@mapNotNull null
                    }
                    mapOf<String, Any>(
                        "reason" to reason,
                        "timestampMs" to exit.timestamp,
                        "status" to exit.status,
                        "pssKiB" to exit.pss,
                        "rssKiB" to exit.rss,
                    )
                }
        } catch (_: RuntimeException) {
            // Vendor/OS diagnostic restrictions must never cause another crash.
            emptyList()
        }
    }
}

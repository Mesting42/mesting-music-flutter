package com.mesting.music

import android.Manifest
import android.app.Activity
import android.app.ActivityOptions
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.ComponentName
import android.content.ContentValues
import android.content.ClipData
import android.content.Context
import android.content.Intent
import android.content.res.ColorStateList
import android.content.pm.PackageManager
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.provider.MediaStore
import android.provider.Settings
import android.telephony.SubscriptionManager
import android.telephony.TelephonyManager
import androidx.core.content.FileProvider
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.view.animation.DecelerateInterpolator
import android.widget.LinearLayout
import android.widget.ImageView
import android.widget.SeekBar
import android.widget.Switch
import android.widget.TextView
import android.widget.Toast
import android.media.MediaScannerConnection
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.security.MessageDigest
import kotlin.math.abs
import kotlin.math.roundToInt

open class MainActivity : AudioServiceActivity() {
    private lateinit var lyricsChannel: MethodChannel
    private var secureScreenRequests = 0
    private var pendingImageSave: PendingImageSave? = null
    private var pendingPhoneNumberResult: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestHighRefreshRate()
    }

    override fun onResume() {
        super.onResume()
        requestHighRefreshRate()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        lyricsChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            LYRICS_CHANNEL,
        )
        LyricsOverlayController.attach(this) { action ->
            lyricsChannel.invokeMethod("overlayAction", action)
        }
        lyricsChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "canDrawOverlays" -> result.success(canDrawOverlays())
                "requestPermission" -> {
                    requestOverlayPermission()
                    result.success(null)
                }
                "requestPermissionFromNotification" -> result.success(
                    requestOverlayPermissionFromNotification(),
                )
                "show" -> result.success(
                    if (canDrawOverlays()) {
                        LyricsOverlayController.show(call)
                        true
                    } else {
                        false
                    },
                )
                "hide" -> {
                    LyricsOverlayController.hide()
                    result.success(null)
                }
                "update" -> {
                    LyricsOverlayController.update(call)
                    result.success(null)
                }
                "isVisible" -> result.success(LyricsOverlayController.isVisible)
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SYSTEM_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "bringAppToFront" -> {
                    packageManager.getLaunchIntentForPackage(packageName)?.let { intent ->
                        intent.addFlags(
                            Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or
                                Intent.FLAG_ACTIVITY_NEW_TASK,
                        )
                        startActivity(intent)
                    }
                    result.success(null)
                }
                "notificationPermissionGranted" -> result.success(notificationPermissionGranted())
                "requestNotificationPermission" -> {
                    requestNotificationPermission()
                    result.success(null)
                }
                "showSocialNotification" -> {
                    val id = call.argument<Int>("id")
                    val title = call.argument<String>("title")
                    val body = call.argument<String>("body")
                    if (id == null || title.isNullOrBlank() || body.isNullOrBlank()) {
                        result.error("invalid_social_notification", "消息通知内容不完整", null)
                    } else {
                        result.success(showSocialNotification(id, title, body))
                    }
                }
                "enterSecureScreen" -> {
                    secureScreenRequests += 1
                    window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    result.success(null)
                }
                "exitSecureScreen" -> {
                    secureScreenRequests = (secureScreenRequests - 1).coerceAtLeast(0)
                    if (secureScreenRequests == 0) {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            DEVICE_IDENTITY_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDataSimPhoneNumber" -> requestDataSimPhoneNumber(result)
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            BRAND_STYLE_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getBrandStyle" -> result.success(currentBrandStyle())
                "queueBrandStyle" -> {
                    val style = call.argument<String>("style")
                    if (style == null || !queueBrandStyle(style)) {
                        result.error("invalid_brand_style", "未知的装扮品牌套装", null)
                    } else {
                        result.success(null)
                    }
                }
                "applyQueuedBrandStyle" -> {
                    Thread(
                        {
                            val applied = applyPendingBrandStyle()
                            runOnUiThread {
                                result.success(applied)
                            }
                        },
                        "brand-style-apply",
                    ).start()
                }
                "setLaunchThemeMode" -> {
                    val mode = call.argument<String>("mode")
                    val updateLauncher =
                        call.argument<Boolean>("updateLauncher") ?: true
                    if (mode == null || !setLaunchThemeMode(mode, updateLauncher)) {
                        result.error("invalid_launch_theme", "未知的启动页主题模式", null)
                    } else {
                        result.success(null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SHARE_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "shareText" -> {
                    val text = call.argument<String>("text")?.trim()
                    if (text.isNullOrEmpty()) {
                        result.error("invalid_text", "分享内容不能为空", null)
                    } else {
                        val title = call.argument<String>("title") ?: "分享"
                        val intent = Intent(Intent.ACTION_SEND).apply {
                            type = "text/plain"
                            putExtra(Intent.EXTRA_TEXT, text)
                        }
                        startActivity(Intent.createChooser(intent, title))
                        result.success(null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            MEDIA_LIBRARY_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveImage" -> handleSaveImage(call, result)
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            APP_UPDATE_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAppInfo" -> result.success(currentAppInfo())
                "canRequestPackageInstalls" -> result.success(canRequestPackageInstalls())
                "openInstallPermission" -> openInstallPermission(result)
                "installApk" -> installApk(call, result)
                "installExternalApk" -> installExternalApk(call, result)
                else -> result.notImplemented()
            }
        }
    }

    @Suppress("DEPRECATION")
    private fun currentAppInfo(): Map<String, Any> {
        val info = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.getPackageInfo(
                packageName,
                PackageManager.PackageInfoFlags.of(0),
            )
        } else {
            packageManager.getPackageInfo(packageName, 0)
        }
        return mapOf(
            "packageName" to packageName,
            "versionName" to (info.versionName ?: ""),
            "versionCode" to packageVersionCode(info),
        )
    }

    private fun canRequestPackageInstalls(): Boolean {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.O ||
            packageManager.canRequestPackageInstalls()
    }

    private fun openInstallPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            result.success(null)
            return
        }
        val intent = Intent(
            Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
            Uri.parse("package:$packageName"),
        )
        runCatching { startActivity(intent) }
            .onSuccess { result.success(null) }
            .onFailure {
                result.error("permission_settings_unavailable", "无法打开安装权限设置", null)
            }
    }

    private fun installApk(call: MethodCall, result: MethodChannel.Result) {
        val requestedPath = call.argument<String>("path")
        if (requestedPath.isNullOrBlank()) {
            result.error("invalid_path", "安装包路径无效", null)
            return
        }
        val file = runCatching { File(requestedPath).canonicalFile }.getOrNull()
        val allowedRoots = listOf(cacheDir, filesDir).mapNotNull { root ->
            runCatching { File(root, "app_updates").canonicalFile }.getOrNull()
        }
        val inAllowedRoot = file != null && allowedRoots.any { root ->
            file.path.startsWith("${root.path}${File.separator}")
        }
        if (
            file == null ||
            !inAllowedRoot ||
            !file.isFile ||
            file.extension.lowercase() != "apk" ||
            file.length() <= 0 ||
            file.length() > MAX_UPDATE_APK_BYTES
        ) {
            result.error("invalid_path", "安装包路径不安全", null)
            return
        }

        val archiveInfo = archivePackageInfo(file)
        if (archiveInfo == null) {
            result.error("invalid_apk", "安装包无效", null)
            return
        }
        if (archiveInfo.packageName != packageName) {
            result.error("apk_package_mismatch", "安装包与当前应用不匹配", null)
            return
        }
        val installedInfo = installedPackageInfoWithSignatures()
        if (packageVersionCode(archiveInfo) <= packageVersionCode(installedInfo)) {
            result.error("apk_version_not_newer", "安装包版本不高于当前版本", null)
            return
        }
        if (signingDigests(archiveInfo) != signingDigests(installedInfo)) {
            result.error("apk_signature_mismatch", "安装包签名校验失败", null)
            return
        }
        if (!canRequestPackageInstalls()) {
            result.error("install_permission_required", "尚未允许安装此来源的应用", null)
            return
        }

        val uri = runCatching {
            FileProvider.getUriForFile(
                this,
                "$packageName.update_files",
                file,
            )
        }.getOrElse {
            result.error("invalid_path", "无法安全共享安装包", null)
            return
        }
        val intent = Intent(Intent.ACTION_INSTALL_PACKAGE).apply {
            data = uri
            clipData = ClipData.newRawUri("Mesting 音乐更新", uri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        runCatching { startActivity(intent) }
            .onSuccess { result.success(null) }
            .onFailure {
                result.error("installer_unavailable", "系统安装程序不可用", null)
            }
    }

    private fun installExternalApk(call: MethodCall, result: MethodChannel.Result) {
        val expectedPackageName = call.argument<String>("expectedPackageName")
        if (expectedPackageName != JAVA_MYSQL_TEST_PACKAGE) {
            result.error("invalid_package", "测试安装包标识无效", null)
            return
        }
        val requestedPath = call.argument<String>("path")
        if (requestedPath.isNullOrBlank()) {
            result.error("invalid_path", "安装包路径无效", null)
            return
        }
        val file = runCatching { File(requestedPath).canonicalFile }.getOrNull()
        val allowedRoots = listOf(cacheDir, filesDir).mapNotNull { root ->
            runCatching { File(root, "app_updates").canonicalFile }.getOrNull()
        }
        val inAllowedRoot = file != null && allowedRoots.any { root ->
            file.path.startsWith("${root.path}${File.separator}")
        }
        if (
            file == null ||
            !inAllowedRoot ||
            !file.isFile ||
            file.extension.lowercase() != "apk" ||
            file.length() <= 0 ||
            file.length() > MAX_UPDATE_APK_BYTES
        ) {
            result.error("invalid_path", "安装包路径不安全", null)
            return
        }
        val archiveInfo = archivePackageInfo(file)
        if (archiveInfo == null || archiveInfo.packageName != expectedPackageName) {
            result.error("apk_package_mismatch", "测试安装包标识不匹配", null)
            return
        }
        if (!canRequestPackageInstalls()) {
            result.error("install_permission_required", "尚未允许安装此来源的应用", null)
            return
        }
        val uri = runCatching {
            FileProvider.getUriForFile(this, "$packageName.update_files", file)
        }.getOrElse {
            result.error("invalid_path", "无法安全共享安装包", null)
            return
        }
        val intent = Intent(Intent.ACTION_INSTALL_PACKAGE).apply {
            data = uri
            clipData = ClipData.newRawUri("Java + MySQL 测试版", uri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        runCatching { startActivity(intent) }
            .onSuccess { result.success(null) }
            .onFailure {
                result.error("installer_unavailable", "系统安装程序不可用", null)
            }
    }

    @Suppress("DEPRECATION")
    private fun archivePackageInfo(file: File) = packageManager.getPackageArchiveInfo(
        file.path,
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            PackageManager.GET_SIGNING_CERTIFICATES
        } else {
            PackageManager.GET_SIGNATURES
        },
    )

    @Suppress("DEPRECATION")
    private fun installedPackageInfoWithSignatures() =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.getPackageInfo(
                packageName,
                PackageManager.PackageInfoFlags.of(
                    PackageManager.GET_SIGNING_CERTIFICATES.toLong(),
                ),
            )
        } else {
            packageManager.getPackageInfo(
                packageName,
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    PackageManager.GET_SIGNING_CERTIFICATES
                } else {
                    PackageManager.GET_SIGNATURES
                },
            )
        }

    @Suppress("DEPRECATION")
    private fun packageVersionCode(info: android.content.pm.PackageInfo): Long =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            info.longVersionCode
        } else {
            info.versionCode.toLong()
        }

    @Suppress("DEPRECATION")
    private fun signingDigests(info: android.content.pm.PackageInfo): Set<String> {
        val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            info.signingInfo?.apkContentsSigners ?: emptyArray()
        } else {
            info.signatures ?: emptyArray()
        }
        return signatures.map { signature ->
            MessageDigest.getInstance("SHA-256")
                .digest(signature.toByteArray())
                .joinToString("") { byte -> "%02x".format(byte.toInt() and 0xff) }
        }.toSet()
    }

    private fun handleSaveImage(call: MethodCall, result: MethodChannel.Result) {
        val bytes = call.argument<ByteArray>("bytes")
        val mimeType = call.argument<String>("mimeType")
        val fileName = call.argument<String>("fileName")
        val validMimeType = mimeType?.takeIf { it in SUPPORTED_IMAGE_MIME_TYPES }
        if (
            bytes == null ||
            bytes.isEmpty() ||
            bytes.size > MAX_SAVED_IMAGE_BYTES ||
            validMimeType == null ||
            fileName.isNullOrBlank()
        ) {
            result.error("invalid_image", "头像文件不可用", null)
            return
        }
        val request = PendingImageSave(
            bytes = bytes,
            mimeType = validMimeType,
            fileName = fileName.replace(Regex("[^A-Za-z0-9._-]"), "_"),
            result = result,
        )
        if (
            Build.VERSION.SDK_INT in Build.VERSION_CODES.M until Build.VERSION_CODES.Q &&
            checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) !=
                PackageManager.PERMISSION_GRANTED
        ) {
            if (pendingImageSave != null) {
                result.error("save_in_progress", "另一个头像正在保存", null)
                return
            }
            pendingImageSave = request
            requestPermissions(
                arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE),
                IMAGE_SAVE_PERMISSION_REQUEST_CODE,
            )
            return
        }
        finishImageSave(request)
    }

    private fun finishImageSave(request: PendingImageSave) {
        runCatching {
            saveImageToGallery(request.bytes, request.mimeType, request.fileName)
        }.onSuccess { uri ->
            request.result.success(uri.toString())
        }.onFailure {
            request.result.error("save_failed", "头像保存失败，请稍后重试", null)
        }
    }

    private fun saveImageToGallery(bytes: ByteArray, mimeType: String, fileName: String): Uri {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            @Suppress("DEPRECATION")
            val pictures = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
            val directory = File(pictures, "Mesting Music").apply { mkdirs() }
            val output = uniqueFile(directory, fileName)
            FileOutputStream(output).use { stream -> stream.write(bytes) }
            MediaScannerConnection.scanFile(
                this,
                arrayOf(output.absolutePath),
                arrayOf(mimeType),
                null,
            )
            return Uri.fromFile(output)
        }

        val values = ContentValues().apply {
            put(MediaStore.Images.Media.DISPLAY_NAME, fileName)
            put(MediaStore.Images.Media.MIME_TYPE, mimeType)
            put(
                MediaStore.Images.Media.RELATIVE_PATH,
                "${Environment.DIRECTORY_PICTURES}/Mesting Music",
            )
            put(MediaStore.Images.Media.IS_PENDING, 1)
        }
        val collection = MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
        val uri = contentResolver.insert(collection, values)
            ?: error("Unable to create MediaStore item")
        try {
            contentResolver.openOutputStream(uri, "w")?.use { stream ->
                stream.write(bytes)
            } ?: error("Unable to open MediaStore item")
            values.clear()
            values.put(MediaStore.Images.Media.IS_PENDING, 0)
            contentResolver.update(uri, values, null, null)
            return uri
        } catch (error: Throwable) {
            contentResolver.delete(uri, null, null)
            throw error
        }
    }

    private fun uniqueFile(directory: File, requestedName: String): File {
        var candidate = File(directory, requestedName)
        if (!candidate.exists()) return candidate
        val dot = requestedName.lastIndexOf('.')
        val base = if (dot > 0) requestedName.substring(0, dot) else requestedName
        val extension = if (dot > 0) requestedName.substring(dot) else ""
        var suffix = 2
        while (candidate.exists()) {
            candidate = File(directory, "${base}_$suffix$extension")
            suffix += 1
        }
        return candidate
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PHONE_NUMBER_PERMISSION_REQUEST_CODE) {
            val result = pendingPhoneNumberResult ?: return
            pendingPhoneNumberResult = null
            if (grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED) {
                result.success(readDataSimPhoneNumber())
            } else {
                result.success(
                    mapOf(
                        "phoneNumber" to "",
                        "maskedPhoneNumber" to "",
                        "simSlot" to 0,
                        "unavailableReason" to "permission_denied",
                    ),
                )
            }
            return
        }
        if (requestCode != IMAGE_SAVE_PERMISSION_REQUEST_CODE) return
        val request = pendingImageSave ?: return
        pendingImageSave = null
        if (grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED) {
            finishImageSave(request)
        } else {
            request.result.error("permission_denied", "需要存储权限才能保存头像", null)
        }
    }

    private fun requestDataSimPhoneNumber(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            result.success(readDataSimPhoneNumber())
            return
        }
        if (checkSelfPermission(Manifest.permission.READ_PHONE_NUMBERS) ==
            PackageManager.PERMISSION_GRANTED
        ) {
            result.success(readDataSimPhoneNumber())
            return
        }
        if (pendingPhoneNumberResult != null) {
            result.error("request_in_progress", "正在获取当前上网卡信息，请稍候", null)
            return
        }
        pendingPhoneNumberResult = result
        requestPermissions(
            arrayOf(Manifest.permission.READ_PHONE_NUMBERS),
            PHONE_NUMBER_PERMISSION_REQUEST_CODE,
        )
    }

    @Suppress("DEPRECATION")
    private fun readDataSimPhoneNumber(): Map<String, Any> {
        val subscriptionId = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            SubscriptionManager.getActiveDataSubscriptionId()
        } else {
            SubscriptionManager.getDefaultDataSubscriptionId()
        }
        if (subscriptionId == SubscriptionManager.INVALID_SUBSCRIPTION_ID) {
            return phoneNumberResult(unavailableReason = "no_active_data_sim")
        }
        val slotIndex = SubscriptionManager.getSlotIndex(subscriptionId)
        val rawNumber = runCatching {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                getSystemService(SubscriptionManager::class.java)
                    ?.getPhoneNumber(subscriptionId)
            } else {
                getSystemService(TelephonyManager::class.java)
                    ?.createForSubscriptionId(subscriptionId)
                    ?.line1Number
            }
        }.getOrNull()
        val normalized = normalizeMainlandPhoneNumber(rawNumber)
        return phoneNumberResult(
            phoneNumber = normalized,
            simSlot = if (slotIndex >= 0) slotIndex + 1 else 0,
            unavailableReason = if (normalized.isEmpty()) "number_unavailable" else "",
        )
    }

    private fun normalizeMainlandPhoneNumber(raw: String?): String {
        val digits = raw.orEmpty().filter(Char::isDigit)
        return when {
            digits.length == 11 && digits.startsWith("1") -> digits
            digits.length == 13 && digits.startsWith("86") -> digits.substring(2)
            else -> ""
        }
    }

    private fun phoneNumberResult(
        phoneNumber: String = "",
        simSlot: Int = 0,
        unavailableReason: String,
    ): Map<String, Any> {
        val masked = if (phoneNumber.length == 11) {
            "${phoneNumber.substring(0, 3)}****${phoneNumber.substring(7)}"
        } else {
            ""
        }
        return mapOf(
            "phoneNumber" to phoneNumber,
            "maskedPhoneNumber" to masked,
            "simSlot" to simSlot,
            "unavailableReason" to unavailableReason,
        )
    }

    private fun brandStyleComponents(): Map<String, List<ComponentName>> = mapOf(
        "coral" to listOf(
            launcherAlias("CoralLauncher"),
            launcherAlias("CoralLightLauncher"),
            launcherAlias("CoralDarkLauncher"),
        ),
        "morning_mist" to listOf(
            launcherAlias("MorningMistLauncher"),
        ),
        "midnight_vinyl" to listOf(
            launcherAlias("MidnightVinylLauncher"),
        ),
    )

    private fun legacyBrandStyleComponents(): Map<String, List<ComponentName>> = mapOf(
        "coral" to listOf(
            ComponentName(this, MainActivity::class.java),
            ComponentName(this, CoralLightActivity::class.java),
            ComponentName(this, CoralDarkActivity::class.java),
        ),
        "morning_mist" to listOf(
            ComponentName(this, MorningMistActivity::class.java),
        ),
        "midnight_vinyl" to listOf(
            ComponentName(this, MidnightVinylActivity::class.java),
        ),
    )

    private fun launcherAlias(name: String): ComponentName =
        ComponentName(packageName, "$packageName.$name")

    private fun currentBrandStyle(): String {
        val preferences = getSharedPreferences(
            BRAND_STYLE_PREFERENCES,
            Context.MODE_PRIVATE,
        )
        // A queued value is valid only inside the explicit selection call that
        // created it. Never carry it into a later cold start: applying an alias
        // after the launch screen has appeared makes some OEM launchers briefly
        // render both the old and new desktop icons.
        if (preferences.contains(PENDING_BRAND_STYLE)) {
            preferences.edit().remove(PENDING_BRAND_STYLE).commit()
        }
        return preferences.getString(APPLIED_BRAND_STYLE, null)
            ?.takeIf(brandStyleComponents()::containsKey)
            ?: legacyBrandStyle()
            ?: activeBrandStyle()
            ?: "coral"
    }

    private fun queueBrandStyle(style: String): Boolean {
        if (!brandStyleComponents().containsKey(style)) return false
        return getSharedPreferences(BRAND_STYLE_PREFERENCES, Context.MODE_PRIVATE)
            .edit()
            .putString(PENDING_BRAND_STYLE, style)
            .commit()
    }

    private fun applyPendingBrandStyle(): Boolean {
        val preferences = getSharedPreferences(
            BRAND_STYLE_PREFERENCES,
            Context.MODE_PRIVATE,
        )
        val pendingStyle = preferences.getString(PENDING_BRAND_STYLE, null)
        val appliedStyle = preferences.getString(APPLIED_BRAND_STYLE, null)
        val style = pendingStyle
            ?: appliedStyle?.takeIf(brandStyleComponents()::containsKey)
            ?: legacyBrandStyle()
            ?: activeBrandStyle()
            ?: "coral"
        val selected = componentForBrandStyle(style) ?: run {
            preferences.edit().remove(PENDING_BRAND_STYLE).commit()
            return false
        }
        try {
            activateBrandComponent(selected)
        } catch (_: RuntimeException) {
            // Do not retry a launcher mutation from the next cold start.
            preferences.edit().remove(PENDING_BRAND_STYLE).commit()
            return false
        }
        val enabled = brandStyleComponents().values
            .flatten()
            .filter(::isComponentEnabled)
        if (enabled.size != 1 || enabled.single() != selected) {
            preferences.edit().remove(PENDING_BRAND_STYLE).commit()
            return false
        }
        return preferences.edit()
            .putString(APPLIED_BRAND_STYLE, style)
            .remove(PENDING_BRAND_STYLE)
            .commit()
    }

    private fun activeBrandStyle(): String? =
        brandStyleComponents().entries.firstOrNull { (_, components) ->
            components.any(::isComponentEnabled)
        }?.key

    private fun legacyBrandStyle(): String? =
        legacyBrandStyleComponents().entries.firstOrNull { (_, components) ->
            components.any { component ->
                packageManager.getComponentEnabledSetting(component) ==
                    PackageManager.COMPONENT_ENABLED_STATE_ENABLED
            }
        }?.key

    private fun isComponentEnabled(component: ComponentName): Boolean =
        when (packageManager.getComponentEnabledSetting(component)) {
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED -> true
            PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
            PackageManager.COMPONENT_ENABLED_STATE_DISABLED_USER,
            PackageManager.COMPONENT_ENABLED_STATE_DISABLED_UNTIL_USED,
            -> false
            else -> try {
                packageManager.getActivityInfo(component, 0).enabled
            } catch (_: PackageManager.NameNotFoundException) {
                false
            }
        }

    private fun setLaunchThemeMode(mode: String, updateLauncher: Boolean): Boolean {
        if (mode !in setOf("light", "dark", "system")) return false
        val preferences = getSharedPreferences(
            BRAND_STYLE_PREFERENCES,
            Context.MODE_PRIVATE,
        )
        if (preferences.getString(LAUNCH_THEME_MODE, "system") == mode) {
            return true
        }
        if (!preferences.edit()
            .putString(LAUNCH_THEME_MODE, mode)
            .commit()
        ) {
            return false
        }
        if (updateLauncher && activeBrandStyle() == "coral") {
            try {
                activateBrandComponent(coralComponent(mode))
            } catch (_: RuntimeException) {
                return false
            }
        }
        return true
    }

    private fun componentForBrandStyle(style: String): ComponentName? = when (style) {
        "coral" -> coralComponent(currentLaunchThemeMode())
        "morning_mist" -> launcherAlias("MorningMistLauncher")
        "midnight_vinyl" -> launcherAlias("MidnightVinylLauncher")
        else -> null
    }

    private fun currentLaunchThemeMode(): String =
        getSharedPreferences(BRAND_STYLE_PREFERENCES, Context.MODE_PRIVATE)
            .getString(LAUNCH_THEME_MODE, "system") ?: "system"

    private fun coralComponent(mode: String): ComponentName = when (mode) {
        "light" -> launcherAlias("CoralLightLauncher")
        "dark" -> launcherAlias("CoralDarkLauncher")
        else -> launcherAlias("CoralLauncher")
    }

    private fun activateBrandComponent(selected: ComponentName) {
        val components = brandStyleComponents().values.flatten()
        val enabled = components.filter(::isComponentEnabled)
        if (enabled.size == 1 && enabled.single() == selected) return
        val updateFlags = launcherComponentUpdateFlags()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.setComponentEnabledSettings(
                components.map { component ->
                    PackageManager.ComponentEnabledSetting(
                        component,
                        if (component == selected) {
                            PackageManager.COMPONENT_ENABLED_STATE_ENABLED
                        } else {
                            PackageManager.COMPONENT_ENABLED_STATE_DISABLED
                        },
                        updateFlags,
                    )
                },
            )
            return
        }

        val previous = enabled.firstOrNull()
        try {
            components
                .filter { it != selected && isComponentEnabled(it) }
                .forEach { component ->
                    packageManager.setComponentEnabledSetting(
                        component,
                        PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                        updateFlags,
                    )
                }
            if (!isComponentEnabled(selected)) {
                packageManager.setComponentEnabledSetting(
                    selected,
                    PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                    updateFlags,
                )
            }
        } catch (error: RuntimeException) {
            if (previous != null && !isComponentEnabled(previous)) {
                packageManager.setComponentEnabledSetting(
                    previous,
                    PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                    updateFlags,
                )
            }
            throw error
        }
    }

    private fun launcherComponentUpdateFlags(): Int {
        var flags = PackageManager.DONT_KILL_APP
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            // Brand application runs on a worker thread. Persist the atomic
            // component state before reporting success so an immediate
            // SwipeUpClean cannot leave the launcher observing stale aliases.
            flags = flags or PackageManager.SYNCHRONOUS
        }
        return flags
    }

    private fun canDrawOverlays(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(this)

    private fun requestOverlayPermission() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M || canDrawOverlays()) return
        startActivity(
            Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName"),
            ),
        )
    }

    private fun requestOverlayPermissionFromNotification(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M || canDrawOverlays()) return false
        val activityIntent = Intent(
            applicationContext,
            LyricsOverlayPermissionActivity::class.java,
        ).addFlags(
            Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_CLEAR_TOP or
                Intent.FLAG_ACTIVITY_SINGLE_TOP,
        )
        val pendingIntent = PendingIntent.getActivity(
            applicationContext,
            OVERLAY_PERMISSION_REQUEST_CODE,
            activityIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        return runCatching {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                val options = ActivityOptions.makeBasic()
                @Suppress("DEPRECATION")
                val backgroundStartMode = if (Build.VERSION.SDK_INT >= 36) {
                    ActivityOptions.MODE_BACKGROUND_ACTIVITY_START_ALLOW_ALWAYS
                } else {
                    ActivityOptions.MODE_BACKGROUND_ACTIVITY_START_ALLOWED
                }
                options.setPendingIntentBackgroundActivityStartMode(backgroundStartMode)
                pendingIntent.send(
                    applicationContext,
                    0,
                    null,
                    null,
                    null,
                    null,
                    options.toBundle(),
                )
            } else {
                pendingIntent.send()
            }
        }.isSuccess
    }

    private fun notificationPermissionGranted(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED

    private fun requestNotificationPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU && !notificationPermissionGranted()) {
            requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), NOTIFICATION_REQUEST_CODE)
        }
    }

    private fun showSocialNotification(id: Int, title: String, body: String): Boolean {
        if (!notificationPermissionGranted()) return false
        val manager = getSystemService(NotificationManager::class.java) ?: return false
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            manager.createNotificationChannel(
                NotificationChannel(
                    SOCIAL_NOTIFICATION_CHANNEL,
                    "Mesting 好友消息",
                    NotificationManager.IMPORTANCE_HIGH,
                ).apply {
                    description = "好友关注、私信和音乐分享提醒"
                },
            )
        }
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)?.apply {
            addFlags(
                Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP or
                    Intent.FLAG_ACTIVITY_NEW_TASK,
            )
        } ?: return false
        val contentIntent = PendingIntent.getActivity(
            this,
            id,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val notification = NotificationCompat.Builder(this, SOCIAL_NOTIFICATION_CHANNEL)
            .setSmallIcon(R.drawable.ic_stat_social_notification)
            .setColor(Color.parseColor("#CC3F56"))
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setContentIntent(contentIntent)
            .setAutoCancel(true)
            .setCategory(NotificationCompat.CATEGORY_MESSAGE)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setVisibility(NotificationCompat.VISIBILITY_PRIVATE)
            .build()
        return runCatching {
            NotificationManagerCompat.from(this).notify(id, notification)
            true
        }.getOrDefault(false)
    }

    /**
     * Flutter follows the display vsync and can render at 90/120 Hz. Some Android
     * devices still default third-party windows to 60 Hz, so prefer the
     * highest same-resolution mode up to 120 Hz (or the next available mode)
     * and also send its refresh-rate hint to the scheduler.
     */
    @Suppress("DEPRECATION")
    private fun requestHighRefreshRate() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return
        val display = windowManager.defaultDisplay
        val activeMode = display.mode
        val sameResolutionModes = display.supportedModes.filter {
            it.physicalWidth == activeMode.physicalWidth &&
                it.physicalHeight == activeMode.physicalHeight &&
                it.refreshRate.isFinite() &&
                it.refreshRate > 0f
        }
        if (sameResolutionModes.isEmpty()) return

        val preferredMode =
            sameResolutionModes
                .filter { it.refreshRate <= TARGET_HIGH_REFRESH_RATE + REFRESH_RATE_TOLERANCE }
                .maxByOrNull { it.refreshRate }
                ?.takeIf { it.refreshRate > 60f + REFRESH_RATE_TOLERANCE }
                ?: sameResolutionModes
                    .filter { it.refreshRate > TARGET_HIGH_REFRESH_RATE + REFRESH_RATE_TOLERANCE }
                    .minByOrNull { it.refreshRate }
                ?: sameResolutionModes.maxByOrNull { it.refreshRate }
                ?: return

        val attributes = window.attributes
        if (
            attributes.preferredDisplayModeId == preferredMode.modeId &&
            abs(attributes.preferredRefreshRate - preferredMode.refreshRate) <= REFRESH_RATE_TOLERANCE
        ) {
            return
        }
        attributes.preferredDisplayModeId = preferredMode.modeId
        attributes.preferredRefreshRate = preferredMode.refreshRate
        window.attributes = attributes
    }

    companion object {
        private const val LYRICS_CHANNEL = "com.mesting.music/lyrics_overlay"
        private const val SYSTEM_CHANNEL = "com.mesting.music/system_media"
        private const val DEVICE_IDENTITY_CHANNEL = "com.mesting.music/device_identity"
        private const val BRAND_STYLE_CHANNEL = "com.mesting.music/brand_style"
        private const val BRAND_STYLE_PREFERENCES = "mesting_brand_style"
        private const val PENDING_BRAND_STYLE = "pending_brand_style"
        private const val APPLIED_BRAND_STYLE = "applied_brand_style"
        private const val LAUNCH_THEME_MODE = "launch_theme_mode"
        private const val SHARE_CHANNEL = "com.mesting.music/share"
        private const val MEDIA_LIBRARY_CHANNEL = "com.mesting.music/media_library"
        private const val APP_UPDATE_CHANNEL = "com.mesting.music/app_update"
        private const val JAVA_MYSQL_TEST_PACKAGE = "com.mesting.music.javatest"
        private const val SOCIAL_NOTIFICATION_CHANNEL = "com.mesting.music.social"
        private const val NOTIFICATION_REQUEST_CODE = 7102
        private const val IMAGE_SAVE_PERMISSION_REQUEST_CODE = 7103
        private const val PHONE_NUMBER_PERMISSION_REQUEST_CODE = 7104
        private const val OVERLAY_PERMISSION_REQUEST_CODE = 7105
        private const val MAX_SAVED_IMAGE_BYTES = 10 * 1024 * 1024
        private const val MAX_UPDATE_APK_BYTES = 350L * 1024L * 1024L
        private val SUPPORTED_IMAGE_MIME_TYPES = setOf("image/jpeg", "image/png", "image/webp")
        private const val TARGET_HIGH_REFRESH_RATE = 120f
        private const val REFRESH_RATE_TOLERANCE = 0.5f
    }
}

private data class PendingImageSave(
    val bytes: ByteArray,
    val mimeType: String,
    val fileName: String,
    val result: MethodChannel.Result,
)

class LyricsOverlayPermissionActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (canDrawOverlays()) {
            dispatchResult(true)
            return
        }
        @Suppress("DEPRECATION")
        startActivityForResult(
            Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName"),
            ),
            REQUEST_OVERLAY_PERMISSION,
        )
    }

    @Deprecated("Deprecated in Android")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_OVERLAY_PERMISSION) {
            dispatchResult(canDrawOverlays())
        }
    }

    private fun canDrawOverlays(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(this)

    private fun dispatchResult(granted: Boolean) {
        LyricsOverlayController.emitPermissionResult(granted)
        finish()
    }

    companion object {
        private const val REQUEST_OVERLAY_PERMISSION = 7201
    }
}

class MorningMistActivity : MainActivity()

class MidnightVinylActivity : MainActivity()

class CoralLightActivity : MainActivity()

class CoralDarkActivity : MainActivity()

class CoralBrandActivity : MainActivity()

class CoralLightBrandActivity : MainActivity()

class CoralDarkBrandActivity : MainActivity()

class MorningMistBrandActivity : MainActivity()

class MidnightVinylBrandActivity : MainActivity()

private object LyricsOverlayController {
    private const val COMPACT_OVERLAY_MAX_WIDTH_DP = 376
    private const val COMPACT_OVERLAY_SIDE_INSET_DP = 6
    private const val OVERLAY_DRAG_EDGE_INSET_DP = 6
    private const val SETTINGS_OVERLAY_MAX_WIDTH_DP = 360
    private const val SETTINGS_OVERLAY_SIDE_INSET_DP = 10

    private val colorPalette = intArrayOf(
        Color.WHITE,
        Color.rgb(255, 212, 92),
        Color.rgb(255, 127, 160),
        Color.rgb(112, 226, 255),
        Color.rgb(140, 255, 181),
        Color.rgb(201, 167, 255),
        Color.rgb(255, 157, 113),
        Color.rgb(126, 169, 255),
    )

    private var context: Context? = null
    private var windowManager: WindowManager? = null
    private var root: LinearLayout? = null
    private var compactContent: LinearLayout? = null
    private var compactHeader: LinearLayout? = null
    private var compactLyricsSurface: LinearLayout? = null
    private var compactDivider: View? = null
    private var compactControls: LinearLayout? = null
    private var settingsContent: LinearLayout? = null
    private var lyricStatusLabel: TextView? = null
    private var currentLine: TextView? = null
    private var nextLine: TextView? = null
    private var playButton: TextView? = null
    private var lockButton: TextView? = null
    private var settingsButton: TextView? = null
    private var favoriteButton: TextView? = null
    private var lockStateLabel: TextView? = null
    private var settingsPreview: TextView? = null
    private var fontSizeValue: TextView? = null
    private var fontSizeSeek: SeekBar? = null
    private var lockSwitch: Switch? = null
    private val colorButtons = mutableListOf<Pair<Int, TextView>>()
    private var params: WindowManager.LayoutParams? = null
    private var actionSink: ((Map<String, Any>) -> Unit)? = null
    private var locked = false
    private var fontSize = 17f
    private var textColor = Color.WHITE
    private var controlsExpanded = false
    private var settingsExpanded = false
    private var syncingSettingsControls = false
    private var playing = false
    private var favorite = false
    private var displayedCurrentLine = ""
    private var displayedNextLine = ""
    private var lyricAnimationGeneration = 0L
    var isVisible: Boolean = false
        private set

    fun attach(activity: MainActivity, sink: (Map<String, Any>) -> Unit) {
        context = activity.applicationContext
        windowManager = activity.applicationContext
            .getSystemService(Context.WINDOW_SERVICE) as WindowManager
        actionSink = sink
    }

    fun emitPermissionResult(granted: Boolean) {
        actionSink?.invoke(
            mapOf(
                "action" to "notificationPermissionResult",
                "granted" to granted,
            ),
        )
    }

    fun show(call: MethodCall) {
        if (isVisible) {
            update(call)
            return
        }
        val appContext = context ?: return
        val manager = windowManager ?: return
        var dragStartWindowX = 0
        var dragStartWindowY = 0
        var dragStartTouchX = 0f
        var dragStartTouchY = 0f
        var dragging = false
        val layout = object : LinearLayout(appContext) {
            override fun onInterceptTouchEvent(event: MotionEvent): Boolean {
                if (locked || settingsExpanded) return super.onInterceptTouchEvent(event)
                val layoutParams = params ?: return super.onInterceptTouchEvent(event)
                when (event.actionMasked) {
                    MotionEvent.ACTION_DOWN -> {
                        dragStartWindowX = layoutParams.x
                        dragStartWindowY = layoutParams.y
                        dragStartTouchX = event.rawX
                        dragStartTouchY = event.rawY
                        dragging = false
                    }
                    MotionEvent.ACTION_MOVE -> {
                        val distance = abs(event.rawX - dragStartTouchX) +
                            abs(event.rawY - dragStartTouchY)
                        if (distance >= dp(5)) {
                            dragging = true
                            return true
                        }
                    }
                }
                return false
            }

            override fun onTouchEvent(event: MotionEvent): Boolean {
                if (locked || settingsExpanded) return false
                val layoutParams = params ?: return false
                when (event.actionMasked) {
                    MotionEvent.ACTION_OUTSIDE -> {
                        if (controlsExpanded || settingsExpanded) {
                            if (settingsExpanded) setSettingsExpanded(false)
                            setControlsExpanded(false)
                        }
                        return true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        dragging = true
                        layoutParams.x = dragStartWindowX +
                            (event.rawX - dragStartTouchX).roundToInt()
                        layoutParams.y = dragStartWindowY +
                            (event.rawY - dragStartTouchY).roundToInt()
                        clampOverlayPosition(this, layoutParams)
                        windowManager?.updateViewLayout(this, layoutParams)
                    }
                    MotionEvent.ACTION_UP,
                    MotionEvent.ACTION_CANCEL -> {
                        if (!dragging && event.actionMasked == MotionEvent.ACTION_UP) {
                            performClick()
                        }
                        dragging = false
                    }
                }
                return true
            }

            override fun performClick(): Boolean = super.performClick()
        }.apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setPadding(dp(8), dp(6), dp(8), dp(6))
            setBackgroundColor(Color.TRANSPARENT)
            elevation = 0f
        }
        compactContent = buildCompactContent(appContext).also { content ->
            compactHeader = (content.getChildAt(0) as? LinearLayout)?.apply {
                visibility = View.GONE
            }
            compactDivider = content.getChildAt(2).apply {
                visibility = View.GONE
            }
            compactControls = (content.getChildAt(3) as? LinearLayout)?.apply {
                visibility = View.GONE
            }
            layout.addView(content)
        }
        settingsContent = buildSettingsContent(appContext).also {
            it.visibility = View.GONE
            layout.addView(it)
        }

        val overlayType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }
        val screenWidth = appContext.resources.displayMetrics.widthPixels
        val compactWidth = overlayWidth(
            screenWidth,
            COMPACT_OVERLAY_MAX_WIDTH_DP,
            COMPACT_OVERLAY_SIDE_INSET_DP,
        )
        params = WindowManager.LayoutParams(
            compactWidth,
            WindowManager.LayoutParams.WRAP_CONTENT,
            overlayType,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH or
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = ((screenWidth - compactWidth) / 2).coerceAtLeast(0)
            y = dp(110)
        }
        root = layout
        layout.setOnClickListener {
            if (!locked && !settingsExpanded) {
                setControlsExpanded(!controlsExpanded)
            }
        }
        manager.addView(layout, params)
        isVisible = true
        layout.post {
            params?.let { layoutParams ->
                clampOverlayPosition(layout, layoutParams)
                runCatching { manager.updateViewLayout(layout, layoutParams) }
            }
        }
        update(call)
    }

    fun update(call: MethodCall) {
        val args = call.arguments as? Map<*, *> ?: return
        updateLyricLines(
            current = args["current"] as? String ?: "Mesting 音乐",
            next = args["next"] as? String ?: "",
        )
        playing = args["playing"] as? Boolean ?: false
        favorite = args["favorite"] as? Boolean ?: favorite
        playButton?.setCompoundDrawablesRelativeWithIntrinsicBounds(
            if (playing) R.drawable.ic_overlay_pause else R.drawable.ic_overlay_play,
            0,
            0,
            0,
        )
        lyricStatusLabel?.text = if (playing) "正在播放" else "已暂停"
        val requestedLocked = args["locked"] as? Boolean ?: locked
        locked = requestedLocked
        fontSize = ((args["fontSize"] as? Number)?.toFloat() ?: fontSize).coerceIn(14f, 34f)
        val color = args["textColor"] as? String
        if (color != null) {
            runCatching { Color.parseColor(color) }.getOrNull()?.let { textColor = it }
        }
        if (locked) {
            if (settingsExpanded) setSettingsExpanded(false)
            setControlsExpanded(false)
        }
        applyAppearance()
    }

    private fun updateLyricLines(current: String, next: String) {
        val currentView = currentLine ?: return
        val nextView = nextLine ?: return
        if (displayedCurrentLine.isEmpty()) {
            displayedCurrentLine = current
            displayedNextLine = next
            currentView.text = current
            nextView.text = next
            currentView.alpha = 1f
            nextView.alpha = 1f
            currentView.translationY = 0f
            nextView.translationY = 0f
            return
        }
        if (current == displayedCurrentLine) {
            if (next != displayedNextLine) {
                displayedNextLine = next
                nextView.text = next
            }
            return
        }

        lyricAnimationGeneration += 1
        val generation = lyricAnimationGeneration
        val travel = dp(7).toFloat()
        currentView.animate().cancel()
        nextView.animate().cancel()
        nextView.animate()
            .alpha(0f)
            .translationY(-travel)
            .setDuration(LYRIC_EXIT_DURATION_MS)
            .start()
        currentView.animate()
            .alpha(0f)
            .translationY(-travel)
            .setDuration(LYRIC_EXIT_DURATION_MS)
            .withEndAction {
                if (generation != lyricAnimationGeneration) return@withEndAction
                displayedCurrentLine = current
                displayedNextLine = next
                currentView.text = current
                nextView.text = next
                settingsPreview?.text = current
                currentView.alpha = 0f
                nextView.alpha = 0f
                currentView.translationY = travel
                nextView.translationY = travel
                currentView.animate()
                    .alpha(1f)
                    .translationY(0f)
                    .setDuration(LYRIC_ENTER_DURATION_MS)
                    .setInterpolator(DecelerateInterpolator(1.35f))
                    .start()
                nextView.animate()
                    .alpha(1f)
                    .translationY(0f)
                    .setDuration(LYRIC_ENTER_DURATION_MS)
                    .setInterpolator(DecelerateInterpolator(1.35f))
                    .start()
            }
            .start()
    }

    fun hide() {
        val view = root ?: return
        lyricAnimationGeneration += 1
        currentLine?.animate()?.cancel()
        nextLine?.animate()?.cancel()
        runCatching { windowManager?.removeView(view) }
        root = null
        compactContent = null
        compactHeader = null
        compactLyricsSurface = null
        compactDivider = null
        compactControls = null
        settingsContent = null
        lyricStatusLabel = null
        currentLine = null
        nextLine = null
        playButton = null
        lockButton = null
        settingsButton = null
        favoriteButton = null
        lockStateLabel = null
        settingsPreview = null
        fontSizeValue = null
        fontSizeSeek = null
        lockSwitch = null
        colorButtons.clear()
        params = null
        controlsExpanded = false
        settingsExpanded = false
        displayedCurrentLine = ""
        displayedNextLine = ""
        isVisible = false
    }

    private fun buildCompactContent(appContext: Context) = LinearLayout(appContext).apply {
        orientation = LinearLayout.VERTICAL
        gravity = Gravity.CENTER_HORIZONTAL

        addView(
            LinearLayout(appContext).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
                addView(
                    ImageView(appContext).apply {
                        setImageResource(R.drawable.mesting_mark_foreground)
                        scaleType = ImageView.ScaleType.CENTER_INSIDE
                        setPadding(dp(6), dp(6), dp(6), dp(6))
                        contentDescription = "Mesting"
                        background = roundedBackground("#0EFFFFFF", "#2EFFFFFF", 10f)
                    },
                    LinearLayout.LayoutParams(dp(32), dp(32)).apply {
                        marginEnd = dp(10)
                    },
                )
                addView(
                    settingText(
                        appContext,
                        "Mesting Music",
                        12f,
                        Color.parseColor("#E8FFFFFF"),
                        true,
                    ).apply {
                        includeFontPadding = false
                        letterSpacing = .02f
                    },
                    LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f),
                )
                lockButton = controlButton(appContext, "", "lock").also(::addView)
                addView(controlButton(appContext, "", "close"))
            },
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,
            ),
        )

        addView(
            LinearLayout(appContext).apply {
                compactLyricsSurface = this
                orientation = LinearLayout.VERTICAL
                gravity = Gravity.CENTER_VERTICAL
                setPadding(dp(2), dp(24), dp(2), dp(17))
                setBackgroundColor(Color.TRANSPARENT)
                currentLine = lyricTextView(appContext, fontSize, true).also {
                    it.setOnClickListener {
                        if (!locked) setControlsExpanded(!controlsExpanded)
                    }
                    addView(it)
                }
                nextLine = lyricTextView(appContext, fontSize - 4f, false).also {
                    it.setOnClickListener {
                        if (!locked) setControlsExpanded(!controlsExpanded)
                    }
                    addView(
                        it,
                        LinearLayout.LayoutParams(
                            LinearLayout.LayoutParams.MATCH_PARENT,
                            LinearLayout.LayoutParams.WRAP_CONTENT,
                        ).apply { topMargin = dp(7) },
                    )
                }
            },
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,
            ).apply { topMargin = dp(5) },
        )

        addView(
            View(appContext).apply {
                background = dividerBackground()
            },
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dp(2),
            ).apply {
                marginStart = dp(48)
                marginEnd = dp(48)
            },
        )

        addView(
            LinearLayout(appContext).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
                setPadding(dp(0), dp(8), dp(0), dp(2))
                settingsButton = controlButton(appContext, "", "settings").also(::addView)
                addView(View(appContext), LinearLayout.LayoutParams(0, dp(1), 1f))
                addView(controlButton(appContext, "", "previous"))
                playButton = controlButton(appContext, "", "playPause").also(::addView)
                addView(controlButton(appContext, "", "next"))
                addView(View(appContext), LinearLayout.LayoutParams(0, dp(1), 1f))
                favoriteButton = controlButton(appContext, "", "favorite").also(::addView)
            },
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,
            ).apply { topMargin = dp(2) },
        )
    }

    private fun buildSettingsContent(appContext: Context) = LinearLayout(appContext).apply {
        orientation = LinearLayout.VERTICAL
        gravity = Gravity.CENTER_HORIZONTAL
        addView(
            LinearLayout(appContext).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
                addView(
                    LinearLayout(appContext).apply {
                        orientation = LinearLayout.VERTICAL
                        addView(settingText(appContext, "桌面歌词", 18f, Color.WHITE, true))
                        addView(settingText(appContext, "样式修改会立即生效", 11f, Color.parseColor("#8CFFFFFF")))
                    },
                    LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f),
                )
                addView(
                    settingButton(appContext, "完成") { setSettingsExpanded(false) },
                    LinearLayout.LayoutParams(dp(68), dp(38)),
                )
            },
        )

        settingsPreview = settingText(appContext, "让音乐停留在桌面", fontSize, textColor, true).also {
            it.gravity = Gravity.CENTER
            it.maxLines = 2
            it.background = gradientBackground(
                intArrayOf(
                    Color.parseColor("#D5141822"),
                    Color.parseColor("#D3121721"),
                ),
                Color.parseColor("#2891A5FF"),
                18f,
            )
            it.setPadding(dp(10), dp(12), dp(10), dp(12))
            addView(
                it,
                LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    dp(76),
                ).apply { topMargin = dp(15) },
            )
        }

        addView(
            LinearLayout(appContext).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
                addView(
                    settingText(appContext, "字体大小", 14f, Color.WHITE, true),
                    LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f),
                )
                fontSizeValue = settingText(appContext, "${fontSize.roundToInt()}px", 13f, Color.parseColor("#FF91A5FF"), true).also(::addView)
            },
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,
            ).apply { topMargin = dp(16) },
        )
        fontSizeSeek = SeekBar(appContext).also { seek ->
            seek.max = 20
            seek.progress = (fontSize - 14f).roundToInt()
            seek.progressTintList = ColorStateList.valueOf(Color.parseColor("#FF667DE0"))
            seek.thumbTintList = ColorStateList.valueOf(Color.parseColor("#FF667DE0"))
            seek.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
                override fun onProgressChanged(view: SeekBar?, progress: Int, fromUser: Boolean) {
                    if (!fromUser) return
                    fontSize = (14 + progress).toFloat()
                    applyAppearance()
                    emitSettingsChanged()
                }
                override fun onStartTrackingTouch(view: SeekBar?) = Unit
                override fun onStopTrackingTouch(view: SeekBar?) = Unit
            })
            addView(seek, LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, dp(42)))
        }

        addView(
            settingText(appContext, "字体颜色", 14f, Color.WHITE, true),
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,
            ).apply { topMargin = dp(10) },
        )
        addView(
            LinearLayout(appContext).apply {
                orientation = LinearLayout.VERTICAL
                gravity = Gravity.CENTER_HORIZONTAL
                clipChildren = false
                clipToPadding = false
                setPadding(dp(2), dp(5), dp(2), dp(2))
                colorPalette.toList().chunked(4).forEach { rowColors ->
                    addView(
                        LinearLayout(appContext).apply {
                            orientation = LinearLayout.HORIZONTAL
                            gravity = Gravity.CENTER
                            clipChildren = false
                            clipToPadding = false
                            rowColors.forEach { color ->
                                val button = TextView(appContext).apply {
                                    gravity = Gravity.CENTER
                                    includeFontPadding = false
                                    textSize = 15f
                                    setTextColor(
                                        if (color == Color.WHITE) {
                                            Color.DKGRAY
                                        } else {
                                            Color.WHITE
                                        },
                                    )
                                    contentDescription = "选择歌词颜色"
                                    setOnClickListener {
                                        textColor = color
                                        applyAppearance()
                                        emitSettingsChanged()
                                    }
                                }
                                colorButtons += color to button
                                addView(
                                    button,
                                    LinearLayout.LayoutParams(dp(34), dp(34)).apply {
                                        marginStart = dp(4)
                                        marginEnd = dp(4)
                                        topMargin = dp(3)
                                        bottomMargin = dp(3)
                                    },
                                )
                            }
                        },
                        LinearLayout.LayoutParams(
                            LinearLayout.LayoutParams.MATCH_PARENT,
                            LinearLayout.LayoutParams.WRAP_CONTENT,
                        ),
                    )
                }
            },
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,
            ),
        )

        addView(
            LinearLayout(appContext).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
                setPadding(dp(12), dp(10), dp(8), dp(10))
                background = roundedBackground("#18FFFFFF", "#18FFFFFF", 16f)
                addView(
                    LinearLayout(appContext).apply {
                        orientation = LinearLayout.VERTICAL
                        addView(settingText(appContext, "锁定桌面歌词", 14f, Color.WHITE, true))
                        addView(settingText(appContext, "锁定后防止误拖动", 10f, Color.parseColor("#80FFFFFF")))
                    },
                    LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f),
                )
                @Suppress("DEPRECATION")
                lockSwitch = Switch(appContext).also { toggle ->
                    toggle.isChecked = locked
                    toggle.buttonTintList = ColorStateList.valueOf(Color.parseColor("#FF667DE0"))
                    toggle.setOnCheckedChangeListener { _, checked ->
                        if (syncingSettingsControls) return@setOnCheckedChangeListener
                        locked = checked
                        emitSettingsChanged()
                        if (locked) {
                            setSettingsExpanded(false)
                            setControlsExpanded(false)
                        } else {
                            applyAppearance()
                        }
                    }
                    addView(toggle)
                }
            },
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,
            ).apply { topMargin = dp(16) },
        )

        addView(
            settingButton(appContext, "恢复默认样式") {
                fontSize = 17f
                textColor = Color.WHITE
                locked = false
                applyAppearance()
                emitSettingsChanged()
            },
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dp(44),
            ).apply { topMargin = dp(12) },
        )
    }

    private fun setControlsExpanded(expanded: Boolean) {
        if (expanded && locked) return
        controlsExpanded = expanded
        compactHeader?.visibility = if (expanded) View.VISIBLE else View.GONE
        compactDivider?.visibility = if (expanded) View.VISIBLE else View.GONE
        compactControls?.visibility = if (expanded) View.VISIBLE else View.GONE
        lyricStatusLabel?.visibility = View.GONE
        currentLine?.gravity = Gravity.CENTER
        nextLine?.gravity = Gravity.CENTER
        nextLine?.visibility = if (expanded) View.GONE else View.VISIBLE

        root?.apply {
            if (expanded || settingsExpanded) {
                if (settingsExpanded) {
                    setPadding(dp(12), dp(11), dp(12), dp(12))
                    background = gradientBackground(
                        intArrayOf(
                            Color.parseColor("#F51C1F29"),
                            Color.parseColor("#F5171922"),
                        ),
                        Color.parseColor("#2EFFFFFF"),
                        24f,
                    )
                    elevation = dp(12).toFloat()
                } else {
                    setPadding(dp(14), dp(12), dp(14), dp(13))
                    background = gradientBackground(
                        intArrayOf(
                            Color.parseColor("#F21B1E28"),
                            Color.parseColor("#F214161E"),
                        ),
                        Color.parseColor("#3D91A5FF"),
                        22f,
                    )
                    elevation = dp(9).toFloat()
                }
            } else {
                setPadding(dp(8), dp(6), dp(8), dp(6))
                setBackgroundColor(Color.TRANSPARENT)
                elevation = 0f
            }
        }
        // The expanded controller is one composed surface. Keeping the lyric
        // stage unboxed removes the heavy nested-card look while the toolbar
        // below still gives the controls a clear tactile boundary.
        compactLyricsSurface?.background = null

        root?.let { view ->
            params?.let { layoutParams ->
                updateOverlayLayout(view, layoutParams)
            }
        }
    }

    private fun setSettingsExpanded(expanded: Boolean) {
        if (expanded && locked) return
        if (!isVisible || settingsExpanded == expanded) return
        if (expanded) setControlsExpanded(true)
        settingsExpanded = expanded
        compactContent?.visibility = if (expanded) View.GONE else View.VISIBLE
        settingsContent?.visibility = if (expanded) View.VISIBLE else View.GONE
        val screenWidth = context?.resources?.displayMetrics?.widthPixels ?: dp(360)
        params?.width = if (expanded) {
            overlayWidth(
                screenWidth,
                SETTINGS_OVERLAY_MAX_WIDTH_DP,
                SETTINGS_OVERLAY_SIDE_INSET_DP,
            )
        } else {
            overlayWidth(
                screenWidth,
                COMPACT_OVERLAY_MAX_WIDTH_DP,
                COMPACT_OVERLAY_SIDE_INSET_DP,
            )
        }
        params?.x = ((screenWidth - (params?.width ?: screenWidth)) / 2)
            .coerceAtLeast(0)
        root?.let { view -> params?.let { updateOverlayLayout(view, it) } }
        setControlsExpanded(controlsExpanded)
        applyAppearance()
    }

    private fun updateOverlayLayout(
        view: View,
        layoutParams: WindowManager.LayoutParams,
    ) {
        clampOverlayPosition(view, layoutParams)
        runCatching { windowManager?.updateViewLayout(view, layoutParams) }
        // Expanded controls and settings change a WRAP_CONTENT window's
        // measured height. Clamp again after that layout pass so the complete
        // surface remains reachable at the bottom edge too.
        view.post {
            if (!isVisible || root !== view || params !== layoutParams) return@post
            clampOverlayPosition(view, layoutParams)
            runCatching { windowManager?.updateViewLayout(view, layoutParams) }
        }
    }

    private fun clampOverlayPosition(
        view: View,
        layoutParams: WindowManager.LayoutParams,
    ) {
        val appContext = context ?: return
        val metrics = appContext.resources.displayMetrics
        val edgeInset = dp(OVERLAY_DRAG_EDGE_INSET_DP)
        val overlayWidth = view.width.takeIf { it > 0 }
            ?: layoutParams.width.takeIf { it > 0 }
            ?: 0
        val overlayHeight = view.height.takeIf { it > 0 }
            ?: view.measuredHeight.takeIf { it > 0 }
            ?: 0
        val topInset = systemBarInset("status_bar_height") + edgeInset
        val bottomInset = systemBarInset("navigation_bar_height") + edgeInset
        val maxX = (metrics.widthPixels - overlayWidth - edgeInset)
            .coerceAtLeast(edgeInset)
        val maxY = (metrics.heightPixels - overlayHeight - bottomInset)
            .coerceAtLeast(topInset)

        layoutParams.x = layoutParams.x.coerceIn(edgeInset, maxX)
        layoutParams.y = layoutParams.y.coerceIn(topInset, maxY)
    }

    private fun systemBarInset(resourceName: String): Int {
        val resources = context?.resources ?: return 0
        val resourceId = resources.getIdentifier(resourceName, "dimen", "android")
        return if (resourceId > 0) resources.getDimensionPixelSize(resourceId) else 0
    }

    private fun overlayWidth(
        screenWidth: Int,
        maxWidthDp: Int,
        sideInsetDp: Int,
    ): Int = minOf(
        dp(maxWidthDp),
        (screenWidth - dp(sideInsetDp * 2)).coerceAtLeast(dp(1)),
    )

    private fun applyAppearance() {
        currentLine?.textSize = fontSize
        nextLine?.textSize = (fontSize - 4f).coerceAtLeast(11f)
        currentLine?.setTextColor(textColor)
        nextLine?.setTextColor((textColor and 0x00FFFFFF) or (145 shl 24))
        currentLine?.setShadowLayer(
            dp(1).toFloat(),
            0f,
            dp(1).toFloat(),
            Color.parseColor("#8F000000"),
        )
        nextLine?.setShadowLayer(
            dp(1).toFloat(),
            0f,
            dp(1).toFloat(),
            Color.parseColor("#73000000"),
        )
        settingsPreview?.text = currentLine?.text ?: "让音乐停留在桌面"
        settingsPreview?.textSize = fontSize
        settingsPreview?.setTextColor(textColor)
        fontSizeValue?.text = "${fontSize.roundToInt()}px"
        lockButton?.background = if (locked) {
            roundedBackground("#426C82EA", "#6491A5FF", 999f)
        } else {
            roundedBackground("#00000000", "#00000000", 999f)
        }
        lockButton?.setCompoundDrawablesRelativeWithIntrinsicBounds(
            if (locked) R.drawable.ic_overlay_lock else R.drawable.ic_overlay_unlock,
            0,
            0,
            0,
        )
        lockButton?.contentDescription =
            if (locked) "桌面歌词已锁定" else "锁定桌面歌词"
        lockStateLabel?.text = if (locked) "已锁定" else "可拖动"
        lockStateLabel?.setTextColor(
            if (locked) Color.parseColor("#FF9EB0FF") else Color.parseColor("#CCFFFFFF"),
        )
        lockStateLabel?.background = null
        settingsButton?.isEnabled = !locked
        settingsButton?.alpha = if (locked) .28f else 1f
        favoriteButton?.setCompoundDrawablesRelativeWithIntrinsicBounds(
            if (favorite) {
                R.drawable.ic_overlay_favorite_filled
            } else {
                R.drawable.ic_overlay_favorite
            },
            0,
            0,
            0,
        )
        favoriteButton?.compoundDrawableTintList = ColorStateList.valueOf(
            if (favorite) Color.parseColor("#FFFF8FA8") else Color.WHITE,
        )
        favoriteButton?.contentDescription =
            if (favorite) "取消收藏当前歌曲" else "收藏当前歌曲"

        syncingSettingsControls = true
        fontSizeSeek?.progress = (fontSize - 14f).roundToInt()
        lockSwitch?.isChecked = locked
        syncingSettingsControls = false
        colorButtons.forEach { (color, button) ->
            val selected = (color and 0x00FFFFFF) == (textColor and 0x00FFFFFF)
            button.text = if (selected) "✓" else ""
            button.background = colorDotBackground(color, selected)
        }

        val layoutParams = params
        val overlay = root
        if (layoutParams != null && overlay != null) {
            layoutParams.flags = if (locked) {
                layoutParams.flags or WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE
            } else {
                layoutParams.flags and WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE.inv()
            }
            runCatching { windowManager?.updateViewLayout(overlay, layoutParams) }
        }
    }

    private fun emitAction(action: String) {
        actionSink?.invoke(mapOf("action" to action))
    }

    private fun emitSettingsChanged() {
        actionSink?.invoke(
            mapOf(
                "action" to "settingsChanged",
                "fontSize" to fontSize.toDouble(),
                "textColor" to String.format("#%08X", textColor.toLong() and 0xFFFFFFFFL),
                "locked" to locked,
            ),
        )
    }

    private fun lyricTextView(appContext: Context, size: Float, bold: Boolean) =
        TextView(appContext).apply {
            textSize = size
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            maxLines = 2
            includeFontPadding = false
            setLineSpacing(dp(2).toFloat(), 1.04f)
            typeface = if (bold) Typeface.DEFAULT_BOLD else Typeface.DEFAULT
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,
            )
        }

    private fun controlButton(appContext: Context, label: String, action: String) =
        TextView(appContext).apply {
            text = label
            textSize = 1f
            gravity = Gravity.CENTER
            setTextColor(Color.WHITE)
            typeface = Typeface.DEFAULT_BOLD
            includeFontPadding = false
            setCompoundDrawablesRelativeWithIntrinsicBounds(
                when (action) {
                    "previous" -> R.drawable.ic_overlay_previous
                    "playPause" -> if (playing) {
                        R.drawable.ic_overlay_pause
                    } else {
                        R.drawable.ic_overlay_play
                    }
                    "next" -> R.drawable.ic_overlay_next
                    "settings" -> R.drawable.ic_overlay_settings
                    "favorite" -> if (favorite) {
                        R.drawable.ic_overlay_favorite_filled
                    } else {
                        R.drawable.ic_overlay_favorite
                    }
                    "lock" -> if (locked) {
                        R.drawable.ic_overlay_lock
                    } else {
                        R.drawable.ic_overlay_unlock
                    }
                    "close" -> R.drawable.ic_overlay_close
                    else -> 0
                },
                0,
                0,
                0,
            )
            compoundDrawableTintList = ColorStateList.valueOf(
                when (action) {
                    "favorite" -> if (favorite) {
                        Color.parseColor("#FFFF8FA8")
                    } else {
                        Color.WHITE
                    }
                    else -> Color.WHITE
                },
            )
            contentDescription = when (action) {
                "previous" -> "上一首"
                "playPause" -> "播放或暂停"
                "next" -> "下一首"
                "settings" -> "设置歌词字体大小和颜色"
                "favorite" -> if (favorite) "取消收藏当前歌曲" else "收藏当前歌曲"
                "lock" -> "锁定桌面歌词"
                "close" -> "关闭桌面歌词"
                else -> action
            }
            background = roundedBackground("#00000000", "#00000000", 999f)
            layoutParams = LinearLayout.LayoutParams(
                dp(if (action == "playPause") 50 else 48),
                dp(if (action == "playPause") 50 else 48),
            ).apply {
                marginStart = dp(if (action == "playPause") 3 else 1)
                marginEnd = dp(if (action == "playPause") 3 else 1)
            }
            setOnTouchListener { view, event ->
                when (event.actionMasked) {
                    MotionEvent.ACTION_DOWN -> view.animate()
                        .scaleX(.93f)
                        .scaleY(.93f)
                        .alpha(.72f)
                        .setDuration(70L)
                        .start()
                    MotionEvent.ACTION_UP,
                    MotionEvent.ACTION_CANCEL -> view.animate()
                        .scaleX(1f)
                        .scaleY(1f)
                        .alpha(1f)
                        .setDuration(140L)
                        .start()
                }
                false
            }
            setOnClickListener {
                when (action) {
                    "close" -> {
                        emitAction(action)
                        hide()
                    }
                    "settings" -> if (!locked) setSettingsExpanded(true)
                    "favorite" -> emitAction("toggleFavorite")
                    "lock" -> {
                        if (!locked) {
                            locked = true
                            emitSettingsChanged()
                            if (settingsExpanded) setSettingsExpanded(false)
                            setControlsExpanded(false)
                            Toast.makeText(
                                appContext,
                                "桌面歌词已锁定，可在灵动岛或通知中心的音乐面板中点击“词”解锁",
                                Toast.LENGTH_LONG,
                            ).show()
                            applyAppearance()
                        }
                    }
                    else -> emitAction(action)
                }
            }
        }

    private fun settingText(
        appContext: Context,
        label: String,
        size: Float,
        color: Int,
        bold: Boolean = false,
    ) = TextView(appContext).apply {
        text = label
        textSize = size
        setTextColor(color)
        typeface = if (bold) Typeface.DEFAULT_BOLD else Typeface.DEFAULT
    }

    private fun settingButton(appContext: Context, label: String, onClick: () -> Unit) =
        TextView(appContext).apply {
            text = label
            textSize = 13f
            gravity = Gravity.CENTER
            setTextColor(Color.WHITE)
            typeface = Typeface.DEFAULT_BOLD
            background = roundedBackground("#22FFFFFF", "#28FFFFFF", 999f)
            setOnClickListener { onClick() }
        }

    private fun colorDotBackground(color: Int, selected: Boolean) = GradientDrawable().apply {
        shape = GradientDrawable.OVAL
        setColor(color)
        setStroke(dp(if (selected) 3 else 1), if (selected) Color.WHITE else Color.parseColor("#35FFFFFF"))
    }

    private fun roundedBackground(fill: String, stroke: String, radius: Float) =
        GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            cornerRadius = dp(radius.roundToInt()).toFloat()
            setColor(Color.parseColor(fill))
            setStroke(dp(1), Color.parseColor(stroke))
        }

    private fun gradientBackground(colors: IntArray, stroke: Int, radius: Float) =
        GradientDrawable(GradientDrawable.Orientation.TL_BR, colors).apply {
            shape = GradientDrawable.RECTANGLE
            cornerRadius = dp(radius.roundToInt()).toFloat()
            setStroke(dp(1), stroke)
        }

    private fun dividerBackground() = GradientDrawable(
        GradientDrawable.Orientation.LEFT_RIGHT,
        intArrayOf(
            Color.parseColor("#00FFFFFF"),
            Color.parseColor("#607790FF"),
            Color.parseColor("#00FFFFFF"),
        ),
    )

    private fun dp(value: Int): Int {
        val density = context?.resources?.displayMetrics?.density ?: 1f
        return (value * density).roundToInt()
    }

    private const val LYRIC_EXIT_DURATION_MS = 120L
    private const val LYRIC_ENTER_DURATION_MS = 220L
}

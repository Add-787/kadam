package com.psyluck.kadam

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.StepsRecord
import androidx.health.connect.client.records.DistanceRecord
import androidx.health.connect.client.records.ActiveCaloriesBurnedRecord
import androidx.health.connect.client.records.HeartRateRecord
import androidx.health.connect.client.request.ReadRecordsRequest
import androidx.health.connect.client.request.AggregateRequest
import androidx.health.connect.client.time.TimeRangeFilter
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId
import java.time.ZonedDateTime
import java.util.UUID

/**
 * Health Connect Plugin for Flutter
 * 
 * Integrates with Health Connect API to read health data
 * from multiple sources (Samsung Health, Google Fit, etc.)
 */
class HealthConnectPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var healthConnectClient: HealthConnectClient? = null
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    
    companion object {
        private const val CHANNEL_NAME = "com.kadam.health/health_connect"
        
        // Required permissions
        private val PERMISSIONS = setOf(
            HealthPermission.getReadPermission(StepsRecord::class),
            HealthPermission.getReadPermission(DistanceRecord::class),
            HealthPermission.getReadPermission(ActiveCaloriesBurnedRecord::class),
            HealthPermission.getReadPermission(HeartRateRecord::class)
        )
    }
    
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        
        // Initialize Health Connect client if available
        if (HealthConnectClient.getSdkStatus(context) == HealthConnectClient.SDK_AVAILABLE) {
            healthConnectClient = HealthConnectClient.getOrCreate(context)
        }
    }
    
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        healthConnectClient = null
    }
    
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isAvailable" -> isAvailable(result)
            "isInstalled" -> isInstalled(result)
            "getSdkStatus" -> getSdkStatus(result)
            "hasPermissions" -> hasPermissions(result)
            "requestPermissions" -> requestPermissions(call, result)
            "getCapabilities" -> getCapabilities(result)
            "querySteps" -> querySteps(call, result)
            "queryDistance" -> queryDistance(call, result)
            "queryCalories" -> queryCalories(call, result)
            "queryHeartRate" -> queryHeartRate(call, result)
            "queryMultiple" -> queryMultiple(call, result)
            "getTodaySteps" -> getTodaySteps(result)
            "getDailySteps" -> getDailySteps(call, result)
            "getDailyDistance" -> getDailyDistance(call, result)
            "getDailyCalories" -> getDailyCalories(call, result)
            "aggregateSteps" -> aggregateSteps(call, result)
            "openSettings" -> openSettings(result)
            "disconnect" -> result.success(null)
            else -> result.notImplemented()
        }
    }
    
    private fun isAvailable(result: MethodChannel.Result) {
        try {
            val status = HealthConnectClient.getSdkStatus(context)
            result.success(status == HealthConnectClient.SDK_AVAILABLE)
        } catch (e: Exception) {
            result.error("AVAILABILITY_CHECK_FAILED", e.message, null)
        }
    }
    
    private fun isInstalled(result: MethodChannel.Result) {
        try {
            val status = HealthConnectClient.getSdkStatus(context)
            result.success(status != HealthConnectClient.SDK_UNAVAILABLE)
        } catch (e: Exception) {
            result.error("INSTALL_CHECK_FAILED", e.message, null)
        }
    }
    
    private fun getSdkStatus(result: MethodChannel.Result) {
        try {
            val status = when (HealthConnectClient.getSdkStatus(context)) {
                HealthConnectClient.SDK_AVAILABLE -> "available"
                HealthConnectClient.SDK_UNAVAILABLE -> "unavailable"
                HealthConnectClient.SDK_UNAVAILABLE_PROVIDER_UPDATE_REQUIRED -> "update_required"
                else -> "unknown"
            }
            result.success(status)
        } catch (e: Exception) {
            result.error("STATUS_CHECK_FAILED", e.message, null)
        }
    }
    
    private fun hasPermissions(result: MethodChannel.Result) {
        val client = healthConnectClient
        if (client == null) {
            result.success(false)
            return
        }
        
        scope.launch {
            try {
                val granted = client.permissionController.getGrantedPermissions()
                result.success(granted.containsAll(PERMISSIONS))
            } catch (e: Exception) {
                result.error("PERMISSION_CHECK_FAILED", e.message, null)
            }
        }
    }
    
    private fun requestPermissions(call: MethodCall, result: MethodChannel.Result) {
        val client = healthConnectClient
        if (client == null) {
            result.error("NOT_AVAILABLE", "Health Connect not available", null)
            return
        }
        
        // Note: Actual permission request requires Activity context
        // This should be handled via a separate Activity result launcher
        // For now, we check if permissions are already granted
        scope.launch {
            try {
                val granted = client.permissionController.getGrantedPermissions()
                if (granted.containsAll(PERMISSIONS)) {
                    result.success(true)
                } else {
                    // In production, launch permission request via Activity
                    result.error(
                        "PERMISSION_REQUEST_REQUIRED",
                        "Need to request permissions via Activity",
                        null
                    )
                }
            } catch (e: Exception) {
                result.error("PERMISSION_REQUEST_FAILED", e.message, null)
            }
        }
    }
    
    private fun getCapabilities(result: MethodChannel.Result) {
        val client = healthConnectClient
        if (client == null) {
            result.success(mapOf(
                "platform" to "health_connect",
                "isAvailable" to false,
                "isAuthorized" to false,
                "version" to "",
                "supportedDataTypes" to emptyList<String>()
            ))
            return
        }
        
        scope.launch {
            try {
                val granted = client.permissionController.getGrantedPermissions()
                val isAuthorized = granted.containsAll(PERMISSIONS)
                
                result.success(mapOf(
                    "platform" to "health_connect",
                    "isAvailable" to true,
                    "isAuthorized" to isAuthorized,
                    "version" to "1.1.0",
                    "supportedDataTypes" to listOf("steps", "distance", "calories", "heart_rate")
                ))
            } catch (e: Exception) {
                result.error("CAPABILITIES_FAILED", e.message, null)
            }
        }
    }
    
    private fun querySteps(call: MethodCall, result: MethodChannel.Result) {
        val startTime = call.argument<Long>("startTime")
        val endTime = call.argument<Long>("endTime")
        
        if (startTime == null || endTime == null) {
            result.error("INVALID_ARGS", "Missing time arguments", null)
            return
        }
        
        val client = healthConnectClient
        if (client == null) {
            result.error("NOT_AVAILABLE", "Health Connect not available", null)
            return
        }
        
        scope.launch {
            try {
                val startInstant = Instant.ofEpochMilli(startTime)
                val endInstant = Instant.ofEpochMilli(endTime)
                
                val request = ReadRecordsRequest(
                    recordType = StepsRecord::class,
                    timeRangeFilter = TimeRangeFilter.between(startInstant, endInstant)
                )
                
                val response = client.readRecords(request)
                
                val healthData = response.records.map { record ->
                    mapOf(
                        "id" to (record.metadata.id ?: UUID.randomUUID().toString()),
                        "source" to "health_connect",
                        "dataType" to "steps",
                        "value" to record.count,
                        "unit" to "count",
                        "startTime" to record.startTime.toEpochMilli(),
                        "endTime" to record.endTime.toEpochMilli(),
                        "metadata" to mapOf(
                            "dataOrigin" to record.metadata.dataOrigin.packageName,
                            "sourceApp" to getSourceAppName(record.metadata.dataOrigin.packageName)
                        )
                    )
                }
                
                result.success(healthData)
            } catch (e: Exception) {
                result.error("QUERY_FAILED", e.message, null)
            }
        }
    }
    
    private fun queryDistance(call: MethodCall, result: MethodChannel.Result) {
        val startTime = call.argument<Long>("startTime")
        val endTime = call.argument<Long>("endTime")
        
        if (startTime == null || endTime == null) {
            result.error("INVALID_ARGS", "Missing time arguments", null)
            return
        }
        
        val client = healthConnectClient
        if (client == null) {
            result.error("NOT_AVAILABLE", "Health Connect not available", null)
            return
        }
        
        scope.launch {
            try {
                val startInstant = Instant.ofEpochMilli(startTime)
                val endInstant = Instant.ofEpochMilli(endTime)
                
                val request = ReadRecordsRequest(
                    recordType = DistanceRecord::class,
                    timeRangeFilter = TimeRangeFilter.between(startInstant, endInstant)
                )
                
                val response = client.readRecords(request)
                
                val healthData = response.records.map { record ->
                    mapOf(
                        "id" to (record.metadata.id ?: UUID.randomUUID().toString()),
                        "source" to "health_connect",
                        "dataType" to "distance",
                        "value" to record.distance.inMeters,
                        "unit" to "meters",
                        "startTime" to record.startTime.toEpochMilli(),
                        "endTime" to record.endTime.toEpochMilli(),
                        "metadata" to mapOf(
                            "dataOrigin" to record.metadata.dataOrigin.packageName,
                            "sourceApp" to getSourceAppName(record.metadata.dataOrigin.packageName)
                        )
                    )
                }
                
                result.success(healthData)
            } catch (e: Exception) {
                result.error("QUERY_FAILED", e.message, null)
            }
        }
    }
    
    private fun queryCalories(call: MethodCall, result: MethodChannel.Result) {
        val startTime = call.argument<Long>("startTime")
        val endTime = call.argument<Long>("endTime")
        
        if (startTime == null || endTime == null) {
            result.error("INVALID_ARGS", "Missing time arguments", null)
            return
        }
        
        val client = healthConnectClient
        if (client == null) {
            result.error("NOT_AVAILABLE", "Health Connect not available", null)
            return
        }
        
        scope.launch {
            try {
                val startInstant = Instant.ofEpochMilli(startTime)
                val endInstant = Instant.ofEpochMilli(endTime)
                
                val request = ReadRecordsRequest(
                    recordType = ActiveCaloriesBurnedRecord::class,
                    timeRangeFilter = TimeRangeFilter.between(startInstant, endInstant)
                )
                
                val response = client.readRecords(request)
                
                val healthData = response.records.map { record ->
                    mapOf(
                        "id" to (record.metadata.id ?: UUID.randomUUID().toString()),
                        "source" to "health_connect",
                        "dataType" to "calories",
                        "value" to record.energy.inKilocalories,
                        "unit" to "kcal",
                        "startTime" to record.startTime.toEpochMilli(),
                        "endTime" to record.endTime.toEpochMilli(),
                        "metadata" to mapOf(
                            "dataOrigin" to record.metadata.dataOrigin.packageName,
                            "sourceApp" to getSourceAppName(record.metadata.dataOrigin.packageName)
                        )
                    )
                }
                
                result.success(healthData)
            } catch (e: Exception) {
                result.error("QUERY_FAILED", e.message, null)
            }
        }
    }
    
    private fun queryHeartRate(call: MethodCall, result: MethodChannel.Result) {
        val startTime = call.argument<Long>("startTime")
        val endTime = call.argument<Long>("endTime")
        
        if (startTime == null || endTime == null) {
            result.error("INVALID_ARGS", "Missing time arguments", null)
            return
        }
        
        val client = healthConnectClient
        if (client == null) {
            result.error("NOT_AVAILABLE", "Health Connect not available", null)
            return
        }
        
        scope.launch {
            try {
                val startInstant = Instant.ofEpochMilli(startTime)
                val endInstant = Instant.ofEpochMilli(endTime)
                
                val request = ReadRecordsRequest(
                    recordType = HeartRateRecord::class,
                    timeRangeFilter = TimeRangeFilter.between(startInstant, endInstant)
                )
                
                val response = client.readRecords(request)
                
                val healthData = response.records.flatMap { record ->
                    record.samples.map { sample ->
                        mapOf(
                            "id" to UUID.randomUUID().toString(),
                            "source" to "health_connect",
                            "dataType" to "heart_rate",
                            "value" to sample.beatsPerMinute,
                            "unit" to "bpm",
                            "startTime" to sample.time.toEpochMilli(),
                            "endTime" to sample.time.toEpochMilli(),
                            "metadata" to mapOf(
                                "dataOrigin" to record.metadata.dataOrigin.packageName,
                                "sourceApp" to getSourceAppName(record.metadata.dataOrigin.packageName)
                            )
                        )
                    }
                }
                
                result.success(healthData)
            } catch (e: Exception) {
                result.error("QUERY_FAILED", e.message, null)
            }
        }
    }
    
    private fun queryMultiple(call: MethodCall, result: MethodChannel.Result) {
        // For simplicity, return empty map
        // In production, implement parallel queries for each data type
        result.success(emptyMap<String, List<Map<String, Any>>>())
    }
    
    private fun getTodaySteps(result: MethodChannel.Result) {
        val today = LocalDate.now()
        val startOfDay = today.atStartOfDay(ZoneId.systemDefault())
        val now = ZonedDateTime.now()
        
        getDailyStepsInternal(startOfDay.toInstant(), now.toInstant(), result)
    }
    
    private fun getDailySteps(call: MethodCall, result: MethodChannel.Result) {
        val dateMillis = call.argument<Long>("date")
        
        if (dateMillis == null) {
            result.error("INVALID_ARGS", "Missing date argument", null)
            return
        }
        
        val date = Instant.ofEpochMilli(dateMillis)
            .atZone(ZoneId.systemDefault())
            .toLocalDate()
        
        val startOfDay = date.atStartOfDay(ZoneId.systemDefault()).toInstant()
        val endOfDay = date.plusDays(1).atStartOfDay(ZoneId.systemDefault()).toInstant()
        
        getDailyStepsInternal(startOfDay, endOfDay, result)
    }
    
    private fun getDailyStepsInternal(startInstant: Instant, endInstant: Instant, result: MethodChannel.Result) {
        val client = healthConnectClient
        if (client == null) {
            result.success(0)
            return
        }
        
        scope.launch {
            try {
                val response = client.aggregate(
                    AggregateRequest(
                        metrics = setOf(StepsRecord.COUNT_TOTAL),
                        timeRangeFilter = TimeRangeFilter.between(startInstant, endInstant)
                    )
                )
                
                val totalSteps = response[StepsRecord.COUNT_TOTAL] ?: 0L
                result.success(totalSteps.toInt())
            } catch (e: Exception) {
                result.error("QUERY_FAILED", e.message, null)
            }
        }
    }
    
    private fun getDailyDistance(call: MethodCall, result: MethodChannel.Result) {
        // Similar to getDailySteps but for distance
        result.success(0.0)
    }
    
    private fun getDailyCalories(call: MethodCall, result: MethodChannel.Result) {
        // Similar to getDailySteps but for calories
        result.success(0)
    }
    
    private fun aggregateSteps(call: MethodCall, result: MethodChannel.Result) {
        val startTime = call.argument<Long>("startTime")
        val endTime = call.argument<Long>("endTime")
        
        if (startTime == null || endTime == null) {
            result.error("INVALID_ARGS", "Missing time arguments", null)
            return
        }
        
        val client = healthConnectClient
        if (client == null) {
            result.success(mapOf("totalSteps" to 0))
            return
        }
        
        scope.launch {
            try {
                val startInstant = Instant.ofEpochMilli(startTime)
                val endInstant = Instant.ofEpochMilli(endTime)
                
                val response = client.aggregate(
                    AggregateRequest(
                        metrics = setOf(StepsRecord.COUNT_TOTAL),
                        timeRangeFilter = TimeRangeFilter.between(startInstant, endInstant)
                    )
                )
                
                val totalSteps = response[StepsRecord.COUNT_TOTAL] ?: 0L
                
                result.success(mapOf(
                    "totalSteps" to totalSteps,
                    "startTime" to startTime,
                    "endTime" to endTime
                ))
            } catch (e: Exception) {
                result.error("AGGREGATE_FAILED", e.message, null)
            }
        }
    }
    
    private fun openSettings(result: MethodChannel.Result) {
        try {
            val intent = Intent().apply {
                action = "androidx.health.ACTION_HEALTH_CONNECT_SETTINGS"
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
            result.success(null)
        } catch (e: Exception) {
            // Fallback to app settings
            try {
                val intent = Intent().apply {
                    action = android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS
                    data = Uri.fromParts("package", context.packageName, null)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                context.startActivity(intent)
                result.success(null)
            } catch (e2: Exception) {
                result.error("OPEN_SETTINGS_FAILED", e2.message, null)
            }
        }
    }
    
    private fun getSourceAppName(packageName: String): String {
        return when (packageName) {
            "com.sec.android.app.shealth" -> "Samsung Health"
            "com.google.android.apps.fitness" -> "Google Fit"
            "com.fitbit.FitbitMobile" -> "Fitbit"
            "com.mi.health" -> "Mi Fitness"
            "com.huawei.health" -> "Huawei Health"
            else -> packageName
        }
    }
}

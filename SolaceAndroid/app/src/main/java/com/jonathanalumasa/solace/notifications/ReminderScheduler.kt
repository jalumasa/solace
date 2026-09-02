package com.jonathanalumasa.solace.notifications

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.work.Constraints
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.Worker
import androidx.work.WorkerParameters
import com.jonathanalumasa.solace.MainActivity
import com.jonathanalumasa.solace.R
import java.util.Calendar
import java.util.concurrent.TimeUnit

/**
 * Schedules the daily check-in reminder. The Android counterpart of the iOS
 * `NotificationScheduler` — local and on-device rather than remote push, for
 * the same reason: there's no server component to trigger from.
 *
 * WorkManager rather than AlarmManager because the reminder is a nudge, not
 * an alarm — it doesn't need to fire at an exact second, and WorkManager
 * survives reboots and Doze without extra permissions.
 */
object ReminderScheduler {
    const val CHANNEL_ID = "daily-check-in"
    private const val WORK_NAME = "daily-check-in-reminder"

    fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Daily check-in",
            NotificationManager.IMPORTANCE_DEFAULT
        ).apply {
            description = "A gentle daily nudge to check in with how you're feeling."
        }
        context.getSystemService(NotificationManager::class.java)
            ?.createNotificationChannel(channel)
    }

    fun schedule(context: Context, hour: Int, minute: Int) {
        ensureChannel(context)

        val request = PeriodicWorkRequestBuilder<ReminderWorker>(24, TimeUnit.HOURS)
            .setInitialDelay(delayUntil(hour, minute), TimeUnit.MILLISECONDS)
            .setConstraints(Constraints.Builder().build())
            .build()

        WorkManager.getInstance(context).enqueueUniquePeriodicWork(
            WORK_NAME,
            ExistingPeriodicWorkPolicy.UPDATE,
            request
        )
    }

    fun cancel(context: Context) {
        WorkManager.getInstance(context).cancelUniqueWork(WORK_NAME)
    }

    /** Milliseconds until the next occurrence of hour:minute. */
    private fun delayUntil(hour: Int, minute: Int): Long {
        val now = Calendar.getInstance()
        val target = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, hour)
            set(Calendar.MINUTE, minute)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
            if (!after(now)) add(Calendar.DAY_OF_YEAR, 1)
        }
        return target.timeInMillis - now.timeInMillis
    }
}

class ReminderWorker(
    context: Context,
    params: WorkerParameters
) : Worker(context, params) {

    override fun doWork(): Result {
        val context = applicationContext

        // Android 13+ can revoke notification permission at any time; without
        // it, posting is a silent no-op rather than a crash.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            ActivityCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS)
            != PackageManager.PERMISSION_GRANTED
        ) {
            return Result.success()
        }

        val openApp = PendingIntent.getActivity(
            context,
            0,
            Intent(context, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val notification = NotificationCompat.Builder(context, ReminderScheduler.CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setContentTitle("Time for a check-in")
            .setContentText("Take a moment for your mood or a gratitude note.")
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setAutoCancel(true)
            .setContentIntent(openApp)
            .build()

        NotificationManagerCompat.from(context).notify(NOTIFICATION_ID, notification)
        return Result.success()
    }

    private companion object {
        const val NOTIFICATION_ID = 1001
    }
}

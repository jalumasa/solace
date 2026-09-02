package com.jonathanalumasa.solace.ui.profile

import android.Manifest
import android.os.Build
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TimePicker
import androidx.compose.material3.rememberTimePickerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import com.jonathanalumasa.solace.notifications.ReminderScheduler
import com.jonathanalumasa.solace.prefs.AppPreferences
import com.jonathanalumasa.solace.ui.shared.SolaceCard
import com.jonathanalumasa.solace.ui.theme.Spacing

/**
 * Daily check-in reminder settings, mirroring the iOS `ReminderSettingsSection`.
 * Local notification scheduled through WorkManager — see [ReminderScheduler]
 * for why it's local rather than remote push.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ReminderSettings() {
    val context = LocalContext.current
    val preferences = remember { AppPreferences(context) }

    var enabled by remember { mutableStateOf(preferences.reminderEnabled) }
    var minutes by remember { mutableIntStateOf(preferences.reminderMinutes) }
    var showPicker by remember { mutableStateOf(false) }

    fun apply(on: Boolean, atMinutes: Int) {
        preferences.reminderEnabled = on
        preferences.reminderMinutes = atMinutes
        if (on) {
            ReminderScheduler.schedule(context, atMinutes / 60, atMinutes % 60)
        } else {
            ReminderScheduler.cancel(context)
        }
    }

    // Android 13+ gates notifications behind a runtime permission; if it's
    // declined we flip the switch back rather than silently doing nothing.
    val permissionLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { granted ->
        enabled = granted
        apply(granted, minutes)
    }

    Text("Reminders", style = MaterialTheme.typography.titleSmall)
    SolaceCard {
        Row(
            Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(Modifier.weight(1f)) {
                Text("Daily check-in reminder", style = MaterialTheme.typography.bodyLarge)
                Text(
                    "A gentle nudge at a time you choose.",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            Switch(
                checked = enabled,
                onCheckedChange = { wantsOn ->
                    if (wantsOn && Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        permissionLauncher.launch(Manifest.permission.POST_NOTIFICATIONS)
                    } else {
                        enabled = wantsOn
                        apply(wantsOn, minutes)
                    }
                }
            )
        }

        if (enabled) {
            TextButton(
                onClick = { showPicker = true },
                modifier = Modifier.padding(top = Spacing.small)
            ) {
                Text("Reminder time — %02d:%02d".format(minutes / 60, minutes % 60))
            }
        }
    }

    if (showPicker) {
        val pickerState = rememberTimePickerState(
            initialHour = minutes / 60,
            initialMinute = minutes % 60,
            is24Hour = true
        )
        androidx.compose.material3.AlertDialog(
            onDismissRequest = { showPicker = false },
            confirmButton = {
                TextButton(onClick = {
                    minutes = pickerState.hour * 60 + pickerState.minute
                    apply(enabled, minutes)
                    showPicker = false
                }) { Text("Set") }
            },
            dismissButton = {
                TextButton(onClick = { showPicker = false }) { Text("Cancel") }
            },
            text = { TimePicker(state = pickerState) }
        )
    }
}

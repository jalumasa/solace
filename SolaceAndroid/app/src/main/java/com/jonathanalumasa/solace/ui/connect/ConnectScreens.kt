package com.jonathanalumasa.solace.ui.connect

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.DatePicker
import androidx.compose.material3.DatePickerDialog
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.rememberDatePickerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.jonathanalumasa.solace.model.Appointment
import com.jonathanalumasa.solace.model.AppointmentStatus
import com.jonathanalumasa.solace.model.Role
import com.jonathanalumasa.solace.model.SupportCircle
import com.jonathanalumasa.solace.model.User
import com.jonathanalumasa.solace.ui.shared.ScreenTitle
import com.jonathanalumasa.solace.ui.shared.SolaceCard
import com.jonathanalumasa.solace.ui.theme.SolaceColors
import com.jonathanalumasa.solace.ui.theme.Spacing
import com.jonathanalumasa.solace.viewmodel.AppointmentListViewModel
import com.jonathanalumasa.solace.viewmodel.CircleListViewModel
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

private val dateFormat = SimpleDateFormat("d MMM yyyy 'at' HH:mm", Locale.getDefault())

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AppointmentsScreen(currentUser: User, viewModel: AppointmentListViewModel) {
    val appointments by viewModel.appointments.collectAsStateWithLifecycle()
    val counselors by viewModel.counselors.collectAsStateWithLifecycle()
    var showRequest by remember { mutableStateOf(false) }

    Column(verticalArrangement = Arrangement.spacedBy(Spacing.large)) {
        ScreenTitle("Appointments")

        if (currentUser.role == Role.STUDENT) {
            Button(onClick = { showRequest = !showRequest }, modifier = Modifier.fillMaxWidth()) {
                Text(if (showRequest) "Close" else "Request an appointment")
            }
        }

        if (showRequest) {
            RequestAppointmentForm(
                counselors = counselors,
                onSubmit = { counselor, date ->
                    viewModel.requestAppointment(counselor, date)
                    showRequest = false
                }
            )
        }

        if (appointments.isEmpty()) {
            Text(
                if (currentUser.role == Role.STUDENT)
                    "No appointments yet. Request a time with a counselor to get started."
                else "Appointment requests from students will appear here.",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }

        Section("Pending", viewModel.pending) { appointment ->
            AppointmentRow(appointment, currentUser)
            Row(horizontalArrangement = Arrangement.spacedBy(Spacing.small)) {
                if (currentUser.role == Role.COUNSELOR) {
                    Button(onClick = {
                        viewModel.respond(appointment, AppointmentStatus.CONFIRMED)
                    }) { Text("Confirm") }
                    OutlinedButton(onClick = {
                        viewModel.respond(appointment, AppointmentStatus.DECLINED)
                    }) { Text("Decline") }
                } else {
                    OutlinedButton(onClick = { viewModel.cancel(appointment) }) {
                        Text("Cancel request")
                    }
                }
            }
        }

        Section("Upcoming", viewModel.upcoming) { appointment ->
            AppointmentRow(appointment, currentUser)
            if (currentUser.role == Role.STUDENT) {
                OutlinedButton(onClick = { viewModel.cancel(appointment) }) { Text("Cancel") }
            }
        }

        Section("Past", viewModel.past) { appointment ->
            AppointmentRow(appointment, currentUser)
        }
    }
}

@Composable
private fun Section(
    title: String,
    items: List<Appointment>,
    row: @Composable (Appointment) -> Unit
) {
    if (items.isEmpty()) return
    Text(title, style = MaterialTheme.typography.titleSmall)
    SolaceCard {
        items.forEachIndexed { index, appointment ->
            Column(Modifier.padding(vertical = Spacing.small)) { row(appointment) }
            if (index != items.lastIndex) HorizontalDivider()
        }
    }
}

@Composable
private fun AppointmentRow(appointment: Appointment, currentUser: User) {
    Column {
        Text(
            appointment.otherParticipantName(currentUser.id),
            style = MaterialTheme.typography.titleMedium
        )
        Text(
            dateFormat.format(appointment.scheduledAt),
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        if (appointment.status != AppointmentStatus.PENDING) {
            Text(
                appointment.status.label,
                style = MaterialTheme.typography.labelSmall,
                color = when (appointment.status) {
                    AppointmentStatus.CONFIRMED -> SolaceColors.Leaf
                    AppointmentStatus.PENDING -> SolaceColors.Warm
                    else -> SolaceColors.Coral
                }
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun RequestAppointmentForm(
    counselors: List<User>,
    onSubmit: (User, Date) -> Unit
) {
    var selected by remember { mutableStateOf<User?>(null) }
    var pickedDateMillis by remember { mutableStateOf<Long?>(null) }
    var hour by remember { mutableIntStateOf(10) }
    var showPicker by remember { mutableStateOf(false) }

    SolaceCard {
        Text("Counselor", style = MaterialTheme.typography.titleSmall)
        counselors.forEach { counselor ->
            Row(
                Modifier
                    .fillMaxWidth()
                    .clickable { selected = counselor }
                    .padding(vertical = Spacing.small),
                verticalAlignment = Alignment.CenterVertically
            ) {
                FilterChip(
                    selected = selected?.id == counselor.id,
                    onClick = { selected = counselor },
                    label = { Text(counselor.displayName) }
                )
            }
        }

        Text(
            "Date & time",
            style = MaterialTheme.typography.titleSmall,
            modifier = Modifier.padding(top = Spacing.medium)
        )
        OutlinedButton(onClick = { showPicker = true }, modifier = Modifier.fillMaxWidth()) {
            Text(
                pickedDateMillis?.let {
                    SimpleDateFormat("d MMM yyyy", Locale.getDefault()).format(Date(it))
                } ?: "Pick a date"
            )
        }

        Row(
            Modifier.padding(top = Spacing.small),
            horizontalArrangement = Arrangement.spacedBy(Spacing.small)
        ) {
            listOf(9, 10, 13, 15, 17).forEach { option ->
                FilterChip(
                    selected = hour == option,
                    onClick = { hour = option },
                    label = { Text("%02d:00".format(option)) }
                )
            }
        }

        Button(
            onClick = {
                val counselor = selected ?: return@Button
                val millis = pickedDateMillis ?: return@Button
                val calendar = Calendar.getInstance().apply {
                    timeInMillis = millis
                    set(Calendar.HOUR_OF_DAY, hour)
                    set(Calendar.MINUTE, 0)
                    set(Calendar.SECOND, 0)
                    set(Calendar.MILLISECOND, 0)
                }
                onSubmit(counselor, calendar.time)
            },
            enabled = selected != null && pickedDateMillis != null,
            modifier = Modifier.fillMaxWidth().padding(top = Spacing.medium)
        ) {
            Text("Request Appointment")
        }
    }

    if (showPicker) {
        val state = rememberDatePickerState()
        DatePickerDialog(
            onDismissRequest = { showPicker = false },
            confirmButton = {
                TextButton(onClick = {
                    pickedDateMillis = state.selectedDateMillis
                    showPicker = false
                }) { Text("OK") }
            },
            dismissButton = {
                TextButton(onClick = { showPicker = false }) { Text("Cancel") }
            }
        ) {
            DatePicker(state = state)
        }
    }
}

@Composable
fun CirclesScreen(
    viewModel: CircleListViewModel,
    onOpenCircle: (SupportCircle) -> Unit
) {
    val circles by viewModel.circles.collectAsStateWithLifecycle()
    val mine = viewModel.myCircles(circles)
    val available = viewModel.availableCircles(circles)

    Column(verticalArrangement = Arrangement.spacedBy(Spacing.large)) {
        ScreenTitle("Support Circles")

        if (circles.isEmpty()) {
            Text(
                "No circles yet. Check back soon.",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }

        if (mine.isNotEmpty()) {
            Text("My Circles", style = MaterialTheme.typography.titleSmall)
            SolaceCard {
                mine.forEachIndexed { index, circle ->
                    Row(
                        Modifier
                            .fillMaxWidth()
                            .clickable { onOpenCircle(circle) }
                            .padding(vertical = Spacing.small),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        CircleInfo(circle, Modifier.weight(1f))
                        TextButton(onClick = { viewModel.leave(circle) }) { Text("Leave") }
                    }
                    if (index != mine.lastIndex) HorizontalDivider()
                }
            }
        }

        if (available.isNotEmpty()) {
            Text("Browse Circles", style = MaterialTheme.typography.titleSmall)
            SolaceCard {
                available.forEachIndexed { index, circle ->
                    Row(
                        Modifier.fillMaxWidth().padding(vertical = Spacing.small),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        CircleInfo(circle, Modifier.weight(1f))
                        Button(onClick = { viewModel.join(circle) }) { Text("Join") }
                    }
                    if (index != available.lastIndex) HorizontalDivider()
                }
            }
        }
    }
}

@Composable
private fun CircleInfo(circle: SupportCircle, modifier: Modifier = Modifier) {
    Column(modifier) {
        Text(circle.name, style = MaterialTheme.typography.titleMedium)
        Text(
            circle.topicDescription,
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            maxLines = 2
        )
        Text(
            "${circle.memberIDs.size} member${if (circle.memberIDs.size == 1) "" else "s"}",
            style = MaterialTheme.typography.labelSmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

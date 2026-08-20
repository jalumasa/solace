package com.jonathanalumasa.solace.ui.shared

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.MedicalServices
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import com.jonathanalumasa.solace.model.CrisisSupport
import com.jonathanalumasa.solace.ui.theme.Radius
import com.jonathanalumasa.solace.ui.theme.Spacing

/** Screen title used at the top of every tab, mirroring iOS large nav titles. */
@Composable
fun ScreenTitle(text: String, modifier: Modifier = Modifier) {
    Text(text, style = MaterialTheme.typography.headlineLarge, modifier = modifier)
}

/**
 * The Android counterpart of the iOS `.glassCard()` modifier. Liquid Glass is
 * iOS-only, so this is a Material 3 surface at the same radius — kept
 * translucent so the tab's [AmbientBackground] tints through it, which is what
 * gives the two clients a shared feel without imitating glass outright.
 */
@Composable
fun SolaceCard(
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit
) {
    Card(
        modifier = modifier.fillMaxWidth(),
        shape = androidx.compose.foundation.shape.RoundedCornerShape(Radius.card),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface.copy(alpha = 0.70f)
        )
    ) {
        Column(Modifier.padding(Spacing.medium)) { content() }
    }
}

/** Icon + title/subtitle list row, mirroring the iOS `GameRow`/`ConnectRow` shape. */
@Composable
fun IconRow(
    title: String,
    subtitle: String,
    icon: ImageVector,
    tint: Color,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(vertical = Spacing.small),
        horizontalArrangement = Arrangement.spacedBy(Spacing.medium)
    ) {
        Icon(icon, contentDescription = null, tint = tint, modifier = Modifier.size(28.dp))
        Column {
            Text(title, style = MaterialTheme.typography.titleMedium)
            Text(
                subtitle,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

/** Always-available crisis contacts. Static data — never a network call. */
@Composable
fun CrisisResourceList() {
    Column(verticalArrangement = Arrangement.spacedBy(Spacing.small)) {
        Text(
            "If you're in crisis, help is available now",
            style = MaterialTheme.typography.titleSmall,
            color = MaterialTheme.colorScheme.error
        )
        CrisisSupport.contacts.forEach { contact ->
            Column {
                Text(contact.name, style = MaterialTheme.typography.bodyLarge)
                Text(
                    contact.detail,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

/** The SOS action shown on every primary tab, mirroring iOS `SOSToolbarButton`. */
@Composable
fun SosButton(onClick: () -> Unit) {
    IconButton(onClick = onClick) {
        Icon(
            Icons.Filled.MedicalServices,
            contentDescription = "Crisis support",
            tint = MaterialTheme.colorScheme.error
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CrisisSheet(onDismiss: () -> Unit) {
    ModalBottomSheet(onDismissRequest = onDismiss) {
        Column(Modifier.padding(Spacing.large)) {
            Text("Crisis Support", style = MaterialTheme.typography.headlineSmall)
            Column(Modifier.padding(top = Spacing.medium)) { CrisisResourceList() }
            Column(Modifier.padding(bottom = Spacing.xLarge)) {}
        }
    }
}

/** Small spacer helper keeping row layouts readable. */
@Composable
fun HSpace(width: androidx.compose.ui.unit.Dp = Spacing.small) {
    Row(Modifier.width(width)) {}
}

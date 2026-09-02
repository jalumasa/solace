package com.jonathanalumasa.solace.ui.onboarding

import androidx.compose.animation.Crossfade
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Chat
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.SentimentSatisfiedAlt
import androidx.compose.material.icons.filled.Spa
import androidx.compose.material3.Button
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.jonathanalumasa.solace.ui.shared.AmbientBackground
import com.jonathanalumasa.solace.ui.theme.Ambient
import com.jonathanalumasa.solace.ui.theme.SolaceColors
import com.jonathanalumasa.solace.ui.theme.Spacing
import kotlinx.coroutines.launch

private data class OnboardingPage(
    val title: String,
    val message: String,
    val icon: ImageVector,
    val colors: List<Color>
)

// Same copy as the iOS carousel, so first-run reads identically on both.
private val pages = listOf(
    OnboardingPage(
        title = "Welcome to Solace",
        message = "A quieter corner of your day, made just for you.",
        icon = Icons.Filled.Spa,
        colors = Ambient.today
    ),
    OnboardingPage(
        title = "Check in with yourself",
        message = "One tap a day to track how you're feeling and watch your streak grow.",
        icon = Icons.Filled.SentimentSatisfiedAlt,
        colors = Ambient.profile
    ),
    OnboardingPage(
        title = "Talk, any time",
        message = "Chat with an AI companion 24/7, or message a real counselor when you're ready.",
        icon = Icons.AutoMirrored.Filled.Chat,
        colors = Ambient.talk
    ),
    OnboardingPage(
        title = "Small moments of calm",
        message = "Breathing exercises, a gratitude garden, and a few playful games — " +
            "no pressure, ever.",
        icon = Icons.Filled.AutoAwesome,
        colors = Ambient.games
    )
)

/**
 * One-time swipeable welcome carousel shown before sign-in on first launch.
 * Mirrors the iOS `OnboardingView`; [OnboardingPreferences] gates it so
 * returning users go straight to sign-in.
 */
@Composable
fun OnboardingScreen(onFinish: () -> Unit) {
    val pagerState = rememberPagerState(pageCount = { pages.size })
    val scope = rememberCoroutineScope()
    val isLastPage = pagerState.currentPage == pages.lastIndex

    Box(Modifier.fillMaxSize()) {
        // The backdrop follows the page, so swiping shifts the whole mood.
        Crossfade(
            targetState = pages[pagerState.currentPage].colors,
            animationSpec = tween(500),
            label = "onboarding-ambient"
        ) { AmbientBackground(colors = it) }

        Column(Modifier.fillMaxSize().padding(Spacing.large)) {
            HorizontalPager(
                state = pagerState,
                modifier = Modifier.weight(1f)
            ) { index ->
                val page = pages[index]
                Column(
                    modifier = Modifier.fillMaxSize(),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center
                ) {
                    Box(
                        Modifier
                            .size(140.dp)
                            .background(
                                MaterialTheme.colorScheme.surface.copy(alpha = 0.75f),
                                CircleShape
                            ),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            page.icon,
                            contentDescription = null,
                            tint = SolaceColors.Primary,
                            modifier = Modifier.size(64.dp)
                        )
                    }

                    Text(
                        page.title,
                        style = MaterialTheme.typography.headlineLarge,
                        textAlign = TextAlign.Center,
                        modifier = Modifier.padding(top = Spacing.xLarge)
                    )
                    Text(
                        page.message,
                        style = MaterialTheme.typography.bodyLarge,
                        textAlign = TextAlign.Center,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        modifier = Modifier.padding(top = Spacing.medium)
                    )
                }
            }

            Row(
                Modifier
                    .fillMaxWidth()
                    .padding(vertical = Spacing.large),
                horizontalArrangement = Arrangement.Center
            ) {
                pages.indices.forEach { index ->
                    val selected = index == pagerState.currentPage
                    Box(
                        Modifier
                            .padding(horizontal = Spacing.xSmall)
                            .size(width = if (selected) 24.dp else 8.dp, height = 8.dp)
                            .background(
                                if (selected) SolaceColors.Primary
                                else MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.35f),
                                CircleShape
                            )
                    )
                }
            }

            Button(
                onClick = {
                    if (isLastPage) {
                        onFinish()
                    } else {
                        scope.launch { pagerState.animateScrollToPage(pagerState.currentPage + 1) }
                    }
                },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text(if (isLastPage) "Get Started" else "Continue")
            }

            TextButton(onClick = onFinish, modifier = Modifier.fillMaxWidth()) {
                Text("Skip")
            }
        }
    }
}

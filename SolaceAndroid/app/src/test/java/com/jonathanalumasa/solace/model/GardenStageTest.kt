package com.jonathanalumasa.solace.model

import org.junit.Assert.assertEquals
import org.junit.Test

/** Mirrors the Swift `GardenStage.stage(forEntryCount:)` tests. */
class GardenStageTest {

    @Test
    fun `stage progresses with entry count`() {
        assertEquals(GardenStage.SEED, GardenStage.forEntryCount(0))
        assertEquals(GardenStage.SEED, GardenStage.forEntryCount(2))
        assertEquals(GardenStage.SPROUT, GardenStage.forEntryCount(3))
        assertEquals(GardenStage.SPROUT, GardenStage.forEntryCount(6))
        assertEquals(GardenStage.BLOOM, GardenStage.forEntryCount(7))
        assertEquals(GardenStage.BLOOM, GardenStage.forEntryCount(14))
        assertEquals(GardenStage.FLOURISHING, GardenStage.forEntryCount(15))
    }
}

/** Guards the raw values that both clients persist to Firestore. */
class RawValueTest {

    @Test
    fun `role raw values match the iOS client`() {
        assertEquals("student", Role.STUDENT.rawValue)
        assertEquals("counselor", Role.COUNSELOR.rawValue)
    }

    @Test
    fun `mood raw values match the iOS client`() {
        assertEquals(1, MoodLevel.AWFUL.rawValue)
        assertEquals(5, MoodLevel.GREAT.rawValue)
    }

    @Test
    fun `appointment status raw values match the iOS client`() {
        assertEquals("pending", AppointmentStatus.PENDING.rawValue)
        assertEquals("confirmed", AppointmentStatus.CONFIRMED.rawValue)
        assertEquals("declined", AppointmentStatus.DECLINED.rawValue)
        assertEquals("cancelled", AppointmentStatus.CANCELLED.rawValue)
    }

    @Test
    fun `academic year raw values match the iOS client`() {
        assertEquals("freshman", AcademicYear.FRESHMAN.rawValue)
        assertEquals("graduate", AcademicYear.GRADUATE.rawValue)
    }
}

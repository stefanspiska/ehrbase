package org.ehrbase.service.util;

import org.junit.Test;

import java.sql.Time;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;

import static org.junit.Assert.*;

public class DatetimeHelperTest {

    @Test
    public void toApiTime() {
        // input as from DB
        LocalDateTime localDateTime = LocalDateTime.of(2020, 01, 25, 12, 25, 8, 355594893);
        Timestamp timestamp = Timestamp.valueOf(localDateTime);

        // converting as in service layer
        String string = DatetimeHelper.toApiTime(timestamp, "UTC-3");

        assertEquals("2020-01-25T08:25:08.355594893-03:00", string);
    }
}
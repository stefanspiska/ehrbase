/*
 * Copyright (c) 2020 Vitasystems GmbH and Jake Smolka (Hannover Medical School).
 *
 * This file is part of project EHRbase
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.ehrbase.service.util;

import java.sql.Timestamp;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;

/**
 * Util to convert between DB- and API-level representation of datetimes.
 *
 * For API-level specification see: https://specifications.openehr.org/releases/ITS-REST/latest/index.html#design-considerations-data-representation
 */
public class DatetimeHelper {

    /**
     * Converts a DB-level timestamp to a String consumable by the outwards API.
     * @param timeFromDb Input time
     * @param TzFromDb Input timezone
     * @return Output time
     */
    public static String toApiTime(Timestamp timeFromDb, String TzFromDb) {
        ZonedDateTime zonedDateTime = ZonedDateTime.ofInstant(timeFromDb.toInstant(), ZoneId.of(TzFromDb));
        // note: could add .truncatedTo(ChronoUnit.MILLIS) to limit sub-seconds to milliseconds only
        return DateTimeFormatter.ISO_OFFSET_DATE_TIME.format(zonedDateTime);
    }
}

/*
 * Copyright 2021-2022 vitasystems GmbH and Hannover Medical School.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.ehrbase.aql.sql.queryimpl;

import org.apache.commons.collections4.CollectionUtils;
import org.ehrbase.aql.sql.binding.Iso8601Duration;
import org.jooq.Field;
import org.jooq.Record;
import org.jooq.Result;
import org.postgresql.util.PGInterval;

/**
 * @author Christian Chevalley
 * @since 1.0
 */
public class DurationFormatter {

    private DurationFormatter() {
    }

    public static void toISO8601(Result<Record> records) {
        if (CollectionUtils.isEmpty(records)) {
            return;
        }

        for (Record rec : records) {
            for (Field field : rec.fields()) {
                if (rec.getValue(field) instanceof PGInterval) {
                    rec.setValue(field, new Iso8601Duration((PGInterval) rec.getValue(field)).toIsoString());
                }
            }
        }
    }
}

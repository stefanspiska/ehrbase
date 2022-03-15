/*
 * Copyright 2015-2022 vitasystems GmbH and Hannover Medical School.
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

package org.ehrbase.aql.sql.postprocessing;

import com.google.gson.JsonElement;
import jakarta.json.Json;
import jakarta.json.JsonException;
import jakarta.json.JsonReader;
import org.ehrbase.serialisation.dbencoding.rawjson.LightRawJsonEncoder;
import org.jooq.Field;
import org.jooq.JSONB;
import org.jooq.Record;
import org.jooq.Result;

import java.io.StringReader;

/**
 * @author Christian Chevalley
 * @since 1.0
 */
@SuppressWarnings({"unchecked", "java:S3776"})
public class RawJsonTransform implements IRawJsonTransform {

    public static final String ARRAY_MARKER = "$array$";

    private RawJsonTransform() {
    }

    public static void toRawJson(Result<Record> records) {
        if (records.isEmpty())
            return;

        for (Record rec : records) {

            for (Field field : rec.fields()) {
                //get associated value
                if (rec.getValue(field) instanceof String || rec.getValue(field) instanceof JSONB) {
                    String value = rec.getValue(field).toString();
                    String jsonbOrigin = null;
                    if (value.startsWith("[")) {
                        //check if this is a valid array
                        try (JsonReader jsonReader = Json.createReader(new StringReader(value))) {
                            jsonReader.readArray();
                            jsonbOrigin = "{\"$array$\":" + value + "}";
                        } catch (JsonException e) {
                            //not a json array, do nothing
                        }
                    } else if (value.startsWith("{")) {
                        try (JsonReader jsonReader = Json.createReader(new StringReader(value))) {
                            jsonReader.readObject();
                            jsonbOrigin = value;
                        } catch (JsonException e) {
                            //not a json object, do nothing
                        }
                    }
                    //apply the transformation
                    if (jsonbOrigin != null) {
                        JsonElement jsonElement = new LightRawJsonEncoder(jsonbOrigin).encodeContentAsJson(null);
                        if (jsonElement.getAsJsonObject().has(ARRAY_MARKER)) {
                            jsonElement = jsonElement.getAsJsonObject().getAsJsonArray(ARRAY_MARKER);
                        }
                        rec.setValue(field, jsonElement);
                    }
                }
            }
        }
    }
}

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
package org.ehrbase.dao.access.util;

/**
 * @author Christian Chevalley
 * @since 1.0
 */
public class ContributionDef {

    private ContributionDef() {
    }

    public enum ContributionType {

        COMPOSITION("composition"),
        FOLDER("folder");

        private final String literal;

        ContributionType(String literal) {
            this.literal = literal;
        }

        public String getLiteral() {
            return literal;
        }
    }

    public enum ContributionState {

        COMPLETE("complete"),
        INCOMPLETE("incomplete"),
        DELETED("deleted"),
        INITIAL("initial"); //this one does not exist in the DB and cannot be committed as is

        private final String literal;

        ContributionState(String literal) {
            this.literal = literal;
        }

        public String getLiteral() {
            return literal;
        }
    }
}

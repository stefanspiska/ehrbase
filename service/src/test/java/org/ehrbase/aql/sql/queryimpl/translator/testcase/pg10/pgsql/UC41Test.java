/*
 *  Copyright (c) 2020 Vitasystems GmbH and Christian Chevalley (Hannover Medical School).
 *
 *  This file is part of project EHRbase
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 *
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *   software distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and  limitations under the License.
 *
 */

package org.ehrbase.aql.sql.queryimpl.translator.testcase.pg10.pgsql;

import org.ehrbase.aql.sql.queryimpl.UnknownVariableException;
import org.ehrbase.aql.sql.queryimpl.translator.testcase.UC41;
import org.junit.Test;

import static org.assertj.core.api.Assertions.assertThat;

public class UC41Test extends UC41 {

    public UC41Test(){
        super();
        this.expectedSqlExpression =
                "select ? as \"constant\" from \"ehr\".\"entry\"";
    }

    @Test
    public void testIt()  {
        assertThat(testAqlSelectQuery()).isTrue();
    }
}

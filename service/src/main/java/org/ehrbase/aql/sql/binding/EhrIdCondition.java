package org.ehrbase.aql.sql.binding;

import org.jooq.Condition;
import org.jooq.Field;

import java.util.UUID;

public abstract class EhrIdCondition {

    public Condition encode(Field<UUID> field){
       return null;
    }
}

package org.ehrbase.aql.sql.binding;

import org.jooq.Condition;
import org.jooq.Field;

import java.util.UUID;

public class EhrIdEqualCondition extends EhrIdCondition{

    private UUID ehrId;

    public EhrIdEqualCondition(UUID ehrId) {
        this.ehrId = ehrId;
    }

    public Condition encode(Field<UUID> field){
        return field.eq(ehrId);
    }
}

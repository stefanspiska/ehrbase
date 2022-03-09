package org.ehrbase.aql.sql.binding;

import org.jooq.Condition;
import org.jooq.Field;

import java.util.List;
import java.util.UUID;

public class EhrIdInCondition  extends EhrIdCondition {

    private List<UUID> ehrIds;

    public EhrIdInCondition(List<UUID> ehrIds) {
        this.ehrIds = ehrIds;
    }

    public Condition encode(Field<UUID> field){
        return field.in(ehrIds);
    }
}

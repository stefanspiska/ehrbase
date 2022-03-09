package org.ehrbase.aql.sql.binding;

import org.ehrbase.aql.sql.queryimpl.attribute.JoinSetup;

import java.util.Arrays;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

import static org.ehrbase.aql.sql.binding.JoinBinder.compositionRecordTable;
import static org.ehrbase.aql.sql.binding.JoinBinder.statusRecordTable;
import static org.ehrbase.jooq.pg.Tables.ENTRY;
import static org.ehrbase.jooq.pg.Tables.EVENT_CONTEXT;

public class DistributedFilter {

    private JoinSetup joinSetup;
    private List<Object> whereItems;

    private EhrIdCondition ehrIdCondition = null; //once set, also use it in explicit join to improve performance

    private final static String LITERAL_AND = "AND";
    private final static String LITERAL_SPACE = " ";

    public DistributedFilter(JoinSetup joinSetup, List<Object> whereItems) {
        this.joinSetup = joinSetup;
        this.whereItems = whereItems;
    }

    private String condition(List<Object> whereItems, int cursor) {
        //traverse the items to get the actual operator and operand following the ehr_id/value condition
        String operator = null;
        StringBuilder operand = new StringBuilder();

        for (Object item: whereItems.subList(cursor+1, whereItems.size())){
            if (operator == null) {
                operator = item.toString(); //first pass

                if (!operator.matches("(?i)(=|IN)"))
                    return null;
            }
            else {
                operand.append(item.toString());
                if (operator.equals("=") || (operator.equalsIgnoreCase("IN") && item.toString().equals(")")))
                    break;
            }
        }

        setEhrIdCondition(operator, operand.toString());

        return operator+" "+operand;
    }

    private void setEhrIdCondition(String operator, String operand){
        if (operator.equals("=")){
            ehrIdCondition = new EhrIdEqualCondition(UUID.fromString(operand.replace("'","")));
        }
        else if (operator.equalsIgnoreCase("IN")){
            ehrIdCondition = new EhrIdInCondition(
                    Arrays.stream(operand.
                            substring(1, operand.length() -1). //skip parenthesis
                            split(",")). //get the id
                            map( s -> UUID.fromString(s.replace("'",""))).
                            collect(Collectors.toList()));
        }
    }

    private void addWhereJoinFilterClause(String joinTableId, String condition, TaggedStringBuilder taggedStringBuilder){
        taggedStringBuilder.append(LITERAL_SPACE);
        taggedStringBuilder.append(joinTableId);
        taggedStringBuilder.append(condition);
        taggedStringBuilder.append(LITERAL_SPACE);
        taggedStringBuilder.append(LITERAL_AND);
    }


    public void addToSql(TaggedStringBuilder taggedStringBuilder, List<Object> whereItems, int cursor) {
        String condition = condition(whereItems, cursor);

        if (joinSetup.isJoinComposition())
            addWhereJoinFilterClause(compositionRecordTable.field("ehr_id").toString(), condition, taggedStringBuilder);

        if (joinSetup.isJoinEhrStatus())
            addWhereJoinFilterClause(statusRecordTable.field("ehr_id").toString(), condition, taggedStringBuilder);

        if (joinSetup.isUseEntry())
            addWhereJoinFilterClause(ENTRY.EHR_ID.toString(), condition, taggedStringBuilder);

        if (joinSetup.isJoinEventContext())
            addWhereJoinFilterClause(EVENT_CONTEXT.EHR_ID.toString(), condition, taggedStringBuilder);

        taggedStringBuilder.append(LITERAL_SPACE); //termination
    }

    public EhrIdCondition getEhrIdCondition(){
        return ehrIdCondition;
    }
}

package org.ehrbase.aql.sql.queryImpl.value_field;

import org.apache.commons.lang3.StringUtils;
import org.ehrbase.aql.sql.queryImpl.I_QueryImpl;
import org.ehrbase.aql.sql.queryImpl.attribute.*;
import org.jooq.Field;
import org.jooq.TableField;
import org.jooq.impl.DSL;

import java.util.Optional;


public class GenericJsonField extends RMObjectAttribute {

    protected Optional<String> jsonPath = Optional.empty();

    private boolean isJsonDataBlock = true; //by default, can be overriden

    public GenericJsonField(FieldResolutionContext fieldContext, JoinSetup joinSetup) {
        super(fieldContext, joinSetup);
    }

    public Field jsonField(String rmType, String plpgsqlFunction, TableField... tableFields){
        fieldContext.setJsonDatablock(isJsonDataBlock);
        fieldContext.setRmType(rmType);
        //query the json representation of a node and cast the result as TEXT
        StringBuilder sqlExpression = new StringBuilder();

        Field jsonContextField;

        if (jsonPath.isPresent())
            sqlExpression.append(plpgsqlFunction+"("+StringUtils.join(tableFields, ",")+")::json #>>"+jsonPath.get());
        else
            sqlExpression.append(plpgsqlFunction+"("+StringUtils.join(tableFields, ",")+")::text");

        String iterativeMarker = ","+ I_QueryImpl.AQL_NODE_ITERATIVE_MARKER+",";

        //this wrap the expression into a json select array call (jsonb_array_elements(...))
        if (sqlExpression.indexOf(iterativeMarker) > -1) {
            sqlExpression.replace(sqlExpression.indexOf(iterativeMarker), sqlExpression.indexOf(iterativeMarker)+iterativeMarker.length(), "}')::jsonb)#>>'{");
            sqlExpression.insert(0, " jsonb_array_elements((");
        }

        jsonContextField = DSL.field(sqlExpression.toString());


        return as(DSL.field(jsonContextField));
    }

    public Field jsonField(String rmType, String plpgsqlFunction, Field... fields){
        fieldContext.setJsonDatablock(isJsonDataBlock);
        fieldContext.setRmType(rmType);
        //query the json representation of a node and cast the result as TEXT
        Field jsonContextField;
        if (jsonPath.isPresent())
            jsonContextField = DSL.field(plpgsqlFunction+"("+StringUtils.join(fields, ",")+")::json #>>"+jsonPath.get());
        else
            jsonContextField = DSL.field(plpgsqlFunction+"("+StringUtils.join(fields, ",")+")::text");


        return as(DSL.field(jsonContextField));

    }

    @Override
    public Field sqlField(){
        return null;
    }

    @Override
    public I_RMObjectAttribute forTableField(TableField tableField) {
        return this;
    }

    public GenericJsonField forJsonPath(String jsonPath){
        if (jsonPath == null || jsonPath.isEmpty()) {
            this.jsonPath = Optional.empty();
            return this;
        }

        this.jsonPath = Optional.of(new GenericJsonPath(jsonPath).jqueryPath());
        return this;
    }

    public GenericJsonField setJsonDataBlock(boolean jsonDataBlock) {
        this.isJsonDataBlock = jsonDataBlock;
        return this;
    }
}

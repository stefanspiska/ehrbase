-- configure CITUS network (deployment specific!!!) shouldn't be in a migration!

-- on each node:
-- make sure you run this on all workers (required by index ehr_subject_id_index)
-- run this AFTER the DB tables are created

CREATE FUNCTION ehr.js_party_ref(text, text, text, text) RETURNS json
    LANGUAGE plpgsql
    IMMUTABLE
AS
$_$
DECLARE
    id_value ALIAS FOR $1;
    id_scheme ALIAS FOR $2;
    namespace ALIAS FOR $3;
    party_type ALIAS FOR $4;
BEGIN

    IF (id_value IS NULL AND id_scheme IS NULL AND namespace IS NULL AND party_type IS NULL) THEN
        RETURN NULL;
    ELSE
        RETURN
            json_build_object(
                    '_type', 'PARTY_REF',
                    'id',
                    json_build_object(
                            '_type', 'GENERIC_ID',
                            'value', id_value,
                            'scheme', id_scheme
                        ),
                    'namespace', namespace,
                    'type', party_type
                );
    END IF;
END
$_$;
ALTER FUNCTION ehr.js_party_ref(text, text, text, text) OWNER TO ehrbase;

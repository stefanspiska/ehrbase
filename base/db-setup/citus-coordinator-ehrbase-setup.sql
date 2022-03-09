/*
 * Copyright (C) 2022 Vitasystems GmbH and Christian Chevalley Hannover Medical School.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

-- POST MIGRATION SCRIPT
-- alter functions and tables according to CITUS requirements
-- Please refer to V2__init_ehrbase.sql initial migration
---
-- patched version to allow push on FDW and remove ref to history table
-- should be enhanced after prototyping

CREATE or replace FUNCTION ehr.js_composition(uuid, server_node_id text) RETURNS json
    LANGUAGE plpgsql
AS
$_$
DECLARE
    composition_uuid ALIAS FOR $1;
BEGIN
    RETURN (
        WITH entry_content AS (
            SELECT composition.id           as composition_id,
                   composition.language     as language,
                   composition.territory    as territory,
                   composition.composer     as composer,
                   composition.feeder_audit as feeder_audit,
                   composition.links        as links,
                   event_context.id         as context_id,
                   territory.twoletter      as territory_code,
                   entry.template_id        as template_id,
                   entry.archetype_id       as archetype_id,
                   entry.rm_version         as rm_version,
                   entry.entry              as content,
                   entry.category           as category,
                   entry.name               as name,
                   jsonb_extract_path (entry.entry, '/composition['||entry.archetype_id||']') as json_content
            FROM ehr.composition
                     INNER JOIN ehr.entry
                                ON entry.composition_id = composition.id
                                    and entry.ehr_id = composition.ehr_id
                     LEFT JOIN ehr.event_context
                               ON event_context.composition_id = composition.id
                                   and event_context.ehr_id = composition.ehr_id
                     LEFT JOIN ehr.territory ON territory.code = composition.territory
            WHERE composition.id = composition_uuid
        )
        SELECT jsonb_strip_nulls(
                       jsonb_build_object(
                               '_type', 'COMPOSITION',
                               'name', ehr.js_dv_text((entry_content.name).value),
                               'archetype_details',
                               ehr.js_archetype_details(entry_content.archetype_id, entry_content.template_id,
                                                        entry_content.rm_version),
                               'archetype_node_id', entry_content.archetype_id,
                               'feeder_audit', entry_content.feeder_audit,
                               'links', entry_content.links,
                               'uid',
                               ehr.js_object_version_id(entry_content.composition_id::text),
                               'language', ehr.js_code_phrase(language, 'ISO_639-1'),
                               'territory', ehr.js_code_phrase(territory_code, 'ISO_3166-1'),
                               'composer', ehr.js_canonical_party_identified(composer),
                               'category', ehr.js_dv_coded_text(category),
                               'context', ehr.js_context(context_id),
                               'content', entry_content.json_content::jsonb
                           )
                   )
        FROM entry_content
    );
END
$_$;

-- patched version to allow push on FDW and remove ref to history table
-- should be enhanced after prototyping
CREATE or replace FUNCTION ehr.js_ehr_status_uid(ehr_uuid uuid, server_id text) RETURNS jsonb
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN jsonb_strip_nulls(
            jsonb_build_object(
                    '_type', 'HIER_OBJECT_ID',
                    'value', ehr_uuid
                )
        );
END
$$;

-- tables distribution and modifications to support it
------------------------------------------------------
-- Modify the DB to support distribution of key tables:
-- EHR STATUS
-- COMPOSITION
-- EVENT_CONTEXT
-- ENTRY
-- other tables might be added later on as well as required reference tables.
--
-- triggers are not distributed and must be recreated independently
--drop trigger versioning_trigger on ehr.entry;
--drop trigger versioning_trigger on ehr.composition;
--drop trigger versioning_trigger on ehr.event_context;
--drop trigger versioning_trigger on ehr.status;
--
-- disable sys_period NULL constraint on the above tables
ALTER TABLE ehr.entry ALTER COLUMN sys_period DROP NOT NULL;
ALTER TABLE ehr.composition ALTER COLUMN sys_period DROP NOT NULL;
ALTER TABLE ehr.event_context ALTER COLUMN sys_period DROP NOT NULL;
ALTER TABLE ehr.status ALTER COLUMN sys_period DROP NOT NULL;
ALTER TABLE ehr.participation ALTER COLUMN sys_period DROP NOT NULL;

-- force an interpretable defaut tstzrange value
ALTER TABLE ehr.entry ALTER COLUMN sys_period SET DEFAULT tstzrange (now(), NULL);
ALTER TABLE ehr.composition ALTER COLUMN sys_period SET DEFAULT tstzrange (now(), NULL);
ALTER TABLE ehr.event_context ALTER COLUMN sys_period SET DEFAULT tstzrange (now(), NULL);
ALTER TABLE ehr.status ALTER COLUMN sys_period SET DEFAULT tstzrange (now(), NULL);
ALTER TABLE ehr.participation ALTER COLUMN sys_period SET DEFAULT tstzrange (now(), NULL);

SELECT create_reference_table('ehr.attestation_ref');
alter table ehr.identifier drop constraint identifier_party_fkey;
SELECT create_reference_table('ehr.identifier');
SELECT create_reference_table('ehr.party_identified');
alter table ehr.identifier add constraint identifier_party_fkey FOREIGN KEY (party) REFERENCES ehr.party_identified (id) ON DELETE CASCADE;
SELECT create_reference_table('ehr.ehr');
SELECT create_reference_table('ehr.audit_details');
SELECT create_reference_table('ehr.contribution');
SELECT create_reference_table('ehr.language');
SELECT create_reference_table('ehr.territory');
SELECT create_reference_table('ehr.concept');
SELECT create_reference_table('ehr.participation');

-- Composition table distribution
ALTER TABLE ehr.composition DROP CONSTRAINT composition_pkey CASCADE;
SELECT create_distributed_table('ehr.composition', 'ehr_id');
ALTER TABLE ehr.composition ADD CONSTRAINT composition_pkey PRIMARY KEY (id, ehr_id);


-- event_context
ALTER TABLE ehr.event_context ADD COLUMN ehr_id UUID;
ALTER TABLE ehr.event_context DROP CONSTRAINT event_context_pkey CASCADE;
SELECT create_distributed_table('ehr.event_context', 'ehr_id');
ALTER TABLE ehr.event_context ADD CONSTRAINT event_context_pkey PRIMARY KEY (id, ehr_id);
ALTER TABLE ehr.event_context ADD CONSTRAINT event_context_composition_id_fkey
    FOREIGN KEY (composition_id, ehr_id) REFERENCES ehr.composition (id, ehr_id) ON DELETE CASCADE;

-- entry
ALTER TABLE ehr.entry ADD COLUMN ehr_id UUID;
ALTER TABLE ehr.entry DROP CONSTRAINT entry_pkey CASCADE;
SELECT create_distributed_table('ehr.entry', 'ehr_id');
ALTER TABLE ehr.entry ADD CONSTRAINT entry_pkey PRIMARY KEY (id, ehr_id);
ALTER TABLE ehr.entry ADD CONSTRAINT entry_composition_id_fkey
    FOREIGN KEY (composition_id, ehr_id) REFERENCES ehr.composition (id, ehr_id) ON DELETE CASCADE;

-- ehr status: TO BE CHECKED IN REGARD TO THE FK
ALTER TABLE ehr.status DROP CONSTRAINT status_pkey CASCADE;
SELECT create_distributed_table('ehr.status', 'ehr_id');
ALTER TABLE ehr.status ADD CONSTRAINT status_pkey PRIMARY KEY (id, ehr_id) ;

-- At this stage, we should be able to create the distributed functions

--  SELECT create_distributed_function('ehr.admin_delete_all_templates() RETURNS integer
--  SELECT create_distributed_function('ehr.admin_delete_attestation(attest_ref_input uuid)
--  SELECT create_distributed_function('ehr.admin_delete_audit(audit_input uuid)
--  SELECT create_distributed_function('ehr.admin_delete_composition(compo_id_input uuid)
--  SELECT create_distributed_function('ehr.admin_delete_composition_history(compo_input uuid)
--  SELECT create_distributed_function('ehr.admin_delete_contribution(contrib_id_input uuid)
--  SELECT create_distributed_function('ehr.admin_delete_ehr(ehr_id_input uuid)
--  SELECT create_distributed_function('ehr.admin_delete_ehr_full(ehr_id_param uuid)
--  SELECT create_distributed_function('ehr.admin_delete_ehr_history(ehr_id_input uuid)
--  SELECT create_distributed_function('ehr.admin_delete_event_context_for_compo(compo_id_input uuid)
--  SELECT create_distributed_function('ehr.admin_delete_folder(folder_id_input uuid)
--  SELECT create_distributed_function('ehr.admin_delete_folder_history(folder_id_input uuid)
--  SELECT create_distributed_function('ehr.admin_delete_folder_obj_ref_history(contribution_id_input uuid)
--  SELECT create_distributed_function('ehr.admin_delete_status(status_id_input uuid)
--  SELECT create_distributed_function('ehr.admin_delete_status_history(status_id_input uuid)
--  SELECT create_distributed_function('ehr.admin_delete_template(target_id text) RETURNS integer
--  SELECT create_distributed_function('ehr.admin_get_linked_compositions(ehr_id_input uuid)
--  SELECT create_distributed_function('ehr.admin_get_linked_compositions_for_contrib(contrib_id_input uuid)
--  SELECT create_distributed_function('ehr.admin_get_linked_contributions(ehr_id_input uuid)
--  SELECT create_distributed_function('ehr.admin_get_linked_status_for_contrib(contrib_id_input uuid)
--  SELECT create_distributed_function('ehr.admin_get_template_usage(target_id text)
--  SELECT create_distributed_function('ehr.admin_update_template(target_id text, update_content text) RETURNS text
SELECT create_distributed_function('ehr.aql_node_name_predicate(jsonb, text, text)');
SELECT create_distributed_function('ehr.camel_to_snake(text)');
SELECT create_distributed_function('ehr.composition_name(jsonb)');
SELECT create_distributed_function('ehr.composition_uid(uuid, text)');
-- SELECT create_distributed_function('ehr.delete_orphan_history()');
SELECT create_distributed_function('ehr.ehr_status_uid(uuid, text)','ehr_uuid', colocate_with := 'ehr.status');
-- SELECT create_distributed_function('ehr.folder_uid(folder_uid uuid, server_id text) RETURNS text
SELECT create_distributed_function('ehr.get_system_version()');
SELECT create_distributed_function('ehr.iso_timestamp(timestamp with time zone)');
SELECT create_distributed_function('ehr.js_archetype_details(text, text)');
SELECT create_distributed_function('ehr.js_archetype_details(text, text, text)');
SELECT create_distributed_function('ehr.js_archetyped(text, text)');
-- SELECT create_distributed_function('ehr.js_audit_details(uuid) RETURNS json
SELECT create_distributed_function('ehr.js_canonical_dv_quantity(double precision, text, integer, boolean)');
SELECT create_distributed_function('ehr.js_canonical_generic_id(text, text) ');
SELECT create_distributed_function('ehr.js_canonical_hier_object_id(text) ');
SELECT create_distributed_function('ehr.js_canonical_hier_object_id(uuid) ');
SELECT create_distributed_function('ehr.js_canonical_object_id( ehr.party_ref_id_type, text, text) ');
SELECT create_distributed_function('ehr.js_canonical_object_version_id(text) ');
SELECT create_distributed_function('ehr.js_canonical_participations(uuid) ');
SELECT create_distributed_function('ehr.js_canonical_party_identified(uuid) ');
SELECT create_distributed_function('ehr.js_canonical_party_ref(text, text, text, text) ');
SELECT create_distributed_function('ehr.js_code_phrase(ehr.code_phrase) ');
SELECT create_distributed_function('ehr.js_code_phrase(text, text) ');
SELECT create_distributed_function('ehr.js_composition(uuid) ');
SELECT create_distributed_function('ehr.js_composition(uuid, text) ');
SELECT create_distributed_function('ehr.js_concept(uuid) ');
SELECT create_distributed_function('ehr.js_context(uuid) ');
SELECT create_distributed_function('ehr.js_context_setting(uuid) ');
-- SELECT create_distributed_function('ehr.js_contribution(uuid, text) ');<<<<<<<<
SELECT create_distributed_function('ehr.js_dv_coded_text(ehr.dv_coded_text) ');
SELECT create_distributed_function('ehr.js_dv_coded_text(text, json) ');
SELECT create_distributed_function('ehr.js_dv_coded_text_inner(ehr.dv_coded_text) ');
SELECT create_distributed_function('ehr.js_dv_coded_text_inner(text, text, text) ');
SELECT create_distributed_function('ehr.js_dv_date_time(timestamp without time zone, text) ');
SELECT create_distributed_function('ehr.js_dv_text(text) ');
SELECT create_distributed_function('ehr.js_ehr(uuid, text)', '$1', colocate_with := 'ehr.composition');
SELECT create_distributed_function('ehr.js_ehr_status(uuid) ');
SELECT create_distributed_function('ehr.js_ehr_status(uuid, text) ');
SELECT create_distributed_function('ehr.js_ehr_status_uid(uuid, text) ');
-- SELECT create_distributed_function('ehr.js_folder(folder_uid uuid, server_id text) ');
SELECT create_distributed_function('ehr.js_object_version_id(text) ');
SELECT create_distributed_function('ehr.js_participations(uuid) ','event_context_id', colocate_with := 'ehr.event_context');
SELECT create_distributed_function('ehr.js_party(uuid) ');
SELECT create_distributed_function('ehr.js_party_identified(text, json) ');
SELECT create_distributed_function('ehr.js_party_ref(text, text, text, text) ');
SELECT create_distributed_function('ehr.js_party_self(uuid) ');
SELECT create_distributed_function('ehr.js_party_self_identified(text, json) ');
SELECT create_distributed_function('ehr.js_term_mappings(text[]) ');
SELECT create_distributed_function('ehr.js_typed_element_value(jsonb) ');
SELECT create_distributed_function('ehr.json_party_identified(text, uuid, text, text, text, text)');
SELECT create_distributed_function('ehr.json_party_identified(text, uuid, text, text, text, text, ehr.party_ref_id_type)');
SELECT create_distributed_function('ehr.json_party_related(text, uuid, text, text, text, text, ehr.party_ref_id_type, ehr.dv_coded_text)');
SELECT create_distributed_function('ehr.json_party_self(uuid, text, text, text, text, ehr.party_ref_id_type)');
SELECT create_distributed_function('ehr.jsonb_array_elements(jsonb)');
SELECT create_distributed_function('ehr.jsonb_extract_path(jsonb, text[]) ');
SELECT create_distributed_function('ehr.jsonb_extract_path_text(jsonb, text[]) ');
SELECT create_distributed_function('ehr.map_change_type_to_codestring(text)');
SELECT create_distributed_function('ehr.object_version_id(uuid, text, integer) ');
SELECT create_distributed_function('ehr.party_ref(text, text, text, text, ehr.party_ref_id_type)');
SELECT create_distributed_function('ehr.xjsonb_array_elements(jsonb) ');
select create_distributed_function('ehr.cast_as_interval(TEXT)');


-- recreate indexes to use the correct primary key combination
--------------------------------------------------------------
-- TRIGGERS and INDEXES
CREATE INDEX attestation_reference_idx ON ehr.attestation USING btree (reference);
CREATE INDEX attested_view_attestation_idx ON ehr.attested_view USING btree (attestation_id);
CREATE INDEX compo_xref_child_idx ON ehr.compo_xref USING btree (child_uuid);
CREATE INDEX composition_composer_idx ON ehr.composition USING btree (composer);
CREATE INDEX composition_ehr_idx ON ehr.composition USING btree (id, ehr_id);
CREATE INDEX composition_history_ehr_idx ON ehr.composition_history USING btree (ehr_id);
CREATE INDEX context_composition_id_idx ON ehr.event_context USING btree (composition_id, ehr_id);
CREATE INDEX context_facility_idx ON ehr.event_context USING btree (facility);
CREATE INDEX context_participation_index ON ehr.participation USING btree (event_context);
CREATE INDEX context_setting_idx ON ehr.event_context USING btree (setting);
CREATE INDEX contribution_ehr_idx ON ehr.contribution USING btree (ehr_id);
CREATE INDEX ehr_compo_xref ON ehr.compo_xref USING btree (master_uuid);
CREATE INDEX ehr_composition_history ON ehr.composition_history USING btree (id);
CREATE INDEX ehr_entry_history ON ehr.entry_history USING btree (id);
CREATE INDEX ehr_event_context_history ON ehr.event_context_history USING btree (id);
CREATE UNIQUE INDEX ehr_folder_idx ON ehr.ehr USING btree (directory);
CREATE INDEX ehr_participation_history ON ehr.participation_history USING btree (id);
CREATE INDEX ehr_status_history ON ehr.status_history USING btree (id);

CREATE INDEX ehr_subject_id_index ON ehr.party_identified USING btree (jsonb_extract_path_text(
                                                                               (ehr.js_party_ref(party_ref_value,
                                                                                                 party_ref_scheme,
                                                                                                 party_ref_namespace,
                                                                                                 party_ref_type))::jsonb,
                                                                               VARIADIC
                                                                               ARRAY ['id'::text, 'value'::text]));

CREATE INDEX entry_composition_id_idx ON ehr.entry USING btree (composition_id, ehr_id);
CREATE INDEX entry_history_composition_idx ON ehr.entry_history USING btree (composition_id);
CREATE INDEX event_context_history_composition_idx ON ehr.event_context_history USING btree (composition_id);
CREATE INDEX fki_folder_hierarchy_parent_fk ON ehr.folder_hierarchy USING btree (parent_folder);
CREATE INDEX folder_hierarchy_history_contribution_idx ON ehr.folder_hierarchy_history USING btree (in_contribution);
CREATE INDEX folder_hierarchy_in_contribution_idx ON ehr.folder_hierarchy USING btree (in_contribution);
CREATE INDEX folder_hist_idx ON ehr.folder_items_history USING btree (folder_id, object_ref_id, in_contribution);
CREATE INDEX folder_history_contribution_idx ON ehr.folder_history USING btree (in_contribution);
CREATE INDEX folder_in_contribution_idx ON ehr.folder USING btree (in_contribution);
CREATE INDEX folder_items_contribution_idx ON ehr.folder_items USING btree (in_contribution);
CREATE INDEX folder_items_history_contribution_idx ON ehr.folder_items_history USING btree (in_contribution);
CREATE INDEX gin_entry_path_idx ON ehr.entry USING gin (entry jsonb_path_ops);
CREATE INDEX obj_ref_in_contribution_idx ON ehr.object_ref USING btree (in_contribution);
CREATE INDEX object_ref_history_contribution_idx ON ehr.object_ref_history USING btree (in_contribution);
CREATE INDEX participation_history_event_context_idx ON ehr.participation_history USING btree (event_context);
CREATE INDEX party_identified_party_ref_idx ON ehr.party_identified USING btree (party_ref_namespace, party_ref_scheme, party_ref_value);
CREATE INDEX party_identified_party_type_idx ON ehr.party_identified USING btree (party_type, name);
CREATE INDEX status_ehr_idx ON ehr.status USING btree (ehr_id);
CREATE INDEX status_history_ehr_idx ON ehr.status_history USING btree (ehr_id);
CREATE INDEX status_party_idx ON ehr.status USING btree (party);
CREATE INDEX template_entry_idx ON ehr.entry USING btree (template_id);
CREATE UNIQUE INDEX territory_code_index ON ehr.territory USING btree (code);
CREATE INDEX concept_code_language_idx ON ehr.concept USING btree (conceptid, language);

-- TRIGGERS
-- at this time (9.2.2022) triggers cannot be distributed with CITUS

CREATE TRIGGER tr_folder_item_delete
    AFTER DELETE
    ON ehr.folder_items
    FOR EACH ROW
EXECUTE FUNCTION ehr.tr_function_delete_folder_item();

-- VERSIONING USING TEMPORAL TABLE
--CREATE TRIGGER versioning_trigger
--    BEFORE INSERT OR DELETE OR UPDATE
--    ON ehr.composition
--    FOR EACH ROW
--EXECUTE FUNCTION ext.versioning('sys_period', 'ehr.composition_history', 'true');
--
--CREATE TRIGGER versioning_trigger
--    BEFORE INSERT OR DELETE OR UPDATE
--    ON ehr.entry
--    FOR EACH ROW
--EXECUTE FUNCTION ext.versioning('sys_period', 'ehr.entry_history', 'true');
--
--CREATE TRIGGER versioning_trigger
--    BEFORE INSERT OR DELETE OR UPDATE
--    ON ehr.event_context
--    FOR EACH ROW
--EXECUTE FUNCTION ext.versioning('sys_period', 'ehr.event_context_history', 'true');
--
--CREATE TRIGGER versioning_trigger
--    BEFORE INSERT OR DELETE OR UPDATE
--    ON ehr.folder
--    FOR EACH ROW
--EXECUTE FUNCTION ext.versioning('sys_period', 'ehr.folder_history', 'true');
--
--CREATE TRIGGER versioning_trigger
--    BEFORE INSERT OR DELETE OR UPDATE
--    ON ehr.folder_hierarchy
--    FOR EACH ROW
--EXECUTE FUNCTION ext.versioning('sys_period', 'ehr.folder_hierarchy_history', 'true');
--
--CREATE TRIGGER versioning_trigger
--    BEFORE INSERT OR DELETE OR UPDATE
--    ON ehr.folder_items
--    FOR EACH ROW
--EXECUTE FUNCTION ext.versioning('sys_period', 'ehr.folder_items_history', 'true');
--
--CREATE TRIGGER versioning_trigger
--    BEFORE INSERT OR DELETE OR UPDATE
--    ON ehr.object_ref
--    FOR EACH ROW
--EXECUTE FUNCTION ext.versioning('sys_period', 'ehr.object_ref_history', 'true');
--
--CREATE TRIGGER versioning_trigger
--    BEFORE INSERT OR DELETE OR UPDATE
--    ON ehr.participation
--    FOR EACH ROW
--EXECUTE FUNCTION ext.versioning('sys_period', 'ehr.participation_history', 'true');
--
--CREATE TRIGGER versioning_trigger
--    BEFORE INSERT OR DELETE OR UPDATE
--    ON ehr.status
--    FOR EACH ROW
--EXECUTE FUNCTION ext.versioning('sys_period', 'ehr.status_history', 'true');

-- set a dummy function for admin_delete for tests!
-- WARNING: this function works OK in most UCs except when folders are linked to an EHR!
CREATE or replace FUNCTION ehr.admin_delete_ehr_full(ehr_id_param uuid)
    RETURNS TABLE
            (
                deleted boolean
            )
    LANGUAGE plpgsql
AS
$$
BEGIN
    -- Disable versioning triggers

    RETURN QUERY WITH
                     -- Query IDs
                     select_composition_ids
                         AS (SELECT id FROM ehr.composition WHERE ehr_id = ehr_id_param),
                     select_contribution_ids
                         AS (SELECT id FROM ehr.contribution WHERE ehr_id = ehr_id_param),

                     -- Delete data

                     -- ON DELETE CASCADE:
                     --   * ehr.attested_view
                     --   * ehr.entry
                     --   * ehr.event_context
                     --   * ehr.folder_hierarchy
                     --   * ehr.folder_items
                     --   * ehr.object_ref
                     --   * ehr.participation

                     delete_compo_xref
                         AS (DELETE FROM ehr.compo_xref cx USING select_composition_ids sci WHERE cx.master_uuid = sci.id OR cx.child_uuid = sci.id),
                     delete_composition
                         AS (DELETE FROM ehr.composition WHERE ehr_id = ehr_id_param RETURNING id, attestation_ref, has_audit),
                     delete_status
                         AS (DELETE FROM ehr.status WHERE ehr_id = ehr_id_param RETURNING id, attestation_ref, has_audit),
                     select_attestation_ids AS (SELECT id
                                                FROM ehr.attestation
                                                WHERE reference IN
                                                      (SELECT attestation_ref FROM delete_composition)
                                                   OR reference IN (SELECT attestation_ref FROM delete_status)),
                     delete_attestation
                         AS (DELETE FROM ehr.attestation a USING select_attestation_ids sa WHERE a.id = sa.id RETURNING a.reference, a.has_audit),
                     delete_attestation_ref
                         AS (DELETE FROM ehr.attestation_ref ar USING delete_attestation da WHERE ar.ref = da.reference),
                     delete_folder_items
                         AS (DELETE FROM ehr.folder_items fi USING select_contribution_ids sci WHERE fi.in_contribution = sci.id),
                     delete_folder_hierarchy
                         AS (DELETE FROM ehr.folder_hierarchy fh USING select_contribution_ids sci WHERE fh.in_contribution = sci.id),
                     delete_folder
                         AS (DELETE FROM ehr.folder f USING select_contribution_ids sci WHERE f.in_contribution = sci.id RETURNING f.id, f.has_audit),
                     delete_contribution
                         AS (DELETE FROM ehr.contribution c WHERE c.ehr_id = ehr_id_param RETURNING c.id, c.has_audit),
                     delete_ehr
                         AS (DELETE FROM ehr.ehr e WHERE e.id = ehr_id_param RETURNING e.access),
                     delete_access
                         AS (DELETE FROM ehr.access a USING delete_ehr de WHERE a.id = de.access),

                     -- Delete _history
                     delete_composition_history
                         AS (DELETE FROM ehr.composition_history WHERE ehr_id = ehr_id_param RETURNING id, attestation_ref, has_audit),
                     delete_entry_history
                         AS (DELETE FROM ehr.entry_history eh USING delete_composition_history dch WHERE eh.composition_id = dch.id),
                     delete_event_context_hisotry
                         AS (DELETE FROM ehr.event_context_history ech USING delete_composition_history dch WHERE ech.composition_id = dch.id RETURNING ech.id),
                     delete_folder_history
                         AS (DELETE FROM ehr.folder_history fh USING select_contribution_ids sc WHERE fh.in_contribution = sc.id RETURNING fh.id, fh.has_audit),
                     delete_folder_items_history
                         AS (DELETE FROM ehr.folder_items_history fih USING select_contribution_ids sc WHERE fih.in_contribution = sc.id),
                     delete_folder_hierarchy_history
                         AS (DELETE FROM ehr.folder_hierarchy_history fhh USING select_contribution_ids sc WHERE fhh.in_contribution = sc.id),
                     delete_participation_history
                         AS (DELETE FROM ehr.participation_history ph USING delete_event_context_hisotry dech WHERE ph.event_context = dech.id),
                     object_ref_history
                         AS (DELETE FROM ehr.object_ref_history orh USING select_contribution_ids sc WHERE orh.in_contribution = sc.id),
                     delete_status_history
                         AS (DELETE FROM ehr.status_history WHERE ehr_id = ehr_id_param RETURNING id, attestation_ref, has_audit),

                     -- Delete audit_details
                     delete_composition_audit
                         AS (DELETE FROM ehr.audit_details ad USING delete_composition dc WHERE ad.id = dc.has_audit),
                     delete_status_audit
                         AS (DELETE FROM ehr.audit_details ad USING delete_status ds WHERE ad.id = ds.has_audit),
                     delete_attestation_audit
                         AS (DELETE FROM ehr.audit_details ad USING delete_attestation da WHERE ad.id = da.has_audit),
                     delete_folder_audit
                         AS (DELETE FROM ehr.audit_details ad USING delete_folder df WHERE ad.id = df.has_audit),
                     delete_contribution_audit
                         AS (DELETE FROM ehr.audit_details ad USING delete_contribution dc WHERE ad.id = dc.has_audit),
                     delete_composition_history_audit
                         AS (DELETE FROM ehr.audit_details ad USING delete_composition_history dch WHERE ad.id = dch.has_audit),
                     delete_status_history_audit
                         AS (DELETE FROM ehr.audit_details ad USING delete_status_history dsh WHERE ad.id = dsh.has_audit),
                     delete_folder_history_audit
                         AS (DELETE FROM ehr.audit_details ad USING delete_folder_history dfh WHERE ad.id = dfh.has_audit)

                 SELECT true;

    -- Restore versioning triggers

END
$$;







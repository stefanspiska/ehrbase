*** Settings ***
Documentation   AQL QUERY SMOME TEST

Resource    ${CURDIR}${/}../_resources/suite_settings.robot

# Suite Setup    Establish Preconditions
# Test Setup  Establish Preconditions
# Test Teardown  restore clean SUT state
# Suite Teardown    Run Keywords    Clean DB    # Delete Temp Result-Data-Sets

Force Tags    adhoc-query    loaded_db    temp



*** Variables ***
${ehr data sets}    ${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/query/data_load/ehrs/
${compo data sets}    ${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/query/data_load/compositions/



*** Test Cases ***
AQL LOADED DB SMOKE TEST
    [Tags]  SMOKE

    # COMMENT: PRECONDITIONS
        Preconditions (PART 1) - Load Blueprints of Queries and Expected-Results
        # comment: Preconditions (PART 2 / MINIMAL SET)
        #          Generates Test-Data and Expected-Results
            [Documentation]     This is a short version of A.1.a__Loaded_DB.robot TC
            ...                 Uploads required test data to server/db and generates expected results
            ...                 during that process. This involves
            ...                 - creating ONE EHR record with ehr_status
            ...                 - committing one Composition of EACH TYPE: admin, evaluation,
            ...                   instruction, observation, action
            ...                 - injecting live data into 'expected result blueprint'
            ...                 - injecting live data into some 'query blueprints'

        upload OPT      minimal/minimal_admin.opt
        upload OPT      minimal/minimal_observation.opt
        upload OPT      minimal/minimal_instruction.opt
        upload OPT      minimal/minimal_evaluation.opt
        upload OPT      minimal/minimal_action.opt
        upload OPT      minimal/minimal_action_2.opt
        upload OPT      all_types/Test_all_types.opt
        upload OPT      nested/nested.opt

        # comment: Populate SUT with Test-Data and Prepare Expected Results
        Create EHR Record On The Server    1    ${ehr data sets}/ehr_status_01.json
        Commit Compo     1    1    ${compo data sets}/minimal_admin_1.composition.json
        Commit Compo     2    1    ${compo data sets}/minimal_evaluation_1.composition.json
        Commit Compo     3    1    ${compo data sets}/minimal_instruction_1.composition.json
        Commit Compo     4    1    ${compo data sets}/minimal_observation_1.composition.json
        Commit Compo     5    1    ${compo data sets}/minimal_action2_1.composition.json
        Commit Compo     6    1    ${compo data sets}/all_types.composition.json
        Commit Compo     7    1    ${compo data sets}/nested_composition.json

        #///////////////////////////////////////////////////
        #//                                              ///
        #//  UNCOMMENT MORE COMPOS TO EXTEND SMOKE TEST  ///
        #//                                              ///
        #///////////////////////////////////////////////////

        # Commit Compo    7    1    ${compo data sets}/minimal_admin_2.composition.json
        # Commit Compo    8    1    ${compo data sets}/minimal_admin_3.composition.json

        # Commit Compo    9    1    ${compo data sets}/minimal_evaluation_2.composition.json
        # Commit Compo   10    1    ${compo data sets}/minimal_evaluation_3.composition.json
        # Commit Compo   11    1    ${compo data sets}/minimal_evaluation_4.composition.json

        # Commit Compo   12    1    ${compo data sets}/minimal_instruction_2.composition.json
        # Commit Compo   13    1    ${compo data sets}/minimal_instruction_3.composition.json
        # Commit Compo   14    1    ${compo data sets}/minimal_instruction_4.composition.json

        # Commit Compo   15    1    ${compo data sets}/minimal_observation_2.composition.json
        # Commit Compo   16    1    ${compo data sets}/minimal_observation_3.composition.json
        # Commit Compo   17    1    ${compo data sets}/minimal_observation_4.composition.json

        # Commit Compo   18    1    ${compo data sets}/minimal_action2_2.composition.json
        # Commit Compo   19    1    ${compo data sets}/minimal_action2_3.composition.json


    # COMMENT: QUERY EXECUTION
        #////////////////////////////////////////////////////////////////
        #//                                                           ///
        #//  UNCOMMENT ONE LINE AT A TIME TO TEST RELATED QUERY ONLY  ///
        #//                                                           ///
        #////////////////////////////////////////////////////////////////

        execute ad-hoc query and check result (loaded DB)  A/100_get_ehrs.json    A/100.tmp.json
        # execute ad-hoc query and check result (loaded DB)  A/101_get_ehrs.json    A/101.tmp.json
        # execute ad-hoc query and check result (loaded DB)  A/102_get_ehrs.json    A/102.tmp.json
        # execute ad-hoc query and check result (loaded DB)  A/103_get_ehrs.json    A/103.tmp.json
        # execute ad-hoc query and check result (loaded DB)  A/104_get_ehrs.json    A/104.tmp.json
        # execute ad-hoc query and check result (loaded DB)  A/105_get_ehrs.json    A/105.tmp.json
        # execute ad-hoc query and check result (loaded DB)  A/106_get_ehrs.json    A/106.tmp.json
        # execute ad-hoc query and check result (loaded DB)  A/107_get_ehrs_top_5.json    A/107.tmp.json
        # execute ad-hoc query and check result (loaded DB)  A/108_get_ehrs_orderby_time-created.json    A/108.tmp.json
        # execute ad-hoc query and check result (loaded DB)  A/109_get_ehrs_within_timewindow.json       A/109.tmp.json
        # execute ad-hoc query and check result (loaded DB)  A/200_query.tmp.json    A/200.tmp.json
        # execute ad-hoc query and check result (loaded DB)  A/201_query.tmp.json    A/201.tmp.json
        # execute ad-hoc query and check result (loaded DB)  A/202_query.tmp.json    A/202.tmp.json
        # execute ad-hoc query and check result (loaded DB)  A/203_query.tmp.json    A/203.tmp.json
        # execute ad-hoc query and check result (loaded DB)  A/300_get_ehrs_by_contains_any_composition.json               A/300.tmp.json
        # execute ad-hoc query and check result (loaded DB)  A/400_get_ehrs_by_contains_composition_with_archetype.json    A/400.tmp.json
        # execute ad-hoc query and check result (loaded DB)  A/401_get_ehrs_by_contains_composition_with_archetype.json    A/401.tmp.json
        # execute ad-hoc query and check result (loaded DB)  A/402_get_ehrs_by_contains_composition_with_archetype.json    A/402.tmp.json
        # execute ad-hoc query and check result (loaded DB)  A/500_get_ehrs_by_contains_composition_contains_entry_of_type.json      A/500.tmp.json
        # execute ad-hoc query and check result (loaded DB)  A/501_get_ehrs_by_contains_composition_contains_entry_of_type.json      A/501.tmp.json
        # execute ad-hoc query and check result (loaded DB)  A/502_get_ehrs_by_contains_composition_contains_entry_of_type.json    A/502.tmp.json
        # execute ad-hoc query and check result (loaded DB)  A/503_get_ehrs_by_contains_composition_contains_entry_of_type.json    A/503.tmp.json
        # execute ad-hoc query and check result (loaded DB)  A/600_get_ehrs_by_contains_composition_contains_entry_with_archetype.json    A/600.tmp.json
        # execute ad-hoc query and check result (loaded DB)  A/601_get_ehrs_by_contains_composition_contains_entry_with_archetype.json    A/601.tmp.json
        # execute ad-hoc query and check result (loaded DB)  A/602_get_ehrs_by_contains_composition_contains_entry_with_archetype.json  A/602.tmp.json
        # execute ad-hoc query and check result (loaded DB)  A/603_get_ehrs_by_contains_composition_contains_entry_with_archetype.json  A/603.tmp.json
        
        # execute ad-hoc query and check result (loaded DB)  B/100_get_compositions_from_all_ehrs.json    B/100.tmp.json
        # execute ad-hoc query and check result (loaded DB)  B/101_get_compositions_top_5.json    B/101.tmp.json
        # execute ad-hoc query and check result (loaded DB)  B/102_get_compositions_orderby_name.json    B/102.tmp.json
        # execute ad-hoc query and check result (loaded DB)  B/103_get_compositions_within_timewindow.json    B/103.tmp.json
        # execute ad-hoc query and check result (loaded DB)  B/200_get_compositions_from_ehr_by_id.json    B/200.tmp.json
        # execute ad-hoc query and check result (loaded DB)  B/300_get_compositions_with_archetype_from_all_ehrs.json    B/300.tmp.json
        # execute ad-hoc query and check result (loaded DB)  B/400_get_compositions_contains_section_with_archetype_from_all_ehrs.json    B/400.tmp.json
        # execute ad-hoc query and check result (loaded DB)  B/500_get_compositions_by_contains_entry_of_type_from_all_ehrs.json    B/500.tmp.json
        # execute ad-hoc query and check result (loaded DB)  B/501_get_compositions_by_contains_entry_of_type_from_all_ehrs.json    B/501.tmp.json
        # execute ad-hoc query and check result (loaded DB)  B/502_get_compositions_by_contains_entry_of_type_from_all_ehrs.json    B/502.tmp.json
        # execute ad-hoc query and check result (loaded DB)  B/503_get_compositions_by_contains_entry_of_type_from_all_ehrs.json    B/503.tmp.json
        # execute ad-hoc query and check result (loaded DB)  B/600_get_compositions_by_contains_entry_with_archetype_from_all_ehrs.json    B/600.tmp.json
        # execute ad-hoc query and check result (loaded DB)  B/601_get_compositions_by_contains_entry_with_archetype_from_all_ehrs.json    B/601.tmp.json
        # execute ad-hoc query and check result (loaded DB)  B/602_get_compositions_by_contains_entry_with_archetype_from_all_ehrs.json    B/602.tmp.json
        # execute ad-hoc query and check result (loaded DB)  B/603_get_compositions_by_contains_entry_with_archetype_from_all_ehrs.json    B/603.tmp.json
        # execute ad-hoc query and check result (loaded DB)  B/700_get_compositions_by_contains_entry_with_archetype_and_condition_from_all_ehrs.json    B/700.tmp.json
        # execute ad-hoc query and check result (loaded DB)  B/701_get_compositions_by_contains_entry_with_archetype_and_condition_from_all_ehrs.json    B/701.tmp.json
        # execute ad-hoc query and check result (loaded DB)  B/702_get_compositions_by_contains_entry_with_archetype_and_condition_from_all_ehrs.json    B/702.tmp.json
        # execute ad-hoc query and check result (loaded DB)  B/802_query.tmp.json    B/802.tmp.json
        # execute ad-hoc query and check result (loaded DB)  B/803_query.tmp.json    B/803.tmp.json
        
        # execute ad-hoc query and check result (loaded DB)  D/200_select_data_values_from_all_ehrs_contains_composition.json    D/200.tmp.json
        # execute ad-hoc query and check result (loaded DB)  D/201_select_data_values_from_all_ehrs_contains_composition.json    D/201.tmp.json
        # execute ad-hoc query and check result (loaded DB)  D/300_select_data_values_from_all_ehrs_contains_composition_with_archetype.json    D/300.tmp.json
        # execute ad-hoc query and check result (loaded DB)  D/301_select_data_values_from_all_ehrs_contains_composition_with_archetype.json    D/301.tmp.json
        # execute ad-hoc query and check result (loaded DB)  D/302_select_data_values_from_all_ehrs_contains_composition_with_archetype.json    D/302.tmp.json
        # execute ad-hoc query and check result (loaded DB)  D/303_select_data_values_from_all_ehrs_contains_composition_with_archetype.json    D/303.tmp.json
        # execute ad-hoc query and check result (loaded DB)  D/304_select_data_values_from_all_ehrs_contains_composition_with_archetype.json    D/304.tmp.json
        # execute ad-hoc query and check result (loaded DB)  D/306_select_data_values_from_all_ehrs_contains_composition_with_archetype.json    D/306.tmp.json
        # execute ad-hoc query and check result (loaded DB)  D/307_select_data_values_from_all_ehrs_contains_composition_with_archetype.json    D/307.tmp.json
        # execute ad-hoc query and check result (loaded DB)  D/308_select_data_values_from_all_ehrs_contains_composition_with_archetype.json    D/308.tmp.json
        # execute ad-hoc query and check result (loaded DB)  D/309_select_data_values_from_all_ehrs_contains_composition_with_archetype.json    D/309.tmp.json
        # execute ad-hoc query and check result (loaded DB)  D/310_select_data_values_from_all_ehrs_contains_composition_with_archetype.json    D/310.tmp.json
        # execute ad-hoc query and check result (loaded DB)  D/312_select_data_values_from_all_ehrs_contains_composition_with_archetype_top_5.json    D/312.tmp.json
        # execute ad-hoc query and check result (loaded DB)  D/400_query.tmp.json    D/400.tmp.json   
        # execute ad-hoc query and check result (loaded DB)  D/401_query.tmp.json    D/401.tmp.json
        # execute ad-hoc query and check result (loaded DB)  D/402_query.tmp.json    D/402.tmp.json
        # execute ad-hoc query and check result (loaded DB)  D/403_query.tmp.json    D/403.tmp.json
        # execute ad-hoc query and check result (loaded DB)  D/404_query.tmp.json    D/404.tmp.json
        # execute ad-hoc query and check result (loaded DB)  D/405_query.tmp.json    D/405.tmp.json
        # execute ad-hoc query and check result (loaded DB)  D/500_query.tmp.json    D/500.tmp.json
        # execute ad-hoc query and check result (loaded DB)  D/501_query.tmp.json    D/501.tmp.json
        # execute ad-hoc query and check result (loaded DB)  D/502_query.tmp.json    D/502.tmp.json
        # execute ad-hoc query and check result (loaded DB)  D/503_query.tmp.json    D/503.tmp.json

        ## FUTURE FEATURE: DON'T USE YET!
            # execute ad-hoc query and check result (loaded DB)  B/800_query.tmp.json    B/800.tmp.json    # GITHUB ISSUE #109
            # execute ad-hoc query and check result (loaded DB)  B/801_query.tmp.json    B/801.tmp.json    # GITHUB ISSUE #109
            # execute ad-hoc query and check result (loaded DB)  C/100_query.tmp.json    C/100.tmp.json
            # execute ad-hoc query and check result (loaded DB)  C/101_query.tmp.json    C/101.tmp.json
            # execute ad-hoc query and check result (loaded DB)  C/102_query.tmp.json    C/102.tmp.json
            # execute ad-hoc query and check result (loaded DB)  C/103_query.tmp.json    C/103.tmp.json
            # execute ad-hoc query and check result (loaded DB)  C/200_query.tmp.json    C/200.tmp.json
            # execute ad-hoc query and check result (loaded DB)  C/300_query.tmp.json    C/300.tmp.json
            # execute ad-hoc query and check result (loaded DB)  C/301_query.tmp.json    C/301.tmp.json
            # execute ad-hoc query and check result (loaded DB)  C/302_query.tmp.json    C/302.tmp.json
            # execute ad-hoc query and check result (loaded DB)  C/303_query.tmp.json    C/303.tmp.json
            # execute ad-hoc query and check result (loaded DB)  C/400_query.tmp.json    C/400.tmp.json
            # execute ad-hoc query and check result (loaded DB)  C/500_query.tmp.json    C/500.tmp.json
            # execute ad-hoc query and check result (loaded DB)  D/311_select_data_values_from_all_ehrs_contains_composition_with_archetype.json    D/311.tmp.json

    [Teardown]    Set Smoke Test Status






#////////////////////////////////////////////////////////////////////////
#///                                                                  ///
#///      TODO: @WLAD REMOVE THIS TCs FROM HERE WHEN THEY PASS!       ///
#///       (they are duplicates of TCs in original test suite)        ///
#///                                                                  ///
#////////////////////////////////////////////////////////////////////////

001 - Execute Ad-Hoc Queries - nested contains
    [Template]          execute ad-hoc query (no result comparison)
    [tags]              nested-contains
    nested_contains/001_nested_and_contains.json
    nested_contains/002_nested_and_contains_anyehr.json
    nested_contains/003_nested_and_contains_nocompoarchid.json
    nested_contains/004_nested_and_contains_nocompoarchid_anyehr.json
    nested_contains/005_nested_and3_contains.json
    nested_contains/006_nested_and3_contains_anyehr.json
    nested_contains/007_nested_and3_contains_nocompoarchid.json
    nested_contains/008_nested_and3_contains_nocompoarchid_anyehr.json
    nested_contains/009_nested_or_contains.json
    nested_contains/010_nested_or_contains_anyehr.json
    nested_contains/011_nested_or_contains_nocompoarchid.json
    nested_contains/012_nested_or_contains_nocompoarchid_anyehr.json
    nested_contains/013_nested_or2_and_contains.json
    nested_contains/014_nested_or2_and_contains_anyehr.json
    nested_contains/015_nested_or2_and_contains_nocompoarchid.json
    nested_contains/016_nested_or2_and_contains_nocompoarchid_anyehr.json
    nested_contains/017_nested_or2_and_p_contains.json
    nested_contains/018_nested_or2_and_p_contains_anyehr.json
    nested_contains/019_nested_or2_and_p_contains_nocompoarchid.json
    nested_contains/020_nested_or2_and_p_contains_nocompoarchid_anyehr.json
    nested_contains/021_nested_or3_contains.json
    nested_contains/022_nested_or3_contains_anyehr.json
    nested_contains/023_nested_or3_contains_nocompoarchid.json
    nested_contains/024_nested_or3_contains_nocompoarchid_anyehr.json
    nested_contains/025_nested_3_levels_contains.json
    nested_contains/026_nested_3_levels_contains_anyehr.json
    nested_contains/027_nested_3_levels_contains_nocompoarchid.json
    nested_contains/028_nested_3_levels_contains_nocompoarchid_anyehr.json
    [Teardown]          TRACE GITHUB ISSUE  NO-ISSUE  not-ready


002 - Execute Ad-Hoc Queries - nested contains
    [Template]          execute ad-hoc query (no result comparison)
    [Documentation]     {"error":"Could not retrieve stored query, reason:java.lang.NullPointerException","status":"Bad Request"}
    [tags]              nested-contains    260
    nested_contains/029_nested_4_levels_contains.json
    nested_contains/031_nested_4_levels_contains_noarchid_1.json
    nested_contains/032_nested_4_levels_contains_noarchid_2.json
    nested_contains/033_nested_4_levels_contains_nocompoarchid.json
    nested_contains/035_nested_5_levels_contains.json
    nested_contains/037_nested_5_levels_contains_noarchid_1.json
    nested_contains/038_nested_5_levels_contains_noarchid_2.json
    nested_contains/039_nested_5_levels_contains_noarchid_3.json
    nested_contains/040_nested_5_levels_contains_nocompoarchid.json
    nested_contains/042_nested_6_levels_contains.json
    nested_contains/044_nested_6_levels_contains_noarchid_1.json
    nested_contains/045_nested_6_levels_contains_noarchid_2.json
    nested_contains/046_nested_6_levels_contains_noarchid_3.json
    nested_contains/047_nested_6_levels_contains_noarchid_4.json
    nested_contains/048_nested_6_levels_contains_nocompoarchid.json
    [Teardown]          TRACE GITHUB ISSUE  260  not-ready


003 - Execute Ad-Hoc Queries - nested contains
    [Template]          execute ad-hoc query (no result comparison)
    [Documentation]     {'error': 'Could not process query, reason:java.lang.NullPointerException','status': 'Bad Request'}
    [tags]              nested-contains
    nested_contains/030_nested_4_levels_contains_anyehr.json
    nested_contains/034_nested_4_levels_contains_nocompoarchid_anyehr.json
    nested_contains/036_nested_5_levels_contains_anyehr.json
    nested_contains/041_nested_5_levels_contains_nocompoarchid_anyehr.json
    nested_contains/043_nested_6_levels_contains_anyehr.json
    nested_contains/049_nested_6_levels_contains_nocompoarchid_anyehr.json
    [Teardown]          TRACE GITHUB ISSUE  313  not-ready
    

A-101 Execute Ad-Hoc Query - Get EHRs
    [Template]          execute ad-hoc query and check result (loaded DB)
    [Tags]              205
    A/101_get_ehrs.json    A/101.tmp.json
    [Teardown]          TRACE GITHUB ISSUE  205  not-ready


B-100 Execute Ad-Hoc Query - Get Compositions From All EHRs
    [Template]          execute ad-hoc query and check result (loaded DB)
    [Tags]              235
    B/100_get_compositions_from_all_ehrs.json    B/100.tmp.json
    [Teardown]          TRACE GITHUB ISSUE  235  not-ready


B-102 Execute Ad-Hoc Query - Get Compositions (ordered by: name)
    [Template]          execute ad-hoc query and check result (loaded DB)
    [Tags]              TODO
    B/102_get_compositions_orderby_name.json    B/102.tmp.json
    # execute ad-hoc query    B/102_get_compositions_orderby_name.json
    # check response (LOADED DB): returns correct ordered content    B/102.tmp.json
    [Teardown]          TRACE GITHUB ISSUE  TODO  not-ready


B-400 Execute Ad-Hoc Query - Get Composition(s)
    [Documentation]     Test w/ "all_types.composition.json" commit
    [Template]          execute ad-hoc query and check result (loaded DB)
    [Tags]              234
    B/400_get_compositions_contains_section_with_archetype_from_all_ehrs.json    B/400.tmp.json
    [Teardown]          TRACE GITHUB ISSUE  234  not-ready


B-800 Execute Ad-Hoc Query - Get Compositions By UID
    [Documentation]     B/800: SELECT c FROM COMPOSITION c [uid/value='123::node.name.com::1']
    ...                 B/801: SELECT c FROM COMPOSITION c [uid/value=$uid]
    [Template]          execute ad-hoc query and check result (loaded DB)
    [Tags]              109    future
    B/800_query.tmp.json    B/800.tmp.json
    B/801_query.tmp.json    B/801.tmp.json
    [Teardown]          TRACE GITHUB ISSUE  109  not-ready  still blocked by


D-306 Execute Ad-HOc Query - Get Data
    [Documentation]     Get Data related query.
    [Template]          execute ad-hoc query and check result (loaded DB)
    [Tags]              206
    D/306_select_data_values_from_all_ehrs_contains_composition_with_archetype.json    D/306.tmp.json
    [Teardown]          TRACE GITHUB ISSUE  206  not-ready


D-309 Execute Ad-HOc Query - Get Data
    [Documentation]     Get Data related query.
    [Template]          execute ad-hoc query and check result (loaded DB)
    [Tags]              205
    D/309_select_data_values_from_all_ehrs_contains_composition_with_archetype.json    D/309.tmp.json
    [Teardown]          TRACE GITHUB ISSUE  205  not-ready


D-312 Execute Ad-HOc Query - Get Data
    [Documentation]     Get Data related query.
    [Template]          execute ad-hoc query and check result (loaded DB)
    [Tags]              TODO  # @WLAD implement a flow w/ TOP5 + ORDERED BY time_created
    D/312_select_data_values_from_all_ehrs_contains_composition_with_archetype_top_5.json    D/312.tmp.json


D-500 Execute Ad-HOc Query - Get Data
    [Documentation]     Get Data related query.
    [Template]          execute ad-hoc query and check result (loaded DB)
    [Tags]              208
    D/500_query.tmp.json    D/500.tmp.json
    [Teardown]          TRACE GITHUB ISSUE  208  not-ready


D-501 Execute Ad-HOc Query - Get Data
    [Documentation]     Get Data related query.
    [Template]          execute ad-hoc query and check result (loaded DB)
    [Tags]              236
    D/501_query.tmp.json    D/501.tmp.json
    [Teardown]          TRACE GITHUB ISSUE  236  not-ready


CLEAN UP SUT
    [Documentation]     ATTENTION: ALWAYS INCLUDE '-i SMOKE' and '-i tempANDissue_id'
    ...                 when you run test from this suite!!!
    [Tags]              SMOKE
    db_keywords.Delete All templates
    db_keywords.Delete All EHR Records







*** Keywords ***
# oooo    oooo oooooooooooo oooooo   oooo oooooo   oooooo     oooo   .oooooo.   ooooooooo.   oooooooooo.    .oooooo..o
# `888   .8P'  `888'     `8  `888.   .8'   `888.    `888.     .8'   d8P'  `Y8b  `888   `Y88. `888'   `Y8b  d8P'    `Y8
#  888  d8'     888           `888. .8'     `888.   .8888.   .8'   888      888  888   .d88'  888      888 Y88bo.
#  88888[       888oooo8       `888.8'       `888  .8'`888. .8'    888      888  888ooo88P'   888      888  `"Y8888o.
#  888`88b.     888    "        `888'         `888.8'  `888.8'     888      888  888`88b.     888      888      `"Y88b
#  888  `88b.   888       o      888           `888'    `888'      `88b    d88'  888  `88b.   888     d88' oo     .d8P
# o888o  o888o o888ooooood8     o888o           `8'      `8'        `Y8bood8P'  o888o  o888o o888bood8P'   8""88888P'
#
# [ THIS KWs OVERIDE EXISTING KWs IN RESOURCE FILE TO WORK PROPERLY IN SMOKE TEST ]

D/500
    [Documentation]     Condition: compo must be an Observation and must belong to first EHR record.
    ${is_observation}=  Set Variable if  ("${compo_content_archetype_node_id}"=="openEHR-EHR-OBSERVATION.minimal.v1")  ${TRUE}
    ${is_from_ehr_1}=   Set Variable If  ${ehr_index}==1  ${TRUE}
                        Return From Keyword If    not (${is_observation} and ${is_from_ehr_1})    NOTHING TO DO HERE!
                        Run Keyword if    ${ehr_index}==1 and ${compo_index}==4    Update Temp Query-Data-Set    D/500
                        Create Temp List    ${compo_uid_value}
                        ...                 ${compo_name_value}
                        ...                 ${compo_data_origin_value}
                        ...                 ${compo_events_time_value}
                        ...                 ${compo_events_items_value_value}
                        Update 'rows', 'q' and 'meta' in Temp Result-Data-Set    D/500


D/501
    [Documentation]     Same flow as D/500, different content in 'rows'
    ${is_observation}=  Set Variable if  ("${compo_content_archetype_node_id}"=="openEHR-EHR-OBSERVATION.minimal.v1")  ${TRUE}
    ${is_from_ehr_1}=   Set Variable If  ${ehr_index}==1  ${TRUE}
                        Return From Keyword If    not (${is_observation} and ${is_from_ehr_1})    NOTHING TO DO HERE!
                        Run Keyword if    ${ehr_index}==1 and ${compo_index}==4    Update Temp Query-Data-Set    D/501
                        Create Temp List    ${compo_uid}
                        ...                 ${compo_name}
                        ...                 ${compo_data_origin}
                        ...                 ${compo_events_time}
                        ...                 ${compo_events_items_value}
                        Update 'rows', 'q' and 'meta' in Temp Result-Data-Set    D/501


D/502
    [Documentation]     Similar flow as D/500, but different element is replaced in query-data-set.
    ...                 Condition: compo must be an Observation and must belong to first EHR record.
    ${is_observation}=  Set Variable if  ("${compo_content_archetype_node_id}"=="openEHR-EHR-OBSERVATION.minimal.v1")  ${TRUE}
    ${is_from_ehr_1}=   Set Variable If  ${ehr_index}==1  ${TRUE}
                        Return From Keyword If    not (${is_observation} and ${is_from_ehr_1})    NOTHING TO DO HERE!
                        Run Keyword if    ${ehr_index}==1 and ${compo_index}==4    Update Query-Parameter in Temp Query-Data-Set    D/502
                        Create Temp List    ${compo_uid_value}
                        ...                 ${compo_name_value}
                        ...                 ${compo_data_origin_value}
                        ...                 ${compo_events_time_value}
                        ...                 ${compo_events_items_value_value}
                        Load Temp Result-Data-Set    D/502
    ${meta_exec_aql}=   Get Value From Json    ${expected}    $.meta._executed_aql
    ${meta_exec_aql}=   Replace String    ${meta_exec_aql}[0]    __MODIFY_EHR_ID_1__    ${ehr_id}
                        Update Value To Json   ${expected}    $.meta._executed_aql    ${meta_exec_aql}
                        Output    ${expected}     ${QUERY RESULTS LOADED DB}/D/502.tmp.json
                        Update 'rows' in Temp Result-Data-Set    D/502


D/503
    [Documentation]     Similar flow as D/500, but different element is replaced in query-data-set.
    ...                 Condition: compo must be an Observation and must belong to first EHR record.
    ${is_observation}=  Set Variable if  ("${compo_content_archetype_node_id}"=="openEHR-EHR-OBSERVATION.minimal.v1")  ${TRUE}
    ${is_from_ehr_1}=   Set Variable If  ${ehr_index}==1  ${TRUE}
                        Return From Keyword If    not (${is_observation} and ${is_from_ehr_1})    NOTHING TO DO HERE!
                        Run Keyword if    ${ehr_index}==1 and ${compo_index}==4    Update Query-Parameter in Temp Query-Data-Set    D/503
                        Create Temp List    ${compo_uid}
                        ...                 ${compo_name}
                        ...                 ${compo_data_origin}
                        ...                 ${compo_events_time}
                        ...                 ${compo_events_items_value}
                        Load Temp Result-Data-Set    D/503
    ${meta_exec_aql}=   Get Value From Json    ${expected}    $.meta._executed_aql
    ${meta_exec_aql}=   Replace String    ${meta_exec_aql}[0]    __MODIFY_EHR_ID_1__    ${ehr_id}
                        Update Value To Json   ${expected}    $.meta._executed_aql    ${meta_exec_aql}
                        # Set Suite Variable    ${expected}    ${expected}
                        Output    ${expected}     ${QUERY RESULTS LOADED DB}/D/503.tmp.json
                        Update 'rows' in Temp Result-Data-Set    D/503

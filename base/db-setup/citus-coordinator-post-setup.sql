
-- to make the test more meaningful with my environment
SELECT alter_distributed_table('ehr.status', shard_count:=6, cascade_to_colocated:=true);
SELECT alter_distributed_table('ehr.entry', shard_count:=6, cascade_to_colocated:=true);
-- should do the same with the other distributed tables. Can see that ehr.status is actual distributed among workers

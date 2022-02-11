-- this is site specific, here we setup one coordinator and two workers.
-- run this only on the coordinator!
SELECT citus_set_coordinator_host('192.168.0.18');
SELECT citus_add_node('192.168.0.28', 5432);
SELECT citus_add_node('192.168.0.38', 5432);

SELECT citus_get_active_worker_nodes();

\ir 'spec_helper.sql'
\ir ../install.sql

\set pt_json `cat $FHIRBASE_HOME/test/fixtures/patient.json`

BEGIN;
SELECT plan(7);

select fhir.insert_resource(:'pt_json'::json) as resource_id \gset

SELECT :'resource_id';

SELECT is(count(*)::integer, 1, 'insert patient')
       FROM fhir.patient;

SELECT is(
       (SELECT family FROM fhir.patient_name
         WHERE text = 'Roel'
         AND resource_id = :'resource_id'),
       ARRAY['Bor']::varchar[],
       'should record name');

SELECT is(_type, 'patient')
       FROM fhir.resource
       WHERE id = :'resource_id';

SELECT is(count(*)::int, 2)
       FROM fhir.patient_gender_cd
       WHERE resource_id = :'resource_id';

SELECT is_empty(
  'SELECT *
  FROM fhir.resource_component
  WHERE _unknown_attributes IS NOT NULL',
  'should not contain any _unknown_attributes'
);

SELECT is((SELECT name FROM fhir.organization
       WHERE container_id = :'resource_id' LIMIT 1),
       'ACME'::varchar,
       'contained resource was correctly saved');

SELECT is((SELECT ot.value FROM fhir.organization_telecom ot
       JOIN fhir.organization o ON o.id = ot.parent_id
       WHERE o.container_id = :'resource_id' LIMIT 1),
       '+31612234322'::varchar,
       'contained resource was correctly saved');

SELECT * FROM finish();
ROLLBACK;

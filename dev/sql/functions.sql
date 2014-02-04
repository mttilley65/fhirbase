create OR replace function underscore(str varchar)
  returns varchar
  language plv8
  as $$
   load_module('shared')
   return underscore(str)
$$;

-- remove last item from array
CREATE OR REPLACE
FUNCTION array_pop(ar varchar[])
  RETURNS varchar[] language plv8 AS $$
  ar.pop()
  return ar;
$$;

DROP FUNCTION array_last(varchar[]) CASCADE;
CREATE OR REPLACE
FUNCTION array_last(ar varchar[])
  RETURNS varchar language plv8 AS $$
  return ar[ar.length -1];
$$;
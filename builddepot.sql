
/* produciton change */
/* depot paths */
/*
create table depotpaths
(
  depotpaths_id serial
  , depotpath text
  , hash int
);
create index depotpaths_hash on depotpaths(hash) ;
*/
-- drop index depotpaths_depotpath ;
-- create unique index depotpaths_depotpath on depotpaths(depotpath);

create or replace function create_or_find_depotpaths( in_path text) returns integer
language 'plpgsql' as
$$
DECLARE
  in_hash int;
  id int;
BEGIN
    in_hash := hashtext(in_path);
    select into id depotpath_id from depotpaths where hash = in_hash and depotpath = in_path;
    if id is null then
        insert into depotpaths(depotpath_id, depotpath, hash) values
              ( DEFAULT, in_path, in_hash) returning depotpath_id into id;
    end if;
    return id;
END;
$$;

drop function find_all() ;
create or replace function find_all() returns boolean
language 'plpgsql' as
$find_all$
DECLARE
  curs1 refcursor;
  -- s text;
  -- o text;
  rc integer;
  rec record;
BEGIN
  OPEN curs1 for select object, subject from integed ;
  <<build_depot>>
  LOOP
    FETCH curs1 INTO rec ;
    EXIT build_depot WHEN NOT FOUND;
    rc:= create_or_find_depotpaths(rec.subject);
    rc:=create_or_find_depotpaths(rec.object);
  END LOOP build_depot; 
  CLOSE curs1;
  return true;
END;
$find_all$;

/*

Table "public.label"
 depotpath       | text    | not null

Table "public.rev"
 depotpath       | text                  | not null
 rcs_file        | text                  | 

Table "public.revcx"
 depotpath       | text    | not null

*/
create or replace function find_all_too() returns boolean
language 'plpgsql' as
$find_all$
DECLARE
  curs1 refcursor;
  curs2 refcursor;
  curs3 refcursor;
  curs4 refcursor;
  -- s text;
  -- o text;
  rc boolean;
  rec record;
  
BEGIN
  OPEN curs1 for select depotpath as pathname from label;
  rc:= find_all_by_cur(curs1);
  OPEN curs2 for select depotpath as pathname from revcx;
  rc:= find_all_by_cur(curs2);
  return rc;
END;
$find_all$;


create or replace function find_all_by_cur(curs1 refcursor) returns boolean
language 'plpgsql' as
$$
DECLARE
  rc integer;
  rec record;
BEGIN
  <<build_depot>>
  LOOP
    FETCH curs1 INTO rec ;
    EXIT build_depot WHEN NOT FOUND;
    rc:= create_or_find_depotpaths(rec.pathname);
  END LOOP build_depot; 
  CLOSE curs1;
  return true;
END;
$$;

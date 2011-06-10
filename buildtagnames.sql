/*
 *
 * label tags 
 *
 */

create or replace function create_or_find_tagname(in_tag text ) returns integer
language 'plpgsql' as
$$
DECLARE
  in_hash int;
  id int;
BEGIN
    in_hash := hashtext(in_tag);
    select into id tagname_id from tagnames
                  where hash = in_hash and tagname = in_tag;
    if id is null then
        insert into tagnames(tagname_id, tagname, hash) values
              ( DEFAULT, in_tag, in_hash) returning tagname_id into id;
    end if;
    return id;
END;
$$;

drop function find_all_tags() ;
create or replace function find_all_tags() returns boolean
language 'plpgsql' as
$find_all$
DECLARE
  curs1 refcursor;
  -- s text;
  -- o text;
  rc integer;
  rec record;
BEGIN
  OPEN curs1 for select tagname from label ;
  <<build>>
  LOOP
    FETCH curs1 INTO rec ;
    EXIT build WHEN NOT FOUND;
    rc:= create_or_find_tagname(rec.tagname);
  END LOOP build; 
  CLOSE curs1;
  return true;
END;
$find_all$;


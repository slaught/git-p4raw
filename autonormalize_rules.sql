-- This is the meat of the metadata, really.  We index 12 distinct
-- varieties of crap out of this once it's loaded, and end up querying
-- it a lot.
alter table integed rename  to integed_normalize;

create table integed (
    subject text not null,	-- what file this log refers to
    object  text not null,	-- file the record refers to in objective
    object_minrev int not null,	-- objective revisions range - lower bound
    object_maxrev int not null,	-- upper bound
    subject_minrev int not null, -- subject revision range - lower
    subject_maxrev int not null, -- upper
    int_type int not null references int_type,
    change int not null,	-- Change this occurred in
--    primary key (change, subject, subject_maxrev, object, object_maxrev)
) inherits (source_file);

-- -------------------------------------------------------------
create function depotpath_rewrite() RETURNS trigger 
language 'plpgsql' as
$$
DECLARE

BEGIN

  IF TG_TABLE_NAME = 'integed' then
      NEW.subject := create_or_find_depotpaths(NEW.subject);
      NEW.object := create_or_find_depotpaths(NEW.object);
  ELSIF TG_TABLE_NAME = 'rev' then
      NEW.rcs_file := create_or_find_depotpaths(NEW.rcs_file);
      NEW.depotpath := create_or_find_depotpaths(NEW.depotpath);
  ELSIF TG_TABLE_NAME = 'revcx'  then
      NEW.depotpath := create_or_find_depotpaths(NEW.depotpath);
  ELSIF TG_TABLE_NAME = 'label'  then
      NEW.depotpath := create_or_find_depotpaths(NEW.depotpath);
      NEW.tagname := create_or_find_tagname(NEW.tagname); 
  END IF;
  return NEW;
END;
$$;

/* add triggers to all the tables */
create trigger tg_depotpath_rewrite 
BEFORE INSERT ON 
integed  
FOR  EACH  ROW EXECUTE PROCEDURE 
  depotpath_rewrite ()
;
create trigger tg_depotpath_rewrite  
BEFORE INSERT ON 
rev
FOR  EACH  ROW EXECUTE PROCEDURE 
  depotpath_rewrite ()
;
create trigger tg_depotpath_rewrite  
BEFORE INSERT ON 
revcx
FOR  EACH  ROW EXECUTE PROCEDURE 
  depotpath_rewrite ()
;
create trigger tg_depotpath_rewrite  
BEFORE INSERT ON 
label
FOR  EACH  ROW EXECUTE PROCEDURE 
  depotpath_rewrite ()
;

create or replace function D(text) returns integer language 'sql' as $$ select create_or_find_depotpaths($1); $$;



gitp4raw=> create RULE rewrite_integ_insert as on insert to integed do instead
insert into integed values (NEW.source_file_id,
NEW.source_file_max,D(NEW.subject_id),D(NEW.object_id),NEW.object_minrev,NEW.object_maxrev,NEW.subject_minrev,NEW.subject_maxrev,NEW.int_type,NEW.change)
;



/*
TODO: create update triggers. DONE
TODO: fix queries to join tables.
*/
/*
          name          |    bytes    |  pages  |    size    
------------------------+-------------+---------+------------
 public.integed         | 24609824768 | 2910239 | 23 GB
 public.revcx           | 18659000320 |  794270 | 17 GB
 public.rev             | 26493878272 | 1783629 | 25 GB
 public.label           | 64189489152 | 2757268 | 60 GB

*/


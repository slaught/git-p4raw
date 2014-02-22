
/*
 * Example & Tests
create table testtable
(
  id int
  , path1 text
  , path2 text
  , change int
);
insert into testtable values ( 1, '//depot/one','//depot/one', 10);
insert into testtable values ( 1, '//depot/two','//depot/three', 100);
alter table testtable alter column path1 type integer using create_or_find_depotpaths(path1);

alter table testtable alter column path2 type integer;
insert into testtable values ( 2, '//depot/one/two/three','//depot/one/2/3', 10);
insert into testtable values ( 2, '//depot/two/three','//depot/three/2/3', 100);
*/
/* produciton change */

begin;
alter table integed 
   alter column subject type integer using create_or_find_depotpaths(subject)
 , add foreign key (subject) references depotpaths (depotpath_id) 
 , alter column object type integer using create_or_find_depotpaths(object)
 , add foreign key (object) references depotpaths (depotpath_id) 
;
alter table rev 
    alter column rcs_file type integer using create_or_find_depotpaths(rcs_file)
  , add foreign key (rcs_file) references depotpaths (depotpath_id) 
  , alter column depotpath type integer using create_or_find_depotpaths(depotpath)
  , add foreign key (depotpath) references depotpaths (depotpath_id) 
;
alter table revcx 
    alter column depotpath type integer using create_or_find_depotpaths(depotpath)
  , add foreign key (depotpath) references depotpaths (depotpath_id) 
;
alter table label 
  alter column depotpath type integer using create_or_find_depotpaths(depotpath)
  , add foreign key (depotpath) references depotpaths (depotpath_id) 
  , alter column tagname type integer using create_or_find_tagname(tagname) 
  , add foreign key (tagname) references tagnames  (tagname_id) 
;

commit;

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

create function D(text) returns integer language 'sql' as $$ select create_or_find_depotpaths($1); $$;



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


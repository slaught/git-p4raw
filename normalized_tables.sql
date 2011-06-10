
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
-- alter table revcx alter column depotpath type integer using create_or_find_depotpaths(depotpath);


/* depot paths */
create table depotpaths
(
  depotpaths_id serial primary key
  , depotpath text
  , hash int
);
create index depotpaths_hash on depotpaths(hash) ;
create index unique depotpaths_depotpath on depotpaths(depotpath);


/*
 *
 * label tags 
 *
 */
--      NEW.tagname := create_or_find_tagname(NEW.tagname); 
create table tagnames 
(
  tagname_id serial primary key
  , tagname text
  , hash int
);
create index tagname_hash on tagnames(hash) ;


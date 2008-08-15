select video_id, match ( title, sentence, year ) against ( "the" ) as r from video_fulltexts where match ( title, sentence, year ) against ( "the" in boolean mode ) order by r desc;

select video_id, match ( title, sentence, year ) against ( "acommonword" ) as r from video_fulltexts where match ( title, sentence, year ) against ( "acommonword" in boolean mode ) order by r desc;

select video_id, match ( title, sentence, year ) against ( "dolorem acommonword" ) as r from video_fulltexts where match ( title, sentence, year ) against ( "dolorem acommonword" in boolean mode ) order by r desc;


select video_id, match ( title, sentence, year ) against ( "acommonword" in boolean mode ) as r from video_fulltexts order by r desc;

select video_id, match ( title, sentence, year ) against ( "acommonword" ) as r from video_fulltexts order by r desc;



select video_id, match ( title, sentence, year ) against ( "seventy" ) as r from video_fulltexts where match ( title, sentence, year ) against ( "seventy" in boolean mode ) order by r desc;


select video_id, match ( title, sentence, year ) against ( "dolorem seventy" ) as r from video_fulltexts where match ( title, sentence, year ) against ( "dolorem seventy" in boolean mode ) order by r desc;


select distinct vfs.video_id, match ( title, sentence, year ) against ( "dolorem seventy" ) as r
   from video_fulltexts vfs, descriptors_videos dvs
   where match ( title, sentence, year ) against ( "dolorem seventy" in boolean mode )
     and vfs.video_id = dvs.video_id
     and dvs.descriptor_id = 10
   order by r desc;

select vfs.video_id, match ( title, sentence, year ) against ( "dolorem seventy" ) as r
   from video_fulltexts vfs, descriptors_videos dvs
   where match ( title, sentence, year ) against ( "dolorem seventy" in boolean mode )
     and vfs.video_id = dvs.video_id
     and dvs.descriptor_id = 10
   order by r desc;

select videos.*, match ( vfs.title, vfs.sentence, vfs.year ) against ( "dolorem seventy" ) as r
  from videos, video_fulltexts vfs, descriptors_videos dvs
  where match ( vfs.title, vfs.sentence, vfs.year ) against ( "dolorem seventy" in boolean mode )
    and videos.id = dvs.video_id
    and dvs.descriptor_id = 10
    and videos.id = vfs.video_id
  order by r desc;

select videos.*, match ( vfs.title, vfs.sentence, vfs.year ) against ( "dolorem seventy" ) as r
  from videos, video_fulltexts vfs, descriptors_videos dvs
  where (match ( vfs.title, vfs.sentence, vfs.year ) against ( "dolorem seventy" in boolean mode ))
    and (videos.id = dvs.video_id)
    and (dvs.descriptor_id = 10)
    and (videos.id = vfs.video_id)
  order by r desc;

select video_id, match ( title, sentence, year ) against ( "forty" ) as r from video_fulltexts where match ( title, sentence, year ) against ( "forty" in boolean mode ) order by r desc;


SELECT distinct videos.*, match ( vfs.title, vfs.sentence, vfs.year ) against ( 'dolorem seventy' ) as r FROM `videos` join video_fulltexts vfs WHERE (((match ( vfs.title, vfs.sentence, vfs.year ) against ( 'dolorem seventy' in boolean mode ))AND(videos.id = vfs.video_id))) ORDER BY r desc LIMIT 0, 10;



 SELECT count(*)
        AS count_distinct_videos_all_match_vfs_title_vfs_sentence_vfs_year_against_dolorem_seventy_as_r
        FROM `videos`    join video_fulltexts vfs
        WHERE (((match ( vfs.title, vfs.sentence, vfs.year ) against ( 'dolorem seventy' in boolean mode ))AND(videos.id = vfs.video_id)));

SELECT count(distinct videos.*, match ( vfs.title, vfs.sentence, vfs.year ) against ( 'dolorem seventy' ) as r) AS count_distinct_videos_all_match_vfs_title_vfs_sentence_vfs_year_against_dolorem_seventy_as_r FROM `videos`    join video_fulltexts vfs WHERE (((match ( vfs.title, vfs.sentence, vfs.year ) against ( 'dolorem seventy' in boolean mode ))AND(videos.id = vfs.video_id)));




select video_id, match ( year ) against ( "1929" ) from video_fulltexts;

SELECT videos.*, match ( vfs.title, vfs.sentence, vfs.year ) against ( 'et' ) as r FROM `videos` join video_fulltexts vfs, descriptors_videos dvs WHERE (((match ( vfs.title, vfs.sentence, vfs.year ) against ( '+et' in boolean mode ))AND(videos.id = vfs.video_id)AND(videos.id = dvs.video_id)AND(dvs.descriptor_id = '2'))) ORDER BY r desc LIMIT 0, 10

select video_id, match ( title, sentence, year ) against ( "1929" ) from video_fulltexts;

select video_id from video_fulltexts where  match ( title, sentence, year ) against ( "et" );

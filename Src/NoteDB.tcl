proc MkUserTable {filename} {
   #create metakit table for user data
      
   #ID:article_ID / lemid
   #NR: running number of note in that article (as indicated by ID)
   #POS: line.char position in textwidget
   #CONTEXT: a few words to the left and right of the note
   #TYPE: 0->Bookmark; 1->NOTE
   #TEXT: if TYPE=1, then TEXT contains the note text
   #EXPMARK: expansion marker "expa$LEMID@DIGIT@DIGIT"
   mk::file open UDB $filename
   mk::view layout UDB.NOTES {ID NR POS CONTEXT TYPE TEXT EXPMARK}
   mk::view size UDB.NOTES 0
   
   mk::view layout UDB.QUERY {DATE INPUT NHITS}
   mk::view size UDB.QUERY 0
}
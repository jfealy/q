// arguments are symbol path to bad log, handle to new tp log


hd8:0x0100000000000000 // an 8 byte header
// 0x01 little endian
// 000000
// 00000000 -> indices 7 6 5 4 which will be replaced with the size of each log file chunk + the 8 bytes of the header itself

id:"\000\000\003\000\000\000\365upd" // an identifier for the start of each log file message which will  be used to split up the byte sequence

// note: the above is intended for use with a log file message which begins with (`upd;..;..)
// 1st \000 type (list)
// 2nd \000 attributes

chunkSize:10000000; //modify to whatever you want
d:`st`sz!(0;chunkSize);
`:newLog set ();
h:hopen `:newLog;


fixLog:{[cLog;h;d]                                  //cLog - corrupt tplog ; new tplog
    0N!"Executing with offset of ",string[d`st]," bytes and a chunk size of ",string[d`sz]," bytes...";
    if[hcount[cLog]<=d[`st]+d[`sz]div 2;:d];        // end of file - done
    i:ss["c"$r:read1 cLog,d`st`sz;id];              // indices of byte sequence to split   
    msgs:i _ r;                                     // split into the individual chunks
    size:0x0 vs'"i"$8+c:count each msgs;            // calculate size of each chunk & add on header size, convert back to bytes
    hd:@[hd8;7 6 5 4;:;]each size;                  // create a new header for each chunk size
    r:@[-9!;;()]each hd,'msgs;                      // try and deserialise each chunk
    h r j:where 3=count each r;                     // send deserialised chunks to new tplog
    if[not count j;:@[d;`sz;*;2]];                  // if no valid chunks this run, increase default chunk size
    newSt:d[`st]+ sums[c]last j;                    // move to end of last valid chunk and define a new start point
    @[d;`st`sz;:;(newSt;chunkSize)]                 // return new dictionary, allows execution to repeat
 };
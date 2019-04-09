// Use this code to merge two HDBs

L:{-1 x;};

.merge.remapPart:{
    L"Remapping partitioned table ",string y;
    c:cols[y]where"s"=value[meta y]`t;          // get all symbol type columns
    allPaths:.Q.par'[`:.;.Q.PV;y];              // paths to each table location (sensitive to par.txt)
    @[;c;x]@'allPaths;                          // apply map function to each column
 };

.merge.remapSplay:{
    L"Remapping splayed table ",string y;
    c:cols[y]where"s"=value[meta y]`t;          // get all symbol type columns
    @[hsym y;c;x];                              // apply map function to each column
 };

.merge.main:{[dest;src]                                         //args are absolute paths to new HDB & old HDB
    L"Enumerating src sym vector to dest sym file";
    map:.Q.dd[hsym`$dest;`sym]?get .Q.dd[hsym`$src;`sym];       // enumerate the syms in old sym file to new sym file and return the enumeration
    system"l ",src;                                             // map the location of the HBD you wish to move
    splayTabs:tables[]where(0b~.Q.qp value@)@'tables`;          // seperate splayed tables
    .merge.remapPart[map;]@'.Q.pt;                              // remap all symbol type columns in partitioned tables (modify if user wishes to move a subset of tables)
    .merge.remapSplay[map;]@'splayTabs;                         // remap all symbol type columns in splayed tables (modify if user wishes to move a subset of tables)
    L"Done.";
 };

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/
 sample usage

q)\l /home/ec2-user/dir1 // -> destination dir
q)
q)
q)t
date       a b c d
------------------
2019.04.07 b k g k
2019.04.07 i k p i
2019.04.07 k l n f
2019.04.07 k f g e
2019.04.07 m j e b
q)
q)sym
`m`i`k`b`j`l`f`e`p`n`g
q)
q)\l /home/ec2-user/dir2 // -> source dir
q)
q)t
date       a b c d
------------------
2019.04.08 A B B M
2019.04.08 C J N L
2019.04.08 H C O M
2019.04.08 J O I H
2019.04.08 N B I K
2019.04.09 C E N K
2019.04.09 E O H E
2019.04.09 F C I M
2019.04.09 M O F B
2019.04.09 M N G M
q)
q)splay1
c1 c2 c3
--------
do ii ij
nc ch ap
df bo ml
ho ed fm
of ce ii
q)
q)splay2
c1 c2 c3
--------
fp pk gc
ol kj jo
pf ig ap
ll nf nn
cn no am
q)
q)sym
`N`J`C`H`A`B`O`I`K`L`M`E`F`G`do`nc`df`ho`of`ii`ch`bo`ed`ce`ij`ap`ml`fm`fp`ol`..
q)
q)
q)\l /home/ec2-user/code/mergeHdb.q // -> load in code
q)
q).merge.main["/home/ec2-user/dir1";"/home/ec2-user/dir2"] // args are ABSOLUTE paths to dest & src directories
Enumerating src sym vector to dest sym file
Remapping partitioned table t
Remapping splayed table splay1
Remapping splayed table splay2
Done.
q)
q)
ec2-user@/home/ec2-user  $ ## move the data from src to dest (this part is left to the developer)
ec2-user@/home/ec2-user  $
ec2-user@/home/ec2-user  $ mv /home/ec2-user/dir2/201* /home/ec2-user/dir1
ec2-user@/home/ec2-user  $ mv /home/ec2-user/dir2/splay* /home/ec2-user/dir1
ec2-user@/home/ec2-user  $
ec2-user@/home/ec2-user  $ q
KDB+ 3.6 2018.12.06 Copyright (C) 1993-2018 Kx Systems
l64/ 1(16)core 990MB ec2-user ip-172-31-0-152.us-east-2.compute.internal 172.31.0.152 EXPIRE 2020.03.12 jfealy@kx.com KOD #4164000

q)\l /home/ec2-user/dir1 // -> map destination dir once again
q)
q)t
date       a b c d
------------------
2019.04.07 b k g k
2019.04.07 i k p i
2019.04.07 k l n f
2019.04.07 k f g e
2019.04.07 m j e b
2019.04.08 A B B M
2019.04.08 C J N L
2019.04.08 H C O M
2019.04.08 J O I H
2019.04.08 N B I K
2019.04.09 C E N K
2019.04.09 E O H E
2019.04.09 F C I M
2019.04.09 M O F B
2019.04.09 M N G M
q)
q)splay1
c1 c2 c3
--------
do ii ij
nc ch ap
df bo ml
ho ed fm
of ce ii
q)
q)splay2
c1 c2 c3
--------
fp pk gc
ol kj jo
pf ig ap
ll nf nn
cn no am
q)
q)sym
`m`i`k`b`j`l`f`e`p`n`g`N`J`C`H`A`B`O`I`K`L`M`E`F`G`do`nc`df`ho`of`ii`ch`bo`ed..
q)
q)// data successfully merged and all symbols maintained correctly. New sym vector is populated with symbols from src.
q)// it is left to the developer to reapply any lost attributes

/
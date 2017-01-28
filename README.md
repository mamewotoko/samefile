samefile [![Build Status](https://travis-ci.org/mamewotoko/samefile.svg?branch=master)](https://travis-ci.org/mamewotoko/samefile)
========
collect same file and output them in one line separated by tab

Build
-----
```
make
```

Run
---
```
./samefile [PATH...]
```

TODO
----
* summarize directory which contains same files
  * e.g. directory A may be copy of B because A and B has many same files
* map reduce?
  * group files by size and compare files whose size are same
  * distributed computing
    * ocaml on hadoop?
* output action to remove duplicate
  * generate link
  * remove file
  * check date
* detect similar file
  * distance
  * included

Reference
---------
* [OCamlMakefile](http://mmottl.github.io/ocaml-makefile/)
* [ocaml/ocaml-ci-scripts](https://github.com/ocaml/ocaml-ci-scripts)

----
Takashi Masuyama < mamewotoko@gmail.com >  
http://mamewo.ddo.jp/

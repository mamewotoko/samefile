samefile [![CI](https://github.com/mamewotoko/samefile/actions/workflows/build.yml/badge.svg)](https://github.com/mamewotoko/samefile/actions/workflows/build.yml)
========
collect files that have same content and output file paths in one line separated by tab

Build with make
-------------------

### Build

```bash
make
```

### Run

```bash
./bin/samefile [PATH...]
```

Build with dune
------------------

### Build

```bash
dune build
```

### Run 

```bash
dune exec ./bin/samefile
```

Build with Docker
------------------
1. pull ocaml docker container image 

    ```bash
    docker pull ocaml/opam
    ```
2. run docker container

    ```bash
    docker run -v `pwd`:/home/opam/work -it ocaml/opam bash
    ```
3. inside container run make

    ```bash
    cd work
    make
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

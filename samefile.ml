(************************************************************
   samefile.ml		Created      : Sat Nov  8 01:53:17 2003
  			Last modified: Sat Sep 22 14:25:35 2018
  Compile: ocamlc -dtypes str.cma unix.cma samefile.ml -o samefile #
  FTP Directory: sources/ocaml #
************************************************************)
(**

  @author Takashi Masuyama <mamewo@dk9.so-net.ne.jp>

*)

open Unix

let split_regexp = Str.regexp "\t"
let ignore_regexp = Str.regexp ".*\\.svn.*"
let ignore_svn_file = ref true
let is_debug_mode = ref false

type t = Same | Differ of int * int

let debug_output message =
  if !is_debug_mode then
    prerr_endline message

let compare_stream in1 in2 =
  let rec iter charnum linenum =
    match (Stream.peek in1), (Stream.peek in2) with
      (Some b1), (Some b2) ->
	if b1 = b2 then
	  begin
	    Stream.junk in1;
	    Stream.junk in2;
	    iter (charnum+1) (if b1 = '\n' then (linenum+1) else linenum)
	  end
	else Differ (charnum, linenum)
    | None, None -> Same
    | _ -> Differ (charnum, linenum) in
  iter 1 1

let is_equal_file path1 path2 =
  try
    let in_channel1 = open_in path1 in
    let in_channel2 = open_in path2 in
    let in_stream1 = Stream.of_channel in_channel1 in
    let in_stream2 = Stream.of_channel in_channel2 in
    let result = compare_stream in_stream1 in_stream2 in
    close_in in_channel1;
    close_in in_channel2;
    match result with
      Same -> true
    | Differ _ -> false
  with e ->
    begin
      Printf.eprintf "%s\n" (Printexc.to_string e);
      false
    end

let samefile path =
  let path_string = List.fold_left (fun s p -> p^" "^s) "" path in
  let uname =
    let ic = Unix.open_process_in "uname" in
    let uname = input_line ic in
    begin
      close_in ic;
      uname
    end in
  let stat_executable =
    if uname = "Darwin" then
      "gstat"
    else
      "stat" in
  let command_string = Printf.sprintf "find %s -type f -exec %s --printf=\"%%n\t%%s\\n\" {} \\;" path_string stat_executable in
  let input = Unix.open_process_in command_string in
  let rec collect_files_iter result =
    try
      let l = input_line input in
      match (Str.split split_regexp l) with
	name::size::[] ->
	  collect_files_iter (if !ignore_svn_file && Str.string_match ignore_regexp name 0 then
	    result
	  else
	    ((name, int_of_string size)::result))
      | _ -> failwith "Why? in files_list"
    with End_of_file ->
      result in
  let collect_samesize lst =
    (* given list is sorted by size *)
    let rec iter size current_group result = function
	[] -> List.rev (current_group::result)
      | (((hd_name, hd_size) as hd)::tl) as lst ->
	  if hd_size = size then
	    iter size (hd::current_group) result tl
	  else
	    nextsize_iter (current_group::result) lst
    and nextsize_iter result = function
	[] -> List.rev result
      | ((hd_name, hd_size) as hd)::tl ->
	  iter hd_size [hd] result tl in
    nextsize_iter [] (List.sort (fun (_, size1) (_, size2) -> compare size1 size2) lst) in
  let rec compare_samesizefile_iter basename basesize same_group different_group result = function
      [] ->
	next_group_iter ((basesize, same_group)::result) different_group
    | ((name, _) as hd)::tl ->
	debug_output (Printf.sprintf "compare_samesizefile_iter: %s %s\n" basename name);
	if is_equal_file basename name then
	  compare_samesizefile_iter basename basesize (name::same_group) different_group result tl
	else
	  compare_samesizefile_iter basename basesize same_group (hd::different_group) result tl
	    (* compare files which are same file size *)
  and next_group_iter result = function
      [] -> result
    | (name, size)::tail ->
	compare_samesizefile_iter name size [name] [] result tail in
  let samesize_group = collect_samesize (collect_files_iter []) in
  if !is_debug_mode then
    List.iter (fun group -> List.iter (fun (name, size) -> Printf.printf "%d: %s\n" size name) group; print_newline ()) samesize_group;
  List.fold_right (fun g l -> (next_group_iter [] g)@l) samesize_group []

let _ =
  let is_print_size_mode = ref false in
  let spec = [ ("-v", Arg.Set(is_debug_mode), "verbose output");
	       ("-size", Arg.Set(is_print_size_mode), "print size") ] in
  let usage_line = "usage: samefile [PATH...]" in
  let pathlist = ref [] in
  Arg.parse spec (fun x -> pathlist := x::!pathlist) usage_line;
  let path = 
    match !pathlist with 
      [] -> [ "." ]
    | _ -> !pathlist in
  try
    let result = samefile path in
    let dupsize = List.fold_left (fun n (size, lst) ->
                      let len = List.length lst in
                      if len > 1 then
                        begin
	                      if !is_print_size_mode then
	                        Printf.printf "%d\t" size;
	                      List.iter (fun x -> Printf.printf "%s\t" x) lst;
	                      Printf.printf "\n"
                        end;
                      n + (size*(len-1)))
                    0 result in
    Printf.printf "dupsize: %d\n" dupsize
  with e ->
    Printexc.get_callstack 5 |> Printexc.raw_backtrace_to_string |> print_endline

(*pp camlp4orf *)

type t = {
  foo: string;
  bar: int64;
} and x = {
    first: (string * int64 * t);
    second: t;
    third: int;
  } with orm

open OUnit
open Test_utils

let s = { foo="f1"; bar=59L }
let x = { first=("first",3434L,s); second=s; third=99 }

let name = "foreign_tuple.db"

let test_init () =
  ignore(open_db x_init name);
  ignore(open_db ~rm:false t_init name);
  ignore(open_db ~rm:false x_init name)

let test_save () =
  let db = open_db x_init name in
  x_save db x

let test_update () =
  let db = open_db x_init name in
  x_save db x;
  x_save db x

let test_get () =
  let db = open_db ~rm:false x_init name in
  let i = x_get db in
  "1 in db" @? (List.length i = 1);
  let i = List.hd i in
  "values match" @? (i.first = x.first && (i.second = x.second))

let test_save_get () =
  let db = open_db x_init name in
  x_save db x;
  let i = x_get db in
  "1 in db" @? (List.length i = 1);
  match i with
    [i] ->
    "structural values equal" @? ( x = i);
    "physical values equal" @? ( x == i)
  |_ -> assert false

let suite = [
  "foreign_tuple_init" >:: test_init;
  "foreign_tuple_save" >:: test_save;
  "foreign_tuple_update" >:: test_update;
  "foreign_tuple_get" >:: test_get;
  "foreign_tuple_save_get" >:: test_save_get;
]

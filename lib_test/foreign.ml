(*pp camlp4orf *)

type t = {
  foo: string;
  bar: int64;
  xyz: char;
} and x = {
    first: t;
    second: t;
    third: int;
  } with orm (
    unique: t<xyz>, t<bar>;
    index: x<first,second>
  )

let name = "foreign.db"
let s1 = { foo="hello"; bar=100L; xyz='a' }
let s2 = { foo="world"; bar=200L; xyz='z' }
let x = { first=s1; second=s2; third=111 }

open Test_utils
open OUnit

let test_init () =
  ignore(open_db t_init name);
  ignore(open_db ~rm:false x_init name);
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
  "foreign_init" >:: test_init;
  "foreign_save" >:: test_save;
  "foreign_update" >:: test_update;
  "foreign_get" >:: test_get;
  "foreign_save_get" >:: test_save_get;
]

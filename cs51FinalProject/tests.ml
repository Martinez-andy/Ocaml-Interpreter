open CS51Utils ;;
open Absbook ;;
open Expr ;;
open Evaluation ;;

module Environment = Env ;;
open Environment ;;

let num0 = Num(0) ;;
let num1 = Num(1) ;;
let num2 = Num(2) ;;
let num4 = Num(4) ;;
let num5 = Num(5) ;;
let num6 = Num(6) ;;
let num24 = Num(24) ;;
let num42 = Num(42) ;;
let num44 = Num(44) ;;

let float6 = Float(6.) ;;

let varx = Var("x") ;;
let vary = Var("y") ;;
let varz = Var("z") ;;
let varf = Var("f") ;;

let binop1 = Binop(Plus, varx, vary) ;;
let binop2 = Binop(Minus, varz, varz) ;;
let binop3 = Binop(Plus, varx, num1) ;;
let binop4 = Binop(Equals, binop1, binop2) ;;
let binop5 = Binop(Minus, num1, num1) ;;
let binop6 = Binop(Plus, num1, vary) ;;
let binop7 = Binop(Equals, num1, num1) ;;
let binop8 = Binop(FloatTimes, Float(12.), Float(2.)) ;;

let let1 = Let("x", binop3, varx) ;;
let let2 = Let("y", binop2, varx) ;;
let let3 = Let("y", binop1, binop1) ;;
let let4 = Let("z", binop1, varz) ;;
let let5 = Let("x", binop7, Conditional(varx, num1, num0))
let let6 = Let("f", Fun("x", 
Conditional(Binop(Equals, varx, Num(0)), Num(1), 
Binop(Times, varx, App(varf, 
Binop(Minus, varx, Num(1)))))), App(varf, Num(4))) ;;

let raise = Raise ;;
let unassigned = Unassigned ;;
let b = Bool(true) ;;

let con = Conditional(binop4, binop1, binop2) ;;
let good_con = Conditional(b, binop5, num1) ;;
let bad_con = Conditional(binop5, binop5, binop5) ;;

let unop1 = Unop(Negate, num1) ;;
let unop2 = Unop(Negate, varz) ;;
let unop3 = Unop(Negate, binop1) ;;
let unop4 = Unop(Negate, binop5) ;;
let bad_unop = Unop(Negate, b) ;;

let app1 = App(varf, num1) ;;
let app2 = App(varf, varf) ;;
let app3 = App(varf, varx) ;;

let func1 = Fun("x", binop3) ;;
let func2 = Fun("f", binop3) ;;
let func3 = Fun("f", binop1) ;;

let letrec1 = Letrec("x", binop3, varx) ;;
let letrec2 = Letrec("y", binop3, varx) ;;
let letrec3 = Letrec("y", binop3, binop1) ;;
let letrec4 = Letrec("y", binop1, binop1) ;;
let fact4 = Letrec("f", Fun("x", 
Conditional(Binop(Equals, varx, Num(0)), Num(1), 
Binop(Times, varx, App(varf, 
Binop(Minus, varx, Num(1)))))), App(varf, Num(4))) ;;

let fact_float = Letrec("f", Fun("x", 
Conditional(Binop(Equals, varx, Num(0)), Num(1), 
Binop(Times, varx, App(varf, 
Binop(Minus, varx, Num(1)))))), App(varf, Float(4.0))) ;;

let diff_output = Let("x", Num(1), Let("f", Fun("y", 
Binop(Plus, varx, vary)), Let("x", Num(2), App(varf, Num(3))))) ;;

let diff_output2 = Let("x", Num(10), Let("f", Fun("y", Fun("z", 
Binop(Times, varz, Binop(Plus, varx, vary)))), Let("y", Num(12), 
App(App(varf, Num(11)), Num(2))))) ;;

let env1 = extend (empty ()) "x" (ref (Val(num1))) ;;
let env2 = extend env1 "y" (ref (Val(num44))) ;;
let env3 = extend env2 "z" (ref (Val(num5))) ;;
let env_replace = extend env3 "x" (ref (Val(num24))) ;;

let let_float1 = Let("x", Binop(FloatMinus, Float(12.), Float(2.)), varx) ;;

let let_float2 = Let("x", Fun("x", Conditional(
Binop(LessThan, varx, Num(0)), Bool(true), 
Bool(false))), App(varf, Unop(FloatNeg, Float(2.)))) ;;(* fail b/c improper types *)

let let_float3 = Let("x", Fun("x", Conditional(
Binop(LessThan, varx, Num(0)), Bool(true), Bool(false))), 
App(varf, Unop(Negate, Float(2.)))) ;; (* fail Negate instead of Neg *)

let let_float4 = Let("f", Fun("x", Conditional(Binop
(LessThan, varx, Float(0.)), Bool(true), Bool(false))),
 App(varf, Unop(FloatNeg, Float(2.)))) ;; (* return true *)

let let_float5 = Let("f", Fun("x", Binop(FloatDivide, varx, Float(2.))), 
App(varf, Num(12))) ;; (* Fail, input is int *)

let let_float6 = Let("f", Fun("x", Binop(FloatDivide, varx, Float(2.))), 
App(varf, Float(12.0))) ;; (* should return 6.0 *)

let free_vars_test () = 
  unit_test(same_vars (free_vars num1) (vars_of_list []))
  "Integers:";
  unit_test(same_vars (free_vars varx) (vars_of_list ["x"]))
  "Single var:";
  unit_test(same_vars (free_vars binop1) (vars_of_list ["x"; "y"]))
  "Binop two vars:";
  unit_test(same_vars (free_vars binop2) (vars_of_list ["z"]))
  "Binop same vars:";
  unit_test(same_vars (free_vars binop3) (vars_of_list ["x"]))
  "Binop var and num:";
  unit_test (same_vars (free_vars binop4) (vars_of_list["x"; "y"; "z"]))
  "Binop of binops:";
  unit_test (same_vars (free_vars let1) (vars_of_list ["x"]))
  "Let x in def:";
  unit_test (same_vars (free_vars let2) (vars_of_list ["x"; "z"]))
  "Let vars in def and body:";
  unit_test (same_vars (free_vars let3) (vars_of_list ["x"; "y"]))
  "Let two vars:";
  unit_test (same_vars (free_vars raise) (vars_of_list []))
  "raise free vars:";
  unit_test (same_vars (free_vars unassigned) (vars_of_list []))
  "unassigned free vars:";
  unit_test (same_vars (free_vars b) (vars_of_list []))
  "bool free vars:";
  unit_test (same_vars (free_vars con) (vars_of_list ["x"; "y"; "z"]))
  "conditional:";
  unit_test (same_vars (free_vars unop1) (vars_of_list []))
  "unop of nums:";
  unit_test (same_vars (free_vars unop2) (vars_of_list ["z"]))
  "unop of var:";
  unit_test (same_vars (free_vars unop3) (vars_of_list ["x"; "y"]))
  "unop of binops";
  unit_test (same_vars (free_vars func1) (vars_of_list []))
  "function x in fun:";
  unit_test (same_vars (free_vars func2) (vars_of_list["x"]))
  "funciton one var:";
  unit_test (same_vars (free_vars func3) (vars_of_list["x"; "y"]))
  "function two vars:";
  unit_test(same_vars (free_vars letrec1) (vars_of_list []))
  "letrec: case 1";
  unit_test(same_vars (free_vars letrec2) (vars_of_list ["x"]))
  "letrec: case 2";
  unit_test(same_vars (free_vars letrec3) (vars_of_list ["x"]))
  "letrec: case 3";
  unit_test(same_vars (free_vars app1) (vars_of_list ["f"]))
  "App no free vars in arg:";
  unit_test(same_vars (free_vars app2) (vars_of_list ["f"]))
  "App with one free var:";
  unit_test(same_vars (free_vars app3) (vars_of_list ["f"; "x"]))
  "App with two free vars:" ;;

let env_test () =
  unit_test(close varx env1 = Closure(varx, env1))
  "Testing the close function";
  unit_test(lookup env3 "x" = Val(num1))
  "Looking up a var in populated env:";
  unit_test(lookup env_replace "x" = Val(num24))
  "Looking up a replaced var:";;

let subst_test () =
  unit_test((subst "x" varz varx) = varz)
  "subst var:";
  unit_test((subst "y" varx num1) = num1)
  "subst num:";
  unit_test((subst "z" vary b) = b)
  "subst bool:";
  unit_test((subst "z" num1 unop2) = unop1)
  "unop var for num:";
  unit_test((subst "x" num1 unop3) = Unop(Negate, Binop(Plus, num1, vary)))
  "unop binop of vars:";
  unit_test ((subst "z" num1 unop3) = unop3)
  "unop binop w/o free vars:";
  unit_test((subst "z" num1 num1) = num1)
  "binop no vars:";
  unit_test((subst "y" num1 binop1) = binop3)
  "binop one var:";
  unit_test((subst "z" num1 binop2) = binop5)
  "binop two vars:";
  unit_test((subst "z" num1 binop1) = binop1)
  "binop w/o free vars:";
  unit_test((subst "z" num1 con) = 
  Conditional(Binop(Equals, binop1, binop5), binop1, binop5))
  "conditional:";
  unit_test((subst "x" num1 func1) = func1)
  "function no sub:";
  unit_test((subst "x" varf func2) = Fun("var1", Binop(Plus, varf, num1)))
  "function new var needed:";
  unit_test((subst "y" num1 func3) = Fun("f", binop3))
  "function no new var needed:";
  unit_test((subst "x" binop3 let1) = Let("x", Binop(Plus, binop3, num1), varx))
  "let bound var = unbound var";
  unit_test((subst "z" num1 let2) = Let("y", binop5, varx))
  "let sub in body:";
  unit_test((subst "x" binop2 let4) = Let("var2", Binop(Plus, binop2, vary), Var("var2")))
  "let new var needed";
  unit_test((subst "x" num1 let3) = Let("y", binop6, binop6))
  "let sub in body and def:";
  unit_test((subst "x" num5 letrec1) = letrec1)
  "letrec no free vars:";
  unit_test((subst "x" num5 letrec2) = Letrec("y", Binop(Plus, num5, num1), num5))
  "letrec free var in body and def";
  unit_test((subst "x" binop6 letrec3) = Letrec("var3", Binop(Plus, binop6, num1), Binop(Plus, binop6, Var("var3")))) 
  "letrec new var case:";
  unit_test((subst "x" binop6 letrec4) = Letrec("var4", Binop(Plus, binop6, Var("var4")), Binop(Plus, binop6, Var("var4"))))
  "letrec new var in body and def:";
  unit_test((subst "z" binop2 raise) = raise)
  "raise test:";
  unit_test((subst "y" binop6 unassigned) = unassigned)
  "unassigned test:";
  unit_test((subst "f" num1 app1) = App(num1, num1))
  "Sub function:";
  unit_test((subst "f" num1 app2) = App(num1, num1))
  "Sub function and arg:";
  unit_test((subst "x" num1 app3) = App(varf, num1))
  "Sub argument";;
  
(* Need tests for eval_s, Env module, and eval_d*)

let eval_s_test () =
  let open Env in
  unit_test(eval_s num24 (empty ()) = Val(num24))
  "Nums evaluate to themselves:";
  unit_test(eval_s b (empty ()) = Val(Bool(true)))
  "Booleans evaluate to themselves";
  unit_test(eval_s func1 (empty()) = Val(func1))
  "Function evaluate to themselves:";
  unit_test(eval_s func1 env1 = eval_s func1 (empty()))
  "Eval_s disregards environment";
  unit_test(
    try
      eval_s (Raise) env1 <> eval_s (Raise) env1
    with
    | _ -> true)
  "Eval_s Raise exits:";
  unit_test(
  try
    eval_s varx env1 <> eval_s varx env1
  with
  |_ -> true)
  "Unbound variable";
  unit_test(eval_s unop1 env1 = Val(Num(~-1)))
  "Unop with int";
  unit_test(
    try
      eval_s unop2 env1 <> eval_s unop2 env1
    with
    | _ -> true)
  "Unop fails with a variable:";
  unit_test(eval_s unop4 env1 = Val(num0))
  "Unop works with valid binop input:";
  unit_test(
    try
      eval_s bad_unop env1 <> eval_s bad_unop env1
    with
    |_ -> true)
  "Unop fails with boolean";
  unit_test(eval_s binop7 (empty ()) = Val(Bool(true)))
  "Binop handle equals properly";
    unit_test(
      try
        eval_s binop2 env1 <> eval_s binop2 env1
      with
      | _ -> true)
  "Binop handles unbound variables properly";
  unit_test(eval_s binop5 env1 = Val(num0))
  "eval_s Binop handles nums correctly:";
  unit_test(eval_s good_con env1 = Val(num0))
  "eval_s conditional evaluates correctly:";
  unit_test(
    try
      eval_s bad_con env1 <> eval_s bad_con env1
    with
    |_ -> true)
  "eval_s conditional fails with inappropriate input:";
  unit_test(
    try
      eval_s let1 env1 <> eval_s let1 env1
    with
    | _ -> true)
  "Let unbound var:";
  unit_test(eval_s let5 env1 = Val(num1))
  "let into a conditional:";
  unit_test(
    try
      eval_s let6 env1 <> eval_s let6 env1
    with
    | _ -> true)
  "Let with recursive body:";
  unit_test(eval_s diff_output (empty ()) = Val(num4))
  "video example 1:";
  unit_test(eval_s diff_output2 (empty ()) = Val(num42))
  "Video example 2:";
  unit_test(eval_s fact4 (empty ()) = Val(num24))
  "4 Factorial sub:";;


let eval_d_test () =
  let open Env in
  unit_test(eval_d num24 (empty ()) = Val(num24))
  "Nums evaluate to themselves:";
  unit_test(eval_d b (empty ()) = Val(Bool(true)))
  "Booleans evaluate to themselves";
  unit_test(eval_d func1 (empty()) = Val(func1))
  "Function evaluate to themselves:";
  unit_test(
    try
      eval_d (Raise) env1 <> eval_d (Raise) env1
    with
    | _ -> true)
  "Eval_l Raise exits:";
  unit_test(eval_d unop1 env1 = Val(Num(~-1)))
  "Unop with int";
  unit_test(
    try
      eval_d unop2 env1 <> eval_d unop2 env1
    with
    | _ -> true)
  "Unop fails with a variable:";
  unit_test(eval_d unop4 env1 = Val(num0))
  "Unop works with valid binop input:";
  unit_test(
    try
      eval_d bad_unop env1 <> eval_d bad_unop env1
    with
    |_ -> true)
  "Unop fails with boolean";
  unit_test(eval_d binop7 (empty ()) = Val(Bool(true)))
  "Binop handle equals properly";
  unit_test(
    try
      eval_d binop2 env1 <> eval_d binop2 env1
    with
    | _ -> true)
  "Binop handles unbound variables properly";
  unit_test(eval_d binop5 env1 = Val(num0))
  "eval_d Binop handles nums correctly:";
  unit_test(eval_d good_con env1 = Val(num0))
  "eval_d conditional evaluates correctly:";
  unit_test(
    try
      eval_d bad_con env1 <> eval_d bad_con env1
    with
    |_ -> true)
    "eval_d conditional fails with inappropriate input:";
  unit_test(
    try
      eval_d let1 (empty ()) <> eval_d let1 (empty ())
    with
    | _ -> true)
  "Let unbound var:";
  unit_test(eval_d let1 env1 = Val(num2))
  "Let var non-empty env:";
  unit_test(eval_d let5 env1 = Val(num1))
  "let into a conditional:";
  unit_test(eval_d let6 (empty ()) = eval_d fact4 (empty ()))
  "Let with recursive body:";
  unit_test(eval_d fact4 (empty ()) = Val(num24))
  "4 Factorial sub:";
  unit_test(eval_d diff_output (empty ()) = Val(num5))
  "video example 1:";
  unit_test(eval_d diff_output2 (empty ()) = Val(num44))
  "Video example 2:";;

let eval_l_test () =
  let open Env in
  unit_test(eval_l num24 (empty ()) = Val(num24))
  "Nums evaluate to themselves:";
  unit_test(eval_l b (empty ()) = Val(Bool(true)))
  "Booleans evaluate to themselves";
  unit_test(eval_l func1 (empty()) = Closure (func1, empty ()))
  "Function evaluate to closures:";
  unit_test(eval_l func1 env1 <> eval_l func1 (empty()))
  "Eval_l does not disregard environment";
  unit_test(
    try
      eval_l (Raise) env1 <> eval_l (Raise) env1
    with
    | _ -> true)
  "Eval_l Raise exits:";
  unit_test(eval_l unop1 env1 = Val(Num(~-1)))
  "Unop with int";
  unit_test(
    try
      eval_l unop2 env1 <> eval_l unop2 env1
    with
    | _ -> true)
  "Unop fails with a variable:";
  unit_test(eval_l unop4 env1 = Val(num0))
  "Unop works with valid binop input:";
  unit_test(
    try
      eval_l bad_unop env1 <> eval_l bad_unop env1
    with
    |_ -> true)
  "Unop fails with boolean";
  unit_test(eval_l binop7 (empty ()) = Val(Bool(true)))
  "Binop handle equals properly";
  unit_test(
    try
      eval_l binop2 env1 <> eval_l binop2 env1
    with
    | _ -> true)
  "Binop handles unbound variables properly";
  unit_test(eval_l binop5 env1 = Val(num0))
  "eval_l Binop handles nums correctly:";
  unit_test(eval_l good_con env1 = Val(num0))
  "eval_l conditional evaluates correctly:";
  unit_test(
    try
      eval_l bad_con env1 <> eval_l bad_con env1
    with
    |_ -> true)
    "eval_l conditional fails with inappropriate input:";
  unit_test(
    try
      eval_l let1 (empty ()) <> eval_l let1 (empty ())
    with
    | _ -> true)
  "Let unbound var:";
  unit_test(eval_l let1 env1 = Val(num2))
  "Let var non-empty env:";
  unit_test(eval_l let5 env1 = Val(num1))
  "let into a conditional:";
  unit_test(
    try
      eval_l let6 env1 <> eval_l let6 env1
    with
    | _ -> true)
  "Let with recursive body:";
  unit_test(eval_l fact4 (empty ()) = Val(num24))
  "4 Factorial sub:";
  unit_test(eval_l diff_output (empty ()) = Val(num4))
  "video example 1:";
  unit_test(eval_l diff_output2 (empty ()) = Val(num42))
  "Video example 2:";;

let eval_e_test () =
  eval_l_test ();
  (* Testing the floats *)
  unit_test(eval_e (Float(51.)) (empty ()) = Val(Float(51.)))
  "Floats evaluate to themselves:";
  unit_test(eval_e binop8 (empty ()) = Val(Float(24.)))
  "Simple float multiplicaiton:";
  unit_test(eval_e let_float1 (empty ()) = Val(Float(10.)))
  "Let and binop with floats:";
  unit_test(
    try
      eval_e let_float2 (empty ()) <> eval_e let_float2 (empty ())
    with
    | _ -> true)
  "Handling floats and nums:";
  unit_test(
    try
      eval_e let_float3 (empty ()) <> eval_e let_float3 (empty ())
    with
    | _ -> true)
  "Handling int negation of float:";
  unit_test(eval_e let_float4 (empty ()) = Val(b))
  "Let, conditional, binop, unop float test:";
  unit_test(
    try
      eval_e let_float5 (empty ()) <> eval_e let_float5 (empty ())
    with
    | _ -> true)
  "Tesing merging of floats and nums:";
  unit_test(eval_e let_float6 (empty ()) = Val(float6))
  "Float divide and function application:";;

(* Optimize code *)
(* Maybe implement something else *)

let _ = 
  free_vars_test ();
  env_test ();
  subst_test ();
  eval_s_test ();
  eval_d_test ();
  eval_l_test ();
  eval_e_test () ;; 
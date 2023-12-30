(* 
                         CS 51 Final Project
                        MiniML -- Expressions
*)

(*......................................................................
  Abstract syntax of MiniML expressions 
 *)

type unop =
  | Negate
  | FloatNeg (* Causes warnings because eval_s and eval_d do not match for this case (as it should be)*)
;;
    
type binop =
  | Plus
  | Minus
  | Times
  | Equals
  | LessThan
  | FloatPlus
  | FloatMinus
  | FloatTimes
  | FloatDivide (* Float operators cause warning in eval_d and eval_s because I am pretty sure we aren't supposed to alter them for our extensions *)
;;

type varid = string ;;
  
type expr =
  | Var of varid                         (* variables *)
  | Num of int                           (* integers *)
  | Float of float                       (* floats *)
  | Bool of bool                         (* booleans *)
  | Unop of unop * expr                  (* unary operators *)
  | Binop of binop * expr * expr         (* binary operators *)
  | Conditional of expr * expr * expr    (* if then else *)
  | Fun of varid * expr                  (* function definitions *)
  | Let of varid * expr * expr           (* local naming *)
  | Letrec of varid * expr * expr        (* recursive local naming *)
  | Raise                                (* exceptions *)
  | Unassigned                           (* (temporarily) unassigned *)
  | App of expr * expr                   (* function applications *)
;;
  
(*......................................................................
  Manipulation of variable names (varids) and sets of them
 *)

(* varidset -- Sets of varids *)
module SS = Set.Make (struct
                       type t = varid
                       let compare = String.compare
                     end ) ;;

type varidset = SS.t ;;

(* same_vars varids1 varids2 -- Tests to see if two `varid` sets have
   the same elements (for testing purposes) *)
let same_vars : varidset -> varidset -> bool =
  SS.equal;;

(* vars_of_list varids -- Generates a set of variable names from a
   list of `varid`s (for testing purposes) *)
let vars_of_list : string list -> varidset =
  SS.of_list ;;
  
(* free_vars exp -- Returns the set of `varid`s corresponding to free
   variables in `exp` *)

(* Test free vars for all cases *)
let rec free_vars (exp : expr) : varidset =
  match exp with
  | Var (var) -> SS.singleton var
  | Num _ -> SS.empty
  | Binop (_, arg1, arg2) -> 
    SS.union (free_vars arg1) (free_vars arg2)
  | Let(x, def, body) -> 
    SS.union (free_vars def) (SS.remove x (free_vars body))
  | Raise
  | Unassigned
  | Bool(_) -> SS.empty
  | Conditional (i, t, e) -> 
    SS.union (free_vars i) (SS.union (free_vars t) (free_vars e))
  | Unop (_, arg) -> free_vars arg
  | App (f, arg) -> SS.union (free_vars f) (free_vars arg)
  | Fun (f, arg) -> SS.remove f (free_vars arg)
  | Letrec (x, def, body) -> 
    SS.union (SS.remove x (free_vars def)) (SS.remove x (free_vars body)) ;;

  (* Raise, Unassigned, Bool, Conditional, Fun, Letrec *)
  
(* new_varname () -- Returns a freshly minted `varid` constructed with
   a running counter a la `gensym`. Assumes no other variable names
   use the prefix "var". (Otherwise, they might accidentally be the
   same as a generated variable name.) *)

let new_varname =
  let counter = ref 0 in
  fun () -> 
    incr counter;
    "var" ^ string_of_int !counter ;;

(*......................................................................
  Substitution 

  Substitution of expressions for free occurrences of variables is the
  cornerstone of the substitution model for functional programming
  semantics.
 *)

(* subst var_name repl exp -- Return the expression `exp` with `repl`
   substituted for free occurrences of `var_name`, avoiding variable
   capture *)

let rec subst (var_name : varid) (repl : expr) (exp : expr) : expr =
  match exp with
  | Var(var) -> 
    if var = var_name then repl else exp
  | Num(_)
  | Bool(_) -> exp
  | Unop(neg, arg) -> Unop(neg, subst var_name repl arg)
  | Binop(operator, arg1, arg2) -> 
    Binop(operator, subst var_name repl arg1, subst var_name repl arg2)
  | Conditional (arg1, arg2, arg3) -> 
    Conditional (subst var_name repl arg1, 
    subst var_name repl arg2, subst var_name repl arg3)
  | Fun (var, arg) ->
    if var = var_name then Fun (var, arg)
    else 
      if SS.mem var (free_vars repl) then 
        let fresh_var = new_varname () in
        Fun(fresh_var, subst var_name repl (subst var (Var(fresh_var)) arg))
      else Fun(var, subst var_name repl arg)
  | Let (var, arg1, arg2) ->
    if var_name = var then Let (var, subst var_name repl arg1, arg2)
    else 
      if SS.mem var (free_vars repl) then
        let fresh_var = new_varname () in
        Let (fresh_var, subst var_name repl arg1, 
        subst var_name repl (subst var (Var(fresh_var)) arg2))
      else
        Let (var, subst var_name repl arg1, subst var_name repl arg2)
  | Letrec (var, arg1, arg2) -> 
    if var_name = var then exp
    else
      if SS.mem var (free_vars repl) then
        let fresh_var = new_varname () in
        Letrec (fresh_var, subst var_name repl (subst var (Var(fresh_var)) arg1),
        subst var_name repl (subst var (Var(fresh_var)) arg2))
      else
        Letrec(var, subst var_name repl arg1, subst var_name repl arg2)
  | Raise -> Raise
  | Unassigned -> Unassigned
  | App (arg1, arg2) -> App (subst var_name repl arg1, subst var_name repl arg2) ;;

  (*
     Pseudocode:
      Chapter 13
      Sub rules
      Check the conditions in chapter 13 
  *)
  (* How do I "avoid variable capture"? *)
     
(*......................................................................
  String representations of expressions
 *)
  
(* exp_to_concrete_string exp -- Returns a string representation of
   the concrete syntax of the expression `exp` *)

(* Am I doing this right? Also, what should I return for app, unassigned, and raise? *)
let rec exp_to_concrete_string (exp : expr) : string =
  match exp with
  | Var (var) -> var
  | Num (integer) -> string_of_int integer
  | Float (floater) -> string_of_float floater
  | Bool (boolean) -> string_of_bool boolean
  | Unop (_, express) -> "-" ^ exp_to_concrete_string express
  | Conditional (i, t, e) -> ("if" ^ exp_to_concrete_string i ^ "then" ^
    exp_to_concrete_string t ^ "else" ^ exp_to_concrete_string e)
  | Fun (var, express) -> "let " ^ var ^ "=" ^ exp_to_concrete_string express
  | Let (var, ex1, ex2) -> "let " ^ var ^ "=" ^ exp_to_concrete_string ex1 ^ exp_to_concrete_string ex2
  | Letrec (var, ex1, ex2) -> "let rec " ^ var ^ "=" ^ exp_to_concrete_string ex1 ^ exp_to_concrete_string ex2
  | Raise -> "raise"
  | Unassigned -> "unassigned"
  | App (ex1, ex2) -> exp_to_concrete_string ex1 ^ " " ^ exp_to_concrete_string ex2
  | Binop (bin, ex1, ex2) -> 
    let con_bin (bin: binop) : string =
      match bin with
      | Plus -> "+" 
      | Minus -> "-" 
      | Times -> "*" 
      | Equals -> "=" 
      | LessThan -> "<" 
      | FloatPlus -> "+."
      | FloatMinus -> "-."
      | FloatTimes -> "*."
      | FloatDivide -> "/." in
    exp_to_concrete_string ex1 ^ " " ^ 
    con_bin bin ^ " " ^ exp_to_concrete_string ex2 ;;
  
(* exp_to_abstract_string exp -- Return a string representation of the
   abstract syntax of the expression `exp` *)
let rec exp_to_abstract_string (exp : expr) : string =
  match exp with
  | Var(var) -> "Var(" ^ var ^ ")"
  | Num(integer) -> "Num(" ^ string_of_int integer ^ ")"
  | Float(floater) -> "Float(" ^ string_of_float floater ^ ")"
  | Bool(boolean) -> "Bool(" ^ string_of_bool boolean ^ ")"
  | Unop(operator, express) -> 
    (match operator with
    | Negate -> "Unop(Negate, " ^ exp_to_abstract_string express ^ ")"
    | FloatNeg -> "Unop(FloatNeg, " ^ exp_to_abstract_string express ^ ")")
  | Conditional(i, t, e) -> ("Conditional(" ^ exp_to_abstract_string i 
          ^ ", " ^ exp_to_abstract_string t ^ ", " ^ exp_to_abstract_string e ^ ")")
  | Fun(var, express) -> "Fun(" ^ var ^ ", " ^ exp_to_abstract_string express ^ ")"
  | Let(var, ex1, ex2) -> ("Let(" ^ var ^ ", " ^ exp_to_abstract_string ex1 ^ ", " ^
          exp_to_abstract_string ex2 ^ ")")
  | Letrec(var, ex1, ex2) -> ("Letrec(" ^ var ^ ", " ^ exp_to_abstract_string ex1 ^ ", "
          ^ exp_to_abstract_string ex2 ^ ")")
  | Raise -> "Raise"
  | Unassigned -> "Unassigned"
  | App (ex1, ex2) -> ("App(" ^ exp_to_abstract_string ex1 ^ ", " ^
  exp_to_abstract_string ex2 ^ ")")
  | Binop(bin, ex1, ex2) -> 
    let find_bin (bin: binop) : string =
      match bin with
      | Plus -> "Plus"
      | Minus -> "Minus"
      | Times -> "Times"
      | Equals -> "Equals"
      | LessThan -> "LessThan"
      | FloatTimes -> "FloatTimes"
      | FloatDivide -> "FloatDivide"
      | FloatPlus -> "FloatPlus"
      | FloatMinus -> "FloatMinus" in
    "Binop(" ^ find_bin bin ^ ", " ^ exp_to_abstract_string ex1 ^ ", " ^ exp_to_abstract_string ex2 ^ ")" ;;



(* Questions *)
(*
   1.) Is my new_varname function correct?
   2.) 
*)

(*
  Notes:
      Invalid operations
      Use binop and uniop from lab 13 or something
*)
open HolKernel bossLib boolLib pairLib integerTheory listTheory Parse boolSimps
open pairTheory numLib numTheory ratTheory fracTheory 
open listLib satTheory relationTheory 
open stringLib 
open stringTheory

val _ = Hol_datatype ` Cand = cand of string ` ; 

val _ = Hol_datatype `judgement =  
                                      state   of 
                         ((Cand list) # (int # int)) list
                                             # (Cand # (int # int)) list
                                             # (Cand # (((Cand list) # (int # int)) list)) list
                                             # Cand list 
                                             # Cand list
                                             # Cand list 
                       | winners of (Cand list) `; 
 
(* start of first part *)
val t_cand_list_def = Define`
t_cand_list tlst = 
       case tlst of 
           [] => []
         | (#"," :: t) => t_cand_list t
         | (#"[" :: t) => t_cand_list t
         | (#"]" :: t) => t_cand_list t
         | (#" " :: t) => t_cand_list t
         | (x :: t) => (cand (STR x)) :: t_cand_list t`   

`t_cand_list ( [#"["; #"A"; #","; #"B"; #","; #"C"; #"]"] ) = [ cand "A"; cand "B"; cand "C"]`
EVAL_TAC

val cand_list_def = Define`
cand_list st = 
  let lst = EXPLODE st in 
  t_cand_list lst` 

`cand_list "[A,B,C]" = [cand "A"; cand "B"; cand "C"]`
EVAL_TAC 


val process_chunk_def = tDefine "process_chunk" `
process_chunk tlst acc lst= 
  case  tlst of
      [] => lst 
    | (#")" :: #"," :: t) => 
      process_chunk t "" 
                    (FLAT [lst; [CONCAT [acc; ")"]]])
    | (#")" :: t) => 
      process_chunk t "" 
                    (FLAT [lst; [CONCAT [acc; ")"]]])
    | (x :: t)  => process_chunk t (CONCAT [acc; (STR x)]) lst`
((WF_REL_TAC `measure (LENGTH o FST )` >>   
REPEAT STRIP_TAC ) 
  >- FULL_SIMP_TAC list_ss []
  >- FULL_SIMP_TAC list_ss [] 
  >- FULL_SIMP_TAC list_ss [] 
  >- FULL_SIMP_TAC list_ss []) 


val split_it_into_pair_def = Define`
split_it_into_pair st = 
    let lst = EXPLODE st in
    process_chunk (TL lst) "" []`
 

EVAL ``split_it_into_pair "[([A,B,C],1.0),([C,B,A],1.0),([B,A,C],1.0),([C,A,B],1.0),([A,B,C],1.0),([A,B,C],1.0),([C,B,A],1.0),([A,C,B],1.0),([B,C,A],1.0),([A,B,C],3.0)]"``


val parse_pair_t_def = tDefine "parse_pair_t" `
parse_pair_t ts (ac, bc) = 
    case ts of
        [] => (ac, bc)
      | (#"(" :: t) => parse_pair_t t (ac, bc)
      | (#")" :: t) => parse_pair_t t (ac, bc)
      | (#"]" :: #"," :: t) => 
        (CONCAT [ac; "]"], IMPLODE t)
      | (x :: t) => 
        parse_pair_t t (CONCAT [ac; STR x], bc)`
((WF_REL_TAC `measure (LENGTH o FST)` >>
             REPEAT STRIP_TAC)
     >- FULL_SIMP_TAC list_ss []
     >- FULL_SIMP_TAC list_ss []
     >- FULL_SIMP_TAC list_ss []
     >- FULL_SIMP_TAC list_ss []
     >- FULL_SIMP_TAC list_ss [])


val parse_pair_def = Define`
parse_pair str = 
        let tm = EXPLODE str in 
        parse_pair_t tm ("", "")`

EVAL``parse_pair "([A,B,C],1.0)"``

        
val parse_number_t_def = Define`
parse_number_t lst acc = 
     case lst of 
         [] => acc
       | h :: t => parse_number_t t (10 * acc + (ORD h - ORD #"0"))`


val parse_number_def = Define`
parse_number str = 
    let nlst = EXPLODE str in
    parse_number_t nlst 0`

EVAL ``parse_number "12345"`` 
        
val parse_rational_def = Define`
parse_rational str =
    let tlst = TOKENS (\x. x = #"%") str in
    let first = HD tlst in 
    let st = EXPLODE (HD (TL tlst)) in 
    let second = IMPLODE (FILTER isDigit st) in 
    (parse_number first, parse_number second)`

EVAL ``parse_rational "123%345)"``


(* lets plug the values togather for first part*)

val parse_first_part_def = Define`
parse_first_part str = 
 let l1 = split_it_into_pair str in 
 let l2 = MAP (\x. parse_pair x) l1 in 
 let l3 = MAP (\(x, y). (cand_list x, parse_rational y)) l2 in
 l3`

EVAL `` parse_first_part "[([A,B,C],1%2),([C,B,A],1%2),([B,A,C],1%2),([C,A,B],1%2),([A,B,C],1%2),([A,B,C],1%2),([C,B,A],1%2),([A,C,B],1%2),([B,C,A],1%2),([A,B,C],3%4)]"``

(* End of first part. *)

(* start of second part *)

val parse_second_t_def = Define`
parse_second_t tstr = 
  let lstr = TOKENS (\x. x = #"{") tstr in 
  let first = HD lstr in 
  let lrest = HD (TL lstr) in
  (cand first, parse_rational lrest)`

val parse_second_part_def = Define`
parse_second_part str = 
 let strs = TOKENS (\x. x = #" ") str in
 MAP parse_second_t strs`


EVAL ``parse_second_part " A{5%6} B{2%3} C{3%4}"``
                                           
(* parse_third_part *)
            
val parse_third_t_def = Define`
parse_third_t tstr = 
 let tlst = TOKENS (\x. x = #"{") tstr in 
 let first = HD tlst in 
 let second = HD (TL tlst) in
 (cand first, parse_first_part second)`
    
val parse_third_part_def = Define`
parse_third_part str = 
  let strs = TOKENS (\x. x = #" ") str in
  MAP parse_third_t strs`
           
EVAL ``parse_third_part " A{[([A,B,C],1%2),([A,B,C],1%2),([A,B,C],1%2),([A,C,B],1%2),([A,B,C],1%3)]} B{[([B,A,C],1%40),([B,C,A],1%2)]} C{[([C,B,A],1%2),([C,A,B],1%5),([C,B,A],15%16)]}"``
                                      
(* end of third part *)
                                      
(* parse rest part, third, fourth and final *)
val parse_rest_def = Define`
parse_rest str = cand_list str`
               
EVAL ``parse_rest "[A,B,C]"``                
 (* combine all to parse one line *)

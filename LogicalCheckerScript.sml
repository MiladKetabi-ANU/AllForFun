open HolKernel bossLib boolLib pairLib integerTheory listTheory Parse boolSimps
open stringLib  
open pairTheory  
open numLib
open numTheory
open ratTheory
open bossLib
open fracTheory 
open listLib 
open satTheory
open sortingTheory  
open relationTheory
;    
     
        
val _ = new_theory "LogicalChecker" ; 
                                               
val _ = Hol_datatype ` Cand = cand of string ` ; 
    
val _ = Hol_datatype `judgement =  
                                 state   of 
                                    ((Cand list) # rat) list
                                  # (Cand # rat) list
                                  # (Cand # (((Cand list) # rat) list)) list
                                  # Cand list 
                                  # Cand list
                                  # Cand list 
                               | winners of (Cand list) `;  
                                                      
val sum_aux_def = Define ` ((sum_aux []) = 0) /\
                          ( (sum_aux (h::t)) = ((SND h) + (sum_aux t)) )  `;
                  
  
    
(*the boolian function for deciding on ewin correct application*)    
val Ewin_def = Define `
        (Ewin (qu : rat) st ((winners l), (j : judgement)) = F) 
        /\ (Ewin qu st (state p, state p') = F)                
        /\ (Ewin qu st (state (ba, t, p, bl, e, h), winners l) =  
                       ( (e =l) /\ (LENGTH e = st)))`;
          
val ewin_def = Define ` ewin (qu: rat) st j1 j2 = ? u t p bl e h w.
               (j1 = state (u, t, p, bl, e, h))                 
               /\ (j2 = winners w) 
               /\ (e = w)
               /\ ((LENGTH e) = st)`;
             
val ewin_to_Ewin_thm = Q.store_thm ("ewin_to_Ewin",
 `!qu st j1 j2. (ewin qu st j1 j2) ==> (Ewin qu st (j1, j2) = T) `, 
   STRIP_TAC 
     >> STRIP_TAC 
       >> Cases_on `j1`
         >> STRIP_TAC 
           >> Cases_on `j2` 
             >> rw[ewin_def] 
               >> rw[ewin_def, Ewin_def, ewin_def]) ;     

 
val Ewin_to_ewin = Q.store_thm ("Ewin_to_ewin", 
 `!qu st j1 j2. (Ewin qu st (j1, j2) = T) ==> (ewin qu st j1 j2) `, 
    STRIP_TAC 
    >> STRIP_TAC 
      >> Cases_on `j1` 
        >> Cases_on `j2` 
    >- rw[Ewin_def] 
    >- (Cases_on `p` 
      >> Cases_on `r` 
        >> Cases_on `r'` 
          >> Cases_on `r` 
            >> Cases_on `r'` 
              >> rw[Ewin_def] 
                >> rw[ewin_def]) 
    >- rw[Ewin_def] 
    >-  rw[Ewin_def])  ;       
        
val Hwin_def = Define `
        (Hwin (qu : rat) st (winners l, (j : judgement)) = F) 
        /\ (Hwin qu st (state p, state p') = F)                
        /\ (Hwin qu st (state (ba, t, p, bl, e, h), winners l) =  
            ((e ++ h) = l) /\ ((LENGTH (e ++ h)) <= st))`; 
   
val hwin_def = Define ` hwin (qu: rat) st j1 j2 = ? u t p bl e h w.
               (j1 = state (u, t, p, bl, e, h))                 
               /\ (j2 = winners w) 
               /\ ((e ++ h) = w)
               /\ ((LENGTH (e ++ h)) <= st)`;
    
val hwin_to_Hwin = Q.store_thm ("hwin_to_Hwin",
  `!qu st j1 j2. (hwin qu st j1 j2) ==> (Hwin qu st (j1, j2) = T)`,
   STRIP_TAC 
        >> STRIP_TAC 
          >> Cases_on `j1` 
   >- (rw[hwin_def]
     >> rw[Hwin_def])
   >- rw[hwin_def]); 
      
val Hwin_to_hwin = Q.store_thm ("Hwin_to_hwin", 
  `!qu st j1 j2. (Hwin qu st (j1, j2) = T) ==> (hwin qu st j1 j2)`,
   STRIP_TAC
        >> STRIP_TAC
	  >> Cases_on `j1`
	    >> Cases_on `j2`  
   >- rw[Hwin_def]
   >- (Cases_on `p` 
      >> Cases_on `r` 
        >> Cases_on `r'` 
          >> Cases_on `r` 
            >> Cases_on `r'`
              >> rw[Hwin_def] 
                >> rw[hwin_def]) 
   >- rw[Hwin_def] 
   >- rw[Hwin_def]); 
  
val eqe_def = Define `
       ((eqe (c: Cand) l nl ) = ?l1 l2. 
                                 (l = l1 ++ l2)
                                 /\ (nl = l1 ++ [c] ++ l2)
                                 /\ (~ (MEM c l1)) 
                                 /\ (~ (MEM c l2))) `;
   
val get_cand_tally_def = Define `
           (get_cand_tally (c: Cand) (h ::t) = (if  (c = FST h) then SND h
                                            else (get_cand_tally c t))) `;
      
val get_cand_pile_def = Define `
     (get_cand_pile (c : Cand) ([] : (Cand # (((Cand list) # rat) list)) list) = [])
     /\ (get_cand_pile c (h ::t) = (if (c = FST h) then SND h
                                     else get_cand_pile c t)) `;
 
val empty_cand_pile_def = Define `
   (empty_cand_pile (c : Cand) ([] : (Cand # (((Cand list) # rat) list)) list) = [])
   /\ (empty_cand_pile c (h ::t) = (if (c = FST h) then ((c, []) :: t)
                                    else h :: (empty_cand_pile c t))) `;

(*a legal tally consists of all of the initial Candidates each of whom appers only once in the list*)     
val legal_tally_cand_def = Define ` 
   (legal_tally_cand l t (c: Cand) =  (MEM c l) 
                /\ (?l1. (?(x:rat) l2. (t = l1 ++ [(c,x)] ++ l2) 
                                   /\ (~ MEM c (MAP FST l1))
                                   /\ (~ MEM c (MAP FST l2))))) `;
      
    
 
val Legal_Tally_Cand_def = Define `
      (Legal_Tally_Cand l ([]: (Cand # rat) list) (c:Cand) = F)
   /\ (Legal_Tally_Cand l (h::t) c =  (MEM c l) 
                                   /\ (if (FST h = c) then (~ MEM c (MAP FST t)) 
                                       else Legal_Tally_Cand l t c)) `;
   
val CAND_EQ_DEC = Q.store_thm ("CAND_EQ_DEC", 
    `!(c1: Cand) c2. (c1 = c2) \/ (c1 <> c2) `,
       REPEAT STRIP_TAC 
          >> Cases_on `c1 = c2` 
             >- (DISJ1_TAC >> METIS_TAC []) 
             >- (DISJ2_TAC >> METIS_TAC []));    
           
val GET_CAND_TALLY_HEAD_REMOVAL_def = Q.store_thm ("GET_CAND_TALLY_HEAD_REM",
`!(h: Cand #rat) t c. (~(c = FST h)) ==> (get_cand_tally c (h::t) = get_cand_tally c t)`,  Induct_on `t` 
               >- rw [get_cand_tally_def] 
               >- (REPEAT STRIP_TAC 
                 >> first_assum (qspecl_then [`h'`,`c`] strip_assume_tac) 
                   >> EVAL_TAC 
                     >> rw []));  
  
 

val GET_CAND_TALLY_MEM2 = Q.store_thm ("GET_CAND_TALLY_MEM",
 `!(t: (Cand #rat) list) c. (MEM c (MAP FST t)) 
                                    ==> (MEM (c, get_cand_tally c t) t) `, 
   
    Induct_on `t`
        >- rw []
        >- (EVAL_TAC 
          >> REPEAT STRIP_TAC >> rw []));
       
                   
       
val Legal_to_legal_tally_cand = Q.store_thm("Legal_to_legal_tally_cand",
   `!l  (t: (Cand # rat) list) c. (Legal_Tally_Cand l t c) ==> (legal_tally_cand l t c) `,                           
 
     Induct_on `t`          
       >- ASM_SIMP_TAC bool_ss [Legal_Tally_Cand_def, legal_tally_cand_def]             
       >- ((ASSUME_TAC CAND_EQ_DEC 
         >> STRIP_TAC 
          >> STRIP_TAC 
           >> STRIP_TAC 
            >> first_assum (qspecl_then [`c`,`FST h`] strip_assume_tac))    
              >- (RW_TAC bool_ss [Legal_Tally_Cand_def, legal_tally_cand_def] 
                >> MAP_EVERY qexists_tac [`[]`, `SND h`,`t`] 
                  >> rw[])   
              >- (first_assum (qspecl_then [`l`,`c`] strip_assume_tac) 
                >> FULL_SIMP_TAC bool_ss [Legal_Tally_Cand_def, legal_tally_cand_def] 
                 >> STRIP_TAC 
                   >> FULL_SIMP_TAC bool_ss [] 
                     >> MAP_EVERY qexists_tac [`h::l1`,`x`,`l2`] 
                      >> rw[]))) ;  
      
val legal_to_Legal_tally_cand = Q.store_thm ("legal_to_Legal_tallt_cand",
    `!l (t: (Cand # rat) list) c. (legal_tally_cand l t c) ==> (Legal_Tally_Cand l t c) `,
 
      Induct_on `t`      
        >- rw[legal_tally_cand_def, Legal_Tally_Cand_def] 
   
          >- ((STRIP_TAC 
           >> STRIP_TAC 
            >> STRIP_TAC 
             >> ASSUME_TAC CAND_EQ_DEC 
              >> first_assum (qspecl_then [`c`,`FST h`] strip_assume_tac))      
          >- ((RW_TAC bool_ss [legal_tally_cand_def, Legal_Tally_Cand_def] 
            >> ASSUME_TAC (INST_TYPE [alpha |-> ``:(Cand #rat)``] list_nchotomy) 
              >> first_assum (qspecl_then [`l1`] strip_assume_tac))
                >- FULL_SIMP_TAC bool_ss [APPEND,APPEND_NIL,CONS_11] 
                >- (FULL_SIMP_TAC bool_ss [APPEND,CONS_11] 
                  >> rw [] 
                    >> FULL_SIMP_TAC bool_ss [MEM,MAP]))
        >- ((STRIP_TAC 
          >> RW_TAC bool_ss [legal_tally_cand_def,Legal_Tally_Cand_def])  
             >- FULL_SIMP_TAC bool_ss [legal_tally_cand_def]  
             >- ((first_assum (qspecl_then [`l`,`c`] strip_assume_tac) 
               >> FULL_SIMP_TAC bool_ss [legal_tally_cand_def] 
                 >> ASSUME_TAC (INST_TYPE [alpha |-> ``:(Cand #rat)``] list_nchotomy)
                   >> first_assum (qspecl_then [`l1`] strip_assume_tac)) 
                     >- FULL_SIMP_TAC bool_ss [APPEND,APPEND_NIL,CONS_11,FST]           
                     >- (rw [] 
                       >> FULL_SIMP_TAC bool_ss [APPEND,CONS_11,MAP,MEM] 
                         >> rw [] 
                           >> METIS_TAC []))))) ;
    
val remove_one_cand_def = Define `
                         (remove_one_cand (c :Cand) [] = [])
                      /\ (remove_one_cand c (h::t) = (if c = h then t 
                                                      else h:: remove_one_cand c t)) `;

 val not_elem = Define `   (not_elem a [] = T)
                       /\ (not_elem a (h::t) = (if (a = h) then F
                                               else (not_elem a t))) `;
   
val no_dup = Define  `   (no_dup [] = T)
                      /\ (no_dup (h::t) = (if (not_elem h t) then (no_dup t)
                                           else F)) `;  

(* the following predicate states when a list is duplicate-free w.r.t. a particular candidate*) 
val NO_DUP_PRED = Define `
   (NO_DUP_PRED h (c: Cand) = (h = []) \/ (~ MEM c h) \/ 
                              (?h1 h2. (h = h1 ++ [c]++ h2) /\ (~ MEM c h1) /\ (~ MEM c h2))) `;  
  

val not_elem_NOT_MEM = Q.store_thm ("not_elem_NOT_MEM",
   `!h (c: Cand). (not_elem c h) <=> (~MEM c h)`,
 
      Induct_on `h`
           >- rw [not_elem] 
           >- rw[not_elem]);  
 
         
val no_dup_IMP_NO_DUP_PRED = Q.store_thm ("no_dup_IMP_NO_DUP",
   ` !h (c :Cand). (no_dup h ) ==> (NO_DUP_PRED h c) `,

     Induct_on `h`
         >- rw [NO_DUP_PRED]  
         >- ((STRIP_TAC >> STRIP_TAC >> ASSUME_TAC CAND_EQ_DEC 
           >> first_x_assum (qspecl_then [`c`,`h'`] strip_assume_tac))                
              >- (first_assum (qspecl_then [`c`] strip_assume_tac) 
                >> RW_TAC bool_ss [NO_DUP_PRED,no_dup]  
                  >> DISJ2_TAC 
                    >> MAP_EVERY qexists_tac [`[]`,`h`] 
                      >> rw [] 
                        >> ASSUME_TAC not_elem_NOT_MEM  
                          >> first_assum (qspecl_then [`h`,`c`] strip_assume_tac) 
                            >> FULL_SIMP_TAC bool_ss [])  
              >- ((first_x_assum (qspecl_then [`c`] strip_assume_tac) 
                >> STRIP_TAC  
                  >> FULL_SIMP_TAC bool_ss [NO_DUP_PRED,no_dup])   
                     >- (DISJ2_TAC >> rw [])  
                     >- (DISJ2_TAC >> rw []) 
                     >- (REPEAT DISJ2_TAC 
                       >> MAP_EVERY qexists_tac [`h'::h1`,`h2`] 
                         >> METIS_TAC [APPEND,MEM])))); 
          
val NO_DUP_HEAD_REMOVAL = Q.store_thm ("NO_DUP_HEAD_REMOVAL",
    `!h h'. (!(c: Cand). NO_DUP_PRED (h'::h) c) ==> (!c. NO_DUP_PRED h c) `,
  
        (rw [NO_DUP_PRED] >> first_assum (qspecl_then [`c`] strip_assume_tac))
          >- (DISJ2_TAC >> DISJ1_TAC >> rw []) 
          >- ((ASSUME_TAC (INST_TYPE [alpha |-> ``:Cand``] list_nchotomy)
            >> first_assum (qspecl_then [`h1`] strip_assume_tac))
              >- (DISJ2_TAC 
                >> DISJ1_TAC 
                  >> FULL_SIMP_TAC bool_ss [APPEND,CONS_11])  
              >- (REPEAT DISJ2_TAC 
                 >> MAP_EVERY qexists_tac [`t`,`h2`] 
                   >> FULL_SIMP_TAC list_ss [CONS_11,MEM])));         
           
 

val NO_DUP_PRED_to_no_dup = Q.store_thm ("NO_DUP_PRED_to_no_dup",
  `!h. (!(c: Cand). (NO_DUP_PRED h c)) ==> (no_dup h) `,
 
     Induct_on `h`
         >- rw [no_dup]  
         >- ((STRIP_TAC 
           >> STRIP_TAC 
             >> ASSUME_TAC NO_DUP_HEAD_REMOVAL 
               >> first_assum (qspecl_then [`h`,`h'`] strip_assume_tac) 
                 >> FULL_SIMP_TAC bool_ss [] 
                   >> rw[no_dup] 
                     >> first_assum (qspecl_then [`h'`] strip_assume_tac) 
                       >> FULL_SIMP_TAC list_ss [NO_DUP_PRED,not_elem_NOT_MEM,MEM] 
                         >> ASSUME_TAC (INST_TYPE [alpha |-> ``:Cand``] list_nchotomy) 
                           >> first_assum (qspecl_then [`h1`] strip_assume_tac))
                              >- FULL_SIMP_TAC list_ss [CONS_11,MEM]          
                              >- FULL_SIMP_TAC list_ss [CONS_11,MEM]));
   

val NO_DUP_TAIL_ONE_CAND = Q.store_thm ("NO_DUP_TAIL_ONE_CAND",
  `!h h' (c:Cand). (NO_DUP_PRED (h'::h) c) ==> (NO_DUP_PRED h c)`,    

     (REPEAT STRIP_TAC 
       >> ASSUME_TAC CAND_EQ_DEC 
         >> first_assum (qspecl_then [`c`,`h'`] strip_assume_tac)) 
            >-  (FULL_SIMP_TAC bool_ss [NO_DUP_PRED] 
                >- rw[] 
                >-  METIS_TAC [MEM]  
                >- ((ASSUME_TAC (INST_TYPE [alpha |-> ``:Cand``] list_nchotomy) 
                  >> first_assum (qspecl_then [`h1`] strip_assume_tac))
                     >- FULL_SIMP_TAC list_ss [MEM,CONS_11]
                     >- FULL_SIMP_TAC list_ss [MEM,CONS_11]))
            >-  (FULL_SIMP_TAC bool_ss [NO_DUP_PRED]  
                >- rw []
                >- (DISJ2_TAC >> METIS_TAC [MEM]) 
                >- ((REPEAT DISJ2_TAC 
                  >> ASSUME_TAC (INST_TYPE [alpha |-> ``:Cand``] list_nchotomy)  
                    >> first_assum (qspecl_then [`h1`] strip_assume_tac)) 
                       >- FULL_SIMP_TAC list_ss [MEM,CONS_11] 
                       >- (FULL_SIMP_TAC list_ss [MEM,CONS_11] 
                         >> MAP_EVERY qexists_tac [`t`,`h2`] 
                           >> METIS_TAC [])))) ;  
     
val Valid_Init_CandList = Define `
     Valid_Init_CandList (l: Cand list) = ((l <> []) /\ (!c. NO_DUP_PRED l c)) `; 
                                                 
   
val Valid_PileTally = Define `
     Valid_PileTally t (l: Cand list) = (!c. (MEM c l) <=> (MEM c (MAP FST t))) `;
  
    
val Valid_PileTally_DEC1_def = Define `
        (Valid_PileTally_DEC1 [] (l: Cand list) = T)
     /\ (Valid_PileTally_DEC1 (h::t) l = (MEM (FST h) l) /\ (Valid_PileTally_DEC1 t l)) `;
    
       
val Valid_PileTally_DEC2_def = Define `
        (Valid_PileTally_DEC2 t ([]: Cand list) = T) 
     /\ (Valid_PileTally_DEC2 t (l0::ls) = if (MEM l0 (MAP FST t)) 
                                                then (Valid_PileTally_DEC2 t ls)
                                           else F) `;
  

val non_empty = Define ` (non_empty [] = F)
                      /\ (non_empty _ = T) `;
 

val empty_list_def = Define `
                         (empty_list [] = T)
                      /\ (empty_list _ = F) `;
 


 
val PileTally_to_PileTally_DEC1 = Q.store_thm ("PileTally_to_PileTally_DEC1",
 `!l t. (!c. (MEM c (MAP FST t)) ==> (MEM c l)) ==> (Valid_PileTally_DEC1 t l) `,

    Induct_on `t`   
       >- rw [Valid_PileTally_DEC1_def]  
       >- (REPEAT STRIP_TAC    
          >> first_assum (qspecl_then [`FST h`] strip_assume_tac)
            >> rfs[Valid_PileTally_DEC1_def,MAP]));
                                                                                                                                                                                                
val PileTally_DEC1_to_PileTally = Q.store_thm ("PileTally_DEC1_to_PileTally",
 `!l t. (Valid_PileTally_DEC1 t l) ==> (!c. MEM c (MAP FST t) ==> (MEM c l))`,
 
    Induct_on `t`  
        >- rw[]  
        >- (REPEAT STRIP_TAC     
            >> rfs [Valid_PileTally_DEC1_def]));  

  
   
val non_empty_IS_CORRECT = Q.store_thm ("non_empty_IS_CORRECT",
  `!(l: (Cand # rat) list). (non_empty l) ==> (?l0 ls. (l = l0::ls)) `,
 
     (STRIP_TAC 
       >> ASSUME_TAC (INST_TYPE [alpha |-> ``:Cand #rat``] list_nchotomy)   
         >> first_assum (qspecl_then [`l`] strip_assume_tac))   
            >- rw [non_empty]   
            >- rw[non_empty]);
 


     
    
val PileTally_to_PileTally_DEC2 = Q.store_thm ("PileTally_to_PileTally_DEC2",
   `!l t. (!c. (MEM c l) ==> (MEM c (MAP FST t))) ==> (Valid_PileTally_DEC2 t l) `,
 
     Induct_on `l`
        >- rw [Valid_PileTally_DEC2_def] 
        >- rfs [Valid_PileTally_DEC2_def]); 
       
      
val PileTally_DEC2_IMP_PileTally = Q.store_thm ("PileTally_DEC2_IMP_PileTally",
  `!l t. (Valid_PileTally_DEC2 t l) ==> (!c. (MEM c l) ==> (MEM c (MAP FST t)))`,

      Induct_on `l` 
         >- rw []   
         >- ((REPEAT STRIP_TAC  
           >> FULL_SIMP_TAC list_ss [MEM])
              >- FULL_SIMP_TAC list_ss [Valid_PileTally_DEC2_def]
              >- rfs [Valid_PileTally_DEC2_def]));
   
 
val REMOVE_ONE_CAND_APPEND = Q.store_thm ("REMOVE_ONE_CAND_APPEND",
 `! l1 l2 (c: Cand). (~ MEM c l1) ==> (remove_one_cand c (l1 ++l2) = l1 ++ (remove_one_cand c l2))`,

   Induct_on `l1`  
       >- RW_TAC list_ss [APPEND_NIL,remove_one_cand_def]
       >- (REPEAT STRIP_TAC
         >> first_assum (qspecl_then [`l2`,`c`] strip_assume_tac)
           >> FULL_SIMP_TAC list_ss [MEM,remove_one_cand_def])); 
 
 
val REMOVE_ONE_CAND_NOTIN = Q.store_thm ("REMOVE_ONE_CAND_NOTIN",
 `!l (c: Cand). (~ MEM c l) ==> (remove_one_cand c l = l) `,

    Induct_on `l`
        >- rw [remove_one_cand_def]
        >- (REPEAT STRIP_TAC 
          >> FULL_SIMP_TAC list_ss [MEM, remove_one_cand_def])) ;  



val EQE_REMOVE_ONE_CAND = Q.store_thm ("EQE_REMOVE_ONE_CAND",
  `!h (c: Cand). (MEM c h) /\ (NO_DUP_PRED h c) ==> (eqe c (remove_one_cand c h) h) `,
 
 Induct_on `h`  
     >- rw []       
  
     >- ((STRIP_TAC 
       >> STRIP_TAC 
         >> ASSUME_TAC CAND_EQ_DEC
           >> first_x_assum (qspecl_then [`c`,`h'`] strip_assume_tac))    
               >- ((rw[eqe_def,remove_one_cand_def,NO_DUP_PRED] 
                  >> MAP_EVERY qexists_tac [`[]`,`h`] 
                     >> EVAL_TAC   
                       >> ASSUME_TAC (INST_TYPE [alpha |-> ``:Cand``] list_nchotomy)   
                         >> first_assum (qspecl_then [`h1`] strip_assume_tac))  
                             >- FULL_SIMP_TAC list_ss [CONS_11,MEM]  
                             >- FULL_SIMP_TAC list_ss [list_11,MEM])  
               >- ((STRIP_TAC 
                  >> first_x_assum (qspecl_then [`c`] strip_assume_tac) 
                    >> ASSUME_TAC NO_DUP_TAIL_ONE_CAND 
                       >> first_x_assum (qspecl_then [`h`,`h'`,`c`] strip_assume_tac)  
                         >> FULL_SIMP_TAC list_ss [MEM])          
                             >- rw []   
                             >-  (`eqe c (remove_one_cand c h) h ` by metis_tac []
                               >> FULL_SIMP_TAC bool_ss [eqe_def,remove_one_cand_def]          
                                 >> MAP_EVERY qexists_tac [`h'::l1`,`l2`] 
                                   >> RW_TAC list_ss [MEM])))) ;         
                              
              
val EQE_IMP_REMOVE_ONE_CAND = Q.store_thm ("EQE_IMP_REMOVE_ONE_CAND",
 `!h1 h2 (c: Cand). (MEM c h2) /\ (eqe c h1 h2) ==> (h1 = remove_one_cand c h2) `,

   REPEAT STRIP_TAC 
     >> FULL_SIMP_TAC list_ss [eqe_def]  
       >> ASSUME_TAC REMOVE_ONE_CAND_APPEND  
         >> FULL_SIMP_TAC list_ss [eqe_def,remove_one_cand_def]
           >> first_assum (qspecl_then [`l1`,`[c]++l2`,`c`] strip_assume_tac)  
             >> rfs [remove_one_cand_def]);   
 
 
val APPEND_NIL_LEFT = Q.store_thm ("APPEND_NIL_LEFT", 
                                                `!l. [] ++ l = l `,
                                                       STRIP_TAC >> EVAL_TAC) ;  

val APPEND_NIL_LEFT_COR = Q.store_thm("APPEND_NIL_lEFT_COR", 
                                             `!h t. [] ++ (h::t) = h::t `,
                                                   rw[APPEND_NIL_LEFT]) ;
 


val MAP_APPEND_TRIO = Q.store_thm ("MAP_APPEND_TRIO",
  `!t l1 l0 l2. (t = l1 ++ [l0] ++ l2) ==> (MAP FST t = (MAP FST l1) ++ [FST l0] ++ (MAP FST l2))`,

     REPEAT STRIP_TAC
          >> `l1 ++ [l0] ++ l2 = l1 ++([l0] ++ l2)` by FULL_SIMP_TAC list_ss [APPEND_ASSOC]  
            >> RW_TAC bool_ss []  
              >> rfs [MAP_APPEND]);
   
 
val NoDupCand_BOTH_SIDES= Q.store_thm ("NoDupCand_BOTH_SIDES",
 `!l1 l2 (c:Cand) (h1: Cand list) h2. (l1 ++ [c] ++ l2 = h1 ++ [c] ++ h2) 
                                      /\ (~ MEM c h1) /\ (~ MEM c h2) ==> (~ MEM c l1) `,

    Induct_on `l1`
         >- rw []
         >- ((REPEAT STRIP_TAC 
           >> ASSUME_TAC CAND_EQ_DEC 
              >> first_assum (qspecl_then [`c`,`h`] strip_assume_tac))   
                  >- ((ASSUME_TAC (INST_TYPE [alpha |-> ``:Cand``] list_nchotomy) 
                    >> first_assum (qspecl_then [`h1`] strip_assume_tac))   
                       >- (FULL_SIMP_TAC list_ss [CONS_11,MEM_APPEND] 
                        >> `l1++ [h]++ l2 = l1 ++ ([h]++l2)` by metis_tac[APPEND_ASSOC] 
                           >> RW_TAC bool_ss [] 
                              >> FULL_SIMP_TAC list_ss []) 
                       >- FULL_SIMP_TAC list_ss [list_11])
                  >- ((ASSUME_TAC (INST_TYPE [alpha |-> ``:Cand``] list_nchotomy) 
                     >> first_assum (qspecl_then [`h1`] strip_assume_tac))
                        >- FULL_SIMP_TAC list_ss [CONS_11]
                        >- (FULL_SIMP_TAC list_ss [list_11] 
                          >> first_assum (qspecl_then [`l2`,`c`,`t`,`h2`] strip_assume_tac) 
                            >> METIS_TAC [])))) ;
              
 
val get_cand_tally_APPEND = Q.store_thm ("get_cand_tally_APPEND",
  `!(l1: (Cand #rat) list) l2 c. (~ MEM c (MAP FST l1)) 
                                  ==> (get_cand_tally c (l1++l2) = get_cand_tally c l2) `,

      Induct_on `l1`
           >- rw[APPEND_NIL,get_cand_tally_def]
           >- (REPEAT STRIP_TAC >> FULL_SIMP_TAC list_ss [MEM,MAP,get_cand_tally_def])) ;  
 
 
val EVERY_CAND_HAS_ONE_TALLY = Q.store_thm ("EVERY_CAND_HAS_ONE_TALLY",
  `!t c (x: rat). (NO_DUP_PRED (MAP FST t) c) /\ (MEM (c,x) t) ==> (get_cand_tally c t = x) `,
 
      (REPEAT STRIP_TAC 
           >> FULL_SIMP_TAC list_ss [MEM_SPLIT]  
             >> `MAP FST t = (MAP FST l1) ++ ([c] ++ (MAP FST l2))` by 
                 rfs [MAP_APPEND_TRIO,APPEND_ASSOC,APPEND_11]   
                   >> FULL_SIMP_TAC list_ss [NO_DUP_PRED] 
                     >> ASSUME_TAC NoDupCand_BOTH_SIDES 
                       >> first_assum (qspecl_then [`MAP FST l1`,`MAP FST l2`,`c`,`h1`,`h2`] 
                          strip_assume_tac) 
                          >> rfs [get_cand_tally_def,get_cand_tally_APPEND])); 
  
 
val less_than_quota_def = Define `
                 (less_than_quota qu [] l = T)
              /\ (less_than_quota qu (h ::tl ) l = (if (get_cand_tally h l < qu) 
                                                         then less_than_quota qu tl l
                                                    else F)) `; 
 
  
 
val LESS_THAN_QUOTA_OK = Q.store_thm ("LESS_THAN_QUOTA_OK",
`!qu t0 t1 h. (less_than_quota qu h (t0::t1)) ==> (!c.(MEM c h) ==> (get_cand_tally c (t0::t1) < qu))`,
      
    Induct_on `h`
       >- rw []
       >- (REPEAT STRIP_TAC 
         >> FULL_SIMP_TAC list_ss [MEM,less_than_quota_def,get_cand_tally_def]));
  

  
   
val less_than_qu_IMP_LogicalLessThanQuota = Q.store_thm ("less_than_qu_IMP_LogicalLessThanQuota",
 `!h t0 t1 (qu:rat). (less_than_quota qu h (t0::t1)) /\ (Valid_PileTally_DEC2 (t0::t1) h) ==> 
           (!c. (MEM c h) ==> ?x. (MEM (c,x) (t0::t1)) /\ (x < qu))`, 
    
       Induct_on `h` 
          >- rw []     
          >- ((REPEAT STRIP_TAC     
            >> FULL_SIMP_TAC bool_ss [MEM])    
             >- ((ASSUME_TAC (INST_TYPE [alpha |-> ``:rat``] PileTally_DEC2_IMP_PileTally)     
                >> first_x_assum (qspecl_then [`h'::h`,`t0::t1`] strip_assume_tac)    
                  >> `!c. MEM c (h'::h) ==> (MEM c (MAP FST (t0::t1))) ` by metis_tac []  
                     >> `!(h: (Cand#rat)) t c. (MEM c (MAP FST (h::t))) 
                                 ==> (MEM (c,get_cand_tally c (h::t)) (h::t))`                        
                        by (ASSUME_TAC GET_CAND_TALLY_MEM2 
                         >> REPEAT STRIP_TAC    
                         >> first_x_assum (qspecl_then [`h''::t`,`c'`] strip_assume_tac) 
                         >> rw [])                          
                          >> first_assum (qspecl_then [`h'`] strip_assume_tac)      
                            >> first_assum (qspecl_then [`t0`,`t1`,`h'`] strip_assume_tac) >> rfs[])    
                             >- (qexists_tac `get_cand_tally h' (t0::t1)`             
                               >> rfs [less_than_quota_def])                 
                             >- (qexists_tac `get_cand_tally h' (t0::t1)`   
                              >> rw [] >> ASSUME_TAC LESS_THAN_QUOTA_OK  
                               >> first_x_assum (qspecl_then [`qu`,`t0`,`t1`,`c::h`] strip_assume_tac) 
                                >> rfs []))   
             >- (first_assum (qspecl_then [`t0`,`t1`,`qu`] strip_assume_tac) 
               >> rfs [less_than_quota_def,Valid_PileTally_DEC2_def]))); 
    
 
  
val LogicalLessThanQu_IMP_less_than_quota =Q.store_thm ("LogicalLessThanQu_IMP_less_than_quota",
  `!(qu:rat) t h. (!c. (MEM c h) ==> ?x. (MEM (c,x) t) 
                                       /\ (x < qu)) /\ (!c'. NO_DUP_PRED (MAP FST t) c')
                                       /\ (!c''. (MEM c'' h) ==> (MEM c'' (MAP FST t)))
                                   ==> (less_than_quota qu h t)`,
  
   Induct_on `h`
     >- rw [less_than_quota_def]       
     >- (REPEAT STRIP_TAC  
       >> rw[less_than_quota_def] 
         >> `?x. (MEM (h',x) t) /\ (x < qu)` by metis_tac[MEM] 
           >> `MEM h' (MAP FST t)` by metis_tac[MEM] 
             >> `MEM (h', get_cand_tally h' t) t` by metis_tac [GET_CAND_TALLY_MEM2] 
               >> ASSUME_TAC EVERY_CAND_HAS_ONE_TALLY 
                 >> `get_cand_tally h' t = x` by rfs []
                   >> metis_tac []));  
 
 
     
val bigger_than_cand_def = Define `
           (bigger_than_cand c t [] = T)
        /\ (bigger_than_cand c t (h0::h1) = if (get_cand_tally c t) <= (get_cand_tally h0 t)
                                                then (bigger_than_cand c t h1)
                                             else F) `;     
     
 
val bigger_than_cand_OK = Q.store_thm ("bigger_than_cand_OK",
 `!c t h. (bigger_than_cand c t h) ==> (!d. (MEM d h) ==> (get_cand_tally c t <= get_cand_tally d t))`,

      Induct_on `h`
          >- rw []
          >- (REPEAT STRIP_TAC 
            >> FULL_SIMP_TAC list_ss [MEM,bigger_than_cand_def]));
     


val bigger_than_cand_LogicallyOK = Q.store_thm ("bigger_than_cand_LogicallyOK",
 `!h (t0: Cand #rat) t1 c. (bigger_than_cand c (t0::t1) h) 
                        /\ (Valid_PileTally_DEC2 (t0::t1) h) /\ (MEM c h) ==>
   (!d. (MEM d h)  ==> (?x (y: rat). (MEM (c,x) (t0::t1)) /\ (MEM (d,y) (t0::t1)) /\ (x <= y)))`,  

     Induct_on `h`    
        >- rw []
        >- (REPEAT STRIP_TAC 
          >> ASSUME_TAC (INST_TYPE [alpha |-> ``:rat``] PileTally_DEC2_IMP_PileTally)   
            >> first_assum (qspecl_then [`h'::h`,`t0::t1`] strip_assume_tac) 
              >> `!c'. (MEM c' (h'::h)) ==> (MEM c' (MAP FST (t0::t1)))` by metis_tac []  
                >> first_assum (qspecl_then [`c`] strip_assume_tac) 
                  >> first_assum (qspecl_then [`d`] strip_assume_tac)  
                    >> `MEM (c,get_cand_tally c (t0::t1)) (t0::t1)` by rfs [GET_CAND_TALLY_MEM2,MEM]   
                      >> `MEM (d,get_cand_tally d (t0::t1)) (t0::t1)` by rfs [GET_CAND_TALLY_MEM2,MEM]   
                       >> MAP_EVERY qexists_tac [`get_cand_tally c (t0::t1)`,`get_cand_tally d (t0::t1)`] 
                         >> RW_TAC list_ss []  
                           >> ASSUME_TAC bigger_than_cand_OK 
                             >> first_assum (qspecl_then [`c`,`t0::t1`,`h'::h`] strip_assume_tac)    
                               >> metis_tac []));     
   
 


 
val Logical_bigger_than_cand_IMP_TheFunctional = Q.store_thm ("Logical_bigger_than_cand_IMP_TheFunctional",
 `!h t c. (!d. (MEM d h)  ==> (?x (y: rat). (MEM (c,x) t) 
                                                  /\ (MEM (d,y) t) /\ (x <= y))) 
                                                  /\ (!d'. NO_DUP_PRED (MAP FST t) d')
                                                  /\ (MEM c (MAP FST t))
                                                  /\ (!d''. (MEM d'' h) ==> (MEM d'' (MAP FST t)))
                                                 ==> (bigger_than_cand c t h)`,

    Induct_on `h`
        >- rw [bigger_than_cand_def]
        >- (REPEAT STRIP_TAC  
             >> rw[bigger_than_cand_def]   
               >> `?x y. (MEM (c,x) t) /\ (MEM (h',y) t) /\ (x <= y) ` by metis_tac [MEM]   
                >> `MEM c (MAP FST t)` by metis_tac [MEM]
                 >> `MEM (c,get_cand_tally c t) t` by metis_tac [GET_CAND_TALLY_MEM2] 
                  >> ASSUME_TAC EVERY_CAND_HAS_ONE_TALLY  
                   >> `x = get_cand_tally c t` by rfs []    
                    >> `MEM h' (MAP FST t)` by metis_tac [MEM]
                     >> `MEM (h',get_cand_tally h' t) t` by metis_tac [GET_CAND_TALLY_MEM2] 
                      >> `y = get_cand_tally h' t ` by rfs [] 
                       >> RW_TAC bool_ss [])); 
  
  

val subpile1_def = Define `
        (subpile1 c ([]: (Cand # (((Cand list) # rat) list)) list) p2 = T)
     /\ (subpile1 c (p0::ps) p2 = if (c = FST p0) then (MEM (c,[]) p2) /\ (subpile1 c ps p2)
                                 else 
                                     if (MEM p0 p2) then (subpile1 c ps p2)
                                     else F) `;  
       
 
 
val SUBPILE_ONE_HEAD_REMOVAL = Q.store_thm ("SUBPILE_ONE_HEAD_REMOVAL",
 `! p1 p2 c h. (subpile1 c (h::p1) p2) ==> (subpile1 c p1 p2)`, 

   (REPEAT STRIP_TAC 
      >> ASSUME_TAC CAND_EQ_DEC 
        >> first_x_assum (qspecl_then [`c`,`FST h`] strip_assume_tac)
          >> FULL_SIMP_TAC list_ss [subpile1_def] 
            >> metis_tac [subpile1_def]));  
   




   
val Functional_subpile1_IMP_TheLogical = Q.store_thm ("Functional_subpile1_IMP_TheLogical",
 `!p1 p2 c. (subpile1 c p1 p2) ==>  (!d'. ((d' <> c) ==> (!l. (MEM (d',l) p1 ==> MEM (d',l) p2))))`,

     Induct_on `p1` 
        >- rw[] 
        >- ((REPEAT STRIP_TAC   
          >> FULL_SIMP_TAC list_ss [MEM])   
            >- (`d' = FST h` by RW_TAC bool_ss [PAIR_EQ,FST]   
              >> `c <> FST h` by RW_TAC bool_ss []  
                >> FULL_SIMP_TAC list_ss [subpile1_def])  
            >- (first_assum (qspecl_then [`p2`,`c`] strip_assume_tac) 
              >> metis_tac[SUBPILE_ONE_HEAD_REMOVAL])));     
  

val GET_CAND_PILE_MEM = Q.store_thm ("GET_CAND_PILE_MEM",
 `!(p:(Cand # (((Cand list) # rat) list)) list) c. (MEM c (MAP FST p)) 
                          ==> (MEM (c,get_cand_pile c p) p)`, 

        Induct_on `p`
             >- rw []
             >- (EVAL_TAC 
               >> REPEAT STRIP_TAC 
                  >> REPEAT (RW_TAC list_ss [])));
 

val get_cand_pile_APPEND = Q.store_thm ("get_cand_pile_APPEND",
 `! (l1:(Cand # (((Cand list) # rat) list)) list) l2 c. (~ MEM c (MAP FST l1))
                           ==> (get_cand_pile c (l1++l2) = get_cand_pile c l2)`, 

     Induct_on `l1`
        >- rw []
        >- (REPEAT STRIP_TAC >> FULL_SIMP_TAC list_ss [MEM,MAP,get_cand_pile_def]));
 
 

val EVERY_CAND_HAS_ONE_PILE = Q.store_thm ("EVERY_CAND_HAS_ONE_PILE",
 `! p c (y: ((Cand list) # rat) list). (NO_DUP_PRED (MAP FST p) c) /\ (MEM (c,y) p) 
                          ==> (get_cand_pile c p = y)`,
  
      (REPEAT STRIP_TAC
         >> FULL_SIMP_TAC list_ss [MEM_SPLIT]  
           >> `MAP FST p = (MAP FST l1) ++ ([c] ++ (MAP FST l2))`
                by rfs [MAP_APPEND_TRIO,APPEND_ASSOC,APPEND_11]   
              >> FULL_SIMP_TAC list_ss [NO_DUP_PRED]
                >> ASSUME_TAC NoDupCand_BOTH_SIDES    
                  >> first_assum (qspecl_then [`MAP FST l1`,`MAP FST l2`,`c`,`h1`,`h2`] strip_assume_tac) 
                    >> `~ MEM c (MAP FST l1)` by metis_tac []  
                      >> ASSUME_TAC get_cand_pile_APPEND  
                        >> FULL_SIMP_TAC list_ss [get_cand_pile_def])); 
        

  
val Logical_subpile1_IMP_TheFunctional = Q.store_thm ("Logical_subpile1_IMP_TheFunctional",
 `! p1 p2 c. (!d'. ((d' <> c) ==> (!l. (MEM (d',l) p1 ==> MEM (d',l) p2))) 
                /\ ((d' = c) ==> (MEM (c,[]) p2))) ==> (subpile1 c p1 p2)`, 

         Induct_on `p1` 
           >- rw[subpile1_def]   
           >- ((REPEAT STRIP_TAC
             >> rw[subpile1_def]  
               >> ASSUME_TAC CAND_EQ_DEC
                 >> first_x_assum (qspecl_then [`c`,`FST h`] strip_assume_tac))
                   >- RW_TAC bool_ss [] 
                   >- (first_assum (qspecl_then [`FST h`] strip_assume_tac)
                     >> `!l. MEM (FST h,l) (h::p1) ==> (MEM (FST h,l) p2)` by metis_tac []
                       >> first_assum (qspecl_then [`SND h`] strip_assume_tac)
                         >> FULL_SIMP_TAC list_ss [MEM,PAIR]))); 
     

val subpile2_def = Define `
      (subpile2 c ([]: (Cand # (((Cand list) # rat) list)) list) p1 = T)
   /\ (subpile2 c (p0::ps) p1 = if (c = FST p0) then (subpile2 c ps p1)
                                else 
                                    if (MEM p0 p1) then (subpile2 c ps p1)
                                    else F)`; 
   
 
val SUBPILE_TWO_HEAD_REMOVAL = Q.store_thm ("SUBPILE_TWO_HEAD_REMOVAL",
 `!p1 p2 c h. (subpile2 c (h::p2) p1) ==> (subpile2 c p2 p1) `,
 
      (REPEAT STRIP_TAC
         >> ASSUME_TAC CAND_EQ_DEC   
           >> first_x_assum (qspecl_then [`c`,`FST h`] strip_assume_tac))
              >- FULL_SIMP_TAC list_ss [subpile2_def]
              >- metis_tac [subpile2_def]);
   
 
val Functional_subpile2_IMP_TheLogical = Q.store_thm ("Functional_subpile2_IMP_TheLogical",
 `!p1 p2 c. (subpile2 c p2 p1) ==>  (!d'. ((d' <> c) ==> (!l. (MEM (d',l) p2 ==> MEM (d',l) p1))))`,

    Induct_on `p2`
        >- rw []
        >- ((REPEAT STRIP_TAC
          >> FULL_SIMP_TAC bool_ss [MEM]) 
             >- (`d' = FST h` by RW_TAC bool_ss [PAIR_EQ,FST] 
               >> `c <> FST h` by RW_TAC bool_ss []   
                 >>  RW_TAC bool_ss [subpile2_def]
                   >> FULL_SIMP_TAC list_ss [subpile2_def])
             >- (first_assum (qspecl_then [`p1`,`c`] strip_assume_tac)
               >> metis_tac [SUBPILE_TWO_HEAD_REMOVAL])));
  
 
val subpile1_CandPile_Empty = Q.store_thm ("subpile1_CandPile_Empty",
 `!(l: Cand list) p1 p2 c. (subpile1 c p1 p2) /\ (MEM c (MAP FST p2)) 
                                              /\ (MEM c (MAP FST p1))  ==> (MEM (c,[]) p2)`,

Induct_on `p1`
   >- rw[]
   >- (REPEAT STRIP_TAC  
     >> ASSUME_TAC CAND_EQ_DEC 
       >> first_assum (qspecl_then [`c`,`FST h`] strip_assume_tac)
         >> FULL_SIMP_TAC list_ss [subpile1_def]
           >> metis_tac [subpile1_def,MAP,MEM]));
 

 
 
val Logical_subpile2_IMP_TheFunctional = Q.store_thm ("Logical_subpile2_IMP_TheFunctional",
 `!p1 p2 c. (!d'. ((d' <> c) ==> (!l. (MEM (d',l) p2 ==> MEM (d',l) p1))) 
              /\ ((d' = c) ==> (?l. MEM (c,l) p1))) ==> (subpile2 c p2 p1)`,

      Induct_on `p2`          
           >- rw[subpile2_def]
           >- ((REPEAT STRIP_TAC   
             >> ASSUME_TAC CAND_EQ_DEC   
               >> first_x_assum (qspecl_then [`c`,`FST h`] strip_assume_tac))
                 >- rw [subpile2_def]  
                 >- (rw [subpile2_def]
                   >> first_assum (qspecl_then [`FST h`] strip_assume_tac)
                     >> `FST h <> c` by (STRIP_TAC >> RW_TAC bool_ss [EQ_SYM_EQ])   
                       >> `!l. MEM (FST h,l) (h::p2) ==> MEM (FST h,l) p1` by metis_tac []      
                         >> first_assum (qspecl_then [`SND h`] strip_assume_tac)
                           >> FULL_SIMP_TAC bool_ss [PAIR,MEM,PAIR_EQ])));  
            
   
val logical_GetCandPile_IMP_TheFunctional = Q.store_thm ("logical_GetCandPile_IMP_TheFunctional",
 `!(p: (Cand # (((Cand list) # rat) list)) list) nba c. (!d. (d <> c) ==> 
   (!l. MEM (d,l) p ==> ~ ((d,l) = (d,nba)))) /\ (!d. (d = c) ==> (!l. MEM (c,l) p /\ ((c,l) = (c,nba)))) 
/\ MEM c (MAP FST p) ==> (nba = get_cand_pile c p)`,   
 
    Induct_on `p`
        >- rw[] 
        >- ((REPEAT STRIP_TAC 
          >> ASSUME_TAC CAND_EQ_DEC    
            >> first_assum (qspecl_then [`c`,`FST h`] strip_assume_tac))          
               >- (ASSUME_TAC GET_CAND_PILE_MEM
                 >> first_assum (qspecl_then [`h::p`,`c`] strip_assume_tac)                 
                   >> `MEM (c,get_cand_pile c (h::p)) (h::p)` by metis_tac[]
                     >> `(c,get_cand_pile c (h::p)) = (c,nba)` by metis_tac[] 
                       >> RW_TAC bool_ss [PAIR_EQ,EQ_SYM_EQ])   
            >- metis_tac[MEM,MAP,PAIR_EQ,EQ_SYM_EQ])); 
 






       
 
val no_dup_pile_def = Define `
     (no_dup_pile x ([] : ((((Cand list) # rat) list) list)) = T)
  /\ (no_dup_pile x (h::t) = if (x = h) then
                               if (not_elem x t) then T else F  
                             else  no_dup_pile x t)`;

 
val NO_DUP_PILE = Define `
    NO_DUP_PILE (p: ((((Cand list) # rat) list) list)) x = (p = []) \/ (~ MEM x p) \/
                                                   (?l1 l2. (p = l1 ++ x::l2) /\ (~ MEM x l1) /\ (~ MEM x l2))`;   
  

 



val list_MEM_def = Define `
      (list_MEM [] l = T)
   /\ (list_MEM (h::t) l = (MEM h l) /\ (list_MEM t l))`;
 
 
val list_not_MEM_def = Define `
        (list_not_MEM  [] l = T)
     /\ (list_not_MEM (h::t) l = (~ MEM h l) /\ (list_not_MEM t l))`;
      

 
val list_not_MEM_verified_fully= Q.store_thm ("list_not_MEM_verified_fully",
 `!l1 (l2: Cand list). (!c. MEM c l1 ==> (~ MEM c l2)) <=> (list_not_MEM l1 l2)`,

        Induct_on `l1`
             >- rw[list_not_MEM_def]
             >- (REPEAT STRIP_TAC 
               >> metis_tac[MEM,list_not_MEM_def]));
   

val Logical_list_MEM_VICE_VERCA_TheFunctional = Q.store_thm("Logical_list_MEM_VICE_VERCA_TheFunctional",
 `!(l1: Cand list) l2. (!c. MEM c l1 ==> MEM c l2) <=> list_MEM l1 l2`, 

    Induct_on `l1`
      >- rw[list_MEM_def]
      >- (REPEAT STRIP_TAC 
        >> metis_tac[MEM,list_MEM_def]));  


     
val elim_cand_def = Define ` (elim_cand st (qu :rat) (l : Cand list) (c: Cand) j1 j2) = (?t p e h nh nba np.
    (j1 = state ([], t, p, [], e, h))
    /\ Valid_Init_CandList l
    /\ (!c'. MEM c' (h++e) ==> (MEM c' l))
    /\ (!c'. NO_DUP_PRED (h++e) c')
    /\ (Valid_PileTally p l)   
    /\ (Valid_PileTally np l)
    /\ (LENGTH (e ++ h) > st) 
    /\ (LENGTH e < st)
    /\ (!c'. NO_DUP_PRED (MAP FST t) c')
    /\ (Valid_PileTally t l)
    /\ (!c'. (MEM c' h ==> (?x. MEM (c',x) t /\ ( x < qu))))  
    /\ (MEM c h) 
    /\ (!d. (MEM d h ==> (?x y. (MEM (c,x) t) /\ (MEM (d,y) t) /\ ( x <= y))))
    /\ (eqe c nh h)
    /\ (nba = get_cand_pile c p)
    /\ (MEM (c,[]) np)
    /\ (!d'. ((d' <> c) ==> (!l. (MEM (d',l) p ==> MEM (d',l) np) 
                              /\ (MEM (d',l) np ==> MEM (d',l) p))))
    /\ (j2 = state (nba, t, np, [], e, nh)) ) `; 
                      
 




   
val Elim_cand_dec_def = Define `
             (Elim_cand_dec st (qu : rat) (l: Cand list) (c:Cand) ((j: judgement), winners w) = F)
          /\ (Elim_cand_dec st qu l c (winners w, (j: judgement)) = F) 
          /\ (Elim_cand_dec st qu l c (state (ba, t, p, bl, e, h), state (ba', t', p', bl', e',h')) = 
                  ((empty_list ba) 
               /\ (empty_list bl) 
               /\ (t = t') /\ (bl = bl') /\ (e = e')
               /\ (LENGTH (e ++ h) > st) /\ (LENGTH e < st)
               /\ (non_empty l) /\ (no_dup l)
               /\ (list_MEM (h++e) l)
               /\ (no_dup (h++e))       
               /\ (Valid_PileTally_DEC1 p l) /\ (Valid_PileTally_DEC2 p l)
               /\ (Valid_PileTally_DEC1 p' l) /\ (Valid_PileTally_DEC2 p' l)
               /\ no_dup (MAP FST t)
               /\ (Valid_PileTally_DEC1 t l) /\ (Valid_PileTally_DEC2 t l) 
               /\ (MEM c h)
               /\ (less_than_quota qu h t)
               /\ (h' = remove_one_cand c h)
               /\ (bigger_than_cand c t h)
               /\ (ba' = get_cand_pile c p)
               /\ (MEM (c,[]) p')
               /\ (subpile1 c p p') /\ (subpile2 c p' p) )) `;
                             
   
  
   
   
val Logical_elim_to_Functional_Elim = Q.store_thm ("Logical_elim_to_Functional_Elim",
 `!st qu l c j1 j2. elim_cand st qu l c j1 j2 ==> (Elim_cand_dec st qu l c (j1,j2))`,
 
   (rw[elim_cand_def,Elim_cand_dec_def]   
    >> EVAL_TAC   
     >> REPEAT STRIP_TAC)  
      >- rw[]      
      >- RW_TAC bool_ss []     
      >- (`l <> []` by metis_tac[Valid_Init_CandList] 
         >> `?l1 x. l = x::l1` by metis_tac [list_nchotomy] 
           >> rw[non_empty])   
      >- metis_tac [Valid_Init_CandList,NO_DUP_PRED_to_no_dup]    
      >- (`!(l1:Cand list) l2 (c':Cand). MEM c' l1 \/ MEM c' l2 ==> MEM c' (l1++l2)` 
              by FULL_SIMP_TAC list_ss [MEM,MEM_APPEND]
          >> `!c'. MEM c' (h++e) ==> MEM c' l` by metis_tac [MEM,MEM_APPEND]      
            >> metis_tac [Logical_list_MEM_VICE_VERCA_TheFunctional])  
      >- metis_tac [NO_DUP_PRED_to_no_dup] 
      >- metis_tac [PileTally_to_PileTally_DEC1,Valid_PileTally]   
      >- metis_tac [PileTally_to_PileTally_DEC2,Valid_PileTally] 
      >- metis_tac [PileTally_to_PileTally_DEC1,Valid_PileTally]  
      >- metis_tac [PileTally_to_PileTally_DEC2,Valid_PileTally]   
      >- metis_tac [NO_DUP_PRED_to_no_dup] 
      >- metis_tac [Valid_PileTally,PileTally_to_PileTally_DEC1] 
      >- metis_tac [Valid_PileTally,PileTally_to_PileTally_DEC2]
      >- rw []
      >- metis_tac [LogicalLessThanQu_IMP_less_than_quota,Valid_PileTally] 
      >- metis_tac [EQE_IMP_REMOVE_ONE_CAND] 
      >- (`MEM c (MAP FST t)` by metis_tac [Valid_PileTally,FST,MAP] 
        >> `!d. MEM d h ==> MEM d (MAP FST t)` by metis_tac [Valid_PileTally] 
         >> metis_tac [Logical_bigger_than_cand_IMP_TheFunctional]) 
      >- rw[] 
      >- metis_tac [Logical_subpile1_IMP_TheFunctional]          
      >- (`!d. (d = c) ==> ?l. MEM (c,l) p` by metis_tac[GET_CAND_PILE_MEM,Valid_PileTally]  
          >> metis_tac [Logical_subpile2_IMP_TheFunctional])); 
  
      
val empty_list_verified= Q.store_thm ("empty_list_verified",
 `!l. empty_list l ==> (l = [])`,

   Induct_on `l`
     >- rw[]  
     >- metis_tac[empty_list_def]);
      
  

 

 
val Functional_Elim_to_Logical_elim = Q.store_thm ("Functional_Elim_to_Logical_elim",
 `!st qu l c j1 j2. Elim_cand_dec st qu l c (j1,j2) ==> elim_cand st qu l c j1 j2`,
   
  (STRIP_TAC 
     >> STRIP_TAC >> STRIP_TAC >> STRIP_TAC >> STRIP_TAC >> STRIP_TAC 
       >> Cases_on `j1`)
         >- (Cases_on `j2` 
           >- ((rw[Elim_cand_dec_def,elim_cand_def] 
            >> Cases_on `p` >> Cases_on `r` >> Cases_on `r'` >> Cases_on `r` >> Cases_on `r'` 
             >> Cases_on `p'` >> Cases_on `r'` >> Cases_on `r''` >> Cases_on `r'` >> Cases_on `r''` 
              >> rfs[Elim_cand_dec_def] 
               >> REPEAT STRIP_TAC)   
                >- metis_tac[empty_list_verified]       
                >- (RW_TAC bool_ss [empty_list_def] 
                 >> metis_tac [empty_list_verified]) 
                >- (`!(L:Cand list). non_empty L ==> (L <> [])` 
                  by (Induct_on `L` 
                     >- rw[non_empty] 
                     >- rw[non_empty]) >> metis_tac[Valid_Init_CandList,no_dup_IMP_NO_DUP_PRED,non_empty])
                >- metis_tac [Logical_list_MEM_VICE_VERCA_TheFunctional,MEM_APPEND]  
                >- (RW_TAC bool_ss [] >> metis_tac [Logical_list_MEM_VICE_VERCA_TheFunctional,MEM_APPEND])
                >- (RW_TAC bool_ss [] >> metis_tac [no_dup_IMP_NO_DUP_PRED]) 
                >- metis_tac [Valid_PileTally,PileTally_DEC1_to_PileTally,PileTally_DEC2_IMP_PileTally]
                >- metis_tac [Valid_PileTally,PileTally_DEC1_to_PileTally,PileTally_DEC2_IMP_PileTally]    
                >- metis_tac[] 
                >- metis_tac[] 
                >- metis_tac [no_dup_IMP_NO_DUP_PRED]
                >- metis_tac [Valid_PileTally,PileTally_DEC1_to_PileTally,PileTally_DEC2_IMP_PileTally]
                >- (`!(L:Cand list). non_empty L ==> (L <> [])` 
                   by (Induct_on `L` 
                     >- rw[non_empty] 
                     >- rw[non_empty]) >> `?L y. l = y::L` by metis_tac[non_empty,list_nchotomy] 
                      >> `MEM y (MAP FST q')` by metis_tac [PileTally_DEC2_IMP_PileTally,MEM] 
                      >> `?l1 q1. q' = q1::l1` by metis_tac [MEM_MAP,MEM,list_nchotomy] 
                      >> `!d. MEM d r ==> MEM d l` 
                           by metis_tac [MEM_APPEND,Logical_list_MEM_VICE_VERCA_TheFunctional] 
                      >> `!d. MEM d r ==> MEM d (MAP FST q')` by metis_tac [PileTally_DEC2_IMP_PileTally] 
                    >> metis_tac[PileTally_to_PileTally_DEC2,less_than_qu_IMP_LogicalLessThanQuota])              
                >- (`!(L:Cand list). non_empty L ==> (L <> [])` 
                   by (Induct_on `L` 
                    >- rw[non_empty] 
                    >- rw[non_empty]) >> `?L y. l = y::L` by metis_tac[non_empty,list_nchotomy] 
                     >> `MEM y (MAP FST q')` by metis_tac [PileTally_DEC2_IMP_PileTally,MEM] 
                     >> `?l1 q1. q' = q1::l1` by metis_tac [MEM_MAP,MEM,list_nchotomy] 
                     >> `!d. MEM d r ==> MEM d l` 
                         by metis_tac [MEM_APPEND,Logical_list_MEM_VICE_VERCA_TheFunctional] 
                     >> `!d. MEM d r ==> MEM d (MAP FST q')` by metis_tac [PileTally_DEC2_IMP_PileTally] 
                     >> metis_tac [PileTally_to_PileTally_DEC2,bigger_than_cand_LogicallyOK])
                >- (`!(l1 :Cand list) l2. no_dup (l1++l2) ==> no_dup l1`   
                    by (Induct_on `l1`
                     >- rw[no_dup]
                     >- ((REPEAT STRIP_TAC >> rw[no_dup]) 
                        >- (`not_elem h (l1++l2)` by rfs [no_dup] 
                         >>`!G1 G2 (s: Cand). (not_elem s (G1++G2) = (not_elem s G1) /\ (not_elem s G2))`
                             by (Induct_on `G1` 
                              >- FULL_SIMP_TAC list_ss [APPEND_NIL_LEFT,not_elem]
                              >- ((ASSUME_TAC CAND_EQ_DEC >> REPEAT STRIP_TAC 
                                >> first_x_assum (qspecl_then [`s`,`h'`] strip_assume_tac))
                                 >- FULL_SIMP_TAC list_ss [not_elem]
                                 >- FULL_SIMP_TAC list_ss [not_elem])) >> metis_tac[]) 
                        >- (`!d. NO_DUP_PRED (h::l1++l2) d` by metis_tac [no_dup_IMP_NO_DUP_PRED] 
                          >> `h::l1++l2 = h::(l1++l2)` by FULL_SIMP_TAC list_ss [] 
                           >> `!d. NO_DUP_PRED (l1++l2) d` by metis_tac [NO_DUP_HEAD_REMOVAL] 
                            >> metis_tac [NO_DUP_PRED_to_no_dup])))
                    >> metis_tac [EQE_REMOVE_ONE_CAND,no_dup_IMP_NO_DUP_PRED]) 
                >- metis_tac [Functional_subpile1_IMP_TheLogical] 
                >- metis_tac [Functional_subpile2_IMP_TheLogical]
                >- metis_tac [empty_list_verified]) 
   
            >- rw[Elim_cand_dec_def])
        >- (Cases_on `j2` 
            >- RW_TAC bool_ss [Elim_cand_dec_def]
            >- rw[Elim_cand_dec_def]));      
  
   
   
val transfer_def = Define `(transfer st (qu:rat) l j1 j2 = ? nba t p bl e h nbl np.
          (j1 = state ([], t, p, bl, e, h))
       /\ (LENGTH e < st)
       /\ (!d. MEM d (h++e) ==> MEM d l)
       /\ (!d. NO_DUP_PRED (h++e) d)
       /\ (Valid_PileTally t l)
       /\ (Valid_PileTally p l)
       /\ (Valid_PileTally np l)
       /\ (Valid_Init_CandList l)
       /\ (!c. NO_DUP_PRED (MAP FST t) c)
       /\ (!c'. (MEM c' h ==> (?x. MEM (c',x) t /\ ( x < qu))))
       /\ ? l c.
                ((bl = c::l)
             /\ (nbl = l)
             /\ (nba = get_cand_pile c p)
             /\ (MEM (c,[]) np)
             /\ (!d'. ((d' <> c) ==> (!l'. (MEM (d',l') p ==> MEM (d',l') np) 
                              /\ (MEM (d',l') np ==> MEM (d',l') p)))))
             /\ (j2 = state (nba, t, np, nbl, e, h)))`; 
  
 
 
val Transfer_dec_def = Define `
         (Transfer_dec st (qu : rat) (l: Cand list) ((j: judgement), winners w) = F)
          /\ (Transfer_dec st qu l (winners w, (j: judgement)) = F) 
          /\ (Transfer_dec st qu l (state (ba, t, p, bl, e, h), state (ba', t', p', bl', e',h')) =
              (empty_list ba) /\ (e = e') /\ (h = h') /\ (t = t')
           /\ (LENGTH e < st)
           /\ (list_MEM (h++e) l)
           /\ no_dup (h++e)
           /\ (Valid_PileTally_DEC1 t l) /\ (Valid_PileTally_DEC2 t l)
           /\ (Valid_PileTally_DEC1 p l) /\ (Valid_PileTally_DEC2 p l)
           /\ (Valid_PileTally_DEC1 p' l) /\ (Valid_PileTally_DEC2 p' l)
           /\ (non_empty l) /\ (no_dup l)
           /\ (no_dup (MAP FST t))
           /\ (less_than_quota qu h t) 
           /\ (bl = (HD bl) :: (TL bl))
           /\ (bl' = (TL bl))
           /\ (ba' = get_cand_pile (HD bl) p)
           /\ (MEM (HD bl,[]) p')
           /\ (subpile1 (HD bl) p p') /\ (subpile2 (HD bl) p' p))`;
   
     
val Logical_transfer_to_Functional_Transfer = Q.store_thm ("Logical_transfer_to_Functional_Transfer",
 `! st qu l j1 j2. transfer st qu l j1 j2 ==> Transfer_dec st qu l (j1,j2)`, 

(rw[transfer_def,Transfer_dec_def]
  >> EVAL_TAC 
    >> REPEAT STRIP_TAC) 
  
     >- rw[]  
     >- (`(!d. MEM d h \/ MEM d e ==> MEM d l) ==> (!d. MEM d (h++e) ==> MEM d l)` 
         by  FULL_SIMP_TAC list_ss [MEM_APPEND] >>
      metis_tac [Logical_list_MEM_VICE_VERCA_TheFunctional])
     >- metis_tac [NO_DUP_PRED_to_no_dup]
     >- metis_tac [PileTally_to_PileTally_DEC1,Valid_PileTally]  
     >- metis_tac [PileTally_to_PileTally_DEC2,Valid_PileTally]
     >- metis_tac [PileTally_to_PileTally_DEC1,Valid_PileTally]
     >- metis_tac [PileTally_to_PileTally_DEC2,Valid_PileTally]
     >- metis_tac [PileTally_to_PileTally_DEC1,Valid_PileTally] 
     >- metis_tac [PileTally_to_PileTally_DEC2,Valid_PileTally]
     >- (`?l1 y. l = y::l1` by metis_tac [Valid_Init_CandList,list_nchotomy]
         >> rw[non_empty])   
     >- metis_tac [NO_DUP_PRED_to_no_dup,Valid_Init_CandList]  
     >- metis_tac [NO_DUP_PRED_to_no_dup]
     >- metis_tac [LogicalLessThanQu_IMP_less_than_quota,Valid_PileTally]
     >- RW_TAC bool_ss [] 
     >- metis_tac [Logical_subpile1_IMP_TheFunctional]   
     >- (`?(y: (Cand # (((Cand list) # rat) list))). (c = FST y) /\ (MEM y np)`
        by (MAP_EVERY qexists_tac [`(c,[])`] >> metis_tac [FST])     
        >> `MEM c (MAP FST np)` by metis_tac[MEM_MAP]              
          >> `!d. (d = c) ==> ?l. MEM (c,l) p` by metis_tac[GET_CAND_PILE_MEM,Valid_PileTally]   
           >> metis_tac [Logical_subpile2_IMP_TheFunctional]));
     


val Functional_Transfer_to_Logical_transfer = Q.store_thm ("Functional_Transfer_to_Logical_transfer",
 `! st qu l j1 j2. Transfer_dec st qu l (j1,j2) ==> transfer st qu l j1 j2`,
 
 (REPEAT STRIP_TAC 
  >> rw[transfer_def] 
    >> Cases_on `j1`)
      >- (Cases_on `j2` 
        >- ((Cases_on `p` >> Cases_on `r` >> Cases_on `r'` >> Cases_on `r` >> Cases_on `r'` 
          >> Cases_on `p'` >> Cases_on `r'`>> Cases_on `r''`>> Cases_on `r'`>> Cases_on `r''`
           >> rfs [Transfer_dec_def] 
            >> MAP_EVERY qexists_tac [`q'''''`,`TL q'''`,`q'''''''`] >> REPEAT STRIP_TAC) 
       >- rw[empty_list_verified]
       >-  RW_TAC bool_ss []  
       >-  metis_tac [MEM_APPEND,Logical_list_MEM_VICE_VERCA_TheFunctional]   
       >-  metis_tac [MEM_APPEND,Logical_list_MEM_VICE_VERCA_TheFunctional]
       >-  metis_tac [no_dup_IMP_NO_DUP_PRED]
       >-  metis_tac [Valid_PileTally,PileTally_DEC1_to_PileTally,PileTally_DEC2_IMP_PileTally]
       >-  metis_tac [Valid_PileTally,PileTally_DEC1_to_PileTally,PileTally_DEC2_IMP_PileTally]      
       >-  metis_tac [Valid_PileTally,PileTally_DEC1_to_PileTally,PileTally_DEC2_IMP_PileTally]
       >- (`!(L:Cand list). non_empty L ==> (L <> [])`  
                  by (Induct_on `L` 
                     >- rw[non_empty] 
                     >- rw[non_empty]) 
           >> metis_tac[Valid_Init_CandList,no_dup_IMP_NO_DUP_PRED,non_empty])
       >- metis_tac [no_dup_IMP_NO_DUP_PRED] 
       >- (`!(L:Cand list). non_empty L ==> (L <> [])` 
                   by (Induct_on `L` 
                     >- rw[non_empty] 
                     >- rw[non_empty]) >> `?L y. l = y::L` by metis_tac[non_empty,list_nchotomy]  
                      >> `MEM y (MAP FST q')` by metis_tac [PileTally_DEC2_IMP_PileTally,MEM]  
                      >> `?l1 q1. q' = q1::l1` by metis_tac [MEM_MAP,MEM,list_nchotomy] 
                      >> `!d. MEM d r ==> MEM d l` 
                           by metis_tac [MEM_APPEND,Logical_list_MEM_VICE_VERCA_TheFunctional]  
                      >> `!d. MEM d r ==> MEM d (MAP FST q')` by metis_tac [PileTally_DEC2_IMP_PileTally] 
                    >> metis_tac[PileTally_to_PileTally_DEC2,less_than_qu_IMP_LogicalLessThanQuota])  
       >- ((MAP_EVERY qexists_tac [`HD q'''`] >> REPEAT STRIP_TAC) 
         >- FULL_SIMP_TAC list_ss [] 
         >- rw[]
         >- RW_TAC bool_ss []
         >- metis_tac [Functional_subpile1_IMP_TheLogical]
         >- metis_tac [Functional_subpile2_IMP_TheLogical] 
         >- rw[]
         >- EVAL_TAC  
         >- rw[]))
     >- rfs [Transfer_dec_def]) 
    >- (Cases_on `j2`
     >- rfs [Transfer_dec_def]
     >- rfs [Transfer_dec_def]));  
 


     
val first_continuing_cand = Define `
       (first_continuing_cand (c: Cand) (b: Cand list)  (h: Cand list) =
            (?l1 l2. (b = l1 ++ c::l2) /\ (!d. MEM d l1 ==> ~ MEM d h)))`;
             

 
val fcc_dec = Define `
        (fcc (c:Cand) ([]: Cand list)  (h: Cand list) = F)
     /\ (fcc c (b0::bs) h = if (c = b0) then T
                              else if (~ MEM b0 h) /\ (fcc c bs h) then T
                                   else F)`;
 


 
val fcc_to_first_continuing_cand = Q.store_thm ("fcc_to_first_continuing_cand",
 `! c b h. fcc c b h ==> first_continuing_cand c b h`, 
 
  Induct_on `b`
    >- rw[fcc_dec]
    >- ((REPEAT STRIP_TAC
      >> rw[first_continuing_cand]
       >> `(c = h) \/ (~ (c = h))` by metis_tac [CAND_EQ_DEC]) 
         >- (MAP_EVERY qexists_tac [`[]`,`b`]
          >> FULL_SIMP_TAC list_ss [APPEND_NIL_LEFT])
         >- (rfs [fcc_dec]
           >- RW_TAC bool_ss []
           >- (rfs [first_continuing_cand]
            >> `?L1 L2. (b = L1 ++ [c]++L2) /\ (!d. MEM d L1 ==> ~ MEM d h')` by metis_tac[]
             >> MAP_EVERY qexists_tac [`h::L1`,`L2`]
              >> FULL_SIMP_TAC list_ss [MEM] >> metis_tac [MEM]))));
 


val first_continuing_cand_IMP_fcc = Q.store_thm ("first_continuing_cand_IMP_fcc",
 `! c b h. first_continuing_cand c b h ==> fcc c b h`,

Induct_on `b`

>- rw[first_continuing_cand]

>- ((REPEAT STRIP_TAC
  >> rw[fcc_dec]
    >> `(c = h) \/ (~ (c = h))` by metis_tac [CAND_EQ_DEC]) 

    >- RW_TAC bool_ss []

    >- ((rfs [first_continuing_cand]
      >> `(l1 = []) \/ (?L1 x. l1 = x::L1)` by metis_tac [list_nchotomy])
 
        >- FULL_SIMP_TAC list_ss [APPEND_NIL_LEFT,CONS_11]

        >- (FULL_SIMP_TAC list_ss [CONS_11]
          >> first_assum (qspecl_then [`c`,`h'`] strip_assume_tac)
            >> metis_tac [MEM])))); 
  
 
 

 
val count_def = Define	`
    (count st qu l j1 j2 = ? ba t nt p np bl e h.
          (j1 = state (ba, t, p, bl, e, h))
       /\ (!d. MEM d (h++e) ==> MEM d l)
       /\ (!d. NO_DUP_PRED (h++e) d)
       /\ (Valid_PileTally t l)
       /\ (Valid_PileTally nt l)
       /\ (Valid_PileTally p l)
       /\ (Valid_PileTally np l)
       /\ (Valid_Init_CandList l)
       /\ (!c. NO_DUP_PRED (MAP FST t) c) 
       /\ (!c. ~ MEM c h ==> MEM c l)
       /\ (ba <> [])
       /\ (!c. ((MEM c h ==> 
                             ?(l: ((Cand list) # rat) list).
                               (l = FILTER (\ (b: (Cand list) # rat). (first_continuing_cand c (FST b) h)) ba)
                            /\ (!l'. MEM (c,l') np ==> (l' = (get_cand_pile c p) ++ l))
                            /\ (!r. MEM (c,r) nt ==> (r = sum_aux l)))
                           /\ (~ MEM c h ==> 
                                           (!l'. MEM (c,l') np <=> MEM (c,l') p)
                                        /\ (!r. MEM (c,r) t <=> MEM (c,r) nt))))  
       /\ (j2 = state ([], nt, np, bl, e, h)))`;  
   


  
val intermediate_count = Define `
        (intermediate_count st qu l j1 j2 = ? ba t nt p np bl e h.
          (j1 = state (ba, t, p, bl, e, h))
       /\ (!d. MEM d (h++e) ==> MEM d l)
       /\ (!d. NO_DUP_PRED (h++e) d)
       /\ (Valid_PileTally t l)
       /\ (Valid_PileTally nt l)
       /\ (Valid_PileTally p l)
       /\ (Valid_PileTally np l)
       /\ (Valid_Init_CandList l)
       /\ (!d. NO_DUP_PRED (MAP FST p) d)
       /\ (!c. NO_DUP_PRED (MAP FST t) c) 
       /\ (!c. NO_DUP_PRED (MAP FST np) c)
       /\ (!c. NO_DUP_PRED (MAP FST nt) c) 
       /\ (ba <> [])
       /\ (h <> [])
       /\ (!c. MEM c l ==>
                            ((MEM c h ==> 
                             ?(l: ((Cand list) # rat) list).
                               (l = FILTER (\ (b: (Cand list) # rat). (first_continuing_cand c (FST b) h)) ba)
                            /\ (get_cand_pile c np = (get_cand_pile c p) ++ l)
                            /\ (get_cand_tally c nt = (sum_aux l)))
                            /\ (~ MEM c h ==> 
                                           (get_cand_pile c np = get_cand_pile c p)
                                        /\ (get_cand_tally c nt = get_cand_tally c t))))  
       /\ (j2 = state ([], nt, np, bl, e, h)))`;  
           



      
val Count_Aux_def = Define `
         (Count_Aux st qu l j1 j2 = ? ba t nt p np bl e h.
          (j1 = state (ba, t, p, bl, e, h))
       /\ (!d. MEM d (h++e) ==> MEM d l)
       /\ (!d. NO_DUP_PRED (h++e) d)
       /\ (Valid_PileTally t l)
       /\ (Valid_PileTally nt l)
       /\ (Valid_PileTally p l)
       /\ (Valid_PileTally np l)
       /\ (Valid_Init_CandList l)
       /\ (!d. NO_DUP_PRED (MAP FST p) d)
       /\ (!c. NO_DUP_PRED (MAP FST t) c) 
       /\ (!c. NO_DUP_PRED (MAP FST np) c) 
       /\ (!c. NO_DUP_PRED (MAP FST nt) c) 
       /\ (ba <> [])
       /\ (h <> [])
       /\ (!c. MEM c l ==>
                            ((MEM c h ==> 
                             ?(l: ((Cand list) # rat) list).
                               (l = FILTER (\ (b: (Cand list) # rat). (first_continuing_cand c (FST b) h)) ba)
                            /\ (!l'. MEM (c,l') np ==> (l' = (get_cand_pile c p) ++ l))
                            /\ (!r. MEM (c,r) nt ==> (r = sum_aux l)))
                            /\ (~ MEM c h ==> 
                                           (!l'. MEM c l /\ MEM (c,l') np <=> MEM c l /\ MEM (c,l') p)
                                        /\ (!r. MEM c l /\ MEM (c,r) t <=> MEM c l /\ MEM (c,r) nt))))  
       /\ (j2 = state ([], nt, np, bl, e, h)))`;  
          
  
  
 
    
val Count_Dec_Aux = Define `
     (Count_Dec_Aux p np t nt ba h [] = T)
  /\ (Count_Dec_Aux p np t nt ba  h (l0::ls) = 
       if (MEM l0 h) then
        (get_cand_pile l0 np = (get_cand_pile l0 p) ++ FILTER (\ (b: (Cand list) # rat). (fcc l0 (FST b) h)) ba) 
          /\ (get_cand_tally l0 nt = sum_aux (FILTER (\ (b: (Cand list) # rat). (fcc l0 (FST b) h)) ba))
           /\ (Count_Dec_Aux p np t nt ba h ls)
        else
             (get_cand_pile l0 np = get_cand_pile l0 p)
          /\ (get_cand_tally l0 nt = get_cand_tally l0 t)
          /\ (Count_Dec_Aux p np t nt ba h ls))`;      
 

     


  
      
 val Count_Aux_dec = Define `
    (Count_Aux_dec st (qu : rat) (l: Cand list) ((j: judgement), winners w) = F)
 /\ (Count_Aux_dec st qu l (winners w, (j: judgement)) = F) 
 /\ (Count_Aux_dec st qu l (state (ba, t, p, bl, e, h), state (ba', t', p', bl', e',h')) =   
       (Count_Dec_Aux p p' t t' ba h l)
    /\ (bl = bl') /\ (e = e') /\ (h = h')
    /\ (no_dup (h++e))
    /\ no_dup (MAP FST p)
    /\ (list_MEM (h++e) l)
    /\ (Valid_PileTally_DEC1 t l) /\ (Valid_PileTally_DEC2 t l)
    /\ (Valid_PileTally_DEC1 t' l) /\ (Valid_PileTally_DEC2 t' l)
    /\ (Valid_PileTally_DEC1 p l) /\ (Valid_PileTally_DEC2 p l)
    /\ (Valid_PileTally_DEC1 p' l) /\ (Valid_PileTally_DEC2 p' l)
    /\ no_dup (MAP FST p')
    /\ no_dup (MAP FST t')
    /\ (non_empty l) /\ (no_dup l)
    /\ (no_dup (MAP FST t))
    /\ (non_empty ba)
    /\ (non_empty h)
    /\ (ba' = []))`;
        
     
 
val Logical_to_Functional_Count_Dec_Aux = Q.store_thm ("Logical_to_Functional_Count_Dec_Aux",
 `!t nt p np ba h l. 
          (!c. MEM c l ==>
                 ((MEM c h ==> 
                    ?(l: ((Cand list) # rat) list).
                      (l = FILTER (\ (b: (Cand list) # rat). (first_continuing_cand c (FST b) h)) ba)
                         /\ (get_cand_pile c np = (get_cand_pile c p) ++ l)
                         /\ (get_cand_tally c nt = (sum_aux l)))
                         /\ (~ MEM c h ==> 
                                      (get_cand_pile c np = get_cand_pile c p)
                                      /\ (get_cand_tally c nt = get_cand_tally c t)))) 
                                           ==> Count_Dec_Aux p np t nt ba h l`,


Induct_on `l`
  >- rw[Count_Dec_Aux]
  >- ((REPEAT STRIP_TAC 
      >> rw[Count_Dec_Aux])
  
    >- (first_assum (qspecl_then [`h`] strip_assume_tac)  
     >> FULL_SIMP_TAC list_ss [MEM]
      >> `!c h ba. first_continuing_cand c h ba <=> fcc c h ba` 
              by metis_tac [first_continuing_cand_IMP_fcc,fcc_to_first_continuing_cand]  
         >> metis_tac [])
  
    >- (first_assum (qspecl_then [`h`] strip_assume_tac)
     >> FULL_SIMP_TAC list_ss []
       >> `!c h ba. first_continuing_cand c h ba <=> fcc c h ba` 
              by metis_tac [first_continuing_cand_IMP_fcc,fcc_to_first_continuing_cand]  
         >> metis_tac [])));
    
 



   
val Functional_to_Logical_Count_Dec_Aux = Q.store_thm ("Functional_to_Logical_Count_Dec_Aux",
`!t nt p np ba h l. Count_Dec_Aux p np t nt ba h l ==>
          (!c. MEM c l ==>
                 ((MEM c h ==> 
                    ?(l: ((Cand list) # rat) list).
                      (l = FILTER (\ (b: (Cand list) # rat). (first_continuing_cand c (FST b) h)) ba)
                         /\ (get_cand_pile c np = (get_cand_pile c p) ++ l)
                         /\ (get_cand_tally c nt = (sum_aux l)))
                         /\ (~ MEM c h ==> 
                                      (get_cand_pile c np = get_cand_pile c p)
                                      /\ (get_cand_tally c nt = get_cand_tally c t))))`, 


Induct_on `l` 
  >- rw[]     
  >- (REPEAT STRIP_TAC   
      >- (`(c = h) \/ (MEM c l)` by FULL_SIMP_TAC list_ss [MEM]    
           >- ((MAP_EVERY qexists_tac [`FILTER (\ (b: (Cand list) # rat). (fcc c (FST b) h')) ba`] 
            >> `!c h ba. first_continuing_cand c h ba <=> fcc c h ba` 
              by metis_tac [first_continuing_cand_IMP_fcc,fcc_to_first_continuing_cand]   
              >>  STRIP_TAC) 
                 >- metis_tac []  
                 >- metis_tac[Count_Dec_Aux]) 
           >- ((MAP_EVERY qexists_tac [`FILTER (\ (b: (Cand list) # rat). (fcc c (FST b) h')) ba`] 
            >> `!c h ba. first_continuing_cand c h ba <=> fcc c h ba` 
              by metis_tac [first_continuing_cand_IMP_fcc,fcc_to_first_continuing_cand]
              >> STRIP_TAC) 
                >- metis_tac []  
                >- metis_tac [Count_Dec_Aux]))
       >- metis_tac[Count_Dec_Aux,MEM]     
       >- metis_tac [Count_Dec_Aux,MEM])); 
  
 

val intermediate_count_IMP_Count_Aux = Q.store_thm ("intermediate_count_IMP_Count_Aux",
 `! (st: num) (qu: rat) l j1 j2. intermediate_count st qu l j1 j2 ==> Count_Aux st qu l j1 j2`,
 

(REPEAT STRIP_TAC 
  >> rw[Count_Aux_def]   
    >> rfs[intermediate_count]  
      >> STRIP_TAC)  
  >- metis_tac []
  >- (REPEAT STRIP_TAC
     >- metis_tac [Valid_PileTally,PileTally_DEC2_IMP_PileTally,EVERY_CAND_HAS_ONE_PILE]
     >- metis_tac [Valid_PileTally,PileTally_DEC2_IMP_PileTally,EVERY_CAND_HAS_ONE_TALLY]
     >- (`get_cand_pile c np = get_cand_pile c p` by metis_tac []  
      >> `!L. MEM (c,L) np ==> (get_cand_pile c np = L)` by 
            metis_tac [Valid_PileTally,PileTally_DEC2_IMP_PileTally,EVERY_CAND_HAS_ONE_PILE]
        >> `!L. MEM (c,L) p ==> (get_cand_pile c p = L)` by 
            metis_tac [Valid_PileTally,PileTally_DEC2_IMP_PileTally,EVERY_CAND_HAS_ONE_PILE]  
          >> `!L. MEM (c,L) p ==> MEM (c,L) np` by (REPEAT STRIP_TAC >>      
              metis_tac [Valid_PileTally,PileTally_DEC2_IMP_PileTally,GET_CAND_PILE_MEM])   
            >> `!L. MEM (c,L) np ==> MEM (c,L) p` by (REPEAT STRIP_TAC >>      
                metis_tac [Valid_PileTally,PileTally_DEC2_IMP_PileTally,GET_CAND_PILE_MEM])     
              >> metis_tac [])      
     >- (`get_cand_tally c nt = get_cand_tally c t` by metis_tac [] 
        >> `!L. MEM (c,L) nt ==> (get_cand_tally c nt = L)` by 
            metis_tac [Valid_PileTally,PileTally_DEC2_IMP_PileTally,EVERY_CAND_HAS_ONE_TALLY] 
          >> `!L. MEM (c,L) t ==> (get_cand_tally c t = L)` by 
              metis_tac [Valid_PileTally,PileTally_DEC2_IMP_PileTally,EVERY_CAND_HAS_ONE_TALLY] 
            >> `!L. MEM (c,L) t ==> MEM (c,L) nt` by (REPEAT STRIP_TAC >>      
                metis_tac [Valid_PileTally,PileTally_DEC2_IMP_PileTally,GET_CAND_TALLY_MEM2]) 
             >> `!L. MEM (c,L) nt ==> MEM (c,L) t` by (REPEAT STRIP_TAC >>      
                 metis_tac [Valid_PileTally,PileTally_DEC2_IMP_PileTally,GET_CAND_TALLY_MEM2]) 
               >> metis_tac [])));       
     
  
  
val Count_Aux_IMP_intermediate_count = Q.store_thm ("Count_Aux_IMP_intermediate_count",
`! (st: num) (qu: rat) l j1 j2. Count_Aux st qu l j1 j2 ==> intermediate_count st qu l j1 j2`,

(REPEAT STRIP_TAC
 >> rw[intermediate_count] 
  >> rfs[Count_Aux_def]
   >> STRIP_TAC)
   >- metis_tac[]   
   >- (REPEAT STRIP_TAC 
     >- (`(!l'. MEM (c,l') np ==> 
       (l' = (get_cand_pile c p) ++ (FILTER (\ (b: (Cand list) # rat).(first_continuing_cand c (FST b) h)) ba)))`
        by  metis_tac[]
      >> first_assum (qspecl_then [`get_cand_pile c np`] strip_assume_tac) 
        >> metis_tac [Valid_PileTally,PileTally_DEC2_IMP_PileTally,GET_CAND_PILE_MEM])  
     >- metis_tac [Valid_PileTally,PileTally_DEC2_IMP_PileTally,GET_CAND_TALLY_MEM2]
     >- (`(!l'. MEM c l /\ MEM (c,l') np <=> MEM c l /\ MEM (c,l') p)` by metis_tac []
       >> `MEM (c,get_cand_pile c np) p` by 
           metis_tac [Valid_PileTally,PileTally_DEC2_IMP_PileTally,GET_CAND_PILE_MEM,EVERY_CAND_HAS_ONE_PILE]
         >> metis_tac [Valid_PileTally,PileTally_DEC2_IMP_PileTally,EVERY_CAND_HAS_ONE_PILE])
     >- (`(!r. MEM c l /\ MEM (c,r) t <=> MEM c l /\ MEM (c,r) nt) ` by metis_tac []
      >> metis_tac [Valid_PileTally,PileTally_DEC2_IMP_PileTally,EVERY_CAND_HAS_ONE_TALLY,GET_CAND_TALLY_MEM2])));
      
  




val Count_Aux_IMP_Count_Aux_dec = Q.store_thm ("Count_Aux_IMP_Count_Aux_dec",
 `! (st: num) (qu: rat) l j1 j2. Count_Aux st qu l j1 j2 ==> Count_Aux_dec st qu l (j1,j2)`,
  
  (ASSUME_TAC Count_Aux_IMP_intermediate_count
   >> REPEAT STRIP_TAC 
    >> `intermediate_count st qu l j1 j2` by metis_tac[Count_Aux_def,Count_Aux_IMP_intermediate_count]
     >> rfs[Count_Aux_dec,Count_Aux_def]
      >> REPEAT STRIP_TAC) 
        >- (rfs [intermediate_count] 
         >> metis_tac [ Logical_to_Functional_Count_Dec_Aux])
        >- metis_tac[NO_DUP_PRED_to_no_dup]      
        >- metis_tac[NO_DUP_PRED_to_no_dup]      
        >- metis_tac [Logical_list_MEM_VICE_VERCA_TheFunctional,MEM_APPEND]
        >- metis_tac [Valid_PileTally,PileTally_to_PileTally_DEC1] 
        >- metis_tac [Valid_PileTally,PileTally_to_PileTally_DEC2] 
        >- metis_tac [Valid_PileTally,PileTally_to_PileTally_DEC1] 
        >- metis_tac [Valid_PileTally,PileTally_to_PileTally_DEC2] 
        >- metis_tac [Valid_PileTally,PileTally_to_PileTally_DEC1] 
        >- metis_tac [Valid_PileTally,PileTally_to_PileTally_DEC2]  
        >- metis_tac [Valid_PileTally,PileTally_to_PileTally_DEC1] 
        >- metis_tac [Valid_PileTally,PileTally_to_PileTally_DEC2] 
        >- metis_tac [NO_DUP_PRED_to_no_dup]
        >- metis_tac [NO_DUP_PRED_to_no_dup]
        >- (`l <> []` by metis_tac[Valid_Init_CandList] 
         >> `?l1 x. l = x::l1` by metis_tac [list_nchotomy] 
           >> rw[non_empty]) 
        >- metis_tac [Valid_Init_CandList,NO_DUP_PRED_to_no_dup]
        >- metis_tac [NO_DUP_PRED_to_no_dup]
        >- (`? X BA. ba = X::BA` by metis_tac [list_nchotomy] >> rw[non_empty]) 
        >- (`? h0 hs. h = h0::hs` by metis_tac [list_nchotomy] >> rw[non_empty]));
   
  
 
val Count_Aux_dec_IMP_Count_Aux = Q.store_thm ("Count_Aux_dec_IMP_Count_Aux",
 `! (st : num) (qu:rat) l j1 j2. Count_Aux_dec st qu l (j1,j2) ==> Count_Aux st qu l j1 j2 `,
 
 (ASSUME_TAC intermediate_count_IMP_Count_Aux   
  >> REPEAT STRIP_TAC  
    >> `intermediate_count st qu l j1 j2` by
      (Cases_on `j1`   
       >- (Cases_on `j2` 
         >- ((Cases_on `p` >> Cases_on `r` >> Cases_on `r'` >> Cases_on `r` >> Cases_on `r'`
           >> Cases_on `p'` >> Cases_on `r'` >> Cases_on `r''` >> Cases_on `r'` >> Cases_on `r''`           
             >> rfs[intermediate_count,Count_Aux_dec]
              >> REPEAT STRIP_TAC)  
            >- metis_tac [Logical_list_MEM_VICE_VERCA_TheFunctional,MEM_APPEND] 
            >- metis_tac [Logical_list_MEM_VICE_VERCA_TheFunctional,MEM_APPEND]
            >- metis_tac [no_dup_IMP_NO_DUP_PRED]   
            >- metis_tac [Valid_PileTally,PileTally_DEC1_to_PileTally,PileTally_DEC2_IMP_PileTally] 
            >- metis_tac [Valid_PileTally,PileTally_DEC1_to_PileTally,PileTally_DEC2_IMP_PileTally]
            >- metis_tac [Valid_PileTally,PileTally_DEC1_to_PileTally,PileTally_DEC2_IMP_PileTally] 
            >- metis_tac [Valid_PileTally,PileTally_DEC1_to_PileTally,PileTally_DEC2_IMP_PileTally] 
            >- (`!(L:Cand list). non_empty L ==> (L <> [])` 
                  by (Induct_on `L` 
                     >- rw[non_empty] 
                     >- rw[non_empty]) >> metis_tac[Valid_Init_CandList,no_dup_IMP_NO_DUP_PRED,non_empty])
            >- metis_tac [no_dup_IMP_NO_DUP_PRED]  
            >- metis_tac [no_dup_IMP_NO_DUP_PRED]  
            >- metis_tac [no_dup_IMP_NO_DUP_PRED]
            >- metis_tac [no_dup_IMP_NO_DUP_PRED]  
            >- metis_tac [non_empty]  
            >- metis_tac [non_empty]
            >- metis_tac [Functional_to_Logical_Count_Dec_Aux]   
            >-  metis_tac [Functional_to_Logical_Count_Dec_Aux]
            >- metis_tac [Functional_to_Logical_Count_Dec_Aux]
            >- metis_tac [Functional_to_Logical_Count_Dec_Aux]) 
         >- rfs [Count_Aux_dec])  
        >- (Cases_on `j2`
         >- rfs [Count_Aux_dec]
         >- rfs [Count_Aux_dec]))) 
           >> metis_tac[]);   
    
  

val APPEND_EQ_NIL2 = Q.store_thm ("APPEND_EQ_NIL2",
    `!l1 l2. ([] = l1 ++ l2) ==> ((l1 = []) /\ (l2 = [])) `,
      Cases_on `l2`
        >- ASM_SIMP_TAC bool_ss [APPEND_NIL]    
        >- (Cases_on `l1` 
          >> rw[APPEND_NIL_LEFT_COR]   
            >> (ASM_SIMP_TAC bool_ss [NOT_NIL_CONS] 
              >> STRIP_TAC 
                >> rw[NOT_NIL_CONS]))) ;
 
 
 
val take_append = Define `
      (take_append [] _ = [])
   /\ (take_append (l0::ls) [] = l0::ls)
   /\ (take_append (l0::ls) (h::t) = (take_append ls t))`; 
 



 
val take_append_returns_appended = Q.store_thm ("take_append_returns_appended",
 `! l1 l2 l3. (l1 = l2 ++ l3) ==> (l3 = take_append l1 l2)`,

 Induct_on `l1`
  >- FULL_SIMP_TAC list_ss [APPEND_EQ_NIL2,take_append] 
  >- (Induct_on `l2`
    >- FULL_SIMP_TAC list_ss [APPEND_NIL_LEFT,take_append] 
    >- (REPEAT STRIP_TAC
     >> rw[take_append] 
       >> FULL_SIMP_TAC list_ss [CONS_11])));
 


val tally_comparison = Define `
     (tally_comparison (t: (Cand # rat) list) c1 c2 = if (get_cand_tally c1 t <= get_cand_tally c2 t)
                                                        then T else F)`;
 
     

  
val eqe_list_dec = Define `
     (eqe_list_dec ([]: Cand list) l1 l2 = if (list_MEM l1 l2) then T else F)
  /\ (eqe_list_dec (l0::ls) l1 l2 = (~ MEM l0 l1) /\ (MEM l0 l2) /\ eqe_list_dec ls l1 l2)`;
                                      
 
val eqe_list_dec_MEM1 = Q.store_thm ("list_eqe_dec_MEM1",
 `!l0 l1 l2. eqe_list_dec l0 l1 l2 ==> (!c. MEM c l0 \/ MEM c l1 ==> MEM c l2)`,
 
Induct_on `l0`
  >- metis_tac [eqe_list_dec,list_MEM_def,Logical_list_MEM_VICE_VERCA_TheFunctional]
  >- (REPEAT STRIP_TAC  
     >- metis_tac [eqe_list_dec,MEM]  
     >- metis_tac [MEM,eqe_list_dec]));
 
  
val logical_to_functional_eqe_list_dec = Q.store_thm ("logical_to_functional_eqe_list_dec",
`!l0 l1 l2. (!c. NO_DUP_PRED (l0 ++ l1) c) /\ (!c. MEM c l0 \/ MEM c l1 ==> MEM c l2) ==> eqe_list_dec l0 l1 l2`,

   Induct_on `l0`
     >- metis_tac [eqe_list_dec,list_MEM_def,Logical_list_MEM_VICE_VERCA_TheFunctional]
     >- ((REPEAT STRIP_TAC
       >> rw[eqe_list_dec])  
           >- (`no_dup (h::l0 ++ l1)` by metis_tac [NO_DUP_PRED_to_no_dup] 
             >> `!G1 G2 (s: Cand). (not_elem s (G1++G2) = (not_elem s G1) /\ (not_elem s G2))`
                             by (Induct_on `G1` 
                              >- FULL_SIMP_TAC list_ss [APPEND_NIL_LEFT,not_elem]
                              >- ((ASSUME_TAC CAND_EQ_DEC >> REPEAT STRIP_TAC 
                                >> first_x_assum (qspecl_then [`s`,`h'`] strip_assume_tac))
                                 >- FULL_SIMP_TAC list_ss [not_elem]
                                 >- FULL_SIMP_TAC list_ss [not_elem]))  
                >> FULL_SIMP_TAC list_ss [no_dup,not_elem,not_elem_NOT_MEM])    
           >- (FULL_SIMP_TAC list_ss [NO_DUP_TAIL_ONE_CAND,MEM] >> metis_tac [NO_DUP_TAIL_ONE_CAND,MEM])));
   



val eqe_list_dec2 = Define `
     (eqe_list_dec2 l0 l1 ([]: Cand list) = T)
  /\ (eqe_list_dec2 l0 l1 (l::ls) = (MEM l l0 \/ MEM l l1) /\ (eqe_list_dec2 l0 l1 ls))`;     

 
val eqe_list_dec2_verified = Q.store_thm ("eqe_list_dec2_verified",
 `! l0 l1 l2. eqe_list_dec2 l0 l1 l2 <=> (!c. MEM c l2 ==> MEM c l0 \/ MEM c l1)`,
  Induct_on `l2`
    >- rw[eqe_list_dec2]
    >- (REPEAT STRIP_TAC 
    >> metis_tac [MEM,eqe_list_dec2])); 
  

val bigger_than_quota = Define `
       (bigger_than_quota ([] :Cand list) t (qu :rat) = T)
    /\ (bigger_than_quota (l0::ls) t qu = (qu <= get_cand_tally l0 t) /\ (bigger_than_quota ls t qu))`;
 

 
val functional_to_logical_BiggerThanQuota = Q.store_thm ("logical_to_functional_BiggerThanQuota",
 `! (qu:rat) l t. bigger_than_quota l t qu /\ no_dup (MAP FST t) ==>
                                     (!c. MEM c l ==> (!r. MEM (c,r) t ==> qu <= r))`,
 
  Induct_on `l`
    >- rw[]
    >- ((REPEAT STRIP_TAC
      >> FULL_SIMP_TAC list_ss [])
         >- (`get_cand_tally c t = r` by metis_tac [no_dup_IMP_NO_DUP_PRED,EVERY_CAND_HAS_ONE_TALLY]
           >> metis_tac [RAT_LEQ_REF,bigger_than_quota])
         >- metis_tac [bigger_than_quota]));
   

   
val logical_to_functional_BiggerThanQuota = Q.store_thm ("logical_to_functional_BiggerThanQuota",
`! (qu: rat) l t. (!c. NO_DUP_PRED (MAP FST t) c) /\ (!d. MEM d l ==> MEM d (MAP FST t)) /\
                  (!c. MEM c l ==> (!r. MEM (c,r) t ==> qu <= r)) ==> bigger_than_quota l t qu`,
                                          
  Induct_on `l`
     >- rw[bigger_than_quota]
     >- ((REPEAT STRIP_TAC
       >> rw[bigger_than_quota])
          >- (`MEM (h,get_cand_tally h t) t` by metis_tac [MEM,GET_CAND_TALLY_MEM2]
            >> metis_tac[MEM])
          >- metis_tac [MEM]));
 
 
val piles_eq_list = Define `
       (piles_eq_list ([]: Cand list) l p1 p2 = T)
    /\ (piles_eq_list (l0::ls) l p1 p2 = 
            if ~ (MEM l0 l) 
                then (get_cand_pile l0 p1 = get_cand_pile l0 p2) /\ (piles_eq_list ls l p1 p2)
            else (piles_eq_list ls l p1 p2))`;


 
val functional_to_logicl_piles_eq = Q.store_thm ("functional_to_logical_piles_eq",
 `! l1 l2 p1 p2. no_dup (MAP FST p1) /\ no_dup (MAP FST p2) /\ (list_MEM l1 (MAP FST p1)) /\
                (list_MEM l1 (MAP FST p2)) /\ (piles_eq_list l1 l2 p1 p2) ==>
   (!c. MEM c l1 ==> (~ MEM c l2 ==> (!l'. MEM (c,l') p1 <=> MEM (c,l') p2)))`, 
 
Induct_on `l1`
 >- rw[]
     
 >- ((REPEAT STRIP_TAC
    >> FULL_SIMP_TAC list_ss [])  

  >- (`get_cand_pile h p1 = get_cand_pile h p2` by metis_tac [piles_eq_list] >>
     (`MEM (h,l') p1 ==> MEM (h, l') p2` by (STRIP_TAC >> 
     `get_cand_pile c p1 = l'` by 
     metis_tac [Logical_list_MEM_VICE_VERCA_TheFunctional,MEM,list_MEM_def,no_dup_IMP_NO_DUP_PRED,
     GET_CAND_PILE_MEM,EVERY_CAND_HAS_ONE_PILE] >>
       `MEM (h,get_cand_pile h p2) p2` by   
       metis_tac [Logical_list_MEM_VICE_VERCA_TheFunctional,MEM,list_MEM_def,no_dup_IMP_NO_DUP_PRED,
       GET_CAND_PILE_MEM,EVERY_CAND_HAS_ONE_PILE] >>
         `l' = get_cand_pile h p2` by  
         metis_tac [Logical_list_MEM_VICE_VERCA_TheFunctional,MEM,list_MEM_def,no_dup_IMP_NO_DUP_PRED,
         GET_CAND_PILE_MEM,EVERY_CAND_HAS_ONE_PILE] >>
           metis_tac [MEM])) >>
     (`MEM (h,l') p2 ==> MEM (h,l') p1` by (STRIP_TAC >> 
     `get_cand_pile c p2 = l'`
     by metis_tac [Logical_list_MEM_VICE_VERCA_TheFunctional,MEM,list_MEM_def,no_dup_IMP_NO_DUP_PRED,
     GET_CAND_PILE_MEM,EVERY_CAND_HAS_ONE_PILE] >> 
       `MEM (h,get_cand_pile h p1) p1` by   
       metis_tac [Logical_list_MEM_VICE_VERCA_TheFunctional,MEM,list_MEM_def,no_dup_IMP_NO_DUP_PRED,
       GET_CAND_PILE_MEM,EVERY_CAND_HAS_ONE_PILE] >>
         `l' = get_cand_pile h p1` by  
         metis_tac [Logical_list_MEM_VICE_VERCA_TheFunctional,MEM,list_MEM_def,no_dup_IMP_NO_DUP_PRED,
         GET_CAND_PILE_MEM,EVERY_CAND_HAS_ONE_PILE] >>
            metis_tac [MEM])) >>
     metis_tac [MEM])
  

   >- (`list_MEM l1 (MAP FST p1)` by metis_tac [MEM,list_MEM_def,Logical_list_MEM_VICE_VERCA_TheFunctional] >>
      `list_MEM l1 (MAP FST p2)` by metis_tac [MEM,list_MEM_def,Logical_list_MEM_VICE_VERCA_TheFunctional] >>
      `piles_eq_list l1 l2 p1 p2` by metis_tac [piles_eq_list] >>        
      metis_tac [MEM])));   
  

val logical_to_functional_piles_eq = Q.store_thm ("logical_to_functional_piles_eq",
`! l1 l2 p1 p2.  (!c. MEM c l1 ==> (~ MEM c l2 ==> (!l'. MEM (c,l') p1 <=> MEM (c,l') p2))) 
              /\ (!c. NO_DUP_PRED (MAP FST p1) c) /\ (!c. NO_DUP_PRED (MAP FST p2) c)
              /\ (!d. MEM d l1 ==> MEM d (MAP FST p1) /\ MEM d (MAP FST p2)) ==> piles_eq_list l1 l2 p1 p2`,

  Induct_on `l1`
    >- rw[piles_eq_list]
    >- (REPEAT STRIP_TAC 
     >> rw[piles_eq_list]
      >> `!l'. MEM (h,l') p1 <=> MEM (h,l') p2` by FULL_SIMP_TAC list_ss [MEM]
       >> metis_tac [GET_CAND_PILE_MEM,EVERY_CAND_HAS_ONE_PILE,MEM]));
 
 

        
val update_cand_trans_val = Define `
    (update_cand_trans_val (qu: rat) (c: Cand) (t: (Cand # rat) list) (p: (Cand # (Cand list # rat) list) list) = 
        MAP (\ (r:rat). r * (((get_cand_tally c t) - qu) / (get_cand_tally c t))) (MAP SND (get_cand_pile c p)))`;
   
   
   
val update_cand_pile = Define `
          (update_cand_pile (qu: rat) t ([]: Cand list) p1 p2 = T)
       /\ (update_cand_pile qu t (l0::ls) p1 p2 = 
           (MAP FST (get_cand_pile l0 p2) = MAP FST (get_cand_pile l0 p1)) 
        /\ (MAP SND (get_cand_pile l0 p2) = update_cand_trans_val qu l0 t p1) /\
           update_cand_pile qu t ls p1 p2)`;
   

val functional_to_logical_update_pile = Q.store_thm ("functional_to_logical_update_pile",
 `! (qu: rat) (t: (Cand # rat) list) l p1 p2. (!c. NO_DUP_PRED (MAP FST p1) c) /\ (!c. NO_DUP_PRED (MAP FST p2) c)
        /\   (update_cand_pile qu t l p1 p2) ==>
              (!c. MEM c l ==> (!l'. MEM (c,l') p2 ==>
                                         (MAP FST l' = MAP FST (get_cand_pile c p1))
                                      /\ (MAP SND l' = update_cand_trans_val qu c t p1)))`,

   Induct_on `l`
     >- rw[]
     >- (REPEAT STRIP_TAC 
       >- (FULL_SIMP_TAC list_ss []
          >- (`? l1 l2. p2 = l1 ++ (c,l') ::l2` by metis_tac [MEM,MEM_SPLIT] 
           >> `MAP FST p2 = (MAP FST l1) ++ c :: (MAP FST l2)` by FULL_SIMP_TAC list_ss [FST,MAP_APPEND_TRIO] 
            >> `MEM c (MAP FST p2)` by FULL_SIMP_TAC list_ss [MEM_APPEND] 
             >> `l' = get_cand_pile h p2` by metis_tac [GET_CAND_PILE_MEM,EVERY_CAND_HAS_ONE_PILE] 
              >> metis_tac [update_cand_pile])
          >- metis_tac [update_cand_pile])
       >- (FULL_SIMP_TAC list_ss [] 
         >- (`? l1 l2. p2 = l1 ++ (c,l') ::l2` by metis_tac [MEM,MEM_SPLIT] 
          >> `MAP FST p2 = (MAP FST l1) ++ c :: (MAP FST l2)` by FULL_SIMP_TAC list_ss [FST,MAP_APPEND_TRIO] 
           >> `MEM c (MAP FST p2)` by FULL_SIMP_TAC list_ss [MEM_APPEND] 
            >> `l' = get_cand_pile h p2` by metis_tac [GET_CAND_PILE_MEM,EVERY_CAND_HAS_ONE_PILE]      
             >> metis_tac[update_cand_pile])
       >- metis_tac [update_cand_pile])));   
 

 
val logical_to_functional_update_pile = Q.store_thm ("logical_to_functional_update_pile",
 `! (qu: rat) (t: (Cand #rat) list) l p1 p2. (!c. MEM c l ==> MEM c (MAP FST p2)) /\ 
                                            (!c. MEM c l ==> (!l'. MEM (c,l') p2 ==>
                                              (MAP FST l' = MAP FST (get_cand_pile c p1))
                                                /\ (MAP SND l' = update_cand_trans_val qu c t p1))) ==>
                                                    (update_cand_pile qu t l p1 p2)`,

    Induct_on `l`
      >- rw [update_cand_pile]
      >- ((REPEAT STRIP_TAC
       >> rw[update_cand_pile])
          >- (`MEM (h,get_cand_pile h p2) p2` by metis_tac [MEM,GET_CAND_PILE_MEM]
            >> metis_tac [MEM])
          >- (`MEM (h,get_cand_pile h p2) p2` by metis_tac [MEM,GET_CAND_PILE_MEM]
            >> metis_tac [MEM])));
  
 
val tally_comparison_total = Q.store_thm ("tally_comparison_total",
 `!t c1 c2. ((tally_comparison t) c1 c2) \/ ((tally_comparison t) c2 c1)`, 
  ((REPEAT STRIP_TAC
    >> rw[tally_comparison]  
     >> ASSUME_TAC RAT_LES_TOTAL 
      >> first_assum (qspecl_then [`get_cand_tally c1 t`,`get_cand_tally c2 t`] strip_assume_tac)) 
         >- (DISJ1_TAC 
          >> metis_tac [RAT_LES_IMP_LEQ])
         >- (DISJ1_TAC
          >> metis_tac [RAT_LEQ_REF])
         >- (DISJ2_TAC
          >> metis_tac [RAT_LES_IMP_LEQ])));


val tally_comparison_total_COR = Q.store_thm ("tally_comparison_total_COR",
 `!t. total (tally_comparison t)`,

   (ASSUME_TAC (INST_TYPE [alpha |-> ``:Cand``] total_def)
     >> STRIP_TAC 
       >> first_assum (qspecl_then [`tally_comparison t`] strip_assume_tac) 
         >> metis_tac [tally_comparison_total])); 
 
 
 
val tally_comparison_trans = Q.store_thm ("tally_comparison_trans",
 `!t. transitive (tally_comparison t)`,
   
   (STRIP_TAC
     >> `! c1 c2 c3. (tally_comparison t) c1 c2 /\ (tally_comparison t) c2 c3 ==> (tally_comparison t) c1 c3` 
       by (REPEAT STRIP_TAC
        >> metis_tac [tally_comparison,RAT_LEQ_TRANS])
          >> metis_tac[transitive_def])); 
  
  


                                  
val elect = Define `
       (elect st (qu: rat) (l: Cand list) j1 j2) = (? t
                 p bl e h nh ne np nbl l1 . 
                (j1 = state ([], t, p, bl, e, h))
                /\ (l1 <> [])
                /\ (SORTED (tally_comparison t) l1) 
                /\ (!c. MEM c l1 ==> (!(r :rat). MEM (c,r) t ==> (qu <= r)))
                /\ (LENGTH (l1 ++ e) <= st)
                /\ (!c. MEM c l1 \/ MEM c nh ==> MEM c h)
                /\ (!c. MEM c h ==> MEM c nh \/ MEM c l1)
                /\ (!c. NO_DUP_PRED h c)
                /\ (!c. NO_DUP_PRED (l1 ++ nh) c)
                /\ (!c. NO_DUP_PRED (l1 ++ e) c)
                /\ (!c. NO_DUP_PRED ne c)
                /\ (!c. MEM c l1 \/ MEM c e ==> MEM c ne)
                /\ (!c. MEM c ne ==> MEM c e \/ MEM c l1)
                /\ (!c. MEM c h /\ (~ MEM c l1) ==> (!l'. MEM (c,l') np <=> MEM (c,l') p))
                /\ (!c. NO_DUP_PRED (MAP FST p) c)
                /\ (!c. NO_DUP_PRED (MAP FST t) c)
                /\ (!c. NO_DUP_PRED (MAP FST np) c)
                /\ (!c. MEM c l1 ==> (!l'. MEM (c,l') np ==>
                                         (MAP FST l' = MAP FST (get_cand_pile c p))
                                      /\ (MAP SND l' = update_cand_trans_val qu c t p)))
                /\ (nbl = bl ++ l1)
                /\ (Valid_Init_CandList l)
                /\ (Valid_PileTally t l)
                /\ (Valid_PileTally p l)
                /\ (Valid_PileTally np l)
                /\ (!c. MEM c ne ==> MEM c l)
                /\ (!c. MEM c h ==> MEM c l)
                /\ (j2 = state ([], t, np, nbl, ne, nh)))`;                   
  

      
val Elect_dec = Define `
              (Elect_dec st (qu : rat) (l: Cand list) ((j: judgement), winners w) = F)
 /\ (Elect_dec st qu l (winners w, (j: judgement)) = F) 
 /\ (Elect_dec st qu l (state (ba, t, p, bl, e, h), state (ba', t', p', bl', e',h')) =  
              let (l1 = (take_append bl' bl))
                 in  
                   (SORTED (tally_comparison t) l1)
                /\ (no_dup (l1 ++ e))
                /\ (ba = []) /\ (ba' = [])
                /\ (t = t')
                /\ (non_empty l1)
                /\ (bigger_than_quota l1 t qu)
                /\ (LENGTH (l1 ++ e) <= st)
                /\ (eqe_list_dec l1 h' h)
                /\ (eqe_list_dec2 l1 h' h)
                /\ (no_dup h)
                /\ (no_dup (l1 ++ h'))
                /\ (no_dup e')
                /\ (eqe_list_dec l1 e e')
                /\ (eqe_list_dec2 l1 e e')
                /\ (piles_eq_list h l1 p p')
                /\ (no_dup (MAP FST p))
                /\ (no_dup (MAP FST t))
                /\ (no_dup (MAP FST p'))
                /\ (non_empty l)
                /\ (no_dup l)
                /\ (bl' = bl ++ l1)
                /\ (Valid_PileTally_DEC1 p l) /\ (Valid_PileTally_DEC2 p l)
                /\ (Valid_PileTally_DEC1 p' l) /\ (Valid_PileTally_DEC2 p' l) 
                /\ (Valid_PileTally_DEC1 t l) /\ (Valid_PileTally_DEC2 t l)
                /\ (list_MEM e' l)
                /\ (list_MEM h l)
                /\ (update_cand_pile qu t l1 p p'))`;
      
 

val Logical_to_Functional_elect = Q.store_thm ("Logical_to_Functional_elect",
 `! st (qu: rat) l j1 j2. elect st qu l j1 j2 ==> Elect_dec st qu l (j1,j2)`,

(rw [elect,Elect_dec]
  >> EVAL_TAC  
   >> `take_append (bl ++ l1) bl = l1` by metis_tac [take_append,take_append_returns_appended]   
    >> REPEAT STRIP_TAC)  
       >- metis_tac [] 
       >- metis_tac [NO_DUP_PRED_to_no_dup] 
       >- (RW_TAC bool_ss [] 
         >> metis_tac [list_nchotomy,non_empty]) 
       >- (RW_TAC bool_ss [] 
         >> `!c. MEM c l1 ==> MEM c (MAP FST t)` by metis_tac [MEM, Valid_PileTally]
           >> metis_tac [logical_to_functional_BiggerThanQuota,bigger_than_quota,MEM])  
       >- FULL_SIMP_TAC list_ss [LENGTH_APPEND]    
       >- metis_tac [logical_to_functional_eqe_list_dec]
       >- metis_tac [eqe_list_dec2_verified]
       >- metis_tac [NO_DUP_PRED_to_no_dup]
       >- metis_tac [NO_DUP_PRED_to_no_dup]
       >- metis_tac [NO_DUP_PRED_to_no_dup]
       >- metis_tac [logical_to_functional_eqe_list_dec] 
       >- metis_tac [eqe_list_dec2_verified]
       >- (`!d. MEM d h ==> MEM d (MAP FST p) /\ MEM d (MAP FST np)` by metis_tac [MEM,Valid_PileTally]
         >> metis_tac [logical_to_functional_piles_eq])
       >- metis_tac [NO_DUP_PRED_to_no_dup]    
       >- metis_tac [NO_DUP_PRED_to_no_dup]
       >- metis_tac [NO_DUP_PRED_to_no_dup]
       >- metis_tac [Valid_Init_CandList,list_nchotomy,non_empty] 
       >- metis_tac [Valid_Init_CandList,NO_DUP_PRED_to_no_dup] 
       >- RW_TAC bool_ss []
       >- metis_tac [Valid_PileTally,PileTally_to_PileTally_DEC1] 
       >- metis_tac [Valid_PileTally,PileTally_to_PileTally_DEC2] 
       >- metis_tac [Valid_PileTally,PileTally_to_PileTally_DEC1] 
       >- metis_tac [Valid_PileTally,PileTally_to_PileTally_DEC2] 
       >- metis_tac [Valid_PileTally,PileTally_to_PileTally_DEC1] 
       >- metis_tac [Valid_PileTally,PileTally_to_PileTally_DEC2]  
       >- metis_tac [Logical_list_MEM_VICE_VERCA_TheFunctional,MEM_APPEND]
       >- metis_tac [Logical_list_MEM_VICE_VERCA_TheFunctional,MEM_APPEND]
       >- (`(!c. MEM c l1 ==> MEM c (MAP FST np))` by metis_tac [MEM,Valid_PileTally]  
         >> `(!c. MEM c l ==> MEM c (MAP FST p))` by metis_tac [MEM,Valid_PileTally] 
           >> metis_tac [logical_to_functional_update_pile]));
    
 
 

val Functional_to_Logical_elect = Q.store_thm ("Functional_to_Logical_elect",
 `! st qu l j1 j2. Elect_dec st qu l (j1,j2) ==> elect st qu l j1 j2`,

 (REPEAT STRIP_TAC
  >> rw[elect] 
    >> Cases_on `j1`) 
   
  >- (Cases_on `j2`
    
     >- ((Cases_on `p` >> Cases_on `r` >> Cases_on `r'` >> Cases_on `r` >> Cases_on `r'` 
      >> Cases_on `p'` >> Cases_on `r'` >> Cases_on `r''` >> Cases_on `r'` >> Cases_on `r''`
       >> rfs[Elect_dec]
        >> MAP_EVERY qexists_tac [`take_append q'''''''' q'''`]
          >> REPEAT STRIP_TAC)
 
          >- metis_tac [non_empty] 
          >- RW_TAC bool_ss [] 
          >- metis_tac [functional_to_logical_BiggerThanQuota] 
          >- rw [] 
          >- metis_tac [eqe_list_dec_MEM1,MEM,no_dup_IMP_NO_DUP_PRED]
          >- metis_tac [eqe_list_dec_MEM1,MEM,no_dup_IMP_NO_DUP_PRED]
          >- metis_tac [eqe_list_dec2_verified,MEM]  
          >- metis_tac [no_dup_IMP_NO_DUP_PRED] 
          >- metis_tac [no_dup_IMP_NO_DUP_PRED] 
          >- metis_tac [no_dup_IMP_NO_DUP_PRED] 
          >- metis_tac [no_dup_IMP_NO_DUP_PRED]
          >- metis_tac [eqe_list_dec_MEM1,MEM,no_dup_IMP_NO_DUP_PRED]
          >- metis_tac [eqe_list_dec_MEM1,MEM,no_dup_IMP_NO_DUP_PRED]
          >-  metis_tac [eqe_list_dec2_verified]
          >- (`!c. MEM c r ==> MEM c l` by metis_tac [Logical_list_MEM_VICE_VERCA_TheFunctional]
            >> `!c. MEM c r ==> MEM c (MAP FST q'')` 
                by metis_tac [Valid_PileTally,PileTally_DEC1_to_PileTally,PileTally_DEC2_IMP_PileTally,MEM] 
              >> `!c. MEM c r ==> MEM c (MAP FST q''''''')` 
                   by metis_tac [Valid_PileTally,PileTally_DEC1_to_PileTally,PileTally_DEC2_IMP_PileTally,
                    MEM,Logical_list_MEM_VICE_VERCA_TheFunctional]
                >> metis_tac[Logical_list_MEM_VICE_VERCA_TheFunctional,functional_to_logicl_piles_eq
                    ,no_dup_IMP_NO_DUP_PRED])  
          >- metis_tac [no_dup_IMP_NO_DUP_PRED]
          >- metis_tac [no_dup_IMP_NO_DUP_PRED]
          >- metis_tac [no_dup_IMP_NO_DUP_PRED]
          >- metis_tac [functional_to_logical_update_pile,no_dup_IMP_NO_DUP_PRED]
          >-  metis_tac [functional_to_logical_update_pile,no_dup_IMP_NO_DUP_PRED]
          >- metis_tac [no_dup_IMP_NO_DUP_PRED,non_empty,Valid_Init_CandList]
          >- metis_tac [Valid_PileTally,PileTally_DEC1_to_PileTally,PileTally_DEC2_IMP_PileTally]
          >-  metis_tac [Valid_PileTally,PileTally_DEC1_to_PileTally,PileTally_DEC2_IMP_PileTally]
          >- metis_tac [Valid_PileTally,PileTally_DEC1_to_PileTally,PileTally_DEC2_IMP_PileTally]
          >- metis_tac [Logical_list_MEM_VICE_VERCA_TheFunctional]
          >- metis_tac [Logical_list_MEM_VICE_VERCA_TheFunctional]
          >- RW_TAC bool_ss [])

     >- rfs [Elect_dec])

  >- (Cases_on `j2` 
  
   >- rfs [Elect_dec]
   >- rfs [Elect_dec]));
 
     
val all_elem_zero = Define `
            (all_elem_zero ([]: rat list) = T)
         /\ (all_elem_zero (t0::ts) = (t0 = rat_0) /\ (all_elem_zero ts))`;
  
 
val all_elem_nil = Define `
            (all_elem_nil ([]: (((Cand list) # rat) list) list) = T)
         /\ (all_elem_nil (p0::ps) = (p0 = []) /\ (all_elem_nil ps))`;
  


 
val All_elem_zero_verified = Q.store_thm ("All_elem_zero_verified",
 `! t. (!c. MEM c t ==> (c = rat_0)) <=> all_elem_zero t`,

  Induct_on `t`
     >- rw[all_elem_zero]
     >- (REPEAT STRIP_TAC 
       >> metis_tac [all_elem_zero,MEM])); 


val All_elem_nil_verified = Q.store_thm ("All_elem_nil_verified",
 `! p. (!c. MEM c p ==> (c = [])) <=> all_elem_nil p`,

  Induct_on `p`
   >- rw[all_elem_nil]
   >- (REPEAT STRIP_TAC
     >> metis_tac [MEM,all_elem_nil]));
  
 
  
val Initial_Judgement_dec = Define `
        (Initial_Judgement_dec (l: Cand list) (winners w) = F)
     /\ (Initial_Judgement_dec l (state (ba, t, p, bl, e, h)) = 
                                (all_elem_zero (MAP SND t))
                             /\ (bl = [])
                             /\ (e = [])
                             /\ (h = l)
                             /\ (all_elem_nil (MAP SND p)))`;
  
  
val initial_judgement = Define `
          (initial_judgement (l: Cand list) j = ? ba t p bl e h.
                                               (j = state (ba, t, p, bl, e, h))
                                            /\ (!c. MEM c (MAP SND t) ==> (c = rat_0))
                                                /\ (!c. MEM c (MAP SND p) ==> (c = []))
                                                /\ (bl = [])
                                                /\ (e = [])
                                                /\ (h = l))`;


val Initial_Judgement_IMP_TheLogical = Q.store_thm ("Initial_Judgement_IMP_TheLogical",
 `! l j. Initial_Judgement_dec l j ==> initial_judgement l j`,

  (REPEAT STRIP_TAC >> rw[initial_judgement] 
    >> Cases_on `j`) 

     >- (Cases_on `p` >> Cases_on `r` >> Cases_on `r'` >> Cases_on `r` >> Cases_on `r'`
      >> rfs [Initial_Judgement_dec]
        >> metis_tac [All_elem_zero_verified,All_elem_nil_verified])
     >- rfs[Initial_Judgement_dec]);
  

val Logical_to_Functional_Initial_Judgement = Q.store_thm ("Logical_to_Functional_Initial_Judgement",
 `! l j. initial_judgement l j ==> Initial_Judgement_dec l j`,

  (REPEAT STRIP_TAC
    >> rfs [initial_judgement]  
      >> rw[Initial_Judgement_dec])  
         >- metis_tac [All_elem_zero_verified] 
         >- metis_tac [All_elem_nil_verified]);


 
val Final_Judgement_dec = Define `
           (Final_Judgement_dec (state (ba,t,p,bl,e,h)) = F)
        /\ (Final_Judgement_dec (winners l) = T)`;
 


val Elim_dec = Define `
         (Elim_dec st qu l (j1,j2) c = Elim_cand_dec st qu l c (j1,j2))`;  

 
   
val Checker_Aux_dec = Define `
          (Checker_Aux_dec st qu l ([] : judgement list) = F)
       /\ (Checker_Aux_dec st qu l (j0::js) = 
              if (empty_list js) 
                          then  (Final_Judgement_dec j0)
              else if (empty_list (TL js))
                        then (Hwin qu st (j0,HD js) \/ Ewin qu st (j0,HD js))
                   else  ((Count_Aux_dec st qu l (j0,HD js))
                      \/ (Transfer_dec st qu l (j0,HD js))
                      \/ (Elect_dec st qu l (j0,HD js))
                      \/ (EXISTS (Elim_dec st qu l (j0,HD js)) l)) 
                      /\ (Checker_Aux_dec st qu l js))`;                
  
   
val final_judgement = Define `
              (final_judgement j = (! ba t p bl e h. (j <> state (ba,t,p,bl,e,h))) 
                                /\ (? (w : Cand list). (j = winners w)))`;

     
 
 
val Checker_Aux2_dec = Define `
             (Checker_Aux2_dec st qu l ([]:judgement list) = F)
          /\ (Checker_Aux2_dec st qu l [j0] = Final_Judgement_dec j0)
          /\ (Checker_Aux2_dec st qu l (j0::j1::js) = 
               ((Hwin qu st (j0,j1) 
            \/ (Ewin qu st (j0,j1))
            \/ (Count_Aux_dec st qu l (j0,j1))
            \/ (Transfer_dec st qu l (j0,j1))
            \/ (Elect_dec st qu l (j0,j1))
            \/ (EXISTS (Elim_dec st qu l (j0,j1)) l)) 
            /\ (Checker_Aux2_dec st qu l (j1::js))))`;  
 

 
 




val checker_aux2_def =  Define `
           (checker_aux2 st qu l J = (J <> [] )
                                  /\ (final_judgement (LAST J)) 
                                  /\ (! J0 J1 j0 j1. (J = J0 ++ [j0;j1]++ J1) ==>
                                      ((hwin qu st j0 j1)
                                   \/ (ewin qu st j0 j1) 
                                   \/ (Count_Aux st qu l j0 j1)
                                   \/ (transfer st qu l j0 j1)
                                   \/ (elect st qu l j0 j1)
                                   \/ (? (c: Cand). MEM c l /\ elim_cand st qu l c j0 j1))))`; 
   



val Logical_to_computational_checker= Q.store_thm("Logical_to_computatonal_checker",
 `! st qu l J. checker_aux2 st qu l J ==> Checker_Aux2_dec st qu l J`, 
     
  Induct_on `J`
    >- rw [checker_aux2_def]
    >- ((REPEAT STRIP_TAC >>
        `(J = []) \/ (J <> [])` by metis_tac [list_nchotomy])
           >- (rfs[Checker_Aux2_dec,checker_aux2_def]
            >> FULL_SIMP_TAC list_ss [LAST_DEF]     
             >> metis_tac [final_judgement,Final_Judgement_dec])
           >- ((`? j' J'. (J = j'::J')` by metis_tac[list_nchotomy] 
                 >> RW_TAC bool_ss [] 
                  >> rw[Checker_Aux2_dec]) 
            >- ((rfs[checker_aux2_def]  
             >> first_assum (qspecl_then [`[]`,`J'`,`h`,`j'`] strip_assume_tac) 
              >> `h::j'::J' = [] ++ [h;j'] ++ J'` by EVAL_TAC 
               >> `  (hwin qu st h j')
                 \/ (ewin qu st h j')
                 \/ (Count_Aux st qu l h j')
                 \/ (transfer st qu l h j')
                 \/ (elect st qu l h j')
                 \/ (? c. MEM c l /\ elim_cand st qu l c h j')` by metis_tac [])   
                   >- metis_tac [hwin_to_Hwin]   
                   >- metis_tac [ewin_to_Ewin_thm]      
                   >- metis_tac [Count_Aux_IMP_Count_Aux_dec]   
                   >- metis_tac [Logical_transfer_to_Functional_Transfer]   
                   >- metis_tac [Logical_to_Functional_elect]     
                   >- (ASSUME_TAC (INST_TYPE [alpha |-> ``:Cand``] MEM_SPLIT) 
                     >> first_x_assum (qspecl_then [`c`,`l`] strip_assume_tac) 
                       >> `? l1 l2. l = l1 ++ c:: l2` by metis_tac [] 
                        >> RW_TAC bool_ss [Elim_dec] >> REPEAT DISJ2_TAC 
                          >> rw [EXISTS_DEF] 
                           >> DISJ2_TAC >> DISJ1_TAC 
                            >> metis_tac [Elim_dec,Logical_elim_to_Functional_Elim]))
                  
  
             >- (rfs[checker_aux2_def] 
              >> first_assum (qspecl_then [`st`,`qu`,`l`] strip_assume_tac) 
               >> `! J0 J1 j0 j1. (j'::J' = J0 ++ [j0;j1] ++ J1) ==>  (hwin qu st j0 j1)
                                                     \/ (ewin qu st j0 j1)
                                                     \/ (Count_Aux st qu l j0 j1)
                                                     \/ (transfer st qu l j0 j1)
                                                     \/ (elect st qu l j0 j1)
                                                     \/ (? c. MEM c l /\ elim_cand st qu l c j0 j1)`
                  by  (REPEAT STRIP_TAC 
                  >> first_assum (qspecl_then [`h::J0`,`J1`,`j0`,`j1`] strip_assume_tac) 
                   >> `h::j'::J' = h::J0 ++ [j0;j1] ++J1` by FULL_SIMP_TAC list_ss[] 
                     >> metis_tac [])   
                       >> metis_tac []))));     
                         













 






                                                            
   
















 

















val Checker_dec = Define `
        (Checker_dec st qu l (J : judgement list) =
           (Initial_Judgement_dec l (HD J)) /\ (Checker_aux_dec st qu l J))`;                                     













val elim_cand2 = Define `
          (elim_cand2 st qu l c (j: judgement, winners w) = F) /\
          (elim_cand2 st qu l c (winners w, j: judgement) = F) /\
          (elim_cand2 st qu l c (state (ba,t,p,bl,e,h), state (nba,nt,np,nbl,ne,nh)) =
                 Valid_Init_CandList l
              /\ (t = nt) /\ (e = ne)
              /\ (!c'. MEM c' (h++e) ==> (MEM c' l))
              /\ (!c'. NO_DUP_PRED (h++e) c')
              /\ (Valid_PileTally p l)   
              /\ (Valid_PileTally np l)
              /\ (LENGTH (e ++ h) > st) 
              /\ (LENGTH e < st)
              /\ (!c'. NO_DUP_PRED (MAP FST t) c')
              /\ (Valid_PileTally t l)
              /\ (!c'. (MEM c' h ==> (?x. MEM (c',x) t /\ ( x < qu))))  
              /\ (MEM c h) 
              /\ (!d. (MEM d h ==> (?x y. (MEM (c,x) t) /\ (MEM (d,y) t) /\ ( x <= y))))
              /\ (eqe c nh h)
              /\ (nba = get_cand_pile c p)
              /\ (MEM (c,[]) np)
              /\ (!d'. ((d' <> c) ==> (!l. (MEM (d',l) p ==> MEM (d',l) np) 
                              /\ (MEM (d',l) np ==> MEM (d',l) p)))))`;



 

val _ = export_theory();



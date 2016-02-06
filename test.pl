/*  Part of SWI-Prolog

    Author:        Jan Wielemaker
    E-mail:        J.Wielemaker@vu.nl
    WWW:           http://www.swi-prolog.org
    Copyright (c)  2000-2014, University of Amsterdam
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:

    1. Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in
       the documentation and/or other materials provided with the
       distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/

:- use_module(jasmine).

:- dynamic
	jasmine/1.

open :-
	odb_ses_start(H, 'einstein::jasmine/jasmine', _, _, _),
	asserta(jasmine(H)),
	exec('Transaction.start();').	% ensure a transaction

close :-
	retract(jasmine(H)), !,
	odb_ses_end(H).

exec(Cmd) :-
	jasmine(H),
	odb_exec_odql(H, Cmd).

get_var(Name, Value) :-
	ensure_transaction,
	jasmine(H),
	odb_get_var(H, Name, Value).

set_var(Name, Value) :-
	ensure_transaction,
	jasmine(H),
	odb_set_var(H, Name, Value).

ensure_transaction :-
	exec('if (Transaction.isWithinTransaction() != TRUE) { Transaction.start(); };').

		 /*******************************
		 *     CLASSES AND FAMILIES	*
		 *******************************/

%	Get all Jasmine class families

families(List) :-
	jasmine(SH),
	ensure_transaction,
	odql(SH,
	     [ ss:'Bag<String>',
	       pcount:'Integer'
	     ],
	     [ 'ss = FamilyManager.getAllFamilies();',
	       'pcount = ss.count();',
	       get(pcount, C),
	       { format('Found ~w families~n', [C])
	       },
	       get_list(ss, List)
	     ]).

family_classes(Family, Classes) :-
	jasmine(SH),
	ensure_transaction,
	odql(SH,
	     [ cBag:'Bag<Composite class>',
	       cc:'Composite class',
	       cname:'String'
	     ],
	     [ 'defaultCF ~w;'-[Family],
	       'cBag = FamilyManager.getAllClasses("~w");'-[Family],
	       { odb_collection_to_list(SH, cBag, ClassObjects),
		 maplist(object_name(SH), ClassObjects, Classes)
	       }
	     ]).

object_name(SH, Class, Name) :-
	odql(SH, [],
	     [ set(cc, Class),
	       'cname = cc.getClassName();',
	       get(cname, Name)
	     ]).

class_properties(Class, Properties) :-
	jasmine(SH),
	odql(SH,
	     [ 'PhysBagTup':'Bag<T1[Integer propType,
				    String name,
				    String CFName,
				    String className,
				    Boolean isClass,
				    Boolean isSet,
				    String propDescription,
				    Integer precision,
				    Integer scale,
				    Boolean isMandatory,
				    Boolean isUnique]>'
	     ],
	     [ 'PhysBagTup = (T1)~w.getPropInfo(TRUE);'-[Class],
	       get_list('PhysBagTup', Properties)
	     ]).

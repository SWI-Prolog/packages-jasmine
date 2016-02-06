/*  Part of SWI-Prolog

    Author:        Jan Wielemaker
    E-mail:        J.Wielemaker@vu.nl
    WWW:           http://www.swi-prolog.org
    Copyright (c)  2000-2011, University of Amsterdam
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

lib(jasmine).
dll(jasmine).

install :-
	install_library,
	install_dlls.

install_library :-
	forall(lib(Base), install_lib(Base)),
	lib_dest(Dest),
	make_library_index(Dest).

install_lib(Base) :-
	lib_dest(Lib),
	absolute_file_name(Base,
			   [ extensions([pl]),
			     access(read)
			   ],
			   Src),
	progress(cp(Src, Lib)).

lib_dest(Lib) :-
	current_prolog_flag(home, PlHome),
	atomic_list_concat([PlHome, library], /, Lib).

install_dlls :-
	forall(dll(Base), install_dll(Base)).

install_dll(Base) :-
	dll_dest(Dir),
	absolute_file_name(Base,
			   [ extensions([dll]),
			     access(read)
			   ],
			   Src),
	progress(cpbin(Src, Dir)).

dll_dest(Dir) :-
	current_prolog_flag(home, PlHome),
	atomic_list_concat([PlHome, bin], /, Dir).


%	cp(From, To)
%
%	Copy a file to a destination (file or directory).

cp(Src, Dest) :-
	cp(Src, Dest, [type(text)]).

cpbin(Src, Dest) :-
	cp(Src, Dest, [type(binary)]).

cp(Src, Dir, Options) :-
	exists_directory(Dir), !,
	file_base_name(Src, Base),
	atomic_list_concat([Dir, Base], /, Dest),
	cp(Src, Dest, Options).
cp(Src, Dest, Options) :-
	open(Src, read, In, Options),
	open(Dest, write, Out, Options),
	copy_stream_data(In, Out),
	close(Out),
	close(In).

progress(Goal) :-
	format('~p ... ', [Goal]),
	flush_output,
	(   catch(Goal, E, (print_message(error, E), fail))
	->  format('ok~n', [])
	;   format('FAILED~n', [])
	).

		 /*******************************
		 *	     ACTIVATE		*
		 *******************************/

:- (   install
   ->  format('~N~nInstallation complete~n~n', [])
   ;   format('~N~nINSTALLATION FAILED~n~n', [])
   ),
   format('Press any key to continue ...', []), flush_output,
   get_single_char(_),
   nl,
   halt.

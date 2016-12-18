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

:- module(jasmine,
          [ odb_ses_start/5,            % -SH, +DB, +User, +Passwd, +EnvFile
            odb_ses_end/1,              % +SH
            odb_exec_odql/2,            % +SH, +Command
            odb_get_var/3,              % +SH, +Var, -Value
            odb_set_var/3,              % +SH, +Var, +Value
            odb_collection_to_list/3,   % +SH, +VarOrOID, -List

            odb_exec_odql/3,            % +SH, +Format, +Args
            odql/3                      % :SH, +Vars, +Statements
          ]).
:- use_module(library(quintus)).        % meta_predicate/1

:- meta_predicate
    odql(:, +, +).

:- load_foreign_library(foreign(jasmine)).

%       odb_exec_odql(+SH, +Format, +Args)
%
%       Provide formatted ODQL commands.

odb_exec_odql(SH, Fmt, Args) :-
    sformat(Command, Fmt, Args),
    odb_exec_odql(SH, Command).

%       odql(+SH, +[Var:Type, ...], +[Cmd, ...])

odql(SH, Vars, Lines) :-
    strip_module(SH, Module, H),
    odb_declare_vars(Vars, H),
    statements(Lines, H, Module).

statements([], _, _).
statements([H|T], SH, Module) :-
    statement(H, SH, Module),
    statements(T, SH, Module).

statement(Fmt-Args, SH, _) :-
    !,
    odb_exec_odql(SH, Fmt, Args).
statement({Command}, _SH, Module) :-
    !,
    Module:Command.
statement(get(Var, Value), SH, _) :-
    !,
    odb_get_var(SH, Var, Value).
statement(set(Var, Value), SH, _) :-
    !,
    odb_set_var(SH, Var, Value).
statement(get_list(Colection, List), SH, _) :-
    !,
    odb_collection_to_list(SH, Colection, List).
statement(Cmd, SH, Module) :-
    odb_exec_odql(SH, Cmd, Module).

odb_declare_vars([], _).
odb_declare_vars([H|T], SH) :-
    odb_declare_var(H, SH),
    odb_declare_vars(T, SH).

odb_declare_var(Name:Type, SH) :-
    catch(odb_exec_odql(SH, 'undefVar ~w;', [Name]), _, true),
    odb_exec_odql(SH, '~w ~w;', [Type, Name]).


                 /*******************************
                 *           MESSAGES           *
                 *******************************/

:- multifile prolog:message/3.

prolog:message(error(package(jasmine, Id), context(Msg, _))) -->
    [ 'Jasmine [ID=~d]: ~w'-[Id, Msg] ].

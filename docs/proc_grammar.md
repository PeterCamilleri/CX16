# The _proc_ Language Grammar --DRAFT--

This document contains the extended Backus–Naur form (BNF) grammar for the
_proc_ programming language. The goals of this language are to be an easy to
understand, easy to compile, simplified language loosely based on Pascal,
but incorporating some of the linguistic memes that have arisen in the last
40 years. At the same time, some Pascal features that have not stood the test
of time are removed.

## Notation guide:

The grammar of *proc* is described using a notation loosely base on BNF. It
is summarized in the following table:

Entry        | Description
-------------|--------------
a &rarr; xyz | Entity _a_ maps onto expression xyz
a            | An intermediate entity.
"text"       | Literal text. Note \\" is a " in the text, \\\\ is a \\.
'text'       | Alternate form string literal text. Note no escapes here.
"a".."z"     | Literal "a" through "z"
a b          | a followed by b.
a\|b         | a or b but not both.
a-b          | the characters of _a_ except those listed in _b_.
(xyz)        | Grouping with parenthesis.
a?           | Zero or One of _a_.
a\*          | Zero or More of _a_.
a\+          | One or More of _a_.
stuff        | A marker for arbitrary text.
eol          | A special mark for end of line.
-- comment   | A comment. Typically a description of a context sensitive aspect.

Note: No operator priority is specified. When needed, parenthesis are used to
disambiguate the meaning of grammar statements.

## Grammar

The design for _proc_ strives to conform to the rules of a simple grammar.
That is, every rule can be "drilled down" to start with a literal text.
This allows the parser to determine the branch of the syntax tree by
examining the input as it is scanned in from the source file without
"look-ahead" beyond the current token. In compiler parlance, we want the
grammar to be LL(1). Whether we can get one is another story. The goal
is to keep exceptions contained and to a minimum.

### Parser level specifications

This is the top level language parser. It is at this level that the connection
between source parsing and code generation is made. Note that "predefined"
refers to an entity the is part of the _proc_ language specification.

<pre><code>program     &rarr; "program" identifier ";" (consts | types | vars | proc)* block "."

consts      &rarr; "const" (identifier (":" type)? "=" constant ";")*

types       &rarr; "type" (identifier ":" type ";")*
type        &rarr; "&uarr;"? (identifier | array_type | record_type)
            -- identifier must be a type either predefined or previously defined in the code.
array_type  &rarr; "array" "[" constant ("," constant)* "]" "of" type
            -- constant must be a number greater than zero.
            -- the array must not exceed the implementation dependent size limit.
record_type &rarr; "record" (identifiers ":" type)* "end"

vars        &rarr; "var" (identifiers (":" type)? ("&larr;" constant)? ";")*

proc        &rarr; "proc" identifier arg_specs? (":" type}? (("forward" | (vars? block)) ";"
arg_specs   &rarr; "(" (arg_spec (";" arg_spec)*)?  ")"
arg_spec    &rarr; identifiers ":" "ref"? type

block       &rarr; "begin" statement* "end"

statement   &rarr; assignment | select | for | if | call | repeat | return | while | empty

assignment  &rarr; variable "&larr;" expression ";"
            -- variable and expression must be type compatible.

select      &rarr; "select" expression ("case" constants ":" statement*)* ("default" ":" statement*)? "endselect"
            -- expression and constants must be of compatible types.

for         &rarr; "for" variable "&larr;" expression ("to"|"downto") expression "do" statement* "endfor"
            -- variable and expressions must all be type compatible.

if          &rarr; "if" expression "then" statement* ("else" statement*) "endif"
            -- expression must have a boolean value.

call        &rarr; identifier ("(" expressions ")")? ";"
            -- identifier must be a proc either predefined or previously defined in the code.
            -- expressions must be compatible with the arguments of the proc.

repeat      &rarr; "repeat" statement* "until" expression ";"
            -- expression must have a boolean value.

return      &rarr; "return" expression? ";"
            -- expression must be compatible with the return type of the proc.

while       &rarr; "while" expression "do" statement* "endwhile"
            -- expression must have a boolean value.

empty       &rarr; ";"

constants   &rarr; constant ("," constant)*
constant    &rarr; ("+" | "-")? cterm (("+" | "-" | "or") cterm)*
cterm       &rarr; cfactor (("*" | "/" | "%" | "and") cfactor)*
cfactor     &rarr; number | string | c_ident | ("(" constant ")") | ("not" cfactor)
            -- c_ident must be a constant either predefined or previously defined in the code.
            -- data types and operators must be compatible.

expressions &rarr; expression ("," expression)*
expression  &rarr; phrase (relop phrase)?
phrase      &rarr; ("+" | "-")? term (("+" | "-" | "or") term)*
term        &rarr; factor (("*" | "/" | "%" | "and") factor)*
factor      &rarr; number | string | variable | c_ident | (p_ident ("(" expressions ")")?) | ("(" expression ")") | ("not" factor)
            -- c_ident must be a constant either predefined or previously defined in the code.
            -- p_ident must be a proc either predefined or previously defined in the code.
            -- arguments to p_ident must match its declaration.
variable    &rarr; identifier (("[" expressions "]") | ("." identifier) | ("&uarr;"))*
            -- data types and operators must be compatible.

c_ident     &rarr; identifier
p_ident     &rarr; identifier

identifiers &rarr; identifier ("," identifier)*
</code></pre>

### Lexical level specifications

These constructs are recognized by the lexical analyser. All parser literal
values are actually detected at this level.

<pre><code>identifier  &rarr; letter alpha*

number      &rarr; ("$" hex_digit+)|(digit+ ("U"|"u")?)
            -- hex numbers must be in the range $0..$FFFF.
            -- decimal numbers must be in the range 0..65535.

string      &rarr; '"' (((" ".."~")-('"'|'\')) | '\"' | '\\')* '"'

rel_op      &rarr; "=" | "<>" | "<" | "<=" | ">" | ">="
</code></pre>

### Character level specifications.

These specifications are done with a character identification routine that
classifies characters bt their type.

<pre><code>alpha       &rarr; letter | digit | "_"
letter      &rarr; "a".."z"
hex_digit   &rarr; "A".."F" | "a".."f" | digit
digit       &rarr; "0".."9"
</code></pre>

## Non-Grammar Elements

Some elements of *proc* are only lexical in scope. Comments are converted into
a single space for the purpose of parsing. Two styles of comment are
supported: the Pascal style contained inside { ... } and the Ruby style
with a # ... to the eol comment.

<pre><code>
comment    &rarr; ("{" {stuff | eol | comment)* "}")
           | ("#" stuff* eol)
</code></pre>

Further, eol itself is treated as a space when it occurs outside of a comment.

It's hard to show here, but one context sensitive aspect of *proc* is that
comments are not processed inside string literals. That is, string literals
take precedence over comments. So, this is a comment:

```
{Hello World}
```

While this is a string with the text {Hello World}:

```
"{Hello World}"
```

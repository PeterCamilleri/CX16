# The Proc Language Grammar

This document contains the extended BNF grammar for the _proc_ programming
language. The goals of this language are to be an easy to understand,
easy to compile, simplified language loosely based on Pascal, but
incorporating some of the linguistic memes that have arisen in the last
40 years.

## Notation guide:

The grammar of *proc* is described using a notation loosely base on BNF. It
is summarized in the following table:

Entry        | Description
-------------|--------------
a &rarr; x   | Entity a maps onto entity x
a            | An intermediate, non-terminal decomposition.
"text"       | Literal text. Note \\" is a " in the text, \\\\ is a \\.
"a".."z"     | Literal "a" through "z"
a b          | a followed by b.
a\|b         | a or b but not both.
(a\|b)       | Grouping with parenthesis.
a?           | Zero or One of a.
a\*          | Zero or More of a.
a\+          | One or More of a.
stuff        | A marker for arbitrary text.
eol          | A special mark for end of line.
-- context   | A description of a context sensitive aspect.

No operator priority is specified. When needed, parenthesis are used to
disambiguate the meaning of grammar statements.

## Grammar

The design for _proc_ strives to conform to the rules of a simple grammar.
That is, every rule can be "drilled down" to start with a literal text.
This allows the parser to determine the branch of the syntax tree by
examining the input as it is scanned in from the source file without
"look-ahead". In compiler parlance, we want the grammar to be LL(0).
Whether we can get one is another story. The goal is to keep exceptions
contained and to a minimum.

<pre><code>module      &rarr; ("program" | "module") identifier body "."

body        &rarr; section* block

section     &rarr; consts | types | vars | proc

consts      &rarr; "const" (identifier (":" type)? "=" expression ";")*

types       &rarr; "type" (identifier ":" type ";")*
type        &rarr; "^"? (simple_type | array_type | record_type)
simple_type &rarr; "int" | "word" | "byte" | "char" | "string" | "boolean" | identifier
            -- identifier must be a type previously defined in the code.
array_type  &rarr; "array" "[" number "]" "of" type
            -- number must be greater than zero.
record_type &rarr; "record" (identifiers ":" type)* "end"

vars        &rarr; "var" (&rarr; identifiers (":" type)? ("=" expression)? ";")*

proc        &rarr; "proc" identifier arg_specs? (":" type}? ("forward" ";") | body
arg_specs   &rarr; "(" arg_spec (";" arg_spec)*  ")"
arg_spec    &rarr; identifiers ":" "ref"? type

block       &rarr; "begin" statement* "end"

identifiers &rarr; identifier ("," identifier)*
identifier  &rarr; letter alpha*
number      &rarr; digit+
alpha       &rarr; letter | digit | "_"
letter      &rarr; "a".."z"
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

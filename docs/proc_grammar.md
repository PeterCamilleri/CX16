# The Proc Language Grammar

This document contains the extended BNF grammar for the _proc_ programming
language. The goals of this language are to be an easy to understand,
easy to compile, simplified language loosely based on Pascal, but
incorporating some of the linguistic memes that have arisen in the last
40 years.

## Notation guide:

Entry        | Description
-------------|--------------
a &rarr; x   | Entity a maps onto entity x
a            | An intermediate, non-terminal decomposition.
"text"       | Literal text. Note \\" is a " in the text, \\\\ is a \\.
"a".."z"     | Literal "a" through "z"
a b          | a followed by b.
a\|b         | a or b but not both.
(a\|b)       | Grouping with parenthesis.
{a}          | Zero or One a.
{a}\*        | Zero or More a.
{a}\+        | One or More a.

When needed, parenthesis are used to disambiguate the meaning of grammar
statements.

## Grammar

The design for _proc_ strives to conform to the rules of a simple grammar.
That is, every rule can be "drilled down" to start with a literal text.
This allows the parser to determine the branch of the syntax tree by
examining the input with only one level of "look-ahead".

<pre><code>module &rarr; ("program" | "module") identifier block "."

alpha  &rarr; letter | digit | "_"
letter &rarr; "a".."z"
digit  &rarr; "0".."9"
</code></pre>


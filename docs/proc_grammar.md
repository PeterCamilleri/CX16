# The Proc Language Grammar

This document contains the extended BNF grammar for the _proc_ programming
language. The goals of this language are to be an easy to understand,
easy to compile, simplified language loosely based on Pascal, but
incorporating some of the linguistic memes that have arisen in the last
40 years.

## Notation guide:

Entry        | Description
-------------|--------------
a            | An intermediate, non-terminal decomposition.
"text"       | Literal text. Note \\" is a " in the text.
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

<pre><code>module &rarr; ("program" | "module") identifier block "."

alpha  &rarr; letter | digit | "_"
letter &rarr; "a".."z"
digit  &rarr; "0".."9"
</code></pre>


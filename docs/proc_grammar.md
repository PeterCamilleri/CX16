# The Proc Language Grammar

This document contains the extended BNF grammar for the proc programming
language. The goals of this language are to be easy to be an easy to compile,
simplified language loosely based on Pascal, but incorporating some of the
linguistic memes that have arisen in the last 40 years.

## Notation guide:

Entry        | Description
-------------|--------------
a            | An intermediate, non-terminal decomposition.
"text"       | Literal text.
a b          | a followed by b.
a|b          | a or b but not both.
(a|b)        | Grouping with parenthesis.
{a}          | Zero or One a.
{a}\*        | Zero or More a.
{a}\+        | One or More a.

When needed, parenthesis are used to disambiguate the meaning of grammar
statements.

## Grammar

<pre><code>module &rarr; ("program" | "module") identifier block "."
</code></pre>


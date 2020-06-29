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
{a}          | Zero or One a.
{a}\*        | Zero or More a.
{a}\+        | One or More a.
stuff        | A marker for arbitrary text.
eol          | A special mark for end of line.

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

<pre><code>module     &rarr; ("program" | "module") identifier {section}* block "."

identifier &rarr; letter {alpha}*
alpha      &rarr; letter | digit | "_"
letter     &rarr; "a".."z"
digit      &rarr; "0".."9"
</code></pre>

## Non-Grammar Elements

Some elements of *proc* are only lexical in scope. Comments are converted into
a single space for the purpose of parsing.

<pre><code>
comment    &rarr; ("{" {stuff | eol | comment}* "}")
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

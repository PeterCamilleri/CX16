# The Proc Language Grammar

This document contains the extended BNF grammar for the proc programming
language. The goals of this language are to be easy to be an easy to compile,
simplified language loosely based on Pascal, but incorporating some of the
linguistic memes that have arisen in the last 40 years.

## Notation guide:

Entry            | Description
-----------------|--------------
\<non-terminal\> | An incomplete decomposition.
"text"           | Literal text.
\<A\> \<B\>      | A followed by B.
\<A\>|\<B\>      | A or B but not both.
(\<A\>|\<B\>)    | Grouping with parenthesis.
{\<A\>}          | Zero or One A.
{\<A\>}\*        | Zero or More A.
{\<A\>}\+        | One or More A.

When needed, parenthesis are used to disambiguate the meaning of grammar
statements.

## Grammar

<pre><code>&#60;module&#62; &rarr; ("program" | "module") &#60;block&#62;
</code></pre>


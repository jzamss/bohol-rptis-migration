<!-- Headers Basic -->
# Header 1
## Header 2
### Header 3
#### Header 4
##### Header 5
###### Header 6

<!-- Headers alternative -->
Header 1
========

Header 2
--------

Note:
* At least three = or - is required for alt-header

EMPHASIS
========

*This is itlaic*
_This is itlaic_

**This is bold**
__This is bold__

_Combination of Italic and **Bold** text_

~~Scratch this~~


LIST
====

1. First order list item
	1. x
		1. aa
		2. bb
    2. b
2. Another item
   * unordered sub-list.
1. Actual numbers don’t matter, just that is a  number
   * Order sub-list

    this is an indented paragraph	
    this is an indented paragraph	
4. Add another item.


* animals
   * dog
   * cat

- items
	+ computer
	+ chair


LINKS
=====

[Inline-style](https://www.filipizen.com)

[Reference-style][Arbitrary case-insensitive reference text]

[Numbers for reference-style link definitions][1]

Or leave it empty and use the [link text itself].

[Introduction][intro]


[arbitrary case-insensitive reference text]: https://www.filipizen.com
[1]: https://www.filipizen.com
[link text itself]: https://www.filipizen.com
[intro]: intro.md


URLS
====

* automatically get turned into links.

https://www.filipizen.com



IMAGES
======

Inline-style:
![alt text](https://www.filipizen.com/res/logo-filipizen-topnav.svg "Filipizen Logo")

Reference-style:
![alt text][logo]

[logo]: https://www.filipizen.com/res/logo-filipizen-topnav.svg "Filipizen Logo"



CODE HIGHLIGHTING
=================

* backtick (`) - used for inline code
* 3 backtics (```) - used to fence code blocks

Inline code:

This `code` has `back-ticks` around it.


Fenced code blocks:

```javascript
var s = "JavaScript syntax highlighting";
alert(s);
```

```python
s = "Python syntax highlighting"
print s
```

```
No language indicated, so no syntax highlighting.
But let's throw in a <b>tag</b>
```


TABLES
======

|Tables           |Are              |Cool       |
|-----------------|:---------------:|----------:|
|col 3 is         | right-aligned   | P1000     |
|col 2 is         | centered        | P12       |
|zebra stripes    | are neat        | P1        |


NOTE:
* There must be at least 3 dashes separating each header cell
* Outer pipes are optional
* No need to make the raw Markdown line up 



BLOCKQUOTES
===========

> Blockquotes are very handy in email
> to emulate reply text

Quote break.

> This is a very long line that will still 
be quoted properly when it wraps. Oh boy let's 
keep writing to make sure this is long enough to 
actually wrap for everyone. Oh, you can *put* **Markdown** 
into a blockquote. 


INLINE HTML
===========

Raw HTML can be used with Markdown.


<dl>
  <dt>Definition list</dt>
  <dd>Is something people use sometimes.</dd>

  <dt>Markdown in HTML</dt>
  <dd>Does *not* work **very** well. Use HTML <em>tags</em>.</dd>
</dl>



HORIZONTAL RULE
===============

Three or more...

Asterisks
***

Underscores
___



LINE BREAKS
===========

* Learn by experiment and discovery
* Hit <enter> once to insert one newline or
  hit <enter> twice to insert two lines 
  then see what happens

〈!DOCTYPE html〉
〈html xmlns=http://www.w3.org/1999/xhtml
  〈!-- https://dev.w3.org/html5/html-polyglot/ --〉
  〈head
    〈meta charset=UTF-8〉
    〈title ch markup〉
    〈link href=styles.css rel=stylesheet type=text/css  〉
  〉
  〈body
    〈h1 Compact HTML Markup〉
    〈p The Compact HTML markup syntax is a representation of XHTML in a less cluttered form that is easier to scan and edit than traditional HTML. The key idea is to write 〈 〈&#9001〉em Hello〈&#9002〉〉 instead of 〈 <em>Hello</em>〉. This avoids the visual clutter of the end tags. The space after the start tag helps too. By using non-ASCII delimiters 〈&#9001〉…〈&#9002〉, there need not be any special rules for escaping commonly used characters. In Compact HTML markup, you write 〈pre 〈&#9001〉pre cout << "Hello";〈&#9002〉〉 instead of 〈pre <pre>cout &lt;&lt; &quot;Hello&quot;;</pre>〉〉
    〈h2 Markup Rules〉
    〈ol
      〈li A tag starts with 〈 〈&#9001〉〉 and ends with a matching 〈 〈&#9002〉〉. That's a U+2329 (LEFT-POINTING ANGLE BRACKET) and a U+232A (RIGHT-POINTING ANGLE BRACKET).〉
      〈li Immediately afterwards is the tag name, such as
        〈pre 〈&#9001〉em Hello〈&#9002〉〉
        for
        〈pre <em>Hello</em>〉〉
      〈li After the tag name may optionally be a period and a class name, such as
        〈pre 〈&#9001〉div.note A note...〈&#9002〉〉
        for
        〈pre <div class='note'>A note...</div>〉
        You can have multiple class names such as
        〈pre div.note.caution〉
        which is converted to
        〈pre <div class='note caution'>〉〉
      〈li If the tag name is omitted and there is a period and a class name immediately after the opening bracket, the tag name is set to 〈 span〉. For example,
        〈pre 〈&#9001〉.hand John Hancock〈&#9002〉〉
        is
        〈pre <span class='hand'>John Hancock</span>〉〉
      〈li After the tag name and any dotted class names, you can have an id prefixed by 〈 #〉:
        〈pre 〈&#9001〉img.margin#hamster ...〈&#9002〉〉
        becomes
        〈pre <img class='margin' id='hamster' .../>〉
        Note that there may be no space before the 〈 #〉.〉
      〈li If the tag name is omitted and there is a space after the opening bracket, then the tag name is set to 〈 code〉. For example, 〈pre 〈&#9001〉 main〈&#9002〉〉 is
        〈pre <code>main</code>〉
        This shortcut cannot be used for code elements with class names, an id, or attributes.〉
      〈li The tag name (and optional class names and id) can be followed by attribute name/value pairs. For example,
        〈pre 〈&#9001〉img src=hamster.jpeg alt='A hamster'〈&#9002〉〉
        or
        〈pre 〈&#9001〉a href=http://horstmann.com My homepage〈&#9002〉〉
        There must be 〈em exactly one space〉 before the attribute name and 〈em no spaces〉 around the 〈 =〉. Use 〈em single quotes〉 for attribute values that are empty or contain spaces. In the unlikely case that the element contents starts with what looks like a name/value pair, precede it by two spaces or a newline. For example,
        〈pre
〈&#9001〉strong  x=1〈&#9002〉〉 or
        〈pre
〈&#9001〉pre
x=1〈&#9002〉〉〉
      〈li If an 〈 a〉 element has an 〈 href〉 value that doesn't start with a 〈 #〉, has no other attribute, and has no text contents, the 〈 href〉 attribute value becomes the contents. For example,
        〈pre
〈&#9001〉a href=http://horstmann.com〈&#9002〉〉becomes
        〈pre
<a href='http://horstmann.com'>http://horstmann.com</a>〉
        However, with a relative URL (starting with something other than 〈 http://〉 or 〈 https://〉), only the filename is used for the content:
        〈pre
〈&#9001〉a href=../files/images.zip〈&#9002〉〉
        becomes
        〈pre
<a href='../files/images.zip'>images.zip</a>〉
      〉
      〈li If an 〈 img〉 element doesn't have an 〈 alt〉 attribute, one is provided with the name of the image file (with directory path and extension removed).〉
      〈li The text content of a 〈 pre〉 element and its descendents may not contain whitespace other than space (U+0020), line feed (U+000A) or carriage return (U+000D). In particular, tab (U+0009) is not allowed.〉
      〈li If the 〈 〈&#9001〉〉 is followed by a 〈 !〉 or 〈 ?〉, everything until the matching 〈 〈&#9002〉〉 is copied verbatim, and surrounded by 〈 < >〉. This lets you include processing instructions, comments, and doctypes. For example, the top of your document can start out as
        〈pre
〈&#9001〉?xml version='1.0' encoding='UTF-8'?〈&#9002〉
〈&#9001〉!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Strict//EN'
  'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'〈&#9002〉〉
      〉
      〈li If the 〈&#9001〉 is followed by a 〈 &〉, then everything up to the matching 〈&#9002〉 is copied verbatim and followed by a 〈 ;〉. This lets you enter entity references. For example,
        〈pre 〈&#9001〉&mdash〈&#9002〉〉
        becomes
        〈pre &mdash;〉
        There are only two (rare) situations where you must use this feature. To include 〈&#9001〉 and 〈&#9002〉, use 〈 〈&#9001〉&#9001〈&#9002〉〉 and 〈 〈&#9001〉&#9002〈&#9002〉〉. To include a single quote in a quoted attribute, use 〈 〈&#9001〉&apos〈&#9002〉〉.
        〈pre
〈&#9001〉a href='http://google.com?q=Alice & Bob〈&#9001〉&apos〈&#9002〉s Restaurant'〈&#9002〉〉
        turns into
        〈pre
<a href='http://google.com?q=Alice &amp; Bob&apos;s Restaurant'>〉
        In all other cases, you need not worry about escaping. For example, in the preceding example, the 〈 &〉 in the 〈 href〉 attribute was correctly converted into 〈 &amp;〉.〉
      〈!-- 〈li If the 〈&#9001〉 is followed by a 〈 `〉 or 〈 $〉, then everything up to the matching 〈&#9002〉 is interpreted as 〈a href=http://asciimath.org/ AsciiMath〉 or LaTeX, and converted to MathML. Use  〈 〈&#9001〉`` ... 〈&#9002〉〉/〈 〈&#9001〉`` ... 〈&#9002〉〉 for display style. If the converter is called with the 〈 -j〉 flag, the contents is instead surrounded by 〈 `...`〉, 〈 $...$〉, or 〈 $$...$$〉 for later processing by 〈a href=https://www.mathjax.org/〉 MathJax.〉 --〉
      〈li The XHTML void elements 〈 area〉, 〈 base〉, 〈 br〉, 〈 col〉, 〈 command〉, 〈 embed〉, 〈 hr〉, 〈 img〉, 〈 input〉, 〈 keygen〉, 〈 link〉, 〈 meta〉, 〈 param〉, 〈 source〉, 〈 track〉, 〈 wbr〉 are self-closing. For example, 〈pre
〈&#9001〉hr〈&#9002〉
〈&#9001〉script src='slidy.js'〈&#9002〉〉 yield 〈pre
<hr/>
<script src='slidy.js'></script>〉〉
      〈li If the converter is called with the 〈 -x〉 flag (which is set in the 〈 ch〉 script when the file extension is 〈 .chx〉), then the special XHTML handling rules about 〈 class〉 attributes, 〈 span〉, 〈 code〉, 〈 a〉, 〈 img〉, and 〈 pre〉 elements, and void elements, do not apply.〉
    〉
    〈h2 Rationale〉
    〈ul
      〈li 〈p 〈a href=http://daringfireball.net/projects/markdown/  Markdown〉 has a noble goal:〉
        〈blockquote The idea is that a Markdown-formatted document should be publishable as-is, as plain text, without looking like it’s been marked up with tags or formatting instructions.〉 But to achieve that goal, there are rules whose details are 〈a href=http://daringfireball.net/projects/markdown/syntax fiendishly complex〉.
        〈p And as soon as the going gets rough, you reach the limitations of Markdown and have to use HTML.〉
      〉
      〈li 〈p What about 〈a href=http://www.methods.co.nz/asciidoc/userguide.html AsciiDoc〉, 〈a href=https://docutils.sourceforge.io/docs/ref/rst/restructuredtext.html reStructuredText〉, 〈a href=http://madoko.org/reference.html Madoko〉, or 〈a href=https://www.pml-lang.dev/index.html PML〉? They are much less limited than Markdown, but all are pretty complex.〉〉
      〈li 〈p So why not just author in HTML? It is too verbose, with its matching start and end tags. And it is a hassle that one has to escape characters that are fairly common in programming (〈 & <〉).〉〉
      〈li 〈p Having 〈 (em Hello)〉 instead of 〈 <em>Hello</em>〉 makes perfect sense to any Lisp programmer, and the 〈a href=https://en.wikipedia.org/wiki/SXML  SXML notation〉 follows this idea to its logical conclusion. It's a fine notation, but not very author-friendly.〉
      〈p Xah Lee has a 〈a href=http://xahlee.info/comp/html6.html  related proposal〉 that makes use of three delimiter pairs:
        〈pre
    〔link 「rel “self” href “http://xahlee.org/emacs/blog.xml”」〕〉
      〉
      〈p Matthew Butterick's 〈a href=https://docs.racket-lang.org/pollen/third-tutorial.html Pollen〉 typesetting system uses this notation:
      〈pre
◊span[#:class "author" #:id "primary" #:living "true"]{Prof. Leonard}
〉〉
        〈p The 〈a href=https://slab-lang.org/tutorial.html Slab〉 markup language uses a YAML-like syntax for block-level elements:〉
        〈pre
h1 A short story
p Alice #{em quickly} jumped over #{a(href="https://en.wikipedia.org/wiki/White_Rabbit") the lazy rabbit} and disappeared under the tree.
ul
  li Item
  li Item
  li Item
〉
      〉
      〈li How do you enter the non-ASCII delimiters 〈&#9001〉...〈&#9002〉 on your keyboard? If you use Emacs, then simply add the following to your 〈 .emacs〉:
        〈pre
(fset 'anglebrackets [?〈&#9001〉 ?〈&#9002〉 left])
(global-set-key [(shift return)] 'anglebrackets)〉 Then typing Shift Return yields a pair of brackets, with the cursor in between. Alternatively, if you use Linux, make a 〈 ~/.XCompose〉 file with this content:
        〈pre
include "%L"
<Multi_key> <bracketleft>        : "〈&#9001〉"   U2329 # LEFT-POINTING ANGLE BRACKET
<Multi_key> <bracketright>       : "〈&#9002〉"   U232A # RIGHT-POINTING ANGLE BRACKET〉 Then you can use Compose [ and Compose ] to enter the brackets. I map my 〈a href=http://en.wikipedia.org/wiki/Compose_key  Compose key〉 to Caps Lock, which makes this quite convenient.
      〉
      〈li 〈p How do you match the brackets? Emacs will match any kind of Unicode brackets, and if your text editor is any good, it will do the same.〉〉
    〉
    〈p So, there you have it. An XML entry format, optimized for XHTML, that removes the tedium of end tags and provides convenient shortcuts for common HTML constructs (classes, ids, spans, code, and character references). An automatic translator converts between this format and XML.〉
    〈h2 Installation〉
    〈p You can download the source of the converter and a handy Emacs mode with syntax coloring from 〈a href=https://github.org/cayhorstmann/ch-mode〉. Installation instructions are in 〈 ch-mode.el〉.〉
    〈p If you just want the converter and not the Emacs mode, then install 〈a href=https://www.scala-sbt.org/ SBT〉 and run〉
    〈pre
sbt assembly
〉
    〈p The run the 〈 ch〉 script.〉
  〉
〉

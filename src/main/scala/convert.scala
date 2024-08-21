/*

TODO: Use https://github.com/mathjax/mathjax-node-cli/ to render AsciiMath, LaTeX. Use --semantics to add original code for recovery

 */

object convert extends App {
  val in = System.in
  val source = scala.io.Source.fromInputStream(in)
  val iter = source.buffered
  var line = 1
  val BEGIN = '〈'
  val END = '〉'

  val voidElements = Set("area", "base", "br", "col", "command", "embed", "hr", "img", "input", "keygen", "link", "meta", "param", "source", "track", "wbr") // http://dev.w3.org/html5/markup/syntax.html

  val elements = Set(
    "a", "abbr", "acronym", "address", "applet", "area", "article", "aside", "audio", "b", "base", "basefont", "bdi", "bdo", "bgsound", "big", "blink", "blockquote", "body", "br", "button", "canvas", "caption", "center", "cite", "code", "col", "colgroup", "command", "data", "datalist", "dd", "del", "details", "dfn", "dir", "div", "dl", "dt", "em", "embed", "fieldset", "figcaption", "figure", "font", "footer", "form", "frame", "frameset", "h1", "h2", "h3", "h4", "h5", "h6", "head", "header", "hgroup", "hr", "html", "i", "iframe", "img", "input", "ins", "isindex", "kbd", "keygen", "label", "legend", "li", "link", "listing", "main", "map", "mark", "marquee", "menu", "menuitem", "meta", "meter", "nav", "nobr", "noframes", "noscript", "object", "ol", "optgroup", "option", "output", "p", "param", "picture", "plaintext", "pre", "progress", "q", "rp", "rt", "ruby", "s", "samp", "script", "section", "select", "small", "source", "spacer", "span", "strike", "strong", "style", "sub", "summary", "sup", "table", "tbody", "td", "textarea", "tfoot", "th", "thead", "time", "title", "tr", "track", "tt", "u", "ul", "var", "video", "wbr", "xmp",
  "math", "mi", "mo", "mn", "mrow", "mtable", "mtr", "mtd", "mfrac", "msup", "maction", "menclose", "mfenced", "mglyph", "mover", "mroot", "ms", "msqrt", "msub", "msubsup", "mtable", "mtext", "munder", "mover", "munderover", "mstyle",
  "svg", "animate", "animateMotion", "animateTransform", "circle", "clipPath", "color-profile", "defs", "desc", "discard", "ellipse", "feBlend", "feColorMatrix", "feComponentTransfer", "feComposite", "feConvolveMatrix", "feDiffuseLighting", "feDisplacementMap", "feDistantLight", "feDropShadow", "feFlood", "feFuncA", "feFuncB", "feFuncG", "feFuncR", "feGaussianBlur", "feImage", "feMerge", "feMergeNode", "feMorphology", "feOffset", "fePointLight", "feSpecularLighting", "feSpotLight", "feTile", "feTurbulence", "filter", "foreignObject", "g", "hatch", "hatchpath", "image", "line", "linearGradient", "marker", "mask", "mesh", "meshgradient", "meshpatch", "meshrow", "metadata", "mpath", "path", "pattern", "polygon", "polyline", "radialGradient", "rect", "set", "solidcolor", "stop", "style", "switch", "symbol", "text", "textPath", "title", "tspan", "unknown", "use", "view"
  )
  var xmlMode = false

  def error(msg: String) {    
    System.err.println(line + ": " + msg) 
    System.exit(0)
  }

  def warning(msg: String) {    
    System.err.println(line + ": " + msg) 
  }

  def ws(iter: BufferedIterator[Char], eolOnly: Boolean = false) {
    var done = false
    while (!done && iter.hasNext && Character.isWhitespace(iter.head)) {
      if (iter.next == '\n') {
        line += 1
        if (eolOnly) done = true
      }
    }
  }

  def isNameChar(ch: Char) = Character.isLetterOrDigit(ch) || ch == '-' || ch == ':' || ch == '_'

  def name(iter: BufferedIterator[Char]) = {
    val b = new StringBuilder
    while (iter.hasNext && isNameChar(iter.head))
      b.append(iter.next)
    b.toString
  }     

  def stringLiteral(iter: BufferedIterator[Char]) = {
    val b = new StringBuilder
    if (!iter.hasNext) error("Character expected")
    if (iter.head == '\'') {
      iter.next
      while (iter.hasNext && iter.head != '\'') {
        if (iter.head == '\n') error("Newline in string")
        b.append(iter.next)
      }
      if (iter.hasNext) iter.next
      else error("Closing ' expected")
    } else {
      while (iter.hasNext && !java.lang.Character.isWhitespace(iter.head) && iter.head != END)
        b.append(iter.next)
    }
    b.toString    
  }

  def escapeAttribute(attr: String) = {
    val b = new StringBuilder
    var inEntity = false
    for (c <- attr) {
      if (c == BEGIN) {
        if (inEntity) error("Unclosed entity reference")
        inEntity = true
        // TODO: Check that the next character is &
      }
      else if (c == '<')
        b.append("&lt;")
      else if (c == '&')
        b.append("&amp;")
      else if (c == '\'')
        b.append("&apos;")
      else if (c == END) {
        inEntity = false;
        b.append(";");
      }
      else {
        b.append(c)
      }
    }
    if (inEntity) error("Unclosed entity reference")
    b.toString
  }

  def altFromSrc(src: String) = {
    val n1 = src.lastIndexOf("/")
    val filepart = src.substring(n1 + 1)
    val n2 = filepart.lastIndexOf(".")
    if (n2 >= 0) filepart.substring(n2) else filepart
  }

  def contentFromHref(href: String) = 
    if (href.startsWith("#")) null
    else if (href.startsWith("http://") || href.startsWith("https://")) href
    else href.substring(href.lastIndexOf("/") + 1)  

  if (args.length > 0 && args(0) == "-x") xmlMode = true;
  val stk = new java.util.Stack[String]
  while (iter.hasNext) {
    val ch = iter.next
    if (ch == BEGIN) { 
      if (iter.hasNext && (iter.head == '!' || iter.head == '?')) {
        // processing instruction, doctype, etc.
        print("<")
        if (iter.head == '!') { // Might be comment
          print(iter.next)
          if (iter.hasNext && iter.head == '-') {
            print(iter.next)
            if (iter.hasNext && iter.head == '-') {
              print(iter.next)
              // Is comment--skip to the -- just before the END
              var endOfComment = 0
              while (endOfComment != 3) {
                if (!iter.hasNext) error("Unclosed comment")
                if (iter.head == '-') endOfComment += 1;
                else endOfComment = 0;
                if (endOfComment == 2) { // -- 
                  iter.next // skip -
                  if (iter.hasNext && iter.head == END) { // --〉
                    print("-") 
                    endOfComment = 3 
                  }
                  else { 
                    print("&#45") // Can't have -- in comments
                    endOfComment = 0
                  }
                } else { 
                  print(iter.head)
                  if (iter.next == '\n') line += 1
                }
              }
            }
          }
        } 
        while (iter.hasNext && iter.head != END)
          print(iter.next)
        if (!iter.hasNext) error(END + " expected")
        iter.next
        print(">")
      }
      else if (iter.head == '&') { // entity reference
        print(iter.next)
        while (iter.hasNext && iter.head != END)
          print(iter.next)
        if (!iter.hasNext) error(END + " expected")
        iter.next
        print(";")
      }
      else {
        var tagName = name(iter)
        if (iter.hasNext && iter.head == ';') { // TODO: Legacy
          // character entity
          iter.next
          if (!iter.hasNext || iter.next != END) error(END + " expected")
          print("&" + tagName + ";")
        }
        else {
          var nonAttr : String = null
          var klass = ""
          var id = ""
          if (tagName == "" && iter.hasNext && iter.head == ' ') {
            if (xmlMode) error("No tag name")
            tagName = "code"
            iter.next
            nonAttr = ""
          }
          else
            while (iter.hasNext && (iter.head == '.' || iter.head == '#')) {
              val prefix = iter.head
              iter.next
              if (tagName == "") {
                if (xmlMode) error("No tag name")
                tagName = "span"
              }
              if (prefix == '.') {
                if (xmlMode) error(". in tag name")
                if (klass == "") klass = name(iter)
                else klass = klass + " " + name(iter)
              } else {
                if (id != "") error("multiple id attributes " + id + " " + name(iter))
                id = name(iter)
                while (iter.hasNext && iter.head == '.') { // IDs can have periods
                  iter.next
                  id = id + "." + name(iter)
                }
              }
            }
                  
          if (tagName == "") error("name or . expected after " + ch)
          if (!xmlMode && !elements.contains(tagName) && !tagName.contains(":")) warning (tagName + " is not a valid HTML element")
          print("<")
          print(tagName)
          if (id != "")
            print(" id='" + escapeAttribute(id) + "'")
          if (klass != "")
            print(" class='" + escapeAttribute(klass) + "'")
          var srcAttr: String = null
          var altAttr: String = null
          var loadingAttr: String = null
          while (nonAttr == null && iter.hasNext && iter.head == ' ') {
            iter.next
            if (iter.hasNext && iter.head == ' ') {
              // Two spaces--end of attributes
              iter.next
              nonAttr = ""
            }
            else {
              val attrName = name(iter)
              if (attrName == "") nonAttr = ""
              else {
                if (iter.hasNext && iter.head == '=') {
                  iter.next
                  if (iter.hasNext && iter.head != END && !java.lang.Character.isWhitespace(iter.head)) {
                    val attrValue = stringLiteral(iter)
                    print(" " + attrName + "='" + escapeAttribute(attrValue) + "'")

                    if (attrName == "class" && klass != "") error("both ." + klass.replace(" ", ".") + " and class='" + attrValue + "'")
                    else if (attrName == "id" && id != "") error("both #" + id + " and id='" + attrValue + "'")
                    else if (!xmlMode && attrName == "href" && !attrValue.startsWith("#") && tagName == "a" && iter.head == END) nonAttr = contentFromHref(attrValue)
                    else if (!xmlMode && tagName == "img") {
                      if (attrName == "src") srcAttr = attrValue;
                      if (attrName == "alt") altAttr = attrValue;
                      if (attrName == "loading") loadingAttr = attrValue;
                    }
                  } else
                    nonAttr = attrName + "="
                }
                else nonAttr = attrName
              }
            }
          }
          if (nonAttr == null) ws(iter, !xmlMode && tagName == "pre")
          if (iter.head == END) {
            if (!xmlMode && tagName == "img") {
              if (srcAttr == null) error("img without src")
              if (altAttr == null) print(" alt='" + escapeAttribute(altFromSrc(srcAttr)) + "'")
              if (loadingAttr == null) print(" loading='lazy'") // https://web.dev/browser-level-image-lazy-loading/
            }
            if ((nonAttr == null || nonAttr.trim().equals("")) && (xmlMode || voidElements.contains(tagName)))
              print("/>")
            else {
              print(">");
              if (nonAttr != null) print(nonAttr);
              print("</" + tagName + ">")
            }
            iter.next
          } else {
            stk.push(tagName)
            print(">")
            if (nonAttr != null) print(nonAttr) 
          }
        }
      }
    }
    else if (ch == END) {
      if (stk.size == 0) error("Unexpected " + ch)
      else print("</" + stk.pop() + ">")
    }
    else if (ch == '<')
      print("&lt;")
    else if (ch == '>')
      print("&gt;")
    else if (ch == '&')
      print("&amp;")
    else {
      if (Character.isWhitespace(ch) && !xmlMode && stk.contains("pre") && !" \n\r".contains(ch))
        error("Invalid whitespace")
      print(ch)
      if (ch == '\n') line += 1
    }
  }
  if (stk.size() > 0) error("Unmatched tags: " + stk)
}

object convert extends App {
  val in = System.in
  val source = scala.io.Source.fromInputStream(in)
  val iter = source.buffered
  var line = 1
  val BEGIN = '〈'
  val END = '〉'

  val voidElements = Set("area", "base", "br", "col", "command", "embed", "hr", "img", "input", "keygen", "link", "meta", "param", "source", "track", "wbr") // http://dev.w3.org/html5/markup/syntax.html

  val elements = Set(
"a", "abbr", "acronym", "address", "applet", "area", "article", "aside", "audio", "b", "base", "basefont", "bdi", "bdo", "bgsound", "big", "blink", "blockquote", "body", "br", "button", "canvas", "caption", "center", "cite", "code", "col", "colgroup", "command", "data", "datalist", "dd", "del", "details", "dfn", "dir", "div", "dl", "dt", "em", "embed", "fieldset", "figcaption", "figure", "font", "footer", "form", "frame", "frameset", "h1", "h2", "h3", "h4", "h5", "h6", "head", "header", "hgroup", "hr", "html", "i", "iframe", "img", "input", "ins", "isindex", "kbd", "keygen", "label", "legend", "li", "link", "listing", "main", "map", "mark", "marquee", "menu", "menuitem", "meta", "meter", "nav", "nobr", "noframes", "noscript", "object", "ol", "optgroup", "option", "output", "p", "param", "plaintext", "pre", "progress", "q", "rp", "rt", "ruby", "s", "samp", "script", "section", "select", "small", "source", "spacer", "span", "strike", "strong", "style", "sub", "summary", "sup", "table", "tbody", "td", "textarea", "tfoot", "th", "thead", "time", "title", "tr", "track", "tt", "u", "ul", "var", "video", "wbr", "xmp"
, "math", "mi", "mo", "mn", "mrow", "mtable", "mtr", "mtd" 
)


  def error(msg: String) {    
    System.err.println(line + ": " + msg) 
    System.exit(0)
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
      while (iter.hasNext && iter.head != '\'')
        b.append(iter.next)
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
                    print(iter.next)
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
            tagName = "code"
            iter.next
            nonAttr = ""
          }
          else
            while (iter.hasNext && (iter.head == '.' || iter.head == '#')) {
              val prefix = iter.head
              iter.next
              if (tagName == "") {
                tagName = "span"
              }
              if (prefix == '.') {
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
          if (!elements.contains(tagName) && !tagName.contains(":")) error (tagName + " is not a valid HTML element")
          print("<")
          print(tagName)
          if (id != "")
            print(" id='" + escapeAttribute(id) + "'")
          if (klass != "")
            print(" class='" + escapeAttribute(klass) + "'")
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
                  if (iter.hasNext && !java.lang.Character.isWhitespace(iter.head)) {
                    val attrValue = stringLiteral(iter)
                    print(" " + attrName + "='" + escapeAttribute(attrValue) + "'")

                    if (attrName == "class" && klass != "") error("both ." + klass.replace(" ", ".") + " and class='" + attrValue + "'")
                    else if (attrName == "id" && id != "") error("both #" + id + " and id='" + attrValue + "'")

                  } else
                    nonAttr = attrName + "="
                }
                else nonAttr = attrName
              }
            }
          }
          if (nonAttr == null) ws(iter, tagName == "pre")
          if (iter.head == END) {
            if ((nonAttr == null || nonAttr.trim().equals("")) && voidElements.contains(tagName))
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
      print(ch)
      if (ch == '\n') line += 1
    }
  }
  if (stk.size() > 0) error("Unmatched tags: " + stk)
}

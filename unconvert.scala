// TODO: Group multiple spaces in output into one

import scala.xml._
import scala.xml.parsing._

object unconvert extends App {
  val tabs = 2
  val in = System.in
  val source = scala.io.Source.fromInputStream(in)
  val parser = new XhtmlParser(source)
  val doc = parser.initialize.document
  val root = doc.docElem
  val dtd = doc.dtd
  val inlineElements = Set("a", "abbr", "acronym", "b", "bdo", 
    "big", "br", "cite", "code", "dfn", "em", "font", "i", "img",
    "input", "kbd", "label", "q", "samp", "select", "small",
    "span", "strong", "sub", "sup", "textarea", "tt", "var")
  // "ins", "del" can be either

  // println("〈?xml version='1.0' encoding='UTF-8'?〉")
  if (dtd != null && dtd.externalID != null)
    println("〈!DOCTYPE html " + dtd.externalID + "〉")
  write(root.asInstanceOf[Elem], 0)

  def writeIndent(indent: Int) {
    println()
    for (i <- 1 to tabs * indent) print(" ")
  }

  def hasNonInlineChildren(e: Elem) = e.child.exists(n => n.isInstanceOf[Elem] && !inlineElements.contains(n.label))

  def unescapeAttribute(t: String) = {
    val b = new StringBuilder
    var i = 0
    val quote = t.length() == 0 || t.exists(java.lang.Character.isWhitespace(_)) || t.startsWith("'")
    if (quote) b.append('\'')
    while (i < t.length) {
      val c = t(i)
      if (c == '〈') b.append("〈&#9001〉")
      else if (c == '〉') b.append("〈&#9002〉")
      else if (quote && c == '\'') b.append("〈&apos〉")
      else b.append(c)
      i += 1
    }
    if (quote) b.append('\'')
    b.toString
  }

  // The XHTML parser doesn't resolve entities in attributes
  /*
  def unescapeAttribute(ns: Seq[Node]) = 
    ns map {
      case EntityRef(r) => "〈" + r + "〉;"
      case Text(t) =>      
        t.flatMap(c => c match {
          case '\'' => "〈apos;〉"
          case '〈' => "〈lang;〉"
          case _ => "" + c})
    } reduce (_ + _)
   */

  def write(e: Elem, indent: Int) {
    val label = if (e.prefix == null) e.label else e.prefix + ":" + e.label
    if (label == "h1") println();
    val isInline = inlineElements.contains(label)
    if (!isInline) writeIndent(indent)

    print("〈")
    if (!(label == "code" && e.attributes.size == 0)) {
      if (label != "span") print(label)

      var klass = e.attributes.get("class").getOrElse(Text("")).text
      if (klass.contains(".")) { // Then can't convert to dotted form
        klass = "";
      } else {
        klass = klass.replace(" ", ".")
        if (klass != "")
          print("." + klass)
      }
      var id = e.attributes.get("id").getOrElse(Text("")).text
      if (id != "")
        printf("#" + id)
      //else if (label == "span")
      //  print(label)

      if (indent == 0) { // root node, write namespaces
        var scope = e.scope
        val namespaces = new scala.collection.mutable.ArrayBuffer[String]
        while (scope != null) {
          if (scope.uri != null)
            namespaces += (if (scope.prefix != null) ":" + scope.prefix else "") + "='" + scope.uri + "'"
          scope = scope.parent
        }
        for (ns <- namespaces.reverse)
          print(" xmlns" + ns)
      }

      for (attr <- e.attributes)
        if (!(attr.prefixedKey == "class" && klass != "" ||
              attr.prefixedKey == "id" && id != "")) {
          print(" " + attr.prefixedKey + "=" + unescapeAttribute(attr.value.text))
        }
    }
    if (e.child.length > 0) {
      if (label == "pre" || label == "script") println() 
      else if (e.child.text.matches("[^= ]+=([^ ]|'[^']*').*")) print("  ") 
      else print(" ")
    }

    for (n <- e.child) 
      n match {
        case e: Elem => write(e, indent + 1)
        case t: Text => {
          var pre = '?'
          for (c <- t.data)
            if (c == '〈') print("〈&#9001〉")
            else if (c == '〉') print("〈&#9002〉")
            else if (label == "pre" || label == "script") print(c)          
            else if (c != '\n' && c != '\t') { if (!(pre == ' ' && c == ' ')) print(c); pre = c }
            else { if (!(pre == ' ')) print(' '); pre = ' ' }
        }
        case p: PCData => print("〈![CDATA[" + p.data + "]]〉")
        case r: EntityRef => print("〈&" + r.entityName + "〉") 
        case c: Comment => print("〈!--" + c.commentText + "--〉")
        case i: ProcInstr => print("〈?" + i.target + " " + i.proctext + "?〉")
        case a: Atom[_] => print(a.text) // For < > 
        case _ => print("〈!-- unexpected " + n.text + " --〉")
      }
    if (hasNonInlineChildren(e)) writeIndent(indent)
    print("〉")
  }
}

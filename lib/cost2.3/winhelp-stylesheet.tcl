######################################################################
# $Id: winhelp-stylesheet.tcl,v 1.6 2002/05/02 19:38:05 joe Exp $
######################################################################
#
# Default RATFINK style sheet for Winhelp output
# 3 Jul 1999
#

rtf::paraStyle normal "Normal" {
    Quadding	Justify
    Font	sans
    FontSize	10pt
    LeftIndent	6pt
    RightIndent	6pt
}

rtf::paraStyle body "Body text" -basedon normal {
    SpaceBefore	3pt
    SpaceAfter	3pt
}

rtf::paraStyle bodynoindent "Body text no indent" -basedon normal {
    FirstIndent	0pt
    SpaceBefore	3pt
    SpaceAfter	3pt
}

rtf::paraStyle note "Note" -basedon normal {
    Font	roman
    Italic	1
    SpaceBefore	6pt
    SpaceAfter	6pt
    LeftIndent	36pt
    RightIndent	36pt
    FirstIndent 0in
}

rtf::charStyle plain "Plain text" { }
rtf::charStyle hp0 "Highlighted Phrase" { Italic	1 }
rtf::charStyle hp1 "Highlighted Phrase" { Bold	1 }
rtf::charStyle ct "Computer Text" { Font	mono }
rtf::charStyle var "Variable Text" { Font sans Italic 1  Bold 0 }

rtf::paraStyle heading "Heading Base" {
    Font	sans
    Quadding	Left
    SpaceBefore	12pt
    SpaceAfter	6pt
}

rtf::paraStyle banner "Non-scrolling region" -basedon heading {
    Font	sans
    Bold	1
    FontSize	12pt
    Banner	1
    Quadding	Center
    SpaceBefore	6pt
    SpaceAfter	6pt
}

rtf::paraStyle heading1 "Heading 1" -basedon heading {
    FontSize	12pt
    Bold	1
}
rtf::paraStyle heading2 "Heading 2" -basedon heading {
    FontSize	12pt
    Italic	1
}
rtf::paraStyle heading3 "Heading 3" -basedon heading {
    FontSize	10pt
    Italic	1
}

rtf::paraStyle minorhead "Minor Heading" {
    Font	sans
    Bold	1
    FontSize	10pt
    Quadding	Left
    SpaceBefore	3pt
    SpaceAfter	0pt
}

rtf::paraStyle verbatim "Verbatim" {
    Font	mono
    FontSize	10pt
    Quadding	Left
    NoWrap	1
    FirstIndent	0in
    LeftIndent	36pt
    RightIndent	36pt
    SpaceBefore	10pt
    SpaceAfter	10pt
    TabStops	{116pt 196pt 276pt 356pt 436pt 516pt 596pt 676pt}
}

#
# Lists:
#	For a bulleted list item, use paraStyle litem,
#	and begin the paragraph with "$rtfSpecial(Bullet)$rtfSpecial(Tab)"
#
#	For a tagged paragraph (e.g., HTML <DT>/<DD> pair),
#	use a the 'tagpara' paragraph style; the tag (<DT> part)
#	should use the 'paratag' character style and be followed by a tab.
#
#
rtf::tabStops litabs {
    {36pt  Align Left}
}
rtf::paraStyle litem "List Item" -basedon normal {
    TabStops	litabs
    LeftIndent	 36pt
    FirstIndent -18pt
    RightIndent	 36pt
}

rtf::paraStyle menu "Menu item" -basedon litem { }

rtf::paraStyle tagpara "Tagged Paragraph" -basedon normal {
    TabStops	{{1.5in Align Left}}
    SpaceBefore	3pt
    SpaceAfter	3pt
    LeftIndent	1.5in
    FirstIndent -1.25in
    RightIndent	0in
}
rtf::charStyle paratag "Paragraph tag" { Bold 1 }
# If there are multiple tags, use "tagpara0" for all but the last one:
rtf::paraStyle tagpara0 "Tagged paragraph with multiple tags" -basedon tagpara {
    SpaceAfter	0pt
}


#
# Table of contents:
#
rtf::paraStyle toc "TOC entry base" {
    Font	roman
    FontSize	10pt
    TabStops	{{6in  Align Right  Leaders Dot}}
}
rtf::paraStyle toc1 "toc 1"  -basedon toc {
    SpaceBefore	3pt
    SpaceAfter	0pt
    Bold	1
}
rtf::paraStyle toc2 "toc 2" -basedon toc { LeftIndent 10pt }
rtf::paraStyle toc3 "toc 3" -basedon toc { LeftIndent 20pt }
rtf::paraStyle toc4 "toc 4" -basedon toc { LeftIndent 30pt }
rtf::paraStyle toc5 "toc 5" -basedon toc { LeftIndent 40pt }
rtf::paraStyle toc6 "toc 6" -basedon toc { LeftIndent 50pt }

#*EOF*

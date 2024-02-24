$w insert end "\n\n\[I]\n\n" pagenr
$w insert end "Vorwort" h1
$w insert end "\n\nDer Wert des Deutschen Wörterbuchs von "
$w insert end "J" ai
$w insert end "ACOB" ar
$w insert end " G" ai
$w insert end "RIMM" ar
$w insert end " und "
$w insert end "W" ai
$w insert end "ILHELM" ar
$w insert end " G" ai
$w insert end "RIMM" ar
$w insert end " wird in erheblichem "
$w insert end "Maße durch die Aussagekraft der dargebotenen Belege bestimmt. Für die Prüfung und "
$w insert end "Verifizierung der Belege durch den wissenschaftlichen Benutzer ist die Möglichkeit, die ausgewerteten "
$w insert end "Quellen des Wörterbuchs eindeutig zu identifizieren, eine wichtige Voraussetzung. "
$w insert end "Darüber hinaus erfordert das richtige Verständnis der Wörterbuchartikel die Kenntnis der chronologischen "
$w insert end "und landschaftlichen Verteilung der Belegtexte. Das vorliegende Verzeichnis sieht seine "
$w insert end "wesentliche Aufgabe darin, dem Benutzer des DWB die für diese Zwecke notwendigen Angaben "
$w insert end "in möglichst straffer Darstellung zur Verfügung zu stellen, doch wird die so gebotene Liste von "
$w insert end "mehr als 25 000 Titeln und Verweisen, die literarische Texte ebenso wie die häufig vernachlässigten "
$w insert end "Gattungen der älteren Sachliteratur aller Wissensgebiete erfaßt, auch für die Verfolgung "
$w insert end "weiter gesteckter Ziele von Sprach- und Literarhistorikern wie Bibliothekaren von Nutzen sein. "
$w insert end "\nIn das Quellenverzeichnis vollständig aufgenommen sind die den Bänden I, II, III, V, VI und "
$w insert end "VII des DWB vorangestellten Quellenlisten und das 1910 herausgegebene Quellenverzeichnis."
label $w.fn -image [tix getimage smallright] -bd 0
set colmsg "Fußnote anzeigen"
$dwb_vars(BHLP) bind $w.fn -msg $colmsg
$w win cr insert -win $w.fn -align baseline
bind $w.fn <1> [eval list "ShowFootnote . $w fn vor33 $dwb_vars(QVZ,footnotes) $dwb_vars(QVZ,footnotew)"]
$w insert end "*)" {sup fn01}
$w insert end " Außerdem sind die auf Grund einer Durchsicht vorwiegend älterer Bände des DWB ermittelten "
$w insert end "Quellen und die in der Arbeitsstelle seit 1910 geführte umfangreiche handschriftliche Quellenkartei "
$w insert end "verarbeitet. Damit sind die regelmäßig herangezogenen literarischen Quellen des DWB "
$w insert end "erfaßt. Genannt werden darüber hinaus sprachwissenschaftliche Literatur und wissenschaftliche "
$w insert end "Hilfsmittel, insbesondere aus der Zeit der älteren Bände. Nicht vollständig nachgewiesen werden "
$w insert end "diejenigen Werke, denen lediglich Gelegenheitsexzerpte entnommen sind. Diese Titel wurden "
$w insert end "von den Artikelautoren meist mit zureichenden Angaben zitiert, so daß sich ihre vollständige "
$w insert end "Aufnahme in das Verzeichnis erübrigt. Die zusätzliche Nennung aller nur gelegentlich herangezogenen "
$w insert end "Quellen und Hilfsmittel hätte die lückenlose Überprüfung der Quellenangaben aller "
$w insert end "32 Bände des Wörterbuchs erfordert und den Umfang des gebotenen Titelmaterials unverhältnismäßig "
$w insert end "stark anschwellen lassen. Beides ließ sich mit der Anlage der Arbeit am Quellenverzeichnis "
$w insert end "nicht vereinbaren. Für ergänzende Mitteilungen, besonders für Hinweise, die zur Klärung "
$w insert end "von schwer zu verifizierenden Zitierangaben führen könnten, sind die Bearbeiter allen Benutzern "
$w insert end "des Quellenverzeichnisses dankbar. Sie sind ihrerseits bereit, auf der Grundlage des gesammelten "
$w insert end "Materials zusätzliche Auskünfte zu geben. "
$w insert end "\nDie Mitarbeiter am Quellenverzeichnis haben die folgenden Anteile bearbeitet: A. Huber "
$w insert end "D, E, I, J, N, R, U; H. Petermann"
$w insert end " O, T, W, X, Y; G. Richter F, G, H, M, Sch, Z; H. Schmidt "
$w insert end "B, K; R. Schmidt"
$w insert end " A, C, S (außer Sch und St), V; U. Schröter L, P, Q, St. Nach dem Ausscheiden "
$w insert end "zweier Bearbeiter führten abschließende Arbeiten aus: A. Huber"
$w insert end " an den Buchstaben O und T, "
$w insert end "H. Schmidt"
$w insert end " an S und V, U. Schröter an W, X, Y. Außerdem waren in Berlin an den Arbeiten zum "
$w insert end "Quellenverzeichnis u. a. W. Braun"
$w insert end " , J. Dückert, J. Mantey und W. Mittring beteiligt. In Göttingen "
$w insert end "hat U. Horn"
$w insert end " die Titel der in der Niedersächsischen Staats- und Universitätsbibliothek vorhandenen "
$w insert end "Quellen aufgenommen und überprüft, außerdem haben H. Albrand"
$w insert end " und H.-G. Maak "
$w insert end "mitgearbeitet. Im Vorbereitungsstadium standen die Arbeiten zunächst unter der Leitung von "
$w insert end "W. Pfeifer"
$w insert end ". Die Abschrift des Manuskripts besorgte im wesentlichen E. Wehrsig. "
$w insert end "\nDie Mitarbeiter danken allen Bibliotheken, die die Ausarbeitung des Quellenverzeichnisses "
$w insert end "durch Auskünfte unterstützt haben. Weit über das übliche Maß in Anspruch genommen wurden "
$w insert end "die folgenden Bibliotheken: Deutsche Staatsbibliothek, Universitätsbibliothek Berlin, Hauptbibliothek "
$w insert end "der Deutschen Akademie der Wissenschaften zu Berlin, Niedersächsische Staats- und "
$w insert end "Universitätsbibliothek Göttingen, Universitätsbibliothek Wroclaw. "
$w insert end "\n\n"
$w insert end "   Berlin, im Mai 1971"
$w insert end "\nDie Bearbeiter   " rtext

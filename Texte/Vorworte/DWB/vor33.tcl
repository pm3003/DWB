$w insert end "\n\n\[I]\n\n" pagenr
$w insert end "Vorwort" h1
$w insert end "\n\nDer Wert des Deutschen W�rterbuchs von "
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
$w insert end "Ma�e durch die Aussagekraft der dargebotenen Belege bestimmt. F�r die Pr�fung und "
$w insert end "Verifizierung der Belege durch den wissenschaftlichen Benutzer ist die M�glichkeit, die ausgewerteten "
$w insert end "Quellen des W�rterbuchs eindeutig zu identifizieren, eine wichtige Voraussetzung. "
$w insert end "Dar�ber hinaus erfordert das richtige Verst�ndnis der W�rterbuchartikel die Kenntnis der chronologischen "
$w insert end "und landschaftlichen Verteilung der Belegtexte. Das vorliegende Verzeichnis sieht seine "
$w insert end "wesentliche Aufgabe darin, dem Benutzer des DWB die f�r diese Zwecke notwendigen Angaben "
$w insert end "in m�glichst straffer Darstellung zur Verf�gung zu stellen, doch wird die so gebotene Liste von "
$w insert end "mehr als 25 000 Titeln und Verweisen, die literarische Texte ebenso wie die h�ufig vernachl�ssigten "
$w insert end "Gattungen der �lteren Sachliteratur aller Wissensgebiete erfa�t, auch f�r die Verfolgung "
$w insert end "weiter gesteckter Ziele von Sprach- und Literarhistorikern wie Bibliothekaren von Nutzen sein. "
$w insert end "\nIn das Quellenverzeichnis vollst�ndig aufgenommen sind die den B�nden I, II, III, V, VI und "
$w insert end "VII des DWB vorangestellten Quellenlisten und das 1910 herausgegebene Quellenverzeichnis."
label $w.fn -image [tix getimage smallright] -bd 0
set colmsg "Fu�note anzeigen"
$dwb_vars(BHLP) bind $w.fn -msg $colmsg
$w win cr insert -win $w.fn -align baseline
bind $w.fn <1> [eval list "ShowFootnote . $w fn vor33 $dwb_vars(QVZ,footnotes) $dwb_vars(QVZ,footnotew)"]
$w insert end "*)" {sup fn01}
$w insert end " Au�erdem sind die auf Grund einer Durchsicht vorwiegend �lterer B�nde des DWB ermittelten "
$w insert end "Quellen und die in der Arbeitsstelle seit 1910 gef�hrte umfangreiche handschriftliche Quellenkartei "
$w insert end "verarbeitet. Damit sind die regelm��ig herangezogenen literarischen Quellen des DWB "
$w insert end "erfa�t. Genannt werden dar�ber hinaus sprachwissenschaftliche Literatur und wissenschaftliche "
$w insert end "Hilfsmittel, insbesondere aus der Zeit der �lteren B�nde. Nicht vollst�ndig nachgewiesen werden "
$w insert end "diejenigen Werke, denen lediglich Gelegenheitsexzerpte entnommen sind. Diese Titel wurden "
$w insert end "von den Artikelautoren meist mit zureichenden Angaben zitiert, so da� sich ihre vollst�ndige "
$w insert end "Aufnahme in das Verzeichnis er�brigt. Die zus�tzliche Nennung aller nur gelegentlich herangezogenen "
$w insert end "Quellen und Hilfsmittel h�tte die l�ckenlose �berpr�fung der Quellenangaben aller "
$w insert end "32 B�nde des W�rterbuchs erfordert und den Umfang des gebotenen Titelmaterials unverh�ltnism��ig "
$w insert end "stark anschwellen lassen. Beides lie� sich mit der Anlage der Arbeit am Quellenverzeichnis "
$w insert end "nicht vereinbaren. F�r erg�nzende Mitteilungen, besonders f�r Hinweise, die zur Kl�rung "
$w insert end "von schwer zu verifizierenden Zitierangaben f�hren k�nnten, sind die Bearbeiter allen Benutzern "
$w insert end "des Quellenverzeichnisses dankbar. Sie sind ihrerseits bereit, auf der Grundlage des gesammelten "
$w insert end "Materials zus�tzliche Ausk�nfte zu geben. "
$w insert end "\nDie Mitarbeiter am Quellenverzeichnis haben die folgenden Anteile bearbeitet: A. Huber "
$w insert end "D, E, I, J, N, R, U; H. Petermann"
$w insert end " O, T, W, X, Y; G. Richter F, G, H, M, Sch, Z; H. Schmidt "
$w insert end "B, K; R. Schmidt"
$w insert end " A, C, S (au�er Sch und St), V; U. Schr�ter L, P, Q, St. Nach dem Ausscheiden "
$w insert end "zweier Bearbeiter f�hrten abschlie�ende Arbeiten aus: A. Huber"
$w insert end " an den Buchstaben O und T, "
$w insert end "H. Schmidt"
$w insert end " an S und V, U. Schr�ter an W, X, Y. Au�erdem waren in Berlin an den Arbeiten zum "
$w insert end "Quellenverzeichnis u. a. W. Braun"
$w insert end " , J. D�ckert, J. Mantey und W. Mittring beteiligt. In G�ttingen "
$w insert end "hat U. Horn"
$w insert end " die Titel der in der Nieders�chsischen Staats- und Universit�tsbibliothek vorhandenen "
$w insert end "Quellen aufgenommen und �berpr�ft, au�erdem haben H. Albrand"
$w insert end " und H.-G. Maak "
$w insert end "mitgearbeitet. Im Vorbereitungsstadium standen die Arbeiten zun�chst unter der Leitung von "
$w insert end "W. Pfeifer"
$w insert end ". Die Abschrift des Manuskripts besorgte im wesentlichen E. Wehrsig. "
$w insert end "\nDie Mitarbeiter danken allen Bibliotheken, die die Ausarbeitung des Quellenverzeichnisses "
$w insert end "durch Ausk�nfte unterst�tzt haben. Weit �ber das �bliche Ma� in Anspruch genommen wurden "
$w insert end "die folgenden Bibliotheken: Deutsche Staatsbibliothek, Universit�tsbibliothek Berlin, Hauptbibliothek "
$w insert end "der Deutschen Akademie der Wissenschaften zu Berlin, Nieders�chsische Staats- und "
$w insert end "Universit�tsbibliothek G�ttingen, Universit�tsbibliothek Wroclaw. "
$w insert end "\n\n"
$w insert end "   Berlin, im Mai 1971"
$w insert end "\nDie Bearbeiter   " rtext

# DHBW CAS - Labor IT Sicherheit - Runde 1

Gruppenmitglieder:

- Jens Hausdorf
- Tobias Goetz

## Aufgabenstellung

Setzen Sie in der VM einen Server unter Verwendung geeigneter Werkzeuge und Technologien auf. Wählen Sie im Zweifelsfall die einfachere Realisierungsvariante, damit Sie nicht mit „Kanonen auf Spatzen schießen“. Die Webseite braucht neben der Grundfunktionalität für den beschriebenen Anwendungsfall keine echten oder gar sinnvolle Inhalte und ein ausgefeiltes Design zu haben, aber etwas Content in einigermaßen ansprechender Form (gerne KI-generiert) wäre nett, um einen realistischen Eindruck zu haben.

Überlegen Sie sich, wie das System (auf den verschiedenen Ebenen OS, Webserver, Anwendung) dem Schutzbedarf entsprechend abgesichert werden kann. Dokumentieren Sie, wie Sie zu Ihren Entscheidungen gelangt sind und (kurz, aber nachvollziehbar) wie Sie diese umgesetzt haben. Halten Sie fest, gegen welche

Bedrohungen Ihre Maßnahmen wirken. Ggf. können Sie auch noch angeben, wie die Wirksamkeit der Maßnahmen überprüft werden kann.

Bauen Sie zu Demonstrationszwecken bitte absichtlich am zwei Schwachstellen in Ihre Lösung ein. Diese Schwachstellen dokumentieren Sie in einem separaten Dokument kurz (Ursache, praktische Ausnutzung, mögliche Konsequenzen). Beschreiben Sie, wie die Schwachstellen vermieden werden können. Dies kann auch in der Form geschehen, dass Sie in bestimmten Teilen Ihres Systems Realisierungsvarianten ohne diese Schwachstellen umsetzen.

**Allgemeine Regeln:**

- Arbeiten Sie mit den zur Verfügung gestellten Images und installieren/konfigurieren Sie dort alles Nötige. Eine Neuinstallation des Betriebssystems ist dabei nicht nötig oder vorgesehen. Zu Beginn erhalten Sie einen root-Zugang. Der Dozenten-Account (User „ts“ o.Ä.) muss auf den Systemen mit allen Rechten erhalten bleiben.
- Treffen Sie keine impliziten Annahmen über die Sicherheit des Ausgangssystems (es handelt sich um vorgefertigte Images), sondern prüfen Sie die notwendigen Kriterien selbst (bitte festhalten!) und nehmen Sie die nötigen Änderungen und Anpassungen vor.
- Für die VMs kann keine bestimmte Verfügbarkeit gewährleistet werden, Sie sind für Backups (bzw. die Reproduzierbarkeit Ihrer Konfigurationen) selbst verantwortlich.
- Jedes Team arbeitet eigenständig, die Teams dürfen sich während der Runde nicht untereinander austauschen oder Ergebnisse veröffentlichen. Zugriffe auf die Systeme anderer Teams sind unzulässig, sofern nicht explizit vom Dozenten gestattet.
- Die Systeme sind aus dem Internet erreichbar (ggf. wird dies eingeschränkt auf das CAS-VPN). Achten Sie daher darauf, dass Sie keine größeren Sicherheitslücken haben. Ausgehender Traffic sollte auf das beschränkt sein, was für die Lösung der Aufgabe erforderlich ist.
- Der Einsatz von KI zur Lösungsfindung und Erzeugung von Dummy-Content o.Ä. ist erlaubt, nicht aber für die Generierung von Text für die Dokumentation. Machen Sie die Verwendung entsprechender Tools bitte kennlich gemäß der Vorlage des CAS. Wie immer sind Sie in jedem Fall für die durch KI erzeugten Ergebnisse verantwortlich, haben diese und mögliche Quellen selbst zu prüfen.

**Bewertungskriterien:**

Sie sollen zeigen, wie sich die fachlichen und funktionalen Anforderungen sicher umsetzen lassen und Ihren Lösungsweg beschreiben. Bei der Bewertung wird u.a. geachtet auf

- Umfang der identifizierten Anforderungen/Bedrohungen
- Methodische Vorgehensweise
- Angemessenheit der technologischen Entscheidungen und Auswahl der Schutzmechanismen
- Nachvollziehbarkeit, Vollständigkeit, Verständlichkeit der Dokumentation (Test-Accounts bitte mit aufführen)
- Originalität

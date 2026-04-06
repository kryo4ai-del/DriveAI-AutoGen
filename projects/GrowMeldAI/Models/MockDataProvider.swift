import Foundation

enum MockDataProvider {
    static let questions: [QuizQuestion] = [
        QuizQuestion(
            id: "q001",
            categoryID: "signs",
            text: "Was bedeutet ein rotes Stoppschild?",
            options: ["Weiterfahren", "Anhalten", "Vorsicht"],
            correctAnswer: "Anhalten",
            explanation: "Ein rotes Stoppschild bedeutet, dass Sie anhalten müssen.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q002",
            categoryID: "signs",
            text: "Welche Farbe hat ein Vorfahrtsschild?",
            options: ["Rot", "Gelb", "Weiß"],
            correctAnswer: "Weiß",
            explanation: "Vorfahrtsschilder sind weiß mit rotem Rand.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q003",
            categoryID: "signs",
            text: "Was bedeutet ein gelbes Warndreieck?",
            options: ["Gefahr", "Parken erlaubt", "Einbahnstraße"],
            correctAnswer: "Gefahr",
            explanation: "Gelbe Warndreiecke weisen auf eine Gefahrenstelle hin.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q004",
            categoryID: "signs",
            text: "Was bedeutet das blaue Schild mit weißem Pfeil nach oben?",
            options: ["Einbahnstraße", "Vorfahrt", "Autobahn"],
            correctAnswer: "Einbahnstraße",
            explanation: "Ein blaues Schild mit weißem Pfeil nach oben zeigt eine Einbahnstraße an.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q005",
            categoryID: "signs",
            text: "Was bedeutet ein rundes rotes Schild mit weißem Balken?",
            options: ["Einfahrt verboten", "Parken verboten", "Halten verboten"],
            correctAnswer: "Einfahrt verboten",
            explanation: "Das runde rote Schild mit weißem Balken bedeutet Einfahrt verboten.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q006",
            categoryID: "signs",
            text: "Was zeigt ein blaues rundes Schild mit weißem P?",
            options: ["Parken erlaubt", "Polizei", "Privatgelände"],
            correctAnswer: "Parken erlaubt",
            explanation: "Ein blaues rundes Schild mit weißem P kennzeichnet einen Parkplatz.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q007",
            categoryID: "signs",
            text: "Was bedeutet ein Schild mit rotem Rand und schwarzem Fahrrad?",
            options: ["Fahrradweg", "Fahrräder verboten", "Fahrradstraße"],
            correctAnswer: "Fahrräder verboten",
            explanation: "Ein Schild mit rotem Rand und durchgestrichenem Fahrrad bedeutet Fahrräder verboten.",
            imageURL: nil,
            difficulty: .medium
        ),
        QuizQuestion(
            id: "q008",
            categoryID: "signs",
            text: "Was bedeutet das Zeichen 'Vorfahrt gewähren'?",
            options: ["Anhalten und Vorfahrt gewähren", "Langsam fahren", "Vorfahrt haben"],
            correctAnswer: "Anhalten und Vorfahrt gewähren",
            explanation: "Das Zeichen 'Vorfahrt gewähren' bedeutet, dass Sie anderen Fahrzeugen Vorfahrt lassen müssen.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q009",
            categoryID: "signs",
            text: "Was bedeutet ein blaues Schild mit weißem Pfeil nach rechts?",
            options: ["Rechts abbiegen", "Vorgeschriebene Fahrtrichtung rechts", "Einbahnstraße rechts"],
            correctAnswer: "Vorgeschriebene Fahrtrichtung rechts",
            explanation: "Ein blaues Schild mit weißem Pfeil nach rechts schreibt die Fahrtrichtung rechts vor.",
            imageURL: nil,
            difficulty: .medium
        ),
        QuizQuestion(
            id: "q010",
            categoryID: "signs",
            text: "Was bedeutet ein Schild mit rotem Rand und schwarzem LKW?",
            options: ["LKW-Parkplatz", "LKW verboten", "LKW-Durchfahrt"],
            correctAnswer: "LKW verboten",
            explanation: "Ein Schild mit rotem Rand und schwarzem LKW bedeutet, dass LKW die Straße nicht benutzen dürfen.",
            imageURL: nil,
            difficulty: .medium
        ),
        QuizQuestion(
            id: "q011",
            categoryID: "rules",
            text: "Wie viel Promille Blutalkohol sind beim Führen eines Fahrzeugs in Deutschland erlaubt?",
            options: ["0,5 Promille", "0,8 Promille", "0,3 Promille"],
            correctAnswer: "0,5 Promille",
            explanation: "In Deutschland gilt eine Promillegrenze von 0,5 für Autofahrer.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q012",
            categoryID: "rules",
            text: "Welche Seite der Straße wird in Deutschland befahren?",
            options: ["Rechts", "Links", "Mitte"],
            correctAnswer: "Rechts",
            explanation: "In Deutschland gilt Rechtsverkehr.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q013",
            categoryID: "rules",
            text: "Was gilt an einer Kreuzung ohne Schilder?",
            options: ["Rechts vor links", "Links vor rechts", "Geradeaus hat Vorfahrt"],
            correctAnswer: "Rechts vor links",
            explanation: "An Kreuzungen ohne Schilder gilt die Regel 'Rechts vor links'.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q014",
            categoryID: "rules",
            text: "Wie groß muss der Sicherheitsabstand bei 100 km/h mindestens sein?",
            options: ["50 Meter", "100 Meter", "30 Meter"],
            correctAnswer: "50 Meter",
            explanation: "Bei 100 km/h sollte der Sicherheitsabstand mindestens 50 Meter betragen (halber Tacho).",
            imageURL: nil,
            difficulty: .medium
        ),
        QuizQuestion(
            id: "q015",
            categoryID: "rules",
            text: "Was müssen Sie tun, wenn Sie einen Unfall beobachten?",
            options: ["Weiterfahren", "Erste Hilfe leisten und Notruf wählen", "Nur fotografieren"],
            correctAnswer: "Erste Hilfe leisten und Notruf wählen",
            explanation: "Bei einem Unfall sind Sie verpflichtet, Erste Hilfe zu leisten und den Notruf zu wählen.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q016",
            categoryID: "rules",
            text: "Welche Höchstgeschwindigkeit gilt innerorts?",
            options: ["50 km/h", "60 km/h", "70 km/h"],
            correctAnswer: "50 km/h",
            explanation: "Innerorts gilt eine Höchstgeschwindigkeit von 50 km/h.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q017",
            categoryID: "rules",
            text: "Welche Höchstgeschwindigkeit gilt außerorts auf normalen Straßen?",
            options: ["100 km/h", "80 km/h", "120 km/h"],
            correctAnswer: "100 km/h",
            explanation: "Außerorts gilt auf normalen Straßen eine Höchstgeschwindigkeit von 100 km/h.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q018",
            categoryID: "rules",
            text: "Darf man auf der Autobahn überholen?",
            options: ["Nur rechts", "Nur links", "Auf beiden Seiten"],
            correctAnswer: "Nur links",
            explanation: "Auf der Autobahn darf nur links überholt werden.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q019",
            categoryID: "rules",
            text: "Was ist bei Nebel mit einer Sichtweite unter 50 Metern vorgeschrieben?",
            options: ["Nebelschlussleuchte einschalten", "Warnblinker einschalten", "Abblendlicht ausschalten"],
            correctAnswer: "Nebelschlussleuchte einschalten",
            explanation: "Bei Sichtweite unter 50 Metern muss die Nebelschlussleuchte eingeschaltet werden.",
            imageURL: nil,
            difficulty: .medium
        ),
        QuizQuestion(
            id: "q020",
            categoryID: "rules",
            text: "Wie lange darf man auf einem eingeschränkten Halteverbot halten?",
            options: ["3 Minuten", "5 Minuten", "10 Minuten"],
            correctAnswer: "3 Minuten",
            explanation: "Im eingeschränkten Halteverbot darf man bis zu 3 Minuten halten.",
            imageURL: nil,
            difficulty: .medium
        ),
        QuizQuestion(
            id: "q021",
            categoryID: "safety",
            text: "Was sollten Sie bei einem Reifenplatzer tun?",
            options: ["Stark bremsen", "Lenkrad festhalten und langsam abbremsen", "Gas geben"],
            correctAnswer: "Lenkrad festhalten und langsam abbremsen",
            explanation: "Bei einem Reifenplatzer sollten Sie das Lenkrad festhalten und das Fahrzeug langsam abbremsen.",
            imageURL: nil,
            difficulty: .medium
        ),
        QuizQuestion(
            id: "q022",
            categoryID: "safety",
            text: "Was ist beim Einschlafen am Steuer zu tun?",
            options: ["Fenster öffnen", "Anhalten und Pause machen", "Musik lauter stellen"],
            correctAnswer: "Anhalten und Pause machen",
            explanation: "Bei Müdigkeit am Steuer sollten Sie sofort anhalten und eine Pause einlegen.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q023",
            categoryID: "safety",
            text: "Welches ist das wichtigste Sicherheitsmerkmal im Auto?",
            options: ["Sicherheitsgurt", "Airbag", "ABS"],
            correctAnswer: "Sicherheitsgurt",
            explanation: "Der Sicherheitsgurt ist das wichtigste passive Sicherheitssystem im Fahrzeug.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q024",
            categoryID: "safety",
            text: "Was bedeutet ABS?",
            options: ["Antiblockiersystem", "Automatisches Bremssystem", "Aktives Bremssystem"],
            correctAnswer: "Antiblockiersystem",
            explanation: "ABS steht für Antiblockiersystem und verhindert das Blockieren der Räder beim Bremsen.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q025",
            categoryID: "safety",
            text: "Was sollten Sie bei Aquaplaning tun?",
            options: ["Stark bremsen", "Gas wegnehmen und Lenkrad halten", "Lenken"],
            correctAnswer: "Gas wegnehmen und Lenkrad halten",
            explanation: "Bei Aquaplaning sollten Sie das Gas wegnehmen und das Lenkrad ruhig halten.",
            imageURL: nil,
            difficulty: .medium
        ),
        QuizQuestion(
            id: "q026",
            categoryID: "safety",
            text: "Wie oft sollte der Reifendruck überprüft werden?",
            options: ["Monatlich", "Jährlich", "Alle 5 Jahre"],
            correctAnswer: "Monatlich",
            explanation: "Der Reifendruck sollte mindestens einmal im Monat überprüft werden.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q027",
            categoryID: "safety",
            text: "Was ist die Mindestprofiltiefe für Reifen in Deutschland?",
            options: ["1,6 mm", "3 mm", "4 mm"],
            correctAnswer: "1,6 mm",
            explanation: "Die gesetzliche Mindestprofiltiefe für Reifen beträgt 1,6 mm.",
            imageURL: nil,
            difficulty: .medium
        ),
        QuizQuestion(
            id: "q028",
            categoryID: "safety",
            text: "Was sollten Sie bei einem Motorenbrand tun?",
            options: ["Motor abstellen und Feuerlöscher benutzen", "Weiterfahren", "Motorhaube öffnen"],
            correctAnswer: "Motor abstellen und Feuerlöscher benutzen",
            explanation: "Bei einem Motorenbrand sollten Sie den Motor abstellen und den Feuerlöscher benutzen.",
            imageURL: nil,
            difficulty: .medium
        ),
        QuizQuestion(
            id: "q029",
            categoryID: "safety",
            text: "Welche Farbe hat das Warndreieck?",
            options: ["Rot", "Gelb", "Orange"],
            correctAnswer: "Rot",
            explanation: "Das Warndreieck ist rot und wird bei einer Panne aufgestellt.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q030",
            categoryID: "safety",
            text: "Was ist bei Glatteis zu beachten?",
            options: ["Langsam fahren und größeren Abstand halten", "Schneller fahren", "Normaler Abstand"],
            correctAnswer: "Langsam fahren und größeren Abstand halten",
            explanation: "Bei Glatteis sollten Sie langsamer fahren und den Abstand zum Vorausfahrenden vergrößern.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q031",
            categoryID: "environment",
            text: "Was bedeutet die blaue Umweltplakette?",
            options: ["Niedrige Emissionen", "Mittlere Emissionen", "Hohe Emissionen"],
            correctAnswer: "Niedrige Emissionen",
            explanation: "Die blaue Umweltplakette kennzeichnet Fahrzeuge mit niedrigen Schadstoffemissionen.",
            imageURL: nil,
            difficulty: .medium
        ),
        QuizQuestion(
            id: "q032",
            categoryID: "environment",
            text: "Was ist eine Umweltzone?",
            options: ["Zone mit Fahrverboten für bestimmte Fahrzeuge", "Naturschutzgebiet", "Parkzone"],
            correctAnswer: "Zone mit Fahrverboten für bestimmte Fahrzeuge",
            explanation: "Eine Umweltzone ist ein Bereich, in dem nur Fahrzeuge mit bestimmten Umweltplaketten fahren dürfen.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q033",
            categoryID: "environment",
            text: "Welche Farbe hat die Umweltplakette für Euro-4-Fahrzeuge?",
            options: ["Gelb", "Grün", "Rot"],
            correctAnswer: "Gelb",
            explanation: "Euro-4-Fahrzeuge erhalten eine gelbe Umweltplakette.",
            imageURL: nil,
            difficulty: .hard
        ),
        QuizQuestion(
            id: "q034",
            categoryID: "environment",
            text: "Was ist der Hauptvorteil von Elektrofahrzeugen?",
            options: ["Keine lokalen Emissionen", "Höhere Geschwindigkeit", "Günstigere Anschaffung"],
            correctAnswer: "Keine lokalen Emissionen",
            explanation: "Elektrofahrzeuge stoßen lokal keine Abgase aus.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q035",
            categoryID: "environment",
            text: "Was bedeutet CO2-neutrales Fahren?",
            options: ["Keine Netto-CO2-Emissionen", "Kein Kraftstoffverbrauch", "Keine Abgase"],
            correctAnswer: "Keine Netto-CO2-Emissionen",
            explanation: "CO2-neutrales Fahren bedeutet, dass die ausgestoßenen CO2-Emissionen durch andere Maßnahmen ausgeglichen werden.",
            imageURL: nil,
            difficulty: .medium
        ),
        QuizQuestion(
            id: "q036",
            categoryID: "signs",
            text: "Was bedeutet ein Schild mit rotem Rand und schwarzem Fußgänger?",
            options: ["Fußgängerzone", "Fußgänger verboten", "Fußgängerüberweg"],
            correctAnswer: "Fußgänger verboten",
            explanation: "Ein Schild mit rotem Rand und schwarzem Fußgänger bedeutet, dass Fußgänger die Straße nicht benutzen dürfen.",
            imageURL: nil,
            difficulty: .medium
        ),
        QuizQuestion(
            id: "q037",
            categoryID: "signs",
            text: "Was bedeutet ein blaues Schild mit weißem Fußgänger?",
            options: ["Fußgängerzone", "Fußgängerweg", "Fußgänger verboten"],
            correctAnswer: "Fußgängerweg",
            explanation: "Ein blaues Schild mit weißem Fußgänger kennzeichnet einen Fußgängerweg.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q038",
            categoryID: "signs",
            text: "Was bedeutet ein gelbes Schild mit schwarzem Ausrufezeichen?",
            options: ["Achtung, Gefahr", "Baustelle", "Schule"],
            correctAnswer: "Achtung, Gefahr",
            explanation: "Ein gelbes Schild mit schwarzem Ausrufezeichen warnt vor einer allgemeinen Gefahrenstelle.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q039",
            categoryID: "signs",
            text: "Was bedeutet ein Schild mit rotem Rand und schwarzem Motorrad?",
            options: ["Motorradparkplatz", "Motorräder verboten", "Motorradstraße"],
            correctAnswer: "Motorräder verboten",
            explanation: "Ein Schild mit rotem Rand und schwarzem Motorrad bedeutet, dass Motorräder die Straße nicht benutzen dürfen.",
            imageURL: nil,
            difficulty: .medium
        ),
        QuizQuestion(
            id: "q040",
            categoryID: "signs",
            text: "Was bedeutet ein blaues Schild mit weißem Fahrrad?",
            options: ["Fahrradweg", "Fahrräder verboten", "Fahrradstraße"],
            correctAnswer: "Fahrradweg",
            explanation: "Ein blaues Schild mit weißem Fahrrad kennzeichnet einen Fahrradweg.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q041",
            categoryID: "rules",
            text: "Was ist beim Überholen zu beachten?",
            options: ["Ausreichend Abstand zum überholten Fahrzeug halten", "So nah wie möglich überholen", "Hupen beim Überholen"],
            correctAnswer: "Ausreichend Abstand zum überholten Fahrzeug halten",
            explanation: "Beim Überholen muss ausreichend seitlicher Abstand zum überholten Fahrzeug gehalten werden.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q042",
            categoryID: "rules",
            text: "Wann darf man nicht überholen?",
            options: ["Bei unklarer Verkehrslage", "Auf gerader Strecke", "Bei gutem Wetter"],
            correctAnswer: "Bei unklarer Verkehrslage",
            explanation: "Bei unklarer Verkehrslage, z.B. an Kuppen oder Kurven, darf nicht überholt werden.",
            imageURL: nil,
            difficulty: .medium
        ),
        QuizQuestion(
            id: "q043",
            categoryID: "rules",
            text: "Was bedeutet 'Reißverschlussverfahren'?",
            options: ["Abwechselndes Einordnen bei Fahrbahnverengung", "Schnelles Bremsen", "Spurwechsel"],
            correctAnswer: "Abwechselndes Einordnen bei Fahrbahnverengung",
            explanation: "Beim Reißverschlussverfahren ordnen sich Fahrzeuge abwechselnd ein, wenn eine Fahrspur endet.",
            imageURL: nil,
            difficulty: .medium
        ),
        QuizQuestion(
            id: "q044",
            categoryID: "rules",
            text: "Wie verhalten Sie sich bei einem Bahnübergang ohne Schranken?",
            options: ["Langsam fahren und auf Züge achten", "Normal weiterfahren", "Hupen"],
            correctAnswer: "Langsam fahren und auf Züge achten",
            explanation: "An Bahnübergängen ohne Schranken müssen Sie langsam fahren und auf herannahende Züge achten.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q045",
            categoryID: "rules",
            text: "Was ist bei einem Fußgängerüberweg zu beachten?",
            options: ["Fußgänger haben Vorrang", "Fahrzeuge haben Vorrang", "Wer zuerst kommt, hat Vorrang"],
            correctAnswer: "Fußgänger haben Vorrang",
            explanation: "An Fußgängerüberwegen haben Fußgänger immer Vorrang.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q046",
            categoryID: "rules",
            text: "Darf man mit dem Auto auf dem Gehweg parken?",
            options: ["Nein, grundsätzlich nicht", "Ja, wenn ein Schild es erlaubt", "Ja, kurz"],
            correctAnswer: "Ja, wenn ein Schild es erlaubt",
            explanation: "Parken auf dem Gehweg ist nur erlaubt, wenn ein entsprechendes Schild es ausdrücklich gestattet.",
            imageURL: nil,
            difficulty: .medium
        ),
        QuizQuestion(
            id: "q047",
            categoryID: "rules",
            text: "Was ist beim Abbiegen zu beachten?",
            options: ["Rechtzeitig blinken und Schulterblick", "Nur blinken", "Nur Schulterblick"],
            correctAnswer: "Rechtzeitig blinken und Schulterblick",
            explanation: "Beim Abbiegen müssen Sie rechtzeitig blinken und einen Schulterblick machen.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q048",
            categoryID: "rules",
            text: "Wie verhalten Sie sich bei einem Einsatzfahrzeug mit Blaulicht?",
            options: ["Sofort Platz machen", "Weiterfahren", "Anhalten und warten"],
            correctAnswer: "Sofort Platz machen",
            explanation: "Einsatzfahrzeugen mit Blaulicht und Martinshorn muss sofort Platz gemacht werden.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q049",
            categoryID: "rules",
            text: "Was bedeutet eine doppelte Sperrlinie?",
            options: ["Überfahren verboten", "Überfahren erlaubt", "Parken verboten"],
            correctAnswer: "Überfahren verboten",
            explanation: "Eine doppelte Sperrlinie darf nicht überfahren werden.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q050",
            categoryID: "rules",
            text: "Welche Vorfahrtsregel gilt an einer T-Kreuzung?",
            options: ["Die durchgehende Straße hat Vorfahrt", "Rechts vor links", "Links vor rechts"],
            correctAnswer: "Die durchgehende Straße hat Vorfahrt",
            explanation: "An einer T-Kreuzung hat die durchgehende Straße Vorfahrt, sofern keine anderen Schilder vorhanden sind.",
            imageURL: nil,
            difficulty: .medium
        ),
        QuizQuestion(
            id: "q051",
            categoryID: "safety",
            text: "Was ist bei starkem Regen zu beachten?",
            options: ["Geschwindigkeit reduzieren und Abstand vergrößern", "Schneller fahren", "Normales Fahrverhalten"],
            correctAnswer: "Geschwindigkeit reduzieren und Abstand vergrößern",
            explanation: "Bei starkem Regen sollten Sie die Geschwindigkeit reduzieren und den Abstand vergrößern.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q052",
            categoryID: "safety",
            text: "Was sollten Sie tun, wenn Ihre Bremsen versagen?",
            options: ["Gangwechsel nach unten und Handbremse", "Türen öffnen", "Hupen"],
            correctAnswer: "Gangwechsel nach unten und Handbremse",
            explanation: "Bei Bremsversagen sollten Sie in einen niedrigeren Gang schalten und die Handbremse benutzen.",
            imageURL: nil,
            difficulty: .hard
        ),
        QuizQuestion(
            id: "q053",
            categoryID: "safety",
            text: "Was ist bei einem Fahrzeugbrand zu tun?",
            options: ["Fahrzeug verlassen und Feuerwehr rufen", "Weiterfahren", "Fenster schließen"],
            correctAnswer: "Fahrzeug verlassen und Feuerwehr rufen",
            explanation: "Bei einem Fahrzeugbrand müssen Sie das Fahrzeug sofort verlassen und die Feuerwehr rufen.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q054",
            categoryID: "safety",
            text: "Wie verhalten Sie sich bei einem Unfall mit Verletzten?",
            options: ["Unfallstelle sichern, Notruf, Erste Hilfe", "Weiterfahren", "Nur fotografieren"],
            correctAnswer: "Unfallstelle sichern, Notruf, Erste Hilfe",
            explanation: "Bei einem Unfall mit Verletzten müssen Sie die Unfallstelle sichern, den Notruf wählen und Erste Hilfe leisten.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q055",
            categoryID: "safety",
            text: "Was ist die stabile Seitenlage?",
            options: ["Erste-Hilfe-Maßnahme für bewusstlose Personen", "Schlafposition", "Sportübung"],
            correctAnswer: "Erste-Hilfe-Maßnahme für bewusstlose Personen",
            explanation: "Die stabile Seitenlage ist eine Erste-Hilfe-Maßnahme für bewusstlose, aber atmende Personen.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q056",
            categoryID: "safety",
            text: "Was sollten Sie bei einem Herzstillstand tun?",
            options: ["Herzdruckmassage und Beatmung", "Wasser geben", "Warten"],
            correctAnswer: "Herzdruckmassage und Beatmung",
            explanation: "Bei einem Herzstillstand müssen Sie sofort mit Herzdruckmassage und Beatmung beginnen.",
            imageURL: nil,
            difficulty: .medium
        ),
        QuizQuestion(
            id: "q057",
            categoryID: "safety",
            text: "Was ist bei starkem Schneefall zu beachten?",
            options: ["Winterreifen und reduzierte Geschwindigkeit", "Sommerreifen reichen", "Normales Fahrverhalten"],
            correctAnswer: "Winterreifen und reduzierte Geschwindigkeit",
            explanation: "Bei starkem Schneefall sollten Sie Winterreifen verwenden und die Geschwindigkeit reduzieren.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q058",
            categoryID: "safety",
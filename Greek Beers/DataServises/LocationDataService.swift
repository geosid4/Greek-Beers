//
//  LocationDataService.swift
//  Greek Beers
//
//  Created by George Sidiropoulos on 11/7/23.
//

import Foundation
import MapKit

enum LocationDataService {

    static let locations: [Location] = [
        Location(
            id: "vergina",
            name: "Βεργίνα",
            cityName: "Κομοτηνή",
            region: .easternMacedoniaThrace,
            founded: 1996,
            coordinates: CLLocationCoordinate2D(latitude: 41.122439, longitude: 25.406558),
            description: "Η αγάπη του Δημήτρη Πολιτόπουλου για καλή μπύρα και την Ελλάδα δημιούργησαν τη Ζυθοποιία Μακεδονίας Θράκης την 1η Φεβρουαρίου 1996. H εμφιάλωση της πρώτης μπύρας ΒΕΡΓΙΝΑ έγινε στις 13 Φεβρουαρίου 1998 και σήμανε την έναρξη της επανάστασης της ανεξάρτητης μικροζυθοποιίας στην Ελλάδα.",
            imageNames: ["vergina"],
            link: URL(string: "https://www.verginabeer.com/")),

        Location(
            id: "septem",
            name: "Septem",
            cityName: "Χαλκίδα",
            region: .centralGreece,
            founded: 2009,
            coordinates: CLLocationCoordinate2D(latitude: 38.46237, longitude: 23.59469),
            description: "Στο Ωρολόγιο Εύβοιας, δημιουργήθηκε από τον χημικό – οινολόγο Σοφοκλή Παναγιώτου και τον οικονομολόγο Γεώργιο Παναγιώτου η πρότυπη Μικροζυθοποιία Septem, η οποία ξεκίνησε τον Ιούνιο του 2009, τη διάθεση φρέσκιας, μη παστεριωμένης μπύρας. Στα λατινικά σημαίνει επτά, που είναι ο αριθμός της δημιουργίας! Aποτέλεσε έμπνευση για εμάς, καθώς κάθε τύπος μπύρας φέρει το όνομα μιας διαφορετικής ημέρας.",
            imageNames: ["septem"],
            link: URL(string: "https://septem.gr/")),

        Location(
            id: "chios",
            name: "Μπύρα Χίου",
            cityName: "Χίος",
            region: .northAegean,
            founded: 2009,
            coordinates: CLLocationCoordinate2D(latitude: 38.369114, longitude: 26.136987),
            description: "Το 2009, δύο φίλοι, αποφάσισαν να ξεκινήσουν μια επιχειρηματική δραστηριότητα στο υπέροχο νησί της Χίου, νησί καταγωγής του Ιάκωβου. Μετά από πολλές συζητήσεις και την εμπειρία, μιας μέρας, ερασιτεχνικής ζυθοποίησης του Μάνου, κατέληξαν στην ιδέα της δημιουργίας της Χιώτικης Μπύρας. Δεν θα μπορούσε άλλωστε, ένα νησί με τόσα τοπικά προϊόντα, να μην έχει την δική του μπύρα.",
            imageNames: ["chios"],
            link: URL(string: "https://chiosbeer.gr/cb/")),

        Location(
            id: "vambeer",
            name: "Vambeer",
            cityName: "Κατερίνη",
            region: .centralMacedonia,
            founded: nil,
            coordinates: CLLocationCoordinate2D(latitude: 40.280559, longitude: 22.50584),
            description: "Ακροβατώντας ανάμεσα στο μυθικό βουνό του Ολύμπου και την πλούσια ιστορία του τόπου μας βρισκόμαστε στο ιδανικό σκηνικό για να δημιουργήσουμε μοναδικό ελληνικό ζύθο. Η αγάπη για αυθεντικές γεύσεις και η βαθιά γνώση μας για τα φρέσκα προϊόντα, μας ώθησε στην παραγωγή φρέσκιας μπύρας και στη δημιουργία της μικροζυθοποιίας μας. Παράγουμε με μεράκι αφιλτράριστη, απαστερίωτη ελληνική μπύρα, χωρίς πρόσθετα και χωρίς συντηρητικά.",
            imageNames: ["vambeer"],
            link: URL(string: "https://vambeer.gr")),

        Location(
            id: "corfu",
            name: "Corfu Beer",
            cityName: "Κέρκυρα",
            region: .ionianIslands,
            founded: 2006,
            coordinates: CLLocationCoordinate2D(latitude: 39.623777, longitude: 19.921086),
            description: "Η Κερκυραϊκή ζυθοποιία ιδρύθηκε το 2006 στην Κέρκυρα. Στόχος της να επενδύσει σε καινοτόμα προϊόντα με σεβασμό στις παραδόσεις και στον πολιτισμό του τόπου. Όραμά της να αριστεύσει στο επιχειρηματικό, κοινωνικό και πολιτιστικό έργο που έχει αναλάβει. Ακολουθώντας πάντα τις αξίες της εταιρίας, όπως καινοτομία, ποιότητα, εμπειρία, παράδοση και υπερηφάνεια για τον τόπο της.",
            imageNames: ["corfu"],
            link: URL(string: "https://corfubeer.com/"))
    ]
}

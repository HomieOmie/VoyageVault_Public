//
//  CountryView.swift
//  VoyageVault
//
//  Created by Matthew Leboffe on 11/4/23.
//

import SwiftUI

let countryAlpha2Codes: [String: String] = [
    "afghanistan": "af",
    "albania": "al",
    "algeria": "dz",
    "andorra": "ad",
    "angola": "ao",
    "antigua and barbuda": "ag",
    "argentina": "ar",
    "armenia": "am",
    "australia": "au",
    "austria": "at",
    "azerbaijan": "az",
    "bahamas": "bs",
    "bahrain": "bh",
    "bangladesh": "bd",
    "barbados": "bb",
    "belarus": "by",
    "belgium": "be",
    "belize": "bz",
    "benin": "bj",
    "bhutan": "bt",
    "bolivia": "bo",
    "bosnia and herzegovina": "ba",
    "botswana": "bw",
    "brazil": "br",
    "brunei": "bn",
    "bulgaria": "bg",
    "burkina faso": "bf",
    "burundi": "bi",
    "côte d'ivoire": "ci",
    "cabo verde": "cv",
    "cambodia": "kh",
    "cameroon": "cm",
    "canada": "ca",
    "central african republic": "cf",
    "chad": "td",
    "chile": "cl",
    "china": "cn",
    "colombia": "co",
    "comoros": "km",
    "congo": "cg",
    "costa rica": "cr",
    "croatia": "hr",
    "cuba": "cu",
    "cyprus": "cy",
    "czechia": "cz",
    "democratic republic of the congo": "cd",
    "denmark": "dk",
    "djibouti": "dj",
    "dominica": "dm",
    "dominican republic": "do",
    "ecuador": "ec",
    "egypt": "eg",
    "el salvador": "sv",
    "equatorial guinea": "gq",
    "eritrea": "er",
    "estonia": "ee",
    "eswatini": "sz",
    "ethiopia": "et",
    "fiji": "fj",
    "finland": "fi",
    "france": "fr",
    "gabon": "ga",
    "gambia": "gm",
    "georgia": "ge",
    "germany": "de",
    "ghana": "gh",
    "greece": "gr",
    "grenada": "gd",
    "guatemala": "gt",
    "guinea": "gn",
    "guinea-bissau": "gw",
    "guyana": "gy",
    "haiti": "ht",
    "holy see": "va",
    "honduras": "hn",
    "hungary": "hu",
    "iceland": "is",
    "india": "in",
    "indonesia": "id",
    "iran": "ir",
    "iraq": "iq",
    "ireland": "ie",
    "israel": "il",
    "italy": "it",
    "jamaica": "jm",
    "japan": "jp",
    "jordan": "jo",
    "kazakhstan": "kz",
    "kenya": "ke",
    "kiribati": "ki",
    "kuwait": "kw",
    "kyrgyzstan": "kg",
    "laos": "la",
    "latvia": "lv",
    "lebanon": "lb",
    "lesotho": "ls",
    "liberia": "lr",
    "libya": "ly",
    "liechtenstein": "li",
    "lithuania": "lt",
    "luxembourg": "lu",
    "madagascar": "mg",
    "malawi": "mw",
    "malaysia": "my",
    "maldives": "mv",
    "mali": "ml",
    "malta": "mt",
    "marshall islands": "mh",
    "mauritania": "mr",
    "mauritius": "mu",
    "mexico": "mx",
    "micronesia": "fm",
    "moldova": "md",
    "monaco": "mc",
    "mongolia": "mn",
    "montenegro": "me",
    "morocco": "ma",
    "mozambique": "mz",
    "myanmar": "mm",
    "namibia": "na",
    "nauru": "nr",
    "nepal": "np",
    "netherlands": "nl",
    "new zealand": "nz",
    "nicaragua": "ni",
    "niger": "ne",
    "nigeria": "ng",
    "north korea": "kp",
    "north macedonia": "mk",
    "norway": "no",
    "oman": "om",
    "pakistan": "pk",
    "palau": "pw",
    "palestine state": "ps",
    "panama": "pa",
    "papua new guinea": "pg",
    "paraguay": "py",
    "peru": "pe",
    "philippines": "ph",
    "poland": "pl",
    "portugal": "pt",
    "qatar": "qa",
    "romania": "ro",
    "russia": "ru",
    "rwanda": "rw",
    "saint kitts and nevis": "kn",
    "saint lucia": "lc",
    "saint vincent and the grenadines": "vc",
    "samoa": "ws",
    "san marino": "sm",
    "sao tome and principe": "st",
    "saudi arabia": "sa",
    "senegal": "sn",
    "serbia": "rs",
    "seychelles": "sc",
    "sierra leone": "sl",
    "singapore": "sg",
    "slovakia": "sk",
    "slovenia": "si",
    "solomon islands": "sb",
    "somalia": "so",
    "south africa": "za",
    "south korea": "kr",
    "south sudan": "ss",
    "spain": "es",
    "sri lanka": "lk",
    "sudan": "sd",
    "suriname": "sr",
    "sweden": "se",
    "switzerland": "ch",
    "syria": "sy",
    "tajikistan": "tj",
    "tanzania": "tz",
    "thailand": "th",
    "timor-leste": "tl",
    "togo": "tg",
    "tonga": "to",
    "trinidad and tobago": "tt",
    "tunisia": "tn",
    "turkey": "tr",
    "turkmenistan": "tm",
    "tuvalu": "tv",
    "uganda": "ug",
    "ukraine": "ua",
    "united arab emirates": "ae",
    "united kingdom": "gb",
    "united states": "us",
    "uruguay": "uy",
    "uzbekistan": "uz",
    "vanuatu": "vu",
    "venezuela": "ve",
    "vietnam": "vn",
    "yemen": "ye",
    "zambia": "zm",
    "zimbabwe": "zw"
]


struct CountryView: View {
    @ObservedObject private var viewModel = CountryViewModel.shared
    
    @State private var searchText = ""
    
    let backgroundColor = Color(red: 248/255, green: 233/255, blue: 223/255)
    
    var body: some View {
        List {
            ForEach(filteredCountries, id: \.self) { country in
                VStack(spacing: 0) {
                    NavigationLink(destination: CountryCityListView(country: country)) {
                        HStack {
                            if let alphaCode = countryAlpha2Codes[country.lowercased()] {
                                Image(uiImage: UIImage(named: "\(alphaCode).png") ?? UIImage())
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 64, height: 44)
                                    .clipped()
                            }
                            Text(country)
                                .font(.headline)
                                .padding(.trailing)
                            Spacer()
                        }
                        .listRowBackground(backgroundColor)
                        .padding()
                    }
                    
                }
            }
        }
        .background(backgroundColor)
        .searchable(text: $searchText)
        .listStyle(PlainListStyle())
        .onChange(of: viewModel.selectedSortOption) { (_, newSortOption) in
            // Sorting option changed, the list will update automatically
        }
        .onAppear {
            viewModel.selectedSortOption = .nameAscending  // Default sorting option
        }
    }
    
    private var filteredCountries: [String] {
        if searchText.isEmpty {
            return viewModel.sortedCountries
        } else {
            return viewModel.sortedCountries.filter { country in
                let countryMatches = country.localizedCaseInsensitiveContains(searchText)
                
                let pinMatches = viewModel.pinRepository.user?.pins?.contains { pin in
                    pin.country == country &&
                        (pin.name.localizedCaseInsensitiveContains(searchText) ||
                         pin.city.localizedCaseInsensitiveContains(searchText) ||
                         pin.notes.localizedCaseInsensitiveContains(searchText) ||
                         pin.type.localizedCaseInsensitiveContains(searchText))
                } == true
                
                return countryMatches || pinMatches
            }
        }
    }
}


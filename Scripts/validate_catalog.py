#!/usr/bin/env python3
"""Checks the Zythos catalog before a commit, so mistakes show up without running the app.

    python3 Scripts/validate_catalog.py

Catalog format: one file per brewery, Greek Beers/Catalog/<brewery id>.json, holding the brewery's
fields with its beers nested under "beers". A beer leaves out its brewery id, and leaves out
"source" and "lastVerified" when they match the brewery's. Nulls and empty lists may be left out.

Unverified breweries live in Data/brewery-candidates.json and must not appear in the catalog.

The allowed values below mirror the Swift enums in Models/Beer.swift and Models/Brewery.swift.
Keep them in sync when an enum changes.
"""

import json
import re
import sys
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CATALOG = ROOT / "Greek Beers" / "Catalog"
CANDIDATES = ROOT / "Data" / "brewery-candidates.json"

REGIONS = {"eastern-macedonia-thrace", "central-macedonia", "western-macedonia", "epirus", "thessaly",
           "ionian-islands", "western-greece", "central-greece", "attica", "peloponnese", "north-aegean",
           "south-aegean", "crete"}
KINDS = {"microbrewery", "industrial", "brewpub", "gypsy"}
FAMILIES = {"lager", "pilsner", "pale-ale-ipa", "wheat", "amber-red", "dark", "belgian", "strong-ale",
            "sour", "specialty"}
COLORS = {"pale", "amber", "dark"}
# Unfiltered and low alcohol are derived from "filtered" and "abv", so they are not written by hand
TAGS = {"smoked", "barrel-aged", "honey", "fruit", "spiced"}
CANDIDATE_STATUSES = {"unverified", "inactive"}

BREWERY_REQUIRED = {"id", "name", "city", "region", "kind", "latitude", "longitude", "description",
                    "source", "lastVerified"}
BREWERY_KEYS = BREWERY_REQUIRED | {"founded", "imageNames", "website", "visitable", "brands", "beers"}
BEER_REQUIRED = {"id", "name", "style", "styleFamily"}
BEER_KEYS = BEER_REQUIRED | {"brandId", "abv", "ibu", "ibuMax", "color", "filtered", "localIngredients",
                             "tags", "description", "source", "lastVerified"}
ID = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")

errors: list[str] = []


def fail(where: str, message: str) -> None:
    errors.append(f"{where}: {message}")


def check_url(where: str, value) -> None:
    if value is not None and not (isinstance(value, str) and value.startswith(("https://", "http://"))):
        fail(where, f"not a URL: {value!r}")


def check_date(where: str, value) -> None:
    if value is None:
        return
    try:
        if date.fromisoformat(value) > date.today():
            fail(where, f"date in the future: {value}")
    except (TypeError, ValueError):
        fail(where, f"not a yyyy-mm-dd date: {value!r}")


def check_brewery(path: Path, brewery: dict, ids: dict[str, str]) -> None:
    where = path.name
    for key in BREWERY_REQUIRED - brewery.keys():
        fail(where, f"missing {key}")
    for key in brewery.keys() - BREWERY_KEYS:
        fail(where, f"unknown field {key}")

    brewery_id = brewery.get("id", "")
    if path.stem != brewery_id:
        fail(where, f"file name must match the id {brewery_id!r}")
    if brewery.get("region") not in REGIONS:
        fail(where, f"unknown region {brewery.get('region')!r}")
    if brewery.get("kind") not in KINDS:
        fail(where, f"unknown kind {brewery.get('kind')!r}")
    lat, lon = brewery.get("latitude"), brewery.get("longitude")
    if not (isinstance(lat, (int, float)) and isinstance(lon, (int, float)) and 34 <= lat <= 42 and 19 <= lon <= 30):
        fail(where, f"coordinates outside Greece: {lat}, {lon}")
    for key in ("website", "source"):
        check_url(where, brewery.get(key))
    check_date(where, brewery.get("lastVerified"))

    register(where, brewery_id, ids)
    brand_ids = set()
    for brand in brewery.get("brands") or []:
        register(f"{where} brand", brand.get("id", ""), ids)
        brand_ids.add(brand.get("id"))
        if not brand.get("name"):
            fail(where, f"brand {brand.get('id')!r} has no name")
        check_url(where, brand.get("website"))

    beers = brewery.get("beers") or []
    if not beers:
        fail(where, "no beers")
    for beer in beers:
        check_beer(f"{where} › {beer.get('id', '?')}", beer, brand_ids, ids)


def check_beer(where: str, beer: dict, brand_ids: set, ids: dict[str, str]) -> None:
    for key in BEER_REQUIRED - beer.keys():
        fail(where, f"missing {key}")
    for key in beer.keys() - BEER_KEYS:
        fail(where, f"unknown field {key}")
    register(where, beer.get("id", ""), ids)

    if beer.get("styleFamily") not in FAMILIES:
        fail(where, f"unknown style family {beer.get('styleFamily')!r}")
    if beer.get("color") is not None and beer["color"] not in COLORS:
        fail(where, f"unknown color {beer['color']!r}")
    for tag in beer.get("tags") or []:
        if tag not in TAGS:
            fail(where, f"unknown tag {tag!r}")
    if beer.get("brandId") is not None and beer["brandId"] not in brand_ids:
        fail(where, f"brand {beer['brandId']!r} is not one of the brewery's brands")

    abv = beer.get("abv")
    if abv is not None and not (isinstance(abv, (int, float)) and 0 <= abv <= 20):
        fail(where, f"implausible ABV {abv!r}")
    ibu, ibu_max = beer.get("ibu"), beer.get("ibuMax")
    if ibu is not None and not (isinstance(ibu, int) and 0 <= ibu <= 150):
        fail(where, f"implausible IBU {ibu!r}")
    if ibu_max is not None and (ibu is None or ibu_max < ibu):
        fail(where, "ibuMax needs an ibu no larger than it")
    if isinstance(beer.get("description"), str) and beer["description"].startswith("PLACEHOLDER"):
        fail(where, "placeholder description")
    check_url(where, beer.get("source"))
    check_date(where, beer.get("lastVerified"))


def register(where: str, identifier: str, ids: dict[str, str]) -> None:
    if not ID.match(identifier or ""):
        fail(where, f"id must be lowercase words joined by hyphens: {identifier!r}")
    elif identifier in ids:
        fail(where, f"id {identifier!r} already used by {ids[identifier]}")
    else:
        ids[identifier] = where


def check_candidates(verified: set[str]) -> None:
    doc = json.loads(CANDIDATES.read_text())
    seen = set()
    for candidate in doc.get("candidates", []):
        where = f"{CANDIDATES.name} › {candidate.get('id', '?')}"
        if candidate.get("id") in verified:
            fail(where, "already verified; remove it from the candidate list")
        if candidate.get("id") in seen:
            fail(where, "listed twice")
        seen.add(candidate.get("id"))
        if candidate.get("status") not in CANDIDATE_STATUSES:
            fail(where, f"unknown status {candidate.get('status')!r}")
        if not candidate.get("sources"):
            fail(where, "no source")


def main() -> int:
    ids: dict[str, str] = {}
    files = sorted(CATALOG.glob("*.json"))
    beer_count = 0
    for path in files:
        try:
            brewery = json.loads(path.read_text())
        except json.JSONDecodeError as error:
            fail(path.name, f"invalid JSON: {error}")
            continue
        check_brewery(path, brewery, ids)
        beer_count += len(brewery.get("beers") or [])
    check_candidates({path.stem for path in files})

    if errors:
        print("\n".join(errors))
        print(f"\n{len(errors)} problem(s)")
        return 1
    print(f"OK: {len(files)} breweries, {beer_count} beers")
    return 0


if __name__ == "__main__":
    sys.exit(main())

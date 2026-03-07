COLOR_MAP = {
    "black": 0, "brown": 1, "red": 2, "orange": 3, "yellow": 4,
    "green": 5, "blue": 6, "violet": 7, "grey": 8, "white": 9
}

MULTIPLIER_MAP = {
    **{color: 10 ** val for color, val in COLOR_MAP.items()},
    "gold": 0.1,
    "silver": 0.01
}

TOLERANCE_MAP = {
    "brown": "±1%", "red": "±2%", "green": "±0.5%", "blue": "±0.25%",
    "violet": "±0.1%", "grey": "±0.05%", "gold": "±5%", "silver": "±10%"
}

def format_ohms(value):
    units = [(1_000_000_000, "gigaohms"), (1_000_000, "megaohms"),
             (1_000, "kiloohms"), (1, "ohms")]
    for threshold, name in units:
        if value >= threshold:
            return f"{value / threshold:g} {name}"
    return f"{value:g} ohms"

def resistor_label(colors):
    if len(colors) == 1:
        if colors[0].lower() != "black":
            raise ValueError("One-band resistor must be black")
        return "0 ohms"

    if len(colors) == 4:
        c = [x.lower() for x in colors]
        d1 = COLOR_MAP[c[0]]
        d2 = COLOR_MAP[c[1]]
        multiplier = MULTIPLIER_MAP[c[2]]
        tolerance = TOLERANCE_MAP[c[3]]
        value = (d1 * 10 + d2) * multiplier

    elif len(colors) == 5:
        c = [x.lower() for x in colors]
        d1 = COLOR_MAP[c[0]]
        d2 = COLOR_MAP[c[1]]
        d3 = COLOR_MAP[c[2]]
        multiplier = MULTIPLIER_MAP[c[3]]
        tolerance = TOLERANCE_MAP[c[4]]
        value = (d1 * 100 + d2 * 10 + d3) * multiplier

    else:
        raise ValueError(f"Invalid number of bands: {len(colors)}")

    return f"{format_ohms(value)} {tolerance}"

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

def label(colors):
    if len(colors) not in (3, 4):
        raise ValueError("Resistor must have 3 or 4 colors")

    colors = [c.lower() for c in colors]

    try:
        d1 = COLOR_MAP[colors[0]]
        d2 = COLOR_MAP[colors[1]]
    except KeyError as e:
        raise ValueError(f"Unknown color: {e}")

    multiplier_color = colors[2]
    if multiplier_color not in MULTIPLIER_MAP:
        raise ValueError(f"Unknown multiplier color: {multiplier_color}")

    value = (d1 * 10 + d2) * MULTIPLIER_MAP[multiplier_color]
    result = format_ohms(value)

    if len(colors) == 4 and colors[3] in TOLERANCE_MAP:
        result += f" {TOLERANCE_MAP[colors[3]]}"

    return result
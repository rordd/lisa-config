---
name: weather
description: "Get current weather and forecasts via wttr.in or Open-Meteo. Use when: user asks about weather, temperature, or forecasts for any location. NOT for: historical weather data, severe weather alerts, or detailed meteorological analysis. No API key needed."

---

# Weather Skill

Get current weather conditions and forecasts using the `web_fetch` tool.

## When to Use

✅ **USE this skill when:**
- "What's the weather?" / "날씨 어때?"
- "Will it rain today/tomorrow?" / "비 와?"
- "Temperature in [city]" / "기온 알려줘"
- "Weather forecast" / "주간 예보"

❌ **DON'T use:** historical data, climate analysis, aviation/marine weather, severe alerts

## Location

- Check USER.md for default location
- If no default, ask the user
- Always include city or coordinates in the request

## How to Fetch Weather

Use the `web_fetch` tool. Do NOT use curl or shell commands.

### wttr.in — Simple text output

```
web_fetch("https://wttr.in/Seoul?format=%l:+%c+%t+(feels+like+%f),+%w+wind,+%h+humidity")
```

```
web_fetch("https://wttr.in/Seoul?format=j1")   # JSON output
```

```
web_fetch("https://wttr.in/Seoul?0")   # Today only
```

```
web_fetch("https://wttr.in/Seoul?1")   # Tomorrow
```

### Open-Meteo API — Structured JSON (no rate limit)

```
web_fetch("https://api.open-meteo.com/v1/forecast?latitude=37.55&longitude=126.85&current=temperature_2m,apparent_temperature,weather_code,relative_humidity_2m,wind_speed_10m,precipitation&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max,weather_code&timezone=Asia/Seoul&forecast_days=2")
```

For other locations, change latitude/longitude accordingly.

### Weather Codes (Open-Meteo)

- 0: Clear ☀️
- 1-3: Partly/mostly cloudy ⛅
- 45, 48: Fog 🌫️
- 51-55: Drizzle 🌦️
- 61-65: Rain 🌧️
- 71-75: Snow ❄️
- 80-82: Rain showers 🌧️
- 95: Thunderstorm ⛈️

## Notes

- No API key needed (both wttr.in and Open-Meteo are free)
- wttr.in is rate limited; prefer Open-Meteo for repeated queries
- Open-Meteo returns structured JSON — easier to parse
- Respond in the user's language

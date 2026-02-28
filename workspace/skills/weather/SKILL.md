---
name: weather
description: "Get current weather and forecasts via wttr.in or Open-Meteo. No API key needed. Refer to USER.md for default location."
---

# Weather Skill

## When to Use

- "날씨 어때?" / "What's the weather?"
- "오늘/내일 비 와?" / "Will it rain?"
- Temperature, forecast queries

## Default Location

Refer to `USER.md` for default location (latitude/longitude). Use this when no location is specified.

## Commands

### wttr.in (quick)

```bash
# One-line summary
curl -s "wttr.in/{city}?format=3"

# Detailed
curl -s "wttr.in/{city}?format=%l:+%c+%t+(feels+like+%f),+%w+wind,+%h+humidity"

# 3-day forecast
curl -s "wttr.in/{city}"

# JSON
curl -s "wttr.in/{city}?format=j1"
```

### Open-Meteo (structured JSON, no rate limit)

```bash
curl -s "https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&current=temperature_2m,apparent_temperature,weather_code,relative_humidity_2m,wind_speed_10m,precipitation&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max,weather_code&timezone=Asia/Seoul&forecast_days=2"
```

## Weather Codes (Open-Meteo)

- 0: Clear ☀️
- 1-3: Partly/mostly cloudy ⛅
- 45, 48: Fog 🌫️
- 51-55: Drizzle 🌦️
- 61-65: Rain 🌧️
- 71-75: Snow ❄️
- 80-82: Rain showers 🌧️
- 95: Thunderstorm ⛈️

## Notes

- No API key needed
- wttr.in: rate limited, don't spam
- Open-Meteo: no rate limit, structured JSON
- Respond in Korean with emoji

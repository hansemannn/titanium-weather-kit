# Titanium iOS 16+ WeatherKit

Use the iOS 16+ WeatherKit APIs in Titanium!

## Requirements

- [x] Xcode 14+
- [x] iOS 16+
- [x] WeatherKit enabled in the developer portal / entitlements

## Example

```js
import WeatherKit from 'ti.weatherkit';

WeatherKit.getWeather({
  latitude: 37.322998,
  longitude: -122.032181,
  callback: event => {
    console.warn(event.currentWeather);
  }
});
```

## Author

Hans Knöchel

## License

MIT

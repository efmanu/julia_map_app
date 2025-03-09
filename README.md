# Sydney Route Finder

A Julia web application that calculates and visualizes routes between two points in Sydney using LightOSM.jl and Mapbox.

## Features

- Calculate the shortest route between two points in Sydney
- Visualize the route on an interactive map
- Calculate the distance of the route in kilometers
- Simple and intuitive web interface

## Requirements

- Julia 1.6 or higher
- Internet connection (for downloading OSM data and loading Mapbox)

## Dependencies

- LightOSM.jl: For routing calculations using OpenStreetMap data
- HTTP.jl: For creating the web server
- JSON3.jl: For JSON serialization/deserialization
- Plots.jl: For optional plotting capabilities

## Installation

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/sydney-route-finder.git
   cd sydney-route-finder
   ```

2. Install the required Julia packages:
   ```
   julia -e 'using Pkg; Pkg.activate("."); Pkg.instantiate()'
   ```

## Usage

1. Start the application:
   ```
   julia app.jl
   ```

2. The first run will download OpenStreetMap data for Sydney, which may take some time depending on your internet connection.

3. Once the server is running, open your web browser and navigate to:
   ```
   http://localhost:8080
   ```

4. In the web interface:
   - Enter the latitude and longitude of your starting point
   - Enter the latitude and longitude of your destination
   - Click "Find Route"

5. The application will display the route on the map and show the total distance.

## Example Coordinates

The application includes some example coordinates for popular Sydney locations:

- Sydney Opera House: -33.8568, 151.2153
- Circular Quay: -33.8609, 151.2134
- Bondi Beach: -33.8915, 151.2767
- Taronga Zoo: -33.8431, 151.2417

## API Endpoints

### GET /route

Calculates the route between two points.

**Parameters:**
- `from_lat`: Latitude of the starting point
- `from_lon`: Longitude of the starting point
- `to_lat`: Latitude of the destination
- `to_lon`: Longitude of the destination

**Response:**
```
json
{
"route": {
"type": "geojson",
"data": {
"type": "Feature",
"properties": {},
"geometry": {
"type": "LineString",
"coordinates": [[lon1, lat1], [lon2, lat2], ...]
}
}
},
"distance_km": 5.2,
"from": [-33.8568, 151.2153],
"to": [-33.8915, 151.2767]
}
```

### GET /health

Health check endpoint.

**Response:**
```
Service is running
```

## How It Works

1. The application uses LightOSM.jl to download and process OpenStreetMap data for Sydney.
2. When a route request is made, it finds the nearest road nodes to the provided coordinates.
3. It calculates the shortest path between these nodes using Dijkstra's algorithm.
4. The route is converted to GeoJSON format and sent to the frontend.
5. The frontend uses Mapbox GL JS to render the route on an interactive map.

## Troubleshooting

- If the application fails to start, ensure you have an active internet connection and that all dependencies are properly installed.
- If no route is found, try coordinates that are closer to roads or within the Sydney area.
- If the map doesn't load, check your browser console for errors related to Mapbox.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
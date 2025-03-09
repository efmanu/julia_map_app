using LightOSM
using HTTP
using JSON3
# using Distances

# Download and load Sydney OSM data
function load_sydney_graph()
    # Download Sydney OSM data if not already downloaded
    map_data = download_osm_network(
        :place_name,
        place_name="sydney, australia",
        network_type=:drive,
    )
    
    # Parse the OSM data into a graph
    graph = graph_from_object(map_data, weight_type=:distance)
    
    return graph
end

# Global variable to store the graph
const SYDNEY_GRAPH = load_sydney_graph()

"""
Calculate route and distance between two points

# ARGUMENTS
- from_coords: Vector{Float64} - The coordinates of the starting point in latitude and longitude, Eg: [-33.85889, 151.05663]
- to_coords: Vector{Float64} - The coordinates of the destination point in latitude and longitude, Eg: [-33.857083, 151.023157]

# RETURNS
- route_coords: Vector{Vector{Float64}} - The coordinates of the route
- distance: Float64 - The distance of the route in kilometers
"""
function get_route_and_distance(from_coords::Vector{Float64}, to_coords::Vector{Float64})
    # Find nearest nodes to the given coordinates
    
    start_node = LightOSM.nearest_node(SYDNEY_GRAPH, from_coords)
    end_node = LightOSM.nearest_node(SYDNEY_GRAPH, to_coords)
    
    # Calculate the shortest path
    route = LightOSM.shortest_path(SYDNEY_GRAPH, start_node[1], end_node[1])
    
    if isnothing(route) || isempty(route)
        return nothing, 0.0
    end
    
    
    # Calculate the total distance in kilometers
    weights = weights_from_path(SYDNEY_GRAPH, route)
    geojson_object = Dict("type" => "geojson", "data" => Dict("type" => "Feature", "properties" => Dict(), "geometry" => Dict("type" => "LineString", "coordinates" => [])))

    for p in route
        push!(geojson_object["data"]["geometry"]["coordinates"], [SYDNEY_GRAPH.nodes[p].location.lon, SYDNEY_GRAPH.nodes[p].location.lat])
    end

    
    return geojson_object, sum(weights)
end


# HTTP server setup
function start_server(port=8080)
    router = HTTP.Router()
    
    # Route endpoint
    HTTP.register!(router, "GET", "/route", function(req)
        # Add CORS headers
        headers = [
            "Access-Control-Allow-Origin" => "*",
            "Access-Control-Allow-Methods" => "GET, OPTIONS",
            "Access-Control-Allow-Headers" => "Content-Type",
            "Content-Type" => "application/json"
        ]
        
        if HTTP.method(req) == "OPTIONS"
            return HTTP.Response(200, headers)
        end
        
        params = HTTP.queryparams(HTTP.URI(req.target))
        
        try
            # Parse coordinates from query parameters
            from_lat = parse(Float64, params["from_lat"])
            from_lon = parse(Float64, params["from_lon"])
            to_lat = parse(Float64, params["to_lat"])
            to_lon = parse(Float64, params["to_lon"])
            
            from_coords = [from_lat, from_lon]
            to_coords = [to_lat, to_lon]
            
            route_coords, distance = get_route_and_distance(from_coords, to_coords)
            
            if isnothing(route_coords)
                return HTTP.Response(404, headers, JSON3.write(Dict(
                    "error" => "No route found between the specified points"
                )))
            end
            
            response = Dict(
                "route" => route_coords,
                "distance_km" => distance,
                "from" => from_coords,
                "to" => to_coords
            )
            
            return HTTP.Response(200, headers, JSON3.write(response))
        catch e
            println("Error: ", e)
            return HTTP.Response(400, headers, JSON3.write(Dict(
                "error" => "Invalid parameters. Required: from_lat, from_lon, to_lat, to_lon"
            )))
        end
    end)
    
    # Serve the HTML page
    HTTP.register!(router, "GET", "/", function(req)
        html_content = read("map.html", String)
        return HTTP.Response(200, ["Content-Type" => "text/html"], html_content)
    end)
    
    # Health check endpoint
    HTTP.register!(router, "GET", "/health", function(req)
        return HTTP.Response(200, "Service is running")
    end)
    
    println("Starting server on port $port...")
    println("View the map at http://localhost:$port")
    HTTP.serve(router, "0.0.0.0", port)
end

# Start the server when the script is run directly
start_server()
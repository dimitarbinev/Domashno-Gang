import json
from fastapi.testclient import TestClient

# Import your FastAPI app from main.py
from main import app

# Create a test client that hits your actual endpoints without mocking,
# so it will use the real Google Maps API Key in main.py
client = TestClient(app)

def test_live_route_three_towns():
    print("Testing /recommend-route with 1 origin (Sofia) and 3 destination towns...\n")
    
    # Example payload matching the RouteRequest model
    payload = {
        "seller_lat": 42.1449,   # Starting point: Plovdiv (updated!)
        "seller_lng": 24.7508,
        "price_per_kg": 2.50,    # 2.50 BGN per kg
        "available_qty": 500.0,  # 500 kg available to sell
        "cost_per_hour": 15.0,   # 15 BGN travel cost per hour
        
        # Towns to visit downstream: Stara Zagora, Burgas
        "cities": [
            {
                "name": "Stara Zagora",
                "lat": 42.4258,
                "lng": 25.6345,
                "requested_qty": 150.0
            },
            {
                "name": "Burgas",
                "lat": 42.5048,
                "lng": 27.4626,
                "requested_qty": 200.0
            }
        ]
    }

    # Make the request to your local app (which in turn calls Google Maps)
    response = client.post("/recommend-route", json=payload)
    
    print(f"Status Code: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print("\nSUCCESS! Saved response to live_response.json\n")
        with open("live_response.json", "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
    else:
        print("\nERROR! Something went wrong:")
        print(response.text)

if __name__ == "__main__":
    test_live_route_three_towns()

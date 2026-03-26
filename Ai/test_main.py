import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch, AsyncMock, MagicMock

# Import the FastAPI app from your main script
from main import app

client = TestClient(app)

def test_predict_price_mocked_data():
    """
    Test the /predict-price endpoint. 
    If Firebase is not connected (firebase_available is False), 
    the API returns mock data.
    """
    payload = {
        "product_id": "prod-123",
        "city": "Sofia",
        "season": "autumn",
        "seller_id": "seller-abc"
    }

    response = client.post("/predict-price", json=payload)
    
    assert response.status_code == 200
    data = response.json()
    
    # Verify the structure of the returned JSON
    assert "confidence" in data
    assert "suggested_price" in data
    assert "vs_market" in data

@patch("main.httpx.AsyncClient")
def test_recommend_route_single_city(mock_async_client_class):
    """
    Test the /recommend-route endpoint for a single city demand.
    We mock the httpx.AsyncClient to simulate a successful Google Maps API response.
    """
    # Setup the mock async context manager and get response
    mock_client_instance = AsyncMock()
    mock_get_response = MagicMock()
    
    # Mocking Google Maps API response for a single leg duration of 3600 seconds (1 hour)
    mock_get_response.json.return_value = {
        "status": "OK",
        "routes": [
            {
                "legs": [
                    {
                        "duration": {"value": 3600},
                        "distance": {"value": 50000}
                    }
                ]
            }
        ]
    }
    
    mock_client_instance.get.return_value = mock_get_response
    mock_client_instance.__aenter__.return_value = mock_client_instance
    mock_client_instance.__aexit__.return_value = None
    mock_async_client_class.return_value = mock_client_instance

    payload = {
        "seller_lat": 42.6977,
        "seller_lng": 23.3219,
        "price_per_kg": 2.50,
        "available_qty": 50.0,
        "cost_per_hour": 15.0,
        "cities": [
            {
                "name": "Plovdiv",
                "lat": 42.1449,
                "lng": 24.7508,
                "requested_qty": 10.0
            }
        ]
    }

    response = client.post("/recommend-route", json=payload)
    
    assert response.status_code == 200
    data = response.json()
    
    assert "options" in data
    assert len(data["options"]) == 1
    
    option = data["options"][0]
    
    # 10 kg demanded & available, price is 2.5
    assert option["expected_sell_qty_kg"] == 10.0
    assert option["expected_revenue_bgn"] == 25.0
    
    # Duration was mocked as 3600s (1 hr), cost is 15 BGN/hr
    assert option["total_travel_hours"] == 1.0
    assert option["estimated_travel_cost_bgn"] == 15.0
    
    # Profit = Revenue - Cost = 25 - 15 = 10
    assert option["estimated_profit_bgn"] == 10.0
    assert option["is_profitable"] == True

import requests
import json

# Verified live IDs from your database:
payload = {
    "seller_id": "2baNK5kLfzMbmSaMWl3yib9Na742",
    "product_id": "Anvk7rah7SNjTUSg2Jjg",
    "listing_id": "r35heobv9qgaMuBIoDnx",
    "cost_per_hour": 15.0
}

url = "http://127.0.0.1:8000/recommend-route"

print(f"🚀 Sending request with Verified IDs to {url}...")
try:
    response = requests.post(url, json=payload)
    print(f"Status Code: {response.status_code}")
    print("Response JSON:")
    print(json.dumps(response.json(), indent=2, ensure_ascii=False))
except Exception as e:
    print(f"❌ Error: {e}")

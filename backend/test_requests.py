import requests

API_URL = "http://127.0.0.1:8000"
test_qr = "http://www.sefaz.mt.gov.br/nfce/consultanfce?p=51201012345678901234550010000000011234567890"

try:
    print("Testing POST /receipts/scan ...")
    res = requests.post(f"{API_URL}/receipts/scan", params={"qr_url": test_qr})
    res.raise_for_status()
    data = res.json()
    print("Success! Created Receipt ID:", data.get("id"))
    print("Store Name:", data.get("store_name"))
    
    print("\nTesting GET /receipts/ ...")
    res2 = requests.get(f"{API_URL}/receipts/")
    res2.raise_for_status()
    receipts = res2.json()
    print(f"Total receipts fetched: {len(receipts)}")
    if len(receipts) > 0:
        print(f"First Receipt Items count: {len(receipts[0]['items'])}")
except Exception as e:
    print(f"Error testing backend: {e}")

# check_app.py
import requests
import json

web_app_url = "https://my-helo-app.azurewebsites.net/hello"
error_url = "https://my-helo-app.azurewebsites.net/error"
function_url = "https://my-helo-function.azurewebsites.net/api/LogError?code=""

# Check Web App health
try:
    r = requests.get(web_app_url)
    if r.status_code == 200:
        print(f"✅ Web App is healthy: {r.status_code}")
    else:
        print(f"⚠️ Web App returned {r.status_code}")
        requests.post(function_url, json={"ErrorCode": r.status_code, "Message": "Health check failed"}, verify=False)
except Exception as e:
    print(f"❌ Health check failed: {e}")
    requests.post(function_url, json={"ErrorCode": 0, "Message": f"Exception: {e}"})

# Simulate errors
for i in range(6):
    try:
        requests.get(error_url)
        print(f"Triggered /error endpoint ({i + 1}/6)")
    except Exception as e:
        print(f"Error triggering endpoint: {e}")
import os
import requests
import json

# def get_current_weather(api_key, city):
def lambda_handler(event, context):
    api_key = os.getenv('WEATHER_API_KEY')
    if not api_key:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'API key not found in environment variables.'})
        }
    
    # Get the city from the event or use a default city
    city = event.get('queryStringParameters', {}).get('city', None)
    
    if not city:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'A city value is required'})
        }
    url = f"http://api.weatherapi.com/v1/current.json?key={api_key}&q={city}&aqi=no"
    
    try:
        response = requests.get(url)
        data = response.json()
        
        if response.status_code == 200:
            # Extracting the weather data
            weather_data = {
                    'location': data['location']['name'],
                    'region': data['location']['region'],
                    'country': data['location']['country'],
                    'temperature': data['current']['temp_c'],
                    'condition': data['current']['condition']['text'],
                    'humidity': data['current']['humidity'],
                    'wind_kph': data['current']['wind_kph']
            }

            return {
                'statusCode' : 200,
                'body': json.dumps(weather_data)
            }
        else:
            return {
                'statusCode' : response.status_code,
                'body': json.dumps(
                    {
                        'error': data.get('error', 'Failed to fetch weather data')
                    }
                )
            }
    
    except Exception as e:
        # Return an error response in case of any exception
        return {
            'statusCode' : 500,
            'body': json.dumps(
                {
                    'error': str(e)
                }
            )
        }

# # Example Usage
# city = "London"

# weather_info = get_current_weather(api_key, city)
# print(weather_info)
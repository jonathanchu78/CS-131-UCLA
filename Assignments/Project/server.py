import asyncio
import aiohttp
import async_timeout
import json

PORT_NUMS = {
	'Goloman' : 12549,
	'Hands' : 12550,
	'Holiday' : 12551,
	'Welsh' : 12552,
	'Wilkes' : 12553
}

connections = {
    'Goloman': ['Hands', 'Holiday', 'Wilkes'],
    'Hands': ['Goloman', 'Wilkes'],
    'Holiday': ['Goloman', 'Welsh', 'Wilkes'],
    'Wilkes': ['Goloman', 'Hands', 'Holiday'],
    'Welsh': ['Holiday'],
}
	
# keep track of clients:
# [server_id, time_difference, lat_lon, time_sent]
clients = {}

places_url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
api_key = "AIzaSyCPqX0rIuz_Bo8aNzAFZRxy-rxCgrPHrBA"

async def fetch(session, url):
    async with async_timeout.timeout(10):
        async with session.get(url) as response:
            return await response.json()

def whatsat(client_id, radius, num_results, time_received):
	response = None
	
	#client id not valid
	if client_id not in clients:
		return None
	
	temp_server, time_diff, latlon, time_sent = clients[client_id]
	
	if '+' not in latlon or '-' not in latlon:
		return None

	coords =  [e for e in latlon.split("-") if e]
	latitude = coords[0][1:]
	longitude = coords[0]
	
	url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%s,%s&radius=%d&key=%s' % (latitude, longitude, radius, api_key)
	
	async:
		response = await fetch(aiohttp.ClientSession(), url)
		results = response['results'][:num_results]
		print results

###################

fake_client = [214, 33, "+34.068930-118.445127", "2105"]
clients.append(fake_client)
whatsat(214, 10, 5, "2105")

























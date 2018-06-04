import sys
import asyncio
import aiohttp
import async_timeout
import json
import time

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
# {
#	client_name: {
#  	  server_name : ''
#  	  latitude : ''
#	  longitude : ''
#  	  time_diff : 0
#  	  cmd_time : 0
#   }
# }
clients = {}

tasks = {}

log_file = ''

places_url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
api_key = 'AIzaSyCPqX0rIuz_Bo8aNzAFZRxy-rxCgrPHrBA'

async def writeLog(msg):	
	if msg == None:
		return
	try:
		logFile.write(msg)
	except:
		print('error logging: %s' % msg)

#################################################
#  	IAMAT

#helper: parse latlon for latitude and longitude strings
def getLatLon(latlon):
	ind = 0
	count = 0
	lat = ''
	lon = ''
	for c in latlon:
		if c == '+' or c == '-':
			count = count + 1
			if count == 2:
				lat = latlon[:(ind-1)]
				lon = latlon[ind:]
		ind = ind + 1
	return [lat, lon]

#handle iamat command
async def iamat(client_name, latlon, cmd_time, actual_time, writer):
	time_diff = float(cmd_time) - actual_time

	if '+' not in latlon and '-' not in latlon:
		return None

	coords =  getLatLon(latlon)
	latitude = coords[0]
	longitude = coords[1]

	if client_name in clients:
		if clients[client_name]['cmd_time'] > cmd_time:
			#this means that the data is not the most up to date, so we ignore the update
			return None

	#add this client to list of clients
	clients[client_name] = {
		'server_name' : server_name,
		'latitude' : latitude,
		'longitude' : longitude,
		'time_diff' : time_diff,
		'cmd_time' : float(cmd_time)
	}
	print(clients[client_name])
	print('\n')

	ret_msg = 'AT %s %s %s %s %s' % (server_name, str(time_diff), client_name, latlon, cmd_time)
	await writeLog('RESPONDING TO IAMAT:\n' + ret_msg + '\n')
	await flood(client_name)
	await writeResponse(writer, ret_msg)


	
#################################################
#  	WHATSAT

#helper: send request to places API
async def fetch(session, url):
    async with async_timeout.timeout(10):
        async with session.get(url) as response:
            return await response.json()

#handle whatsat command
async def whatsat(client_name, radius, num_results, cmd_time, cmd, writer):
	response = None
	
	#client id not valid
	if client_name not in clients:
		await writeLog('INVALID CLIENT WITH WHATSAT COMMAND: ' + client_name + '\n\n')
		await writeLog('RESPONDING TO INVALID WHATSAT: ' + '? ' + cmd + '\n\n')
		await writeResponse(writer, '? ' + cmd)
		return None
	
	lat = clients[client_name]["latitude"]
	lon = clients[client_name]["longitude"]

	print(lat, ' ', lon)
	
	url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%s,%s&radius=%d&key=%s' % (lat, lon, float(radius), api_key)
	
	async with aiohttp.ClientSession() as session:
		await writeLog('QUERYING PLACES API FOR LOCATION = (%s, %s), RADIUS = %s\n\n' % (lat, lon, radius))
		response = await fetch(session, url)
		results = response['results'][:int(num_results)]
		#print(json.dumps(results[0], indent=2, sort_keys=True)) #just print the first one to save space

		time_diff = clients[client_name]["time_diff"]
		latlon = lat + lon

		ret_msg = 'AT %s %s %s %s %s\n%s\n\n' % (server_name, str(time_diff), client_name, latlon, cmd_time, json.dumps(results, indent=3))

		await writeLog('RESPONDING TO WHATSAT:\n' + ret_msg[:200] + '\n...\n\n')
		await writeResponse(writer, ret_msg)

#respond to writer
async def writeResponse(writer, msg):
	if msg == None:
		return
	try:
		writer.write(msg.encode())
		print("writing response:\n" + msg)
		await writer.drain()
		writer.write_eof()
	except:
		print('error writing msg: %s' % msg)
	return

#################################################
#  	AT
#	AT commands between servers look like this:
#	AT <client_name> <server_name> <latitude> <longitude> <time_diff> <cmd_time>

async def flood(client_name):
	client = clients[client_name]
	at_cmd = 'AT %s %s %s %s %s %s' % (client_name, client['server_name'], client['latitude'], client['longitude'], str(client['time_diff']), str(client['cmd_time']))

	for node in connections[server_name]:
		port = PORT_NUMS[node]
		try:
			print('propagating %s to %s' % (client_name, node))
			reader, writer = await asyncio.open_connection('127.0.0.1', port, loop=loop)
			await writeLog('CONNECTED TO ' + node + '\n')
			await writeLog('PROPAGATING %s TO %s:\n%s\n' % (client_name, node, at_cmd))
			await writeResponse(writer, at_cmd)
			await writeLog('CLOSED CONNECTION WITH ' + node + '\n\n')
		except:
			print('error propagating message to ' + node)
			await writeLog('ERROR PROPAGATING %s TO %s\n\n' % (client_name, node))


async def at(client_name, server_name, latitude, longitude, time_diff, cmd_time, writer):
	if client_name in clients and float(clients[client_name]['cmd_time']) >= float(cmd_time): 
		#we've already seen this client on this server or it's not the most up to date
		await writeLog('RECEIVED REDUNDANT AT COMMAND FOR: ' + client_name + '\n\n')
		return

	clients[client_name] = {
		'server_name' : server_name,
		'latitude' : latitude,
		'longitude' : longitude,
		'time_diff' : float(time_diff),
		'cmd_time' : float(cmd_time)
	}

	await flood(client_name)


#################################################
#  	HANDLE CLIENTS AND THEIR REQUESTS

async def handleCmd(writer, cmd, parts):
	#print("handling command")
	cmd_type = parts[0]
	time_received = time.time()

	valid_cmds = ['IAMAT', 'WHATSAT', 'AT']

	if cmd != '' and cmd_type not in valid_cmds:
			await writeLog('INVALID COMMAND RECEIVED:\n' + cmd + '\n\n')
			await writeLog('RESPONDING TO INVALID COMMAND:\n' + '? ' + cmd + '\n\n')
			print("error: server received an invalid command")
			await writeResponse(writer, '? ' + cmd)
			return None

	if len(parts) > 3:
		await writeLog('RECEIVED ' + cmd_type + ' COMMAND:\n' + cmd + '\n')

	log_msg = '\nreceived a ' + cmd_type + ' command at ' + str(time_received)
	print(log_msg)

	#client giving us their position
	if cmd_type == 'IAMAT':
		await iamat(parts[1], parts[2], parts[3], time_received, writer)

	#querying another client's surroundings
	elif cmd_type == 'WHATSAT':
		await whatsat(parts[1], parts[2], parts[3], time_received, cmd, writer)

	#another server flooding client info here
	elif cmd_type == 'AT':
		await at(parts[1], parts[2], parts[3], parts[4], parts[5], parts[5], writer)



async def handle_client(reader, writer):
	#print("handle_client")
	while not reader.at_eof():
		#print("handle_client")
		command = await reader.readline()
		parts = command.decode().split(' ')
		await handleCmd(writer, command.decode(), parts)


def acceptClient(reader, writer):
	# accept all clients equally, handle clients and servers separately
	task = asyncio.ensure_future(handle_client(reader, writer))
	tasks[task] = (reader, writer)

	def close_client(task):
		logFile.write('CLOSING CONNECTION\n\n')
		print('Closing client')
		del tasks[task]
		writer.close()
    
    # if the task is completed, close the client
	task.add_done_callback(close_client)


#################################################
#  	MAIN


def main():
	if len(sys.argv) != 2:
		print("error: must specify name of server!")
		exit()

	global server_name
	server_name = sys.argv[1]
	print(server_name)
	if server_name not in PORT_NUMS:
		print("error: invalid server name")
		exit()

	log = server_name + "-log.txt"
	global logFile
	open(log, "w").close() #clears the file
	logFile = open(log, 'a+')


	#event loop
	global loop
	loop = asyncio.get_event_loop()
	loop.set_debug(True)

	logFile.write(server_name + '\n')

	#accept clients
	accept_conn = asyncio.start_server(acceptClient, '127.0.0.1', PORT_NUMS[server_name], loop=loop)
	server = loop.run_until_complete(accept_conn)


	# Serve requests until Ctrl+C is pressed
	print('Serving on {}'.format(server.sockets[0].getsockname()))
	logFile.write('Serving on {}'.format(server.sockets[0].getsockname()) + '\n\n')
	try:
		loop.run_forever()
	except KeyboardInterrupt:
		print('\n' + server_name +' closed at time:', time.time())
		logFile.write(server_name + ' closed at time:' + str(time.time()))
		pass

	#KEYBOARD INTERRUPT IS NOT WORKING!

	# Close the server
	server.close()
	loop.run_until_complete(server.wait_closed())
	loop.close()

if __name__ == '__main__':
    main()






















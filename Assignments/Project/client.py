import asyncio
import time
import sys

async def tcp_echo_client(loop):
	reader, writer = await asyncio.open_connection('127.0.0.1', 12553, loop=loop)
	try:
		cmd1 = 'IAMAT kiwi.cs.ucla.edu +34.068930-118.445127 1520023935.918963997\n'
		cmd2 = 'WHATSAT kiwi.cs.ucla.edu 10 5\n'
		cmd3 = 'INVALIDCMD kiwi.cs.ucla.edu 3 4\n'

		#IAMAT COMMAND
		print('Sending: ' + cmd1)

		writer.write(cmd1.encode())
		await writer.drain()
		# writer.write_eof()

		while not reader.at_eof():
			data = await reader.read(50000)
			print('%s' % data.decode())
			break


		#WHATSAT COMMAND
		time.sleep(2)

		print('Sending: ' + cmd2)

		writer.write(cmd2.encode())
		await writer.drain()
        
		while not reader.at_eof():
			data = await reader.read(50000)
			print('%s' % data.decode())
			break


		#INVALID COMMAND
		time.sleep(2)

		print('Sending: ' + cmd3)

		writer.write(cmd3.encode())
		await writer.drain()

		while not reader.at_eof():
			data = await reader.read(50000)
			print('%s' % data.decode())
			return

		writer.write_eof()
	except KeyboardInterrupt:
		print('Closed connection')
		writer.close()
		return

loop = asyncio.get_event_loop()
loop.run_until_complete(tcp_echo_client(loop))
loop.close()
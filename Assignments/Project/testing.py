import re

latlons = [
	"+34.068930-118.445127",
	"+34.068930+118.445127",
	"-34.068930-118.445127",
	"-34.068930+118.445127"
]

#if '+' not in latlon or '-' not in latlon:
	#return None

# for latlon in latlons:
# 	coords = [e+d for e in re.split(r'[+-]', latlon)[1:] if e]
# 	print(coords)

for latlon in latlons:
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
	print(lat, lon)


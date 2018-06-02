latlon = "+34.068930-118.445127"

#if '+' not in latlon or '-' not in latlon:
	#return None

coords =  [e for e in latlon.split("-") if e]
coords[0] = coords[0][1:]
	
print(coords)
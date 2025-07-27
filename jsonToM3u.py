#!/usr/bin/env python3
import json
import os
import sys
import re


def main(args):
  if len(args) != 1:
    print ("Please specify JSON file")
    return

  ext = '.'+ os.path.realpath(args[0]).split('.')[-1:][0]
  m3uFilePath = args[0].replace(ext,'')
  m3uFilePath = m3uFilePath + '.m3u'

  print("Opening JSON file " + args[0])
  print("Writing to file " + m3uFilePath)

  excludeList = ["YYYY", "@@", "SuNoSwen", "742vTsU", "(", ")"]
  pattern = re.compile("(?<="").*(?="")")

  with (
    open(args[0], 'r') as jsonFile,
    open(m3uFilePath, 'w') as m3uFile
  ):
    # returns JSON object as
    # a dictionary
    data = json.load(jsonFile)

    m3uFile.write('#EXTM3U\n\n')

    # Iterating through the json list

    counter = 0
    for channel in data['Channels']:
      title = channel['TitleEng']
      logo = channel['Logo']
      epg_provider = channel.get("EPGProvider", "")
      epg_station_id = channel.get("EPGStationId", "")
      headers = channel.get("Headers", "")
      if headers:
       user_agent = next((header.split(":", 1)[1] for header in channel["Headers"] if header.startswith("User-Agent")), "")
       origin = next((header.split(":", 1)[1] for header in channel["Headers"] if header.startswith("Origin")), "")
       referer = next((header.split(":", 1)[1] for header in channel["Headers"] if header.startswith("Referer")), "")

      streamUrls = list(filter(lambda url: pattern.match(url) and all(x not in url for x in excludeList), channel['StreamUrls']))

      for streamUrl in streamUrls:
        m3uFile.write(f'#EXTINF:-1 tvg-id="{epg_station_id}" tvg-name="{title}" tvg-logo="{logo}" group-title="{epg_provider}",{title}\n')
        if user_agent:
          m3uFile.write(f'#EXTVLCOPT:http-user-agent={user_agent}\n')
        if referer:
          m3uFile.write(f'#EXTVLCOPT:http-referrer={referer}\n')
        if origin:
          m3uFile.write(f'#EXTVLCOPT:http-origin={origin}\n')
        m3uFile.write(streamUrl + '\n\n')
        counter = counter + 1

    print("Wrote [" + str(counter) + "] channels to m3u" )

if __name__ == "__main__":
   main(sys.argv[1:])ls
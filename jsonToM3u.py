#!/usr/bin/env python3
import json
import os
import sys

def main(args):
  if len(args) != 1:
    print ("Please specify JSON file")
    return

  ext = '.'+ os.path.realpath(args[0]).split('.')[-1:][0]
  m3uFilePath = args[0].replace(ext,'')
  m3uFilePath = m3uFilePath + '.m3u'

  print("Opening JSON file " + args[0])
  print("Writing to file " + m3uFilePath)

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
      url = channel['StreamUrls'][0]

      m3uFile.write('#EXTINF:0 tvg-logo="' + logo + '",' + title + '\n')
      m3uFile.write(url + '\n\n')
      counter = counter + 1
    
    print("Wrote [" + str(counter) + "] channels to m3u" )

if __name__ == "__main__":
   main(sys.argv[1:])

library('jsonlite')

#import json values as text from json file
json_value = readLines("Experiments/Tracking_01_2017-05-26-09-17_17.json", n = -1, warn = FALSE)
#remove the extra header in the data to make it compatible with the JSON format
#replace the 1st occurence of square brackets and anything inside the square brackets with an empty string ("") effectively deleting it
x = sub("*\\[.*?\\] *", "", json_value)
#read the variable as a valid json
sample_json = jsonlite::fromJSON(x)
sample_json = sample_json$bodies_data

#initialize a list of 3 lists
#each sub-lists for each camera
json_data = list(c1 = list(), c2 = list(), c4 = list())
#Note: going through each directory on the disk: c1, c2 and c4 might have to be implemented to import data recursively
#go through each of the data frames in sample_json and store them in the correct sub-list of json_data according to the camera
for(i in 1:length(sample_json))
{
  #In the next line: "json_data$c1" might have to be made dynamic by changing it to json_data[1], for example
  #This can be done after implementing recursive directory traversal (see "Note" above)
  json_data$c1[length(json_data$c1)+1] = sample_json[i]
  #access by: json_data$c1[[i]]$x, json_data$c1[[i]]$time etc.
  #converting "time" to POSIX time
  json_data$c1[[i]]$time = strptime(json_data$c1[[i]]$time, format = "%T")
  #Find starting & ending times
  print("Start time: ")
  start = head(json_data$c1[[i]]$time,1)
  print(format(start, "%T"))
  print("End time: ")
  end = tail(json_data$c1[[i]]$time,1)
  print(format(end, "%T"))
  #Find the duration
  print("Duration: ")
  print(end-start)
}

